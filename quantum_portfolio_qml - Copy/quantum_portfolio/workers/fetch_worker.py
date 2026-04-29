import contextlib
import io
import numpy as np
import pandas as pd
import yfinance as yf
from PySide6.QtCore import QThread, Signal


class FetchWorker(QThread):
    resultReady = Signal(object, bool, str)
    errorOccurred = Signal(str)

    def __init__(self, tickers, start, end, parent=None):
        super().__init__(parent)
        self.tickers = tickers
        self.start_date = start
        self.end_date = end

    def run(self):
        try:
            prices = self._download_prices()
            self.resultReady.emit(prices, False, "Live market data")
        except Exception as e:
            demo_prices = self._generate_demo_prices()
            self.resultReady.emit(
                demo_prices,
                True,
                f"Demo data mode ({self._short_error_message(e)})"
            )

    def _download_prices(self):
        with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
            raw = yf.download(
                self.tickers,
                start=self.start_date,
                end=self.end_date,
                progress=False,
                auto_adjust=False,
                threads=False,
                timeout=10,
            )
        if raw.empty:
            raise ValueError("no market data returned")

        if isinstance(raw.columns, pd.MultiIndex):
            lvl0 = raw.columns.get_level_values(0)
            prices = raw["Adj Close"] if "Adj Close" in lvl0 else raw["Close"]
        else:
            prices = raw["Adj Close"] if "Adj Close" in raw.columns else raw["Close"]

        if isinstance(prices, pd.Series):
            prices = prices.to_frame(name=self.tickers[0])

        prices = prices.ffill().dropna(axis=1, how="all")
        if prices.empty:
            raise ValueError("price table is empty after cleaning")

        prices = prices.dropna(axis=0, how="any")
        if len(prices) < 20:
            raise ValueError("not enough history returned")

        return prices

    def _generate_demo_prices(self):
        dates = pd.bdate_range(self.start_date, self.end_date)
        if len(dates) < 40:
            dates = pd.bdate_range(end=pd.Timestamp.today().normalize(), periods=252)

        seed = sum(sum(ord(ch) for ch in ticker) for ticker in self.tickers) + len(dates)
        rng = np.random.default_rng(seed)
        prices = {}

        for i, ticker in enumerate(self.tickers):
            base_price = 90 + i * 18
            drift = 0.0005 + (i % 5) * 0.00015
            volatility = 0.012 + (i % 4) * 0.002
            shocks = rng.normal(drift, volatility, len(dates))
            path = base_price * np.cumprod(1 + shocks)
            prices[ticker] = np.round(path, 2)

        return pd.DataFrame(prices, index=dates)

    def _short_error_message(self, error):
        message = str(error).strip()
        if not message:
            return "live feed unavailable"
        return message[:80]
