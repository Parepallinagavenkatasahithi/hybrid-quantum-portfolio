import sys
import os
import faulthandler
import warnings
from PySide6.QtGui import QGuiApplication, QFont, QFontDatabase
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import Qt

from models.portfolio_model import PortfolioModel
from models.chart_model import ChartModel

def main():
    os.environ["QT_QUICK_CONTROLS_STYLE"] = "Basic"
    os.environ.setdefault("QSG_RENDER_LOOP", "basic")
    warnings.filterwarnings("ignore", message="splu converted its input to CSC format")
    warnings.filterwarnings("ignore", message="spsolve is more efficient when sparse b is in the CSC matrix format")
    faulthandler.disable()

    app = QGuiApplication(sys.argv)
    app.setApplicationName("Quantum Portfolio Optimizer")
    app.setOrganizationName("QuantumFinance")

    engine = QQmlApplicationEngine()
    engine.warnings.connect(
        lambda warnings: [
            print(f"QML warning: {warning.toString()}", file=sys.stderr)
            for warning in warnings
        ]
    )

    # Register Python models with QML
    portfolio_model = PortfolioModel()
    chart_model = ChartModel()

    engine.rootContext().setContextProperty("portfolioModel", portfolio_model)
    engine.rootContext().setContextProperty("chartModel", chart_model)

    engine.load(os.path.join(os.path.dirname(__file__), "qml", "Main.qml"))

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())

if __name__ == "__main__":
    main()
