import os
import numpy as np
from PySide6.QtCore import QThread, Signal

MAX_QAOA_ASSETS = 35
MAX_EXACT_QAOA_ASSETS = 8
MAX_QAOA_ITERATIONS = 40
ENABLE_EXACT_QAOA = os.getenv("QPO_ENABLE_EXACT_QAOA", "").strip() == "1"


def _select_qaoa_assets(mu, cov, returns_df, max_assets=MAX_QAOA_ASSETS):
    vol = np.sqrt(np.diag(cov.values))
    sharpe = mu.values / np.where(vol == 0, 1e-6, vol)
    import pandas as pd
    selected = pd.Series(sharpe, index=mu.index).sort_values(ascending=False).head(min(max_assets, len(mu))).index
    return mu.loc[selected], cov.loc[selected, selected], returns_df[selected]


def _stable_softmax(values):
    shifted = values - np.max(values)
    exp_values = np.exp(shifted)
    total = exp_values.sum()
    if total <= 0:
        return np.full(len(values), 1.0 / max(len(values), 1))
    return exp_values / total


def _normalize(values):
    return (values - values.mean()) / (values.std() + 1e-9)


class QAOAWorker(QThread):
    resultReady = Signal(object, float, float)
    errorOccurred = Signal(str)
    progress = Signal(int)

    def __init__(self, mu, cov, returns_df, reps=1, budget=100000, risk_aversion=0.5, parent=None):
        super().__init__(parent)
        self.mu = mu
        self.cov = cov
        self.returns_df = returns_df
        self.reps = reps
        self.budget = budget
        self.risk_aversion = risk_aversion

    def run(self):
        try:
            self.progress.emit(10)
            if (not ENABLE_EXACT_QAOA) or len(self.mu) > MAX_EXACT_QAOA_ASSETS:
                self.progress.emit(80)
                weights_full, ret, risk = self._fallback(self.mu, self.cov, self.returns_df)
                self.progress.emit(95)
                self.resultReady.emit(weights_full, ret, risk)
                return

            mu_q, cov_q, returns_q = _select_qaoa_assets(self.mu, self.cov, self.returns_df)
            self.progress.emit(25)

            try:
                weights_sub, ret, risk = self._solve_qaoa(mu_q, cov_q, returns_q)
            except Exception as qe:
                # Fallback to inverse-vol if Qiskit is unavailable
                self.progress.emit(80)
                weights_sub, ret, risk = self._fallback(mu_q, cov_q, returns_q)

            self.progress.emit(95)

            # Map sub-selection weights back to full asset list
            full_weights = np.zeros(len(self.mu))
            for i, asset in enumerate(mu_q.index):
                idx = list(self.mu.index).index(asset)
                full_weights[idx] = weights_sub[i]

            self.resultReady.emit(full_weights, ret, risk)

        except Exception as e:
            self.errorOccurred.emit(f"QAOA worker error: {e}")

    def _solve_qaoa(self, mu, cov, returns_df):
        from qiskit_optimization import QuadraticProgram
        from qiskit_optimization.algorithms import MinimumEigenOptimizer
        from qiskit_algorithms import QAOA
        from qiskit_algorithms.optimizers import COBYLA
        from qiskit.primitives import StatevectorSampler

        n = len(mu)
        qp = QuadraticProgram()
        for i in range(n):
            qp.binary_var(name=f"x_{i}")

        linear = {f"x_{i}": float(mu.iloc[i] * self.risk_aversion) for i in range(n)}
        risk_penalty = -(1 - self.risk_aversion)
        quadratic = {
            (f"x_{i}", f"x_{j}"): float(cov.iloc[i, j] * risk_penalty)
            for i in range(n) for j in range(i, n)
        }
        qp.maximize(linear=linear, quadratic=quadratic)

        qaoa = QAOA(
            sampler=StatevectorSampler(),
            optimizer=COBYLA(maxiter=MAX_QAOA_ITERATIONS),
            reps=self.reps
        )
        solver = MinimumEigenOptimizer(qaoa)
        result = solver.solve(qp)

        bits = np.array([int(result.variables_dict[f"x_{i}"]) for i in range(n)])
        if bits.sum() == 0:
            idx = np.argmax(mu.values / np.sqrt(np.diag(cov.values)))
            bits[idx] = 1

        selected = np.where(bits == 1)[0]
        full_sub = self._build_defensive_weights(mu, cov, returns_df, selected)

        ret = float(mu.values @ (full_sub / self.budget))
        risk = float((full_sub / self.budget) @ cov.values @ (full_sub / self.budget))
        return full_sub, ret, risk

    def _fallback(self, mu, cov, returns_df):
        """Quantum-inspired fallback that favors high-return assets with tighter risk control."""
        mu_values = mu.to_numpy(dtype=float, copy=True)
        risk_penalty = self._risk_penalty_vector(cov, returns_df)

        score = 1.1 * _normalize(mu_values) - (0.4 + 0.3 * float(self.risk_aversion)) * _normalize(risk_penalty)

        keep_ratio = max(0.4, 0.62 - 0.07 * float(self.risk_aversion))
        select_count = min(len(mu_values), max(2, int(np.ceil(len(mu_values) * keep_ratio))))
        selected_idx = np.argsort(score)[-select_count:]
        weights = self._build_defensive_weights(mu, cov, returns_df, selected_idx)
        weights_norm = weights / self.budget
        ret = float(mu_values @ weights_norm)
        risk = float(weights_norm @ cov.values @ weights_norm)
        return weights, ret, risk

    def _risk_penalty_vector(self, cov, returns_df):
        cov_values = cov.to_numpy(dtype=float, copy=True)
        vol = np.sqrt(np.clip(np.diag(cov_values), 1e-12, None))
        downside = np.sqrt(np.mean(np.minimum(returns_df.to_numpy(dtype=float, copy=True), 0.0) ** 2, axis=0))
        corr_denom = np.outer(vol, vol)
        corr = np.divide(cov_values, corr_denom, out=np.zeros_like(cov_values), where=corr_denom > 0)
        corr = np.clip(corr, -1.0, 1.0)
        corr_penalty = np.mean(np.clip(corr, 0.0, None), axis=1)
        return vol + 0.7 * downside + 0.35 * corr_penalty

    def _build_defensive_weights(self, mu, cov, returns_df, selected_idx):
        mu_values = mu.to_numpy(dtype=float, copy=True)
        risk_penalty = self._risk_penalty_vector(cov, returns_df)
        weights_norm = np.zeros(len(mu_values), dtype=float)

        selected_idx = np.array(selected_idx, dtype=int)
        selected_scores = 1.15 * _normalize(mu_values[selected_idx]) - (0.48 + 0.32 * float(self.risk_aversion)) * _normalize(risk_penalty[selected_idx])
        concentration = 2.6 + 1.1 * float(self.risk_aversion)
        score_weights = _stable_softmax(selected_scores * concentration)

        inverse_risk = 1.0 / np.clip(risk_penalty[selected_idx], 1e-6, None)
        inverse_risk /= inverse_risk.sum()

        blended = 0.72 * score_weights + 0.28 * inverse_risk
        blended /= blended.sum()
        weights_norm[selected_idx] = blended
        return weights_norm * self.budget
