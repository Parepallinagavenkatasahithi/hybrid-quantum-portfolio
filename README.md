# Quantum Portfolio Optimizer - QML Edition

A desktop portfolio optimization app built with `PySide6 + QML` that compares:

- Classical mean-variance optimization with `cvxpy`
- Quantum-inspired/QAOA portfolio selection with `qiskit`
- A blended allocation view for presentation and analysis

## Project Structure

```text
quantum_portfolio/
|-- main.py
|-- requirements.txt
|-- models/
|   |-- portfolio_model.py
|   `-- chart_model.py
|-- workers/
|   |-- fetch_worker.py
|   |-- classical_worker.py
|   `-- qaoa_worker.py
`-- qml/
    |-- Main.qml
    |-- DashboardPage.qml
    |-- ClassicalPage.qml
    |-- QAOAPage.qml
    |-- ComparisonPage.qml
    |-- MonteCarloPage.qml
    |-- HeatmapPage.qml
    |-- SettingsPage.qml
    `-- shared components...
```

## Run

From the `quantum_portfolio` folder:

```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
python main.py
```

If you already have the dependencies installed globally, this also works:

```powershell
python main.py
```

## Demo-Safe Behavior

The app now supports two data modes:

- `Live market data` when Yahoo Finance download succeeds
- `Demo data mode` when the live feed is unavailable, blocked, or returns too little history

That means the app will still produce allocations, metrics, comparison charts, Monte Carlo paths, and a heatmap during a hackathon demo even without internet access.

## Default Demo Flow

1. Launch the app with `python main.py`
2. Keep the default assets or choose your own in `Settings`
3. Click `Optimize`
4. Present the `Dashboard`, `Classical`, `Quantum QAOA`, and `Comparison` pages

## What The App Shows

- Dashboard KPIs for return, risk, and Sharpe ratio
- Classical and QAOA allocation charts
- Asset-level allocation table
- Comparison between classical, quantum, and blended strategies
- Monte Carlo portfolio simulation
- Correlation heatmap
- QAOA stability panel

## Research Study Module (Your Assignment)

This repo now includes a full constrained multi-objective hybrid framework:

- `hybrid_framework.py`: mathematical model, QUBO-style penalties, classical baselines, and hybrid QAOA-style solver
- `run_hybrid_study.py`: executes study and prints comparative + critical evaluation
- `HYBRID_FRAMEWORK_REPORT.md`: formal formulation and discussion

Run:

```powershell
python run_hybrid_study.py
```

## Troubleshooting

- If the app opens but live prices are unavailable, it will automatically switch to `Demo data mode`
- If PowerShell blocks virtual environment activation, run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
```

- If the window does not open, confirm you are in:

```powershell
d:\quantum_portfolio_qml\quantum_portfolio
```

and run:

```powershell
python main.py
```
