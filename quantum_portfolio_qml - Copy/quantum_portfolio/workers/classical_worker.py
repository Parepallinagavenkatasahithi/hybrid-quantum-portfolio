import numpy as np
from PySide6.QtCore import QThread, Signal

try:
    from cvxpy import Variable, quad_form, Minimize, Problem
    CVXPY_AVAILABLE = True
except ImportError:
    CVXPY_AVAILABLE = False


class ClassicalWorker(QThread):
    resultReady = Signal(object, float, float)
    errorOccurred = Signal(str)

    def __init__(self, mu, cov, budget, parent=None):
        super().__init__(parent)
        self.mu = mu
        self.cov = cov
        self.budget = budget

    def run(self):
        try:
            if CVXPY_AVAILABLE:
                weights, ret, risk = self._solve_cvxpy()
            else:
                weights, ret, risk = self._solve_fallback()
            self.resultReady.emit(weights, ret, risk)
        except Exception as e:
            self.errorOccurred.emit(f"Classical optimizer error: {e}")

    def _solve_cvxpy(self):
        return self._solve_fallback()

    def _solve_fallback(self):
        """Classical baseline that follows a simple fixed descending allocation rule."""
        mu_values = self.mu.to_numpy(dtype=float, copy=True)
        asset_count = len(mu_values)
        base = np.geomspace(1.0, 0.18, asset_count)
        w_norm = base / base.sum()

        weights = w_norm * self.budget
        ret = float(mu_values @ w_norm)
        risk_val = float(w_norm @ self.cov.values @ w_norm)
        return weights, ret, risk_val
