# 🚀 Hybrid Quantum Portfolio Optimizer (QML Edition)

A desktop application built with **PySide6 + QML** that demonstrates how **hybrid quantum-classical optimization** can improve portfolio allocation by comparing traditional financial optimization techniques with the **Quantum Approximate Optimization Algorithm (QAOA)**.

---

# 🎯 Challenge

This project addresses the challenge of **portfolio optimization**, where investors seek to maximize returns while minimizing financial risk under real-world investment constraints.

Traditional optimization methods become computationally expensive as portfolio complexity grows. This project explores whether **hybrid quantum computing** can provide an effective alternative for solving such optimization problems.

---

# 👥 Team Members & Contributions

| Team Member | Contribution |
|-------------|-------------|
| **Naga Venkata Sahithi Parepalli** | Project Lead, Hybrid Quantum Framework, QAOA implementation, Desktop Application Development (PySide6 + QML), Documentation |
| **A.V.preeti ** | Classical optimization implementation, testing, validation |
| **K.Mounika** | Research, visualization, presentation, result analysis |


---

# 📖 Project Overview

The **Hybrid Quantum Portfolio Optimizer** combines classical financial optimization with quantum-inspired algorithms to analyze and compare different portfolio allocation strategies.

The application provides an interactive desktop interface that enables users to visualize investment allocations, portfolio performance, and optimization metrics through dashboards and analytical charts.

The project demonstrates how hybrid quantum-classical optimization can be applied to real-world financial decision-making while providing an educational platform for understanding emerging quantum computing techniques.

---

# ❓ Problem Statement

Portfolio optimization aims to determine the best allocation of investments among multiple assets while balancing expected returns and financial risk.

The objective of this project is to:

- Maximize expected portfolio returns.
- Minimize investment risk.
- Satisfy portfolio constraints.
- Compare Classical and Quantum optimization approaches.
- Demonstrate the effectiveness of Hybrid Quantum Computing in financial optimization.

---

# 💡 Proposed Solution

The project follows a Hybrid Quantum-Classical workflow:

1. Fetch historical stock market data.
2. Calculate expected returns and covariance matrices.
3. Perform **Classical Mean-Variance Optimization** using **CVXPY**.
4. Convert the optimization problem into a **QUBO (Quadratic Unconstrained Binary Optimization)** model.
5. Solve the optimization problem using **QAOA (Quantum Approximate Optimization Algorithm)**.
6. Compare Classical, Quantum, and Hybrid portfolio allocations.
7. Present results using an interactive QML desktop dashboard.

---

# ⚙️ Methods & Tools Used

## Programming Language

- Python

## Desktop Framework

- PySide6
- Qt QML

## Quantum Computing

- Qiskit
- Qiskit Optimization
- Quantum Approximate Optimization Algorithm (QAOA)

## Classical Optimization

- CVXPY
- Mean-Variance Optimization

## Data Processing

- NumPy
- Pandas

## Visualization

- Matplotlib
- Qt Charts

## Financial Data

- Yahoo Finance (yfinance)

---

# 📂 Project Structure

```text
quantum_portfolio/
│
├── main.py
├── requirements.txt
├── hybrid_framework.py
├── run_hybrid_study.py
├── HYBRID_FRAMEWORK_REPORT.md
│
├── models/
│   ├── portfolio_model.py
│   └── chart_model.py
│
├── workers/
│   ├── fetch_worker.py
│   ├── classical_worker.py
│   └── qaoa_worker.py
│
└── qml/
    ├── Main.qml
    ├── DashboardPage.qml
    ├── ClassicalPage.qml
    ├── QAOAPage.qml
    ├── ComparisonPage.qml
    ├── MonteCarloPage.qml
    ├── HeatmapPage.qml
    ├── SettingsPage.qml
    └── Shared Components
```

---

# ▶️ Installation

Clone the repository:

```bash
git clone https://github.com/Parepallinagavenkatasahithi/hybrid-quantum-portfolio.git
```

Navigate to the project directory:

```bash
cd hybrid-quantum-portfolio
```

Create a virtual environment:

```bash
python -m venv venv
```

### Windows

```powershell
.\venv\Scripts\Activate.ps1
```

Install the required packages:

```bash
pip install -r requirements.txt
```

Run the application:

```bash
python main.py
```

Run the Hybrid Research Study:

```bash
python run_hybrid_study.py
```

---

# 🌐 Demo Mode

The application supports two operating modes:

- ✅ **Live Market Mode** (Yahoo Finance)
- ✅ **Demo Data Mode**

If live financial data is unavailable due to internet or API issues, the application automatically switches to **Demo Mode**, ensuring uninterrupted execution during demonstrations, presentations, or hackathons.

---

# 🚀 Default Demo Flow

1. Launch the application:

```bash
python main.py
```

2. Select default assets or configure custom assets.

3. Click **Optimize**.

4. Explore the following pages:

- Dashboard
- Classical Optimization
- Quantum QAOA
- Portfolio Comparison
- Monte Carlo Simulation
- Correlation Heatmap

---

# 📊 Features

- 📈 Dashboard KPIs
  - Expected Return
  - Portfolio Risk
  - Sharpe Ratio

- 💼 Classical Portfolio Optimization

- ⚛️ Quantum Portfolio Optimization (QAOA)

- 🔀 Hybrid Allocation Comparison

- 📉 Portfolio Allocation Charts

- 📋 Asset Allocation Table

- 🎲 Monte Carlo Portfolio Simulation

- 🔥 Correlation Heatmap

- 📊 QAOA Stability Analysis

- ⚙️ Configurable Portfolio Settings

---

# 📈 Results & Findings

The implementation demonstrates that:

- Classical Mean-Variance Optimization produces efficient baseline portfolios.
- QAOA successfully models portfolio optimization using QUBO formulations.
- Hybrid optimization enables comparison between classical and quantum allocation strategies.
- Interactive visualizations make optimization results easy to understand.
- Demo Mode ensures consistent application performance without internet connectivity.

---

# 📌 Recommendations

- Increase the number of portfolio assets.
- Execute on real IBM Quantum hardware.
- Integrate real-time market streaming.
- Explore additional Quantum Optimization algorithms.
- Incorporate transaction costs and market constraints.
- Improve scalability for larger investment portfolios.

---

# ⚠️ Limitations

- Current quantum hardware supports only limited qubit counts.
- Most experiments are performed using quantum simulators.
- Large-scale portfolio optimization remains computationally expensive.
- External financial APIs may occasionally be unavailable.
- QAOA performance depends on quantum hardware noise and simulator limitations.

---

# 🔮 Future Work

Future improvements include:

- IBM Quantum Cloud Integration
- Real-time Portfolio Tracking
- Quantum Noise Mitigation
- Support for Larger Asset Universes
- Advanced Financial Constraints
- AI-assisted Portfolio Recommendation
- Additional Quantum Algorithms (VQE, Quantum Annealing)
- Enhanced Dashboard Analytics

---

# 📚 Sources & References

1. Markowitz, H. (1952). *Portfolio Selection*. Journal of Finance.
2. IBM Quantum Documentation
3. Qiskit Documentation
4. CVXPY Documentation
5. Yahoo Finance API (yfinance)
6. PySide6 Documentation
7. Qt QML Documentation
8. WISER Summer Program Learning Resources

---

# 📄 Repository Contents

This repository contains:

- ✅ Complete Source Code
- ✅ Desktop Application
- ✅ Hybrid Optimization Framework
- ✅ Quantum Optimization Algorithms
- ✅ Classical Optimization Algorithms
- ✅ Research Study Module
- ✅ QML User Interface
- ✅ Documentation
- ✅ Reports
- ✅ Supporting Materials

---

# 🏆 Conclusion

The **Hybrid Quantum Portfolio Optimizer** demonstrates how classical optimization techniques can be combined with emerging quantum computing methods to address financial portfolio optimization problems.

By integrating **Classical Mean-Variance Optimization**, **QAOA**, and an intuitive **PySide6 + QML desktop interface**, this project provides both a practical portfolio optimization tool and an educational platform for exploring hybrid quantum computing in finance.

Although current quantum hardware is still evolving, hybrid quantum-classical approaches show significant promise for solving increasingly complex optimization problems in future financial systems.

---

## 📜 License

This project is licensed under the MIT License.

---

### ⭐ If you found this project useful, consider giving the repository a star!
