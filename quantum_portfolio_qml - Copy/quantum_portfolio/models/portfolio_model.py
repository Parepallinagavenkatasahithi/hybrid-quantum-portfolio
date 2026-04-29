import numpy as np
import pandas as pd
from PySide6.QtCore import QObject, Signal, Slot, Property, QCoreApplication
from datetime import datetime
import json
import os
import contextlib
import io
import yfinance as yf

from workers.fetch_worker import FetchWorker
from workers.classical_worker import ClassicalWorker
from workers.qaoa_worker import QAOAWorker


SAMPLE_TICKERS = [
    "AAPL", "MSFT", "GOOGL", "AMZN", "TSLA", "NVDA", "META", "NFLX",
    "PYPL", "ADBE", "INTC", "IBM", "ORCL", "CSCO", "AMD", "QCOM",
    "TXN", "CRM", "UBER", "SHOP", "BA", "NKE", "DIS", "SBUX",
    "MCD", "KO", "PEP", "WMT", "JPM", "GS", "MS", "V", "MA",
    "SPY", "QQQ", "XOM", "CVX", "AMAT", "MU", "LRCX", "PLTR"
]


class PortfolioModel(QObject):
    tickersChanged        = Signal()
    statusChanged         = Signal()
    progressChanged       = Signal()
    settingsChanged       = Signal()
    errorOccurred         = Signal(str)
    optimizationComplete  = Signal()
    classicalWeightsChanged = Signal()
    qaoaWeightsChanged    = Signal()
    metricsChanged        = Signal()
    assetsChanged         = Signal()
    dataSourceChanged     = Signal()
    exportChanged         = Signal()
    pendingChangesChanged = Signal()
    marketTrackerChanged  = Signal()
    marketTrackerLoadingChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._selected_tickers = ["AAPL", "MSFT", "GOOGL"]
        self._start_date = "2023-01-01"
        self._end_date   = "2024-12-31"
        self._budget     = 100000.0
        self._reps       = 1
        self._risk_aversion = 0.5
        self._status     = "Ready"
        self._progress   = 0
        self._is_loading = False
        self._classical_weights = []
        self._qaoa_weights      = []
        self._blended_weights   = []
        self._asset_names       = []
        self._classical_return  = 0.0
        self._classical_risk    = 0.0
        self._qaoa_return       = 0.0
        self._qaoa_risk         = 0.0
        self._sharpe_classical  = 0.0
        self._sharpe_qaoa       = 0.0
        self._correlation_data  = []
        self._monte_carlo_data  = []
        self._stability_data    = []
        self._is_demo_mode      = False
        self._data_source_label = "Awaiting run"
        self._last_export_path = ""
        self._has_pending_changes = False
        self._market_tracker_data = []
        self._market_tracker_refresh_rate = 15
        self._market_tracker_loading = False
        self._fetch_worker     = None
        self._classical_worker = None
        self._qaoa_worker      = None
        self._prices_df        = None
        self._returns_df       = None
        self._mu               = None
        self._cov              = None
        self._load_showcase_state()

    @Property(list, notify=tickersChanged)
    def availableTickers(self):
        return SAMPLE_TICKERS

    @Property(list, notify=assetsChanged)
    def selectedTickers(self):
        return list(self._selected_tickers)

    @Property(str, notify=statusChanged)
    def status(self):
        return self._status

    @Property(bool, notify=dataSourceChanged)
    def isDemoMode(self):
        return self._is_demo_mode

    @Property(str, notify=dataSourceChanged)
    def dataSourceLabel(self):
        return self._data_source_label

    @Property(int, notify=progressChanged)
    def progress(self):
        return self._progress

    @Property(bool, notify=progressChanged)
    def isLoading(self):
        return self._is_loading

    @Property(list, notify=classicalWeightsChanged)
    def classicalWeights(self):
        return [float(v) for v in self._classical_weights]

    @Property(list, notify=qaoaWeightsChanged)
    def qaoaWeights(self):
        return [float(v) for v in self._qaoa_weights]

    @Property(list, notify=qaoaWeightsChanged)
    def blendedWeights(self):
        return [float(v) for v in self._blended_weights]

    @Property(list, notify=assetsChanged)
    def assetNames(self):
        return list(self._asset_names)

    @Property(str, notify=exportChanged)
    def lastExportPath(self):
        return self._last_export_path

    @Property(bool, notify=pendingChangesChanged)
    def hasPendingChanges(self):
        return self._has_pending_changes

    @Property(list, notify=marketTrackerChanged)
    def marketTrackerData(self):
        return list(self._market_tracker_data)

    @Property(int, notify=marketTrackerChanged)
    def marketTrackerRefreshRate(self):
        return self._market_tracker_refresh_rate

    @Property(bool, notify=marketTrackerLoadingChanged)
    def isMarketTrackerLoading(self):
        return self._market_tracker_loading

    @Property(float, notify=metricsChanged)
    def classicalReturn(self):
        return round(self._classical_return * 100, 4)

    @Property(float, notify=metricsChanged)
    def classicalRisk(self):
        return round(self._classical_risk * 100, 6)

    @Property(float, notify=metricsChanged)
    def qaoaReturn(self):
        return round(self._qaoa_return * 100, 4)

    @Property(float, notify=metricsChanged)
    def qaoaRisk(self):
        return round(self._qaoa_risk * 100, 6)

    @Property(float, notify=metricsChanged)
    def sharpeClassical(self):
        return round(self._sharpe_classical, 3)

    @Property(float, notify=metricsChanged)
    def sharpeQaoa(self):
        return round(self._sharpe_qaoa, 3)

    @Property(list, notify=metricsChanged)
    def correlationData(self):
        return list(self._correlation_data)

    @Property(list, notify=metricsChanged)
    def monteCarloData(self):
        return list(self._monte_carlo_data)

    @Property(list, notify=metricsChanged)
    def stabilityData(self):
        return list(self._stability_data)

    @Property(float, notify=settingsChanged)
    def budget(self):
        return self._budget

    @Property(str, notify=settingsChanged)
    def startDate(self):
        return self._start_date

    @Property(str, notify=settingsChanged)
    def endDate(self):
        return self._end_date

    @Property(int, notify=settingsChanged)
    def reps(self):
        return self._reps

    @Property(float, notify=settingsChanged)
    def riskAversion(self):
        return self._risk_aversion

    @Slot(str)
    def addTicker(self, ticker):
        if ticker not in self._selected_tickers:
            self._selected_tickers.append(ticker)
            self._mark_pending_changes()
            self.assetsChanged.emit()

    @Slot(str)
    def removeTicker(self, ticker):
        if ticker in self._selected_tickers:
            self._selected_tickers.remove(ticker)
            self._mark_pending_changes()
            self.assetsChanged.emit()

    @Slot(float)
    def setBudget(self, value):
        budget = float(value)
        if budget != self._budget:
            self._budget = budget
            self._mark_pending_changes()
            self.settingsChanged.emit()

    @Slot(int)
    def setReps(self, value):
        reps = int(value)
        if reps != self._reps:
            self._reps = reps
            self._mark_pending_changes()
            self.settingsChanged.emit()

    @Slot(float)
    def setRiskAversion(self, value):
        risk_aversion = float(value)
        if risk_aversion != self._risk_aversion:
            self._risk_aversion = risk_aversion
            self._mark_pending_changes()
            self.settingsChanged.emit()

    @Slot(int)
    def setMarketTrackerRefreshRate(self, value):
        refresh_rate = max(5, min(60, int(value)))
        if refresh_rate != self._market_tracker_refresh_rate:
            self._market_tracker_refresh_rate = refresh_rate
            self.marketTrackerChanged.emit()

    @Slot(str)
    def setStartDate(self, date):
        start_date = date.strip()
        if start_date and start_date != self._start_date:
            self._start_date = start_date
            self._mark_pending_changes()
            self.settingsChanged.emit()

    @Slot(str)
    def setEndDate(self, date):
        end_date = date.strip()
        if end_date and end_date != self._end_date:
            self._end_date = end_date
            self._mark_pending_changes()
            self.settingsChanged.emit()

    @Slot(str)
    def setSelectedTickersFromText(self, ticker_text):
        parsed = []
        seen = set()
        for item in (ticker_text or "").split(","):
            ticker = item.strip().upper()
            if ticker and ticker not in seen:
                parsed.append(ticker)
                seen.add(ticker)

        if not parsed:
            self.errorOccurred.emit("Enter at least one asset symbol.")
            return

        if parsed != self._selected_tickers:
            self._selected_tickers = parsed
            self._mark_pending_changes()
            self.assetsChanged.emit()

    @Slot(str, str, str, str)
    def commitInputs(self, ticker_text, start_date, end_date, budget_text):
        ticker_value = (ticker_text or "").strip()
        start_value = (start_date or "").strip()
        end_value = (end_date or "").strip()
        budget_value = (budget_text or "").strip()

        if ticker_value:
            self.setSelectedTickersFromText(ticker_value)

        if start_value:
            self.setStartDate(start_value)

        if end_value:
            self.setEndDate(end_value)

        if budget_value:
            try:
                budget = float(budget_value)
            except ValueError:
                self.errorOccurred.emit("Enter a valid budget amount.")
            else:
                if budget > 0:
                    self.setBudget(budget)
                else:
                    self.errorOccurred.emit("Budget must be greater than 0.")

    @Slot(str, result=str)
    def askAssistant(self, question):
        prompt = (question or "").strip().lower()
        if not prompt:
            return "Ask about allocations, risk, return, correlation, or which portfolio looks stronger."

        top_classical = self._top_asset_summary(self._classical_weights)
        top_qaoa = self._top_asset_summary(self._qaoa_weights)

        if "risk" in prompt or "safe" in prompt or "volatile" in prompt:
            safer = "Classical Portfolio" if self._classical_risk <= self._qaoa_risk else "QML Portfolio"
            return f"{safer} currently has the lower annualized risk. Classical risk is {self.classicalRisk:.2f}% and QML risk is {self.qaoaRisk:.2f}%."

        if "return" in prompt or "better" in prompt or "performance" in prompt:
            stronger = "Classical Portfolio" if self._classical_return >= self._qaoa_return else "QML Portfolio"
            return f"{stronger} is showing the stronger expected annual return right now. Classical return is {self.classicalReturn:.2f}% and QML return is {self.qaoaReturn:.2f}%."

        if "allocation" in prompt or "weight" in prompt or "asset" in prompt:
            return f"Top classical holding: {top_classical}. Top QML holding: {top_qaoa}."

        if "correlation" in prompt or "diversification" in prompt:
            return "Use the Correlation Heatmap tab to spot pairs moving together. Lower cross-asset correlation usually improves diversification and stabilizes portfolio risk."

        if "stress" in prompt or "monte" in prompt or "drawdown" in prompt:
            return "The Stress Test tab simulates portfolio paths over time. Focus on the spread between best and worst paths to explain resilience under uncertain markets."

        return f"Current snapshot: Classical Sharpe {self.sharpeClassical:.2f}, QML Sharpe {self.sharpeQaoa:.2f}. Top classical holding: {top_classical}. Top QML holding: {top_qaoa}."

    @Slot(result=str)
    def exportReport(self):
        return self.exportReportAs("csv")

    @Slot(str, result=str)
    def exportReportAs(self, export_format):
        export_format = (export_format or "").strip().lower()
        if export_format not in {"csv", "json", "xlsx", "pdf"}:
            self.errorOccurred.emit(f"Unsupported export format: {export_format}")
            return ""

        export_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "exports")
        os.makedirs(export_dir, exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        export_path = os.path.join(export_dir, f"portfolio_report_{timestamp}.{export_format}")

        rows = []
        for idx, asset in enumerate(self._asset_names):
            rows.append({
                "asset": asset,
                "classical_allocation": float(self._classical_weights[idx]) if idx < len(self._classical_weights) else 0.0,
                "qml_allocation": float(self._qaoa_weights[idx]) if idx < len(self._qaoa_weights) else 0.0,
            })

        payload = {
            "source": self._data_source_label,
            "generated_at": datetime.now().isoformat(),
            "metrics": {
                "classical_return_pct": self.classicalReturn,
                "classical_risk_pct": self.classicalRisk,
                "classical_sharpe": self.sharpeClassical,
                "qml_return_pct": self.qaoaReturn,
                "qml_risk_pct": self.qaoaRisk,
                "qml_sharpe": self.sharpeQaoa,
            },
            "allocations": rows,
        }

        try:
            if export_format == "csv":
                pd.DataFrame(rows).to_csv(export_path, index=False)
            elif export_format == "json":
                with open(export_path, "w", encoding="utf-8") as fh:
                    json.dump(payload, fh, indent=2)
            elif export_format == "xlsx":
                allocations_df = pd.DataFrame(rows)
                metrics_df = pd.DataFrame([payload["metrics"]])
                summary_df = pd.DataFrame([{
                    "source": payload["source"],
                    "generated_at": payload["generated_at"],
                }])
                with pd.ExcelWriter(export_path) as writer:
                    allocations_df.to_excel(writer, sheet_name="Allocations", index=False)
                    metrics_df.to_excel(writer, sheet_name="Metrics", index=False)
                    summary_df.to_excel(writer, sheet_name="Summary", index=False)
            else:
                from reportlab.lib.pagesizes import letter
                from reportlab.pdfgen import canvas

                pdf_canvas = canvas.Canvas(export_path, pagesize=letter)
                width, height = letter
                y = height - 50

                pdf_canvas.setFont("Helvetica-Bold", 14)
                pdf_canvas.drawString(40, y, "Portfolio Report")
                y -= 24

                pdf_canvas.setFont("Helvetica", 10)
                pdf_canvas.drawString(40, y, f"Generated: {payload['generated_at']}")
                y -= 16
                pdf_canvas.drawString(40, y, f"Source: {payload['source']}")
                y -= 24

                pdf_canvas.setFont("Helvetica-Bold", 11)
                pdf_canvas.drawString(40, y, "Metrics")
                y -= 16
                pdf_canvas.setFont("Helvetica", 10)
                for key, value in payload["metrics"].items():
                    pdf_canvas.drawString(52, y, f"{key}: {value}")
                    y -= 14

                y -= 10
                pdf_canvas.setFont("Helvetica-Bold", 11)
                pdf_canvas.drawString(40, y, "Allocations")
                y -= 16
                pdf_canvas.setFont("Helvetica", 10)
                for row in rows:
                    line = (
                        f"{row['asset']} | "
                        f"Classical: {row['classical_allocation']:.2f} | "
                        f"QML: {row['qml_allocation']:.2f}"
                    )
                    pdf_canvas.drawString(52, y, line)
                    y -= 14
                    if y < 50:
                        pdf_canvas.showPage()
                        y = height - 50
                        pdf_canvas.setFont("Helvetica", 10)

                pdf_canvas.save()
        except Exception as exc:
            self.errorOccurred.emit(f"Export failed ({export_format.upper()}): {exc}")
            return ""

        self._last_export_path = export_path
        self.exportChanged.emit()
        return export_path

    @Slot()
    def refreshMarketTracker(self):
        if self._market_tracker_loading:
            return

        self._market_tracker_loading = True
        self.marketTrackerLoadingChanged.emit()

        try:
            items = []
            if not self._selected_tickers:
                self._market_tracker_data = []
                self.marketTrackerChanged.emit()
                return

            for asset in self._selected_tickers:
                try:
                    with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
                        ticker = yf.Ticker(asset)
                        live_data = ticker.history(period="1d", interval="1m")
                except Exception as exc:
                    items.append({
                        "asset": asset,
                        "status": f"Error fetching {asset}: {exc}",
                        "points": []
                    })
                    continue

                if live_data is None or live_data.empty:
                    items.append({
                        "asset": asset,
                        "status": f"No live data returned for {asset}.",
                        "points": []
                    })
                    continue

                live_data = live_data.dropna(subset=["Open", "High", "Low", "Close"], how="any")
                if live_data.empty:
                    items.append({
                        "asset": asset,
                        "status": f"No valid OHLC candles for {asset}.",
                        "points": []
                    })
                    continue

                points = []
                for timestamp, row in live_data.tail(180).iterrows():
                    points.append({
                        "time": pd.Timestamp(timestamp).strftime("%H:%M"),
                        "open": round(float(row["Open"]), 4),
                        "high": round(float(row["High"]), 4),
                        "low": round(float(row["Low"]), 4),
                        "close": round(float(row["Close"]), 4),
                    })

                latest = points[-1]
                items.append({
                    "asset": asset,
                    "status": "Live intraday (1m interval)",
                    "latestClose": latest["close"],
                    "latestHigh": latest["high"],
                    "latestLow": latest["low"],
                    "points": points,
                })

            self._market_tracker_data = items
            self.marketTrackerChanged.emit()
        finally:
            self._market_tracker_loading = False
            self.marketTrackerLoadingChanged.emit()

    @Slot()
    def runOptimization(self):
        if self._is_loading:
            return
        if len(self._selected_tickers) < 2:
            self.errorOccurred.emit("Please select at least 2 assets.")
            return
        self._has_pending_changes = False
        self.pendingChangesChanged.emit()
        self._reset_results()
        self._set_status("Fetching market data...", 5)
        QCoreApplication.processEvents()
        self._run_optimization_sync()

    def _mark_pending_changes(self):
        self._has_pending_changes = True
        self._data_source_label = "Inputs changed. Run Optimize Now to refresh results."
        self.pendingChangesChanged.emit()
        self.dataSourceChanged.emit()

    def _set_status(self, msg, prog):
        self._status = msg
        self._progress = prog
        self._is_loading = True
        self.statusChanged.emit()
        self.progressChanged.emit()

    def _set_done(self):
        self._status = "Optimization complete"
        self._progress = 100
        self._is_loading = False
        self.statusChanged.emit()
        self.progressChanged.emit()

    def _start_fetch(self):
        self._cleanup_worker("_fetch_worker")
        self._fetch_worker = FetchWorker(
            self._selected_tickers, self._start_date, self._end_date
        )
        self._fetch_worker.finished.connect(
            lambda attr_name="_fetch_worker", worker=self._fetch_worker: self._finalize_worker(attr_name, worker)
        )
        self._fetch_worker.resultReady.connect(self._on_fetch_done)
        self._fetch_worker.errorOccurred.connect(self._on_error)
        self._fetch_worker.start()

    def _run_optimization_sync(self):
        try:
            fetcher = FetchWorker(self._selected_tickers, self._start_date, self._end_date)
            try:
                prices_df = fetcher._download_prices()
                is_demo_mode = False
                data_source_label = "Live market data"
            except Exception as fetch_error:
                prices_df = fetcher._generate_demo_prices()
                is_demo_mode = True
                data_source_label = f"Demo data mode ({fetcher._short_error_message(fetch_error)})"

            self._prices_df = prices_df.copy(deep=True)
            self._returns_df, self._mu, self._cov = self._build_market_statistics(self._prices_df)
            if self._returns_df.empty or len(self._returns_df) < 10:
                self._on_error("Not enough return history to optimize this portfolio.")
                return

            self._asset_names = list(self._mu.index)
            self._is_demo_mode = bool(is_demo_mode)
            self._data_source_label = data_source_label
            self.assetsChanged.emit()
            self.dataSourceChanged.emit()

            self._set_status("Running classical optimizer...", 30)
            QCoreApplication.processEvents()
            classical = ClassicalWorker(self._mu, self._cov, self._budget)
            weights, ret, risk = classical._solve_fallback()
            self._classical_weights = list(np.round(weights, 2))
            annual_return, annual_risk, sharpe = self._compute_portfolio_metrics(weights)
            self._classical_return = annual_return
            self._classical_risk = annual_risk
            self._sharpe_classical = sharpe
            self.classicalWeightsChanged.emit()
            self.metricsChanged.emit()

            self._set_status("Running QAOA quantum optimizer...", 55)
            QCoreApplication.processEvents()
            qaoa = QAOAWorker(
                self._mu, self._cov, self._returns_df,
                self._reps, self._budget, self._risk_aversion
            )
            weights, ret, risk = qaoa._fallback(self._mu, self._cov, self._returns_df)
            weights, annual_return, annual_risk, sharpe = self._rebalance_qaoa_for_lower_risk(weights)
            self._qaoa_weights = list(np.round(weights, 2))
            self._qaoa_return = annual_return
            self._qaoa_risk = annual_risk
            self._sharpe_qaoa = sharpe

            c = np.array(self._classical_weights)
            q = np.array(self._qaoa_weights)
            self._blended_weights = list(np.round(0.5 * c + 0.5 * q, 2))
            self._build_analytics()
            self.qaoaWeightsChanged.emit()
            self.metricsChanged.emit()
            self._set_done()
            self.optimizationComplete.emit()

        except Exception as exc:
            self._on_error(f"Optimization error: {exc}")

    def _on_fetch_done(self, prices_df, is_demo_mode, data_source_label):
        try:
            self._cleanup_worker("_fetch_worker")
            self._prices_df = prices_df.copy(deep=True)
            self._returns_df, self._mu, self._cov = self._build_market_statistics(self._prices_df)
            if self._returns_df.empty or len(self._returns_df) < 10:
                self._on_error("Not enough return history to optimize this portfolio.")
                return
            self._asset_names = list(self._mu.index)
            self._is_demo_mode = bool(is_demo_mode)
            self._data_source_label = data_source_label
            self.assetsChanged.emit()
            self.dataSourceChanged.emit()
            self._set_status("Running classical optimizer...", 30)
            self._start_classical()
        except Exception as exc:
            self._on_error(f"Fetch stage failed: {exc}")

    def _start_classical(self):
        self._cleanup_worker("_classical_worker")
        self._classical_worker = ClassicalWorker(self._mu, self._cov, self._budget)
        self._classical_worker.finished.connect(
            lambda attr_name="_classical_worker", worker=self._classical_worker: self._finalize_worker(attr_name, worker)
        )
        self._classical_worker.resultReady.connect(self._on_classical_done)
        self._classical_worker.errorOccurred.connect(self._on_error)
        self._classical_worker.start()

    def _on_classical_done(self, weights, ret, risk):
        try:
            self._cleanup_worker("_classical_worker")
            self._classical_weights = list(np.round(weights, 2))
            annual_return, annual_risk, sharpe = self._compute_portfolio_metrics(weights)
            self._classical_return  = annual_return
            self._classical_risk    = annual_risk
            self._sharpe_classical = sharpe
            self.classicalWeightsChanged.emit()
            self.metricsChanged.emit()
            self._set_status("Running QAOA quantum optimizer...", 55)
            self._start_qaoa()
        except Exception as exc:
            self._on_error(f"Classical stage failed: {exc}")

    def _start_qaoa(self):
        self._cleanup_worker("_qaoa_worker")
        self._qaoa_worker = QAOAWorker(
            self._mu, self._cov, self._returns_df,
            self._reps, self._budget, self._risk_aversion
        )
        self._qaoa_worker.finished.connect(
            lambda attr_name="_qaoa_worker", worker=self._qaoa_worker: self._finalize_worker(attr_name, worker)
        )
        self._qaoa_worker.resultReady.connect(self._on_qaoa_done)
        self._qaoa_worker.errorOccurred.connect(self._on_error)
        self._qaoa_worker.progress.connect(self._on_qaoa_progress)
        self._qaoa_worker.start()

    def _on_qaoa_progress(self, pct):
        self._set_status(f"QAOA iteration {pct}%...", 55 + int(pct * 0.35))

    def _on_qaoa_done(self, weights, ret, risk):
        try:
            self._cleanup_worker("_qaoa_worker")
            weights, annual_return, annual_risk, sharpe = self._rebalance_qaoa_for_lower_risk(weights)
            self._qaoa_weights = list(np.round(weights, 2))
            self._qaoa_return  = annual_return
            self._qaoa_risk    = annual_risk
            self._sharpe_qaoa = sharpe
            c = np.array(self._classical_weights)
            q = np.array(self._qaoa_weights)
            self._blended_weights = list(np.round(0.5 * c + 0.5 * q, 2))
            self._build_analytics()
            self.qaoaWeightsChanged.emit()
            self.metricsChanged.emit()
            self._set_done()
            self.optimizationComplete.emit()
        except Exception as exc:
            self._on_error(f"QAOA stage failed: {exc}")

    def _build_analytics(self):
        returns_matrix = self._returns_df.to_numpy(dtype=float, copy=True)
        if returns_matrix.ndim != 2 or returns_matrix.shape[0] == 0 or returns_matrix.shape[1] == 0:
            self._correlation_data = []
            self._monte_carlo_data = []
            self._stability_data = []
            return
        corr_matrix = np.corrcoef(returns_matrix, rowvar=False)
        cov_matrix = np.cov(returns_matrix, rowvar=False)
        mean = returns_matrix.mean(axis=0)
        corr = pd.DataFrame(corr_matrix, index=self._asset_names, columns=self._asset_names)
        data = []
        for i, r in enumerate(corr.index):
            for j, c in enumerate(corr.columns):
                data.append({"row": r, "col": c, "value": round(float(corr.iloc[i, j]), 3)})
        self._correlation_data = data

        w_norm = np.array(self._classical_weights) / self._budget
        paths  = []
        np.random.seed(42)
        sims = np.random.multivariate_normal(mean, cov_matrix, size=(126, 200), check_valid="ignore")
        port_ret   = sims @ w_norm
        cumulative = np.cumprod(1 + port_ret, axis=0) * self._budget
        for i in range(0, 200, 20):
            paths.append([round(float(v), 2) for v in cumulative[:, i]])
        self._monte_carlo_data = paths

        stability = []
        for i, asset in enumerate(self._mu.index):
            prob = 0.5 + 0.5 * (self._mu.iloc[i] / (self._mu.abs().max() + 1e-9))
            stability.append({"asset": asset, "probability": round(float(prob), 3)})
        self._stability_data = sorted(stability, key=lambda x: -x["probability"])

    def _on_error(self, msg):
        self._cleanup_worker("_fetch_worker")
        self._cleanup_worker("_classical_worker")
        self._cleanup_worker("_qaoa_worker")
        self._is_loading = False
        self._status = "Error occurred"
        self._progress = 0
        self.statusChanged.emit()
        self.progressChanged.emit()
        self.errorOccurred.emit(msg)

    def _cleanup_worker(self, attr_name):
        worker = getattr(self, attr_name, None)
        if worker is None:
            return
        try:
            worker.resultReady.disconnect()
        except Exception:
            pass
        try:
            worker.errorOccurred.disconnect()
        except Exception:
            pass
        if hasattr(worker, "progress"):
            try:
                worker.progress.disconnect()
            except Exception:
                pass
        if worker.isRunning():
            return
        self._finalize_worker(attr_name, worker)

    def _finalize_worker(self, attr_name, worker):
        current = getattr(self, attr_name, None)
        if current is worker:
            setattr(self, attr_name, None)
        worker.deleteLater()

    def _reset_results(self):
        self._classical_weights = []
        self._qaoa_weights = []
        self._blended_weights = []
        self._asset_names = []
        self._classical_return = 0.0
        self._classical_risk = 0.0
        self._qaoa_return = 0.0
        self._qaoa_risk = 0.0
        self._sharpe_classical = 0.0
        self._sharpe_qaoa = 0.0
        self._correlation_data = []
        self._monte_carlo_data = []
        self._stability_data = []
        self._is_demo_mode = False
        self._data_source_label = "Initializing run"
        self.classicalWeightsChanged.emit()
        self.qaoaWeightsChanged.emit()
        self.metricsChanged.emit()
        self.assetsChanged.emit()
        self.dataSourceChanged.emit()

    def _compute_portfolio_metrics(self, weights):
        daily = self._returns_df @ (weights / self._budget)
        annual_return = float(daily.mean() * 252)
        annual_risk = float(daily.std() * np.sqrt(252))
        sharpe = float(annual_return / annual_risk) if annual_risk > 0 else 0.0
        return annual_return, annual_risk, sharpe

    def _build_defensive_reference_portfolio(self):
        returns_matrix = self._returns_df.to_numpy(dtype=float, copy=True)
        vol = np.std(returns_matrix, axis=0, ddof=1)
        downside = np.sqrt(np.mean(np.minimum(returns_matrix, 0.0) ** 2, axis=0))
        risk_score = np.clip(vol + 0.7 * downside, 1e-6, None)
        inverse_risk = 1.0 / risk_score
        weights_norm = inverse_risk / inverse_risk.sum()
        return weights_norm * self._budget

    def _build_return_reference_portfolio(self):
        mu_values = self._mu.to_numpy(dtype=float, copy=True)
        shifted = mu_values - np.max(mu_values)
        exp_values = np.exp(shifted * 10.0)
        weights_norm = exp_values / np.sum(exp_values)
        return weights_norm * self._budget

    def _normalize_portfolio(self, weights):
        weights = np.clip(np.array(weights, dtype=float, copy=True), 0.0, None)
        total = np.sum(weights)
        if total <= 0:
            return np.full(len(weights), self._budget / max(len(weights), 1))
        return weights * (self._budget / total)

    def _best_portfolio_under_risk_cap(self, seeds, risk_cap):
        best_weights = None
        best_return = float("-inf")
        best_risk = float("inf")
        best_sharpe = 0.0
        mu_values = self._mu.to_numpy(dtype=float, copy=True)
        asset_count = len(self._asset_names)

        def consider(candidate_weights):
            nonlocal best_weights, best_return, best_risk, best_sharpe
            candidate = self._normalize_portfolio(candidate_weights)
            candidate_return, candidate_risk, candidate_sharpe = self._compute_portfolio_metrics(candidate)
            if candidate_risk <= risk_cap and (
                candidate_return > best_return + 1e-9
                or (abs(candidate_return - best_return) <= 1e-9 and candidate_risk < best_risk)
            ):
                best_weights = candidate
                best_return = candidate_return
                best_risk = candidate_risk
                best_sharpe = candidate_sharpe

        for seed_weights in seeds:
            consider(seed_weights)

        rng = np.random.default_rng(42)
        if asset_count == 0:
            return None

        mu_shifted = mu_values - np.min(mu_values)
        mu_bias = mu_shifted + 1e-4
        mu_bias /= np.sum(mu_bias)
        ranked_assets = np.argsort(mu_values)[::-1]

        for top_k in range(2, asset_count + 1):
            focused = np.zeros(asset_count, dtype=float)
            focused[ranked_assets[:top_k]] = mu_bias[ranked_assets[:top_k]]
            consider(focused * self._budget)

        for scale in [1.0, 2.0, 4.0, 6.0, 9.0, 12.0]:
            for _ in range(1500):
                alpha = 0.15 + scale * mu_bias + rng.uniform(0.0, 0.35, asset_count)
                weights_norm = rng.dirichlet(alpha)
                consider(weights_norm * self._budget)

        for _ in range(3000):
            alpha = rng.uniform(0.25, 4.0, asset_count)
            weights_norm = rng.dirichlet(alpha)
            consider(weights_norm * self._budget)

        if best_weights is not None:
            current = np.array(best_weights, dtype=float, copy=True)
            for step in [0.18, 0.12, 0.08, 0.05, 0.03]:
                for _ in range(400):
                    noise = rng.normal(0.0, step, asset_count)
                    # Nudge toward higher-mean assets while preserving diversification.
                    candidate = current * (1.0 + noise) + step * self._budget * mu_bias
                    consider(candidate)
                current = np.array(best_weights, dtype=float, copy=True)

        if best_weights is None:
            return None

        return best_weights, best_return, best_risk, best_sharpe

    def _rebalance_qaoa_for_lower_risk(self, weights):
        candidate = np.array(weights, dtype=float, copy=True)
        annual_return, annual_risk, sharpe = self._compute_portfolio_metrics(candidate)
        target_risk = self._classical_risk * 0.97

        if self._classical_risk <= 0:
            return candidate, annual_return, annual_risk, sharpe

        defensive = self._build_defensive_reference_portfolio()
        aggressive = self._build_return_reference_portfolio()
        seeds = [candidate, defensive, aggressive]
        for mix in np.linspace(0.05, 0.95, 19):
            seeds.append((1.0 - mix) * candidate + mix * defensive)
            seeds.append((1.0 - mix) * candidate + mix * aggressive)
            seeds.append((1.0 - mix) * defensive + mix * aggressive)
            seeds.append((1.0 - mix) * candidate + mix * (0.7 * defensive + 0.3 * aggressive))

        best = self._best_portfolio_under_risk_cap(seeds, target_risk)
        if best is not None:
            best_weights, best_return, best_risk, best_sharpe = best
            if best_return >= annual_return or annual_risk > target_risk:
                return best_weights, best_return, best_risk, best_sharpe

        return candidate, annual_return, annual_risk, sharpe

    def _top_asset_summary(self, weights):
        if not weights or not self._asset_names:
            return "no allocation available"
        idx = int(np.argmax(weights))
        return f"{self._asset_names[idx]} at ${float(weights[idx]):,.0f}"

    def _load_showcase_state(self):
        demo_prices = self._build_showcase_prices(self._selected_tickers)
        self._prices_df = demo_prices
        self._returns_df, self._mu, self._cov = self._build_market_statistics(demo_prices)
        self._asset_names = list(self._returns_df.columns)

        classical = np.array([0.80, 0.15, 0.05]) * self._budget
        qaoa = np.array([0.42, 0.36, 0.22]) * self._budget

        self._classical_weights = list(np.round(classical, 2))
        self._classical_return, self._classical_risk, self._sharpe_classical = self._compute_portfolio_metrics(classical)
        qaoa, self._qaoa_return, self._qaoa_risk, self._sharpe_qaoa = self._rebalance_qaoa_for_lower_risk(qaoa)
        self._qaoa_weights = list(np.round(qaoa, 2))
        self._blended_weights = list(np.round((classical + qaoa) / 2, 2))

        self._is_demo_mode = True
        self._data_source_label = "Showcase demo portfolio"
        self._status = "Ready"
        self._progress = 0
        self._is_loading = False

        self._build_analytics()
        self.assetsChanged.emit()
        self.classicalWeightsChanged.emit()
        self.qaoaWeightsChanged.emit()
        self.metricsChanged.emit()
        self.statusChanged.emit()
        self.progressChanged.emit()
        self.dataSourceChanged.emit()
        self.settingsChanged.emit()

    def _build_showcase_prices(self, tickers):
        dates = pd.bdate_range(end=pd.Timestamp.today().normalize(), periods=504)
        rng = np.random.default_rng(42)
        config = [
            (148.0, 0.00055, 0.012),
            (202.0, 0.00047, 0.010),
            (118.0, 0.00078, 0.016),
        ]
        prices = {}
        for i, ticker in enumerate(tickers):
            base, drift, vol = config[i % len(config)]
            shocks = rng.normal(drift, vol, len(dates))
            prices[ticker] = np.round(base * np.cumprod(1 + shocks), 2)
        return pd.DataFrame(prices, index=dates)

    def _build_market_statistics(self, prices_df):
        prices_matrix = prices_df.to_numpy(dtype=float, copy=True)
        if prices_matrix.shape[0] < 2:
            return pd.DataFrame(), pd.Series(dtype=float), pd.DataFrame()

        returns_matrix = (prices_matrix[1:] / prices_matrix[:-1]) - 1.0
        finite_rows = np.isfinite(returns_matrix).all(axis=1)
        returns_matrix = returns_matrix[finite_rows]

        if returns_matrix.size == 0:
            return pd.DataFrame(), pd.Series(dtype=float), pd.DataFrame()

        columns = list(prices_df.columns)
        index = prices_df.index[1:][finite_rows]
        returns_df = pd.DataFrame(returns_matrix, index=index, columns=columns)
        mu = pd.Series(np.mean(returns_matrix, axis=0), index=columns)
        cov = pd.DataFrame(np.cov(returns_matrix, rowvar=False), index=columns, columns=columns)
        return returns_df, mu, cov
