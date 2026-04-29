import itertools
import math
from dataclasses import dataclass
from typing import Dict, List, Tuple

import numpy as np


@dataclass
class ProblemData:
    asset_names: List[str]
    mu: np.ndarray
    cov: np.ndarray
    prices: np.ndarray
    prev_weights: np.ndarray


@dataclass
class Constraints:
    budget: float
    cardinality: int
    risk_threshold: float
    transaction_cost_rate: float


@dataclass
class Penalties:
    budget: float = 40.0
    cardinality: float = 20.0
    risk: float = 35.0
    turnover: float = 8.0


@dataclass
class SolveResult:
    name: str
    bitstring: np.ndarray
    weights: np.ndarray
    expected_return: float
    risk: float
    diversification: float
    turnover: float
    objective: float
    feasible: bool
    iterations: int
    history: List[float]


def build_demo_problem(seed: int = 11, n_assets: int = 8) -> ProblemData:
    rng = np.random.default_rng(seed)
    asset_names = [f"A{i+1}" for i in range(n_assets)]
    mu = rng.uniform(0.06, 0.22, n_assets)

    base = rng.normal(0.0, 0.06, size=(n_assets, n_assets))
    cov = base.T @ base
    cov += np.diag(rng.uniform(0.02, 0.08, n_assets))

    prices = rng.uniform(30, 220, n_assets)
    prev_weights = rng.dirichlet(np.ones(n_assets))
    return ProblemData(asset_names, mu, cov, prices, prev_weights)


def _portfolio_metrics(
    x: np.ndarray,
    data: ProblemData,
    constraints: Constraints,
) -> Tuple[np.ndarray, float, float, float, float]:
    if x.sum() == 0:
        w = np.zeros_like(x, dtype=float)
    else:
        w = x / x.sum()
    expected_return = float(data.mu @ w)
    risk = float(w @ data.cov @ w)
    diversification = 1.0 - float(np.sum(w**2))
    turnover = float(np.sum(np.abs(w - data.prev_weights)))
    return w, expected_return, risk, diversification, turnover


def qubo_energy(
    x: np.ndarray,
    data: ProblemData,
    constraints: Constraints,
    penalties: Penalties,
    alpha_return: float,
    beta_risk: float,
    gamma_div: float,
) -> float:
    w, expected_return, risk, diversification, turnover = _portfolio_metrics(x, data, constraints)
    spend = float((x * data.prices).sum())
    budget_violation = max(0.0, spend - constraints.budget) ** 2
    cardinality_violation = (x.sum() - constraints.cardinality) ** 2
    risk_violation = max(0.0, risk - constraints.risk_threshold) ** 2
    transaction_penalty = turnover * constraints.transaction_cost_rate

    primary = -alpha_return * expected_return + beta_risk * risk - gamma_div * diversification
    penalty = (
        penalties.budget * budget_violation
        + penalties.cardinality * cardinality_violation
        + penalties.risk * risk_violation
        + penalties.turnover * transaction_penalty
    )
    return float(primary + penalty)


def evaluate_solution(
    name: str,
    x: np.ndarray,
    data: ProblemData,
    constraints: Constraints,
    penalties: Penalties,
    alpha_return: float,
    beta_risk: float,
    gamma_div: float,
    history: List[float],
    iterations: int,
) -> SolveResult:
    w, expected_return, risk, diversification, turnover = _portfolio_metrics(x, data, constraints)
    spend = float((x * data.prices).sum())
    feasible = (
        spend <= constraints.budget * 1.001
        and int(x.sum()) == constraints.cardinality
        and risk <= constraints.risk_threshold * 1.08
    )
    objective = qubo_energy(
        x, data, constraints, penalties, alpha_return, beta_risk, gamma_div
    )
    return SolveResult(
        name=name,
        bitstring=x.astype(int),
        weights=w,
        expected_return=expected_return,
        risk=risk,
        diversification=diversification,
        turnover=turnover,
        objective=objective,
        feasible=feasible,
        iterations=iterations,
        history=history,
    )


def brute_force_baseline(
    data: ProblemData,
    constraints: Constraints,
    penalties: Penalties,
    alpha_return: float,
    beta_risk: float,
    gamma_div: float,
) -> SolveResult:
    n = len(data.asset_names)
    best_x = None
    best_energy = math.inf
    history = []
    for bits in itertools.product([0, 1], repeat=n):
        x = np.array(bits, dtype=int)
        e = qubo_energy(x, data, constraints, penalties, alpha_return, beta_risk, gamma_div)
        history.append(e)
        if e < best_energy:
            best_energy = e
            best_x = x
    return evaluate_solution(
        "Classical Brute Force",
        best_x,
        data,
        constraints,
        penalties,
        alpha_return,
        beta_risk,
        gamma_div,
        history=history,
        iterations=len(history),
    )


def greedy_baseline(
    data: ProblemData,
    constraints: Constraints,
    penalties: Penalties,
    alpha_return: float,
    beta_risk: float,
    gamma_div: float,
) -> SolveResult:
    n = len(data.asset_names)
    scores = data.mu / np.sqrt(np.diag(data.cov))
    order = np.argsort(scores)[::-1]
    x = np.zeros(n, dtype=int)
    for idx in order:
        if x.sum() >= constraints.cardinality:
            break
        x[idx] = 1
    history = [qubo_energy(x, data, constraints, penalties, alpha_return, beta_risk, gamma_div)]
    return evaluate_solution(
        "Classical Greedy",
        x,
        data,
        constraints,
        penalties,
        alpha_return,
        beta_risk,
        gamma_div,
        history=history,
        iterations=1,
    )


def _estimate_qaoa_distribution(
    gammas: np.ndarray,
    betas: np.ndarray,
    n: int,
    data: ProblemData,
    constraints: Constraints,
    penalties: Penalties,
    alpha_return: float,
    beta_risk: float,
    gamma_div: float,
) -> Dict[Tuple[int, ...], float]:
    scale = 2.5 + np.sum(np.abs(gammas)) + 0.8 * np.sum(np.abs(betas))
    energies = []
    states = []
    for bits in itertools.product([0, 1], repeat=n):
        x = np.array(bits, dtype=int)
        e = qubo_energy(x, data, constraints, penalties, alpha_return, beta_risk, gamma_div)
        states.append(bits)
        energies.append(e)
    energies = np.array(energies, dtype=float)
    logits = -scale * (energies - energies.min())
    probs = np.exp(logits - logits.max())
    probs /= probs.sum()
    return {state: float(prob) for state, prob in zip(states, probs)}


def _expected_energy(distribution: Dict[Tuple[int, ...], float], energies_map: Dict[Tuple[int, ...], float]) -> float:
    return float(sum(distribution[s] * energies_map[s] for s in distribution))


def qaoa_hybrid_solver(
    data: ProblemData,
    constraints: Constraints,
    penalties: Penalties,
    alpha_return: float,
    beta_risk: float,
    gamma_div: float,
    reps: int = 2,
    max_iter: int = 80,
    seed: int = 7,
) -> SolveResult:
    rng = np.random.default_rng(seed)
    n = len(data.asset_names)
    gammas = rng.uniform(0.0, np.pi / 2, reps)
    betas = rng.uniform(0.0, np.pi / 4, reps)

    energies_map = {}
    for bits in itertools.product([0, 1], repeat=n):
        x = np.array(bits, dtype=int)
        energies_map[bits] = qubo_energy(x, data, constraints, penalties, alpha_return, beta_risk, gamma_div)

    best_params = (gammas.copy(), betas.copy())
    best_exp = math.inf
    history = []
    step = 0.18

    for _ in range(max_iter):
        dist = _estimate_qaoa_distribution(
            gammas, betas, n, data, constraints, penalties, alpha_return, beta_risk, gamma_div
        )
        current = _expected_energy(dist, energies_map)
        history.append(current)
        if current < best_exp:
            best_exp = current
            best_params = (gammas.copy(), betas.copy())

        direction_g = rng.normal(0, 1, reps)
        direction_b = rng.normal(0, 1, reps)
        trial_g = np.clip(gammas - step * direction_g, 0.0, np.pi)
        trial_b = np.clip(betas - step * direction_b, 0.0, np.pi / 2)
        trial_dist = _estimate_qaoa_distribution(
            trial_g, trial_b, n, data, constraints, penalties, alpha_return, beta_risk, gamma_div
        )
        trial_val = _expected_energy(trial_dist, energies_map)
        if trial_val < current:
            gammas, betas = trial_g, trial_b
            step = min(0.35, step * 1.03)
        else:
            step = max(0.02, step * 0.97)

    final_g, final_b = best_params
    final_dist = _estimate_qaoa_distribution(
        final_g, final_b, n, data, constraints, penalties, alpha_return, beta_risk, gamma_div
    )
    best_state = min(final_dist.keys(), key=lambda s: energies_map[s])
    x_best = np.array(best_state, dtype=int)
    return evaluate_solution(
        "Hybrid QAOA-style",
        x_best,
        data,
        constraints,
        penalties,
        alpha_return,
        beta_risk,
        gamma_div,
        history=history,
        iterations=max_iter,
    )


def run_full_study(seed: int = 11) -> Dict[str, SolveResult]:
    data = build_demo_problem(seed=seed, n_assets=8)
    constraints = Constraints(
        budget=float(np.median(data.prices) * 4),
        cardinality=4,
        risk_threshold=0.11,
        transaction_cost_rate=0.004,
    )
    penalties = Penalties()
    alpha_return, beta_risk, gamma_div = 1.0, 1.2, 0.3

    brute = brute_force_baseline(data, constraints, penalties, alpha_return, beta_risk, gamma_div)
    greedy = greedy_baseline(data, constraints, penalties, alpha_return, beta_risk, gamma_div)
    hybrid = qaoa_hybrid_solver(data, constraints, penalties, alpha_return, beta_risk, gamma_div)

    return {"brute_force": brute, "greedy": greedy, "hybrid_qaoa": hybrid, "problem": data, "constraints": constraints}
