import QtQuick

Rectangle {
    id: root
    color: "#0f1018"
    border.color: "#2a2d45"
    radius: 12

    property var candles: []
    property string assetName: ""
    property int hoveredIndex: -1
    property string hoverTime: "--"
    property string hoverOpen: "--"
    property string hoverHigh: "--"
    property string hoverLow: "--"
    property string hoverClose: "--"

    Canvas {
        id: canvas
        anchors.fill: parent
        anchors.margins: 12
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            if (!candles || candles.length === 0)
                return

            var minLow = Number(candles[0].low)
            var maxHigh = Number(candles[0].high)
            for (var i = 0; i < candles.length; ++i) {
                minLow = Math.min(minLow, Number(candles[i].low))
                maxHigh = Math.max(maxHigh, Number(candles[i].high))
            }

            var padTop = 20
            var padBottom = 26
            var chartHeight = height - padTop - padBottom
            var candleWidth = Math.max(2, (width - 8) / candles.length * 0.55)
            var step = (width - 8) / candles.length

            function scaleY(value) {
                return padTop + (1 - ((value - minLow) / Math.max(maxHigh - minLow, 1e-6))) * chartHeight
            }

            ctx.strokeStyle = "#24314d"
            ctx.lineWidth = 1
            ctx.beginPath()
            ctx.moveTo(0, padTop + chartHeight)
            ctx.lineTo(width, padTop + chartHeight)
            ctx.stroke()

            for (var c = 0; c < candles.length; ++c) {
                var candle = candles[c]
                var x = 4 + c * step + (step - candleWidth) / 2
                var openY = scaleY(Number(candle.open))
                var closeY = scaleY(Number(candle.close))
                var highY = scaleY(Number(candle.high))
                var lowY = scaleY(Number(candle.low))
                var rising = Number(candle.close) >= Number(candle.open)

                ctx.strokeStyle = rising ? "#00e5a0" : "#ff6b81"
                ctx.fillStyle = rising ? "#00d4ff" : "#b060ff"
                ctx.lineWidth = 1

                ctx.beginPath()
                ctx.moveTo(x + candleWidth / 2, highY)
                ctx.lineTo(x + candleWidth / 2, lowY)
                ctx.stroke()

                var bodyTop = Math.min(openY, closeY)
                var bodyHeight = Math.max(2, Math.abs(closeY - openY))
                ctx.fillRect(x, bodyTop, candleWidth, bodyHeight)
            }

            if (root.hoveredIndex >= 0 && root.hoveredIndex < candles.length) {
                var hoverX = 4 + root.hoveredIndex * step + step / 2
                ctx.strokeStyle = "#4db7ff"
                ctx.lineWidth = 1
                ctx.beginPath()
                ctx.moveTo(hoverX, padTop)
                ctx.lineTo(hoverX, padTop + chartHeight)
                ctx.stroke()
            }

            ctx.fillStyle = "#7f89a6"
            ctx.font = "10px sans-serif"
            ctx.textAlign = "left"
            ctx.fillText(candles[0].time || "", 0, height - 6)
            ctx.textAlign = "center"
            ctx.fillText(candles[Math.floor(candles.length / 2)].time || "", width / 2, height - 6)
            ctx.textAlign = "right"
            ctx.fillText(candles[candles.length - 1].time || "", width, height - 6)
        }
    }

    MouseArea {
        anchors.fill: canvas
        hoverEnabled: true

        function updateHover(xPos) {
            if (!candles || candles.length === 0) {
                root.hoveredIndex = -1
                root.hoverTime = "--"
                root.hoverOpen = "--"
                root.hoverHigh = "--"
                root.hoverLow = "--"
                root.hoverClose = "--"
                return
            }
            var step = (canvas.width - 8) / candles.length
            var idx = Math.floor((xPos - 4) / Math.max(step, 1))
            idx = Math.max(0, Math.min(candles.length - 1, idx))
            if (idx !== root.hoveredIndex) {
                root.hoveredIndex = idx
                var candle = candles[idx]
                root.hoverTime = candle && candle.time ? String(candle.time) : "--"
                root.hoverOpen = candle ? Number(candle.open).toFixed(4) : "--"
                root.hoverHigh = candle ? Number(candle.high).toFixed(4) : "--"
                root.hoverLow = candle ? Number(candle.low).toFixed(4) : "--"
                root.hoverClose = candle ? Number(candle.close).toFixed(4) : "--"
                canvas.requestPaint()
            }
        }

        onPositionChanged: updateHover(mouse.x)
        onEntered: updateHover(mouse.x)
        onExited: {
            root.hoveredIndex = -1
            root.hoverTime = "--"
            root.hoverOpen = "--"
            root.hoverHigh = "--"
            root.hoverLow = "--"
            root.hoverClose = "--"
            canvas.requestPaint()
        }
    }

    Rectangle {
        id: tooltip
        visible: root.hoveredIndex >= 0 && root.hoveredIndex < root.candles.length
        color: "#e8ecf5"
        opacity: 0.95
        border.color: "#b8c0d3"
        radius: 8
        z: 10
        width: 170
        height: 104
        x: {
            if (!visible || !candles || candles.length === 0)
                return 0
            var step = (canvas.width - 8) / candles.length
            var cx = canvas.x + 4 + root.hoveredIndex * step + step / 2
            return Math.max(8, Math.min(root.width - width - 8, cx + 12))
        }
        y: 16

        Column {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 2

            Text {
                text: root.hoverTime
                color: "#3a4254"
                font.pixelSize: 11
                font.weight: Font.DemiBold
            }
            Text {
                text: "open: " + root.hoverOpen
                color: "#58627a"
                font.pixelSize: 11
            }
            Text {
                text: "high: " + root.hoverHigh
                color: "#58627a"
                font.pixelSize: 11
            }
            Text {
                text: "low: " + root.hoverLow
                color: "#58627a"
                font.pixelSize: 11
            }
            Text {
                text: "close: " + root.hoverClose
                color: "#58627a"
                font.pixelSize: 11
            }
        }
    }

    onCandlesChanged: canvas.requestPaint()
    onHoveredIndexChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()
    Component.onCompleted: canvas.requestPaint()
}
