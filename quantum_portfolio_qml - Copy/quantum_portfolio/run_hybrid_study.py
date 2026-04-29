from hybrid_framework import run_full_study


def fmt_vec(values, precision=4):
    return "[" + ", ".join(f"{v:.{precision}f}" for v in values) + "]"


def main():
    results = run_full_study(seed=11)
    problem = results["problem"]
    constraints = results["constraints"]
    brute = results["brute_force"]
    greedy = results["greedy"]
    hybrid = results["hybrid_qaoa"]

    print("\n=== Constrained Multi-Objective Portfolio Optimization ===")
    print("Decision variables:")
    print("  x_i in {0,1}, 1 if asset i is selected, 0 otherwise")
    print("Objectives (scalarized):")
    print("  maximize return, minimize risk, maximize diversification")
    print("Equivalent minimization energy:")
    print("  E(x) = -a*R(x) + b*V(x) - g*D(x) + P_budget + P_card + P_risk + P_turnover")
    print("Constraints encoded as penalties:")
    print(f"  Budget cap: sum_i p_i x_i <= {constraints.budget:.2f}")
    print(f"  Cardinality target: sum_i x_i = {constraints.cardinality}")
    print(f"  Risk threshold: V(x) <= {constraints.risk_threshold:.4f}")
    print(f"  Transaction cost rate: {constraints.transaction_cost_rate:.4f}")
    print("\nAssets:", ", ".join(problem.asset_names))
    print("Expected returns mu:", fmt_vec(problem.mu))
    print("Prices:", fmt_vec(problem.prices, precision=2))

    rows = [brute, greedy, hybrid]
    print("\n=== Comparative Results ===")
    for r in rows:
        print(f"\n[{r.name}]")
        print(f"  bitstring: {''.join(str(int(b)) for b in r.bitstring)}")
        print(f"  weights: {fmt_vec(r.weights)}")
        print(f"  expected return: {r.expected_return:.6f}")
        print(f"  risk (variance): {r.risk:.6f}")
        print(f"  diversification (1-HHI): {r.diversification:.6f}")
        print(f"  turnover: {r.turnover:.6f}")
        print(f"  objective energy: {r.objective:.6f}")
        print(f"  feasible: {r.feasible}")
        print(f"  iterations/evals: {r.iterations}")
        if r.history:
            print(f"  convergence start/end: {r.history[0]:.6f} -> {r.history[-1]:.6f}")

    print("\n=== Critical Evaluation ===")
    print("1. Solution quality:")
    print("   Brute force is the global reference on 8 assets and sets the best attainable objective.")
    print("   Hybrid QAOA-style often approaches but may not always match brute force due to variational search bias.")
    print("2. Convergence behavior:")
    print("   Greedy has one-step convergence but can be trapped in local structure.")
    print("   Hybrid shows iterative expected-energy reduction but with stochastic plateaus.")
    print("3. Computational limitations:")
    print("   Brute force scales as O(2^N); exact benchmarking breaks quickly.")
    print("   Hybrid needs repeated distribution/energy estimation and classical optimizer loops.")
    print("4. Scalability:")
    print("   Current approach remains simulation-bound; true hardware execution introduces sampling noise and depth limits.")
    print("5. Quantum advantage verdict:")
    print("   No demonstrated quantum advantage in this implementation.")
    print("   Reason: small-N setting, classical pre/post-processing dominates, and variational overhead")
    print("   outweighs gains versus strong classical heuristics and exact search at this scale.")


if __name__ == "__main__":
    main()
