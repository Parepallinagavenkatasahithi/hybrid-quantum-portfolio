# Hybrid Quantum-Classical Portfolio Optimization

## 1. Problem Formulation
Let `x_i in {0,1}` indicate whether asset `i` is selected. Let `w_i = x_i / sum_j x_j` for selected assets.

- Expected return:
  - `R(x) = mu^T w`
- Risk (variance):
  - `V(x) = w^T Sigma w`
- Diversification objective:
  - `D(x) = 1 - sum_i w_i^2` (higher is better)

Scalarized multi-objective energy:

`E_primary(x) = -alpha * R(x) + beta * V(x) - gamma * D(x)`

## 2. Constraint Encoding (QUBO-style penalties)
The constrained problem is embedded in penalties:

- Budget:
  - `P_budget = lambda_b * max(0, sum_i p_i x_i - B)^2`
- Cardinality:
  - `P_card = lambda_k * (sum_i x_i - K)^2`
- Risk threshold:
  - `P_risk = lambda_r * max(0, V(x) - V_max)^2`
- Transaction cost:
  - `P_turnover = lambda_t * c * ||w - w_prev||_1`

Total energy:

`E(x) = E_primary(x) + P_budget + P_card + P_risk + P_turnover`

Minimizing `E(x)` yields a constrained combinatorial selection/allocation policy.

## 3. Classical Baselines
- Brute force search over all `2^N` bitstrings (global optimum for small `N`)
- Greedy heuristic by return-to-volatility ranking (fast but local)

## 4. Hybrid Quantum-Classical Method
- QAOA-style ansatz parameters: `theta = {gamma_1..gamma_p, beta_1..beta_p}`
- Classical loop updates `theta` to reduce expected energy
- Distribution over bitstrings approximates measurement outcomes
- Best sampled/min-energy bitstring is decoded into portfolio weights

## 5. Comparative Criteria
- Solution quality: objective value, return, risk, diversification, feasibility
- Convergence: energy trajectory across iterations
- Computation: exact exponential complexity vs variational loop overhead
- Scalability: simulator-bound limits and hardware noise/depth constraints

## 6. Critical Quantum Advantage Assessment
No clear quantum advantage is claimed here.

Technical reason:
- Problem sizes tested are small enough for strong classical methods.
- Variational methods incur optimizer + sampling overhead.
- Constraint-heavy finance QUBOs require large penalty scales and careful tuning.
- In NISQ regimes, noise and limited depth reduce performance reliability.

This framework is a rigorous benchmarking scaffold, not proof of practical quantum superiority.
