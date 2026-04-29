import QtQuick

Canvas {
    property var names: []
    property var values: []
    property color barColor: "#00d4ff"
    property string title: ""

    onNamesChanged: requestPaint()
    onValuesChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)

        var n = names.length
        if (n === 0 || values.length === 0) {
            ctx.fillStyle = "#2a2d45"
            ctx.font = "13px sans-serif"
            ctx.textAlign = "center"
            ctx.fillText("No data - run optimization first", width / 2, height / 2)
            return
        }

        var maxVal = 1
        for (var i = 0; i < values.length; i++) {
            var current = Number(values[i] || 0)
            if (current > maxVal)
                maxVal = current
        }
        var padL = 50
        var padB = 28
        var padT = 10
        var chartW = width - padL
        var chartH = height - padB - padT
        var barW = Math.min(40, chartW / n - 6)
        var gap = (chartW - n * barW) / (n + 1)

        // Y-axis grid
        ctx.strokeStyle = "#1e2030"
        ctx.lineWidth = 1
        for (var g = 0; g <= 4; g++) {
            var gy = padT + g * chartH / 4
            ctx.beginPath()
            ctx.moveTo(padL, gy)
            ctx.lineTo(width, gy)
            ctx.stroke()

            var gVal = maxVal * (1 - g / 4)
            ctx.fillStyle = "#4a5068"
            ctx.font = "9px sans-serif"
            ctx.textAlign = "right"
            ctx.fillText("$" + (gVal / 1000).toFixed(0) + "K", padL - 4, gy + 3)
        }

        // Bars
        for (var i = 0; i < n; i++) {
            var numericValue = Number(values[i] || 0)
            var bh = (numericValue / maxVal) * chartH
            var bx = padL + gap + i * (barW + gap)
            var by = padT + chartH - bh

            // Gradient bar
            var grad = ctx.createLinearGradient(bx, by, bx, by + bh)
            var c = barColor.toString()
            grad.addColorStop(0, c)
            grad.addColorStop(1, c.replace(")", ", 0.4)").replace("rgb", "rgba"))
            ctx.fillStyle = grad

            ctx.fillRect(bx, by, barW, bh)

            // Value label above bar
            ctx.fillStyle = barColor.toString()
            ctx.font = "bold 9px sans-serif"
            ctx.textAlign = "center"
            if (numericValue > 0)
                ctx.fillText("$" + (numericValue / 1000).toFixed(0) + "K", bx + barW / 2, by - 4)

            // Asset name label
            ctx.fillStyle = "#4a5068"
            ctx.font = "9px sans-serif"
            ctx.fillText(names[i], bx + barW / 2, height - 8)
        }
    }
}
