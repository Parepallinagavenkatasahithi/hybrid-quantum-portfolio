from PySide6.QtCore import QObject, Signal, Slot, Property


class ChartModel(QObject):
    dataChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._pie_data = []
        self._bar_data = []

    @Property(list, notify=dataChanged)
    def pieData(self):
        return self._pie_data

    @Slot(list, list)
    def setPieData(self, labels, values):
        self._pie_data = [{"label": l, "value": v} for l, v in zip(labels, values)]
        self.dataChanged.emit()
