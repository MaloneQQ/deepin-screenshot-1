import QtQuick 2.1
import "calculateRect.js" as CalcEngine

Item {
	property bool selected: false
	property bool reSized: false
	property bool rotated: false
	property bool firstDraw: false

	property point clickedPoint
	property var points: []
 	property var mainPoints: [Qt.point(0, 0), Qt.point(0, 0), Qt.point(0, 0), Qt.point(0,0)]
	property var minorPoints: [Qt.point(0, 0), Qt.point(0, 0), Qt.point(0, 0), Qt.point(0,0)]

	property int bigPointRadius: 6
	property int smallPointRadius: 4

	function _getMainPoints() {

		var startPoint = points[0]
		var endPoint = points[points.length - 1]
		var leftX = Math.min(startPoint.x, endPoint.x)
		var leftY = Math.min(startPoint.y, endPoint.y)
		var pWidth = Math.abs(startPoint.x - endPoint.x)
		var pHeight = Math.abs(startPoint.y - endPoint.y)
		mainPoints[0] = Qt.point(leftX, leftY)
		mainPoints[1] = Qt.point(leftX + pWidth, leftY)
		mainPoints[2] = Qt.point(leftX, pHeight + leftY)
		mainPoints[3] = Qt.point(leftX + pWidth, leftY + pHeight)

		var tmpPoints = CalcEngine.fourPoint_dir(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3])
		return tmpPoints
	}

	function draw(ctx) {
		if (!firstDraw) {
			mainPoints = _getMainPoints()
		}

	    ctx.save()
	    ctx.beginPath()
	    ctx.moveTo(mainPoints[0].x, mainPoints[0].y)
	    ctx.lineTo(mainPoints[2].x, mainPoints[2].y)
	    ctx.lineTo(mainPoints[3].x, mainPoints[3].y)
	    ctx.lineTo(mainPoints[1].x, mainPoints[1].y)
	    ctx.lineTo(mainPoints[0].x, mainPoints[0].y)

	    ctx.closePath()
	    ctx.stroke()
	    if (selected||reSized||rotated) {
	    	ctx.strokeStyle = "#00A0E9"
	    	ctx.fillStyle = "yellow"

	    	/* Rotate */

	    	var rotatePoint = CalcEngine.getRotatePoint(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3])

	    	ctx.beginPath()
	    	ctx.arc(rotatePoint.x, rotatePoint.y, smallPointRadius, 0, Math.PI * 2, false)
	    	ctx.closePath()
	    	ctx.fill()
	    	ctx.stroke()

	    	ctx.fillStyle = "white"
	    	/* Top left */
	    	ctx.beginPath()
	    	ctx.arc(mainPoints[1].x, mainPoints[1].y, bigPointRadius, 0, Math.PI * 2, false)
	    	ctx.closePath()
	    	ctx.fill()
	    	ctx.stroke()
	    	/* Top right */
	    	ctx.beginPath()
	    	ctx.arc(mainPoints[3].x, mainPoints[3].y, bigPointRadius, 0, Math.PI * 2, false)
	    	ctx.closePath()
	    	ctx.fill()
	    	ctx.stroke()

	    	/* Bottom left */
	    	ctx.beginPath()
	    	ctx.arc(mainPoints[0].x, mainPoints[0].y, bigPointRadius, 0, Math.PI * 2, false)
	    	ctx.closePath()
	    	ctx.fill()
	    	ctx.stroke()

	    	/* Bottom right */
	    	ctx.beginPath()
	    	ctx.arc(mainPoints[2].x, mainPoints[2].y, bigPointRadius, 0, Math.PI * 2, false)
	    	ctx.closePath()
	    	ctx.fill()
	    	ctx.stroke()

	    	minorPoints = CalcEngine.getAnotherFourPoint(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3])
	    	/* Top */
	    	ctx.beginPath()
	    	ctx.arc(minorPoints[0].x, minorPoints[0].y, smallPointRadius, 0, Math.PI * 2, false)
	    	ctx.closePath()
	    	ctx.fill()
	    	ctx.stroke()

	    	/* Bottom */
	    	ctx.beginPath()
	    	ctx.arc(minorPoints[1].x, minorPoints[1].y, smallPointRadius, 0, Math.PI * 2, false)
	    	ctx.closePath()
	    	ctx.fill()
	    	ctx.stroke()

	    	/* Left */
	    	ctx.beginPath()
	    	ctx.arc(minorPoints[2].x, minorPoints[2].y, smallPointRadius, 0, Math.PI * 2, false)
	    	ctx.closePath()
	    	ctx.fill()
	    	ctx.stroke()

	    	/* Right */
	    	ctx.beginPath()
	    	ctx.arc(minorPoints[3].x, minorPoints[3].y, smallPointRadius, 0, Math.PI * 2, false)
	    	ctx.closePath()
	    	ctx.fill()
	    	ctx.stroke()
	    }

	    ctx.restore()

	}
	function clickOnPoint(p) {
		selected = false
		reSized = false
		rotated = false
		clickedPoint = Qt.point(0, 0)
		if (CalcEngine.pointClickIn(mainPoints[0], p) || CalcEngine.pointClickIn(mainPoints[1], p) ||
		CalcEngine.pointClickIn(mainPoints[2], p) || CalcEngine.pointClickIn(mainPoints[3], p) ||
		CalcEngine.pointClickIn(minorPoints[0], p) || CalcEngine.pointClickIn(minorPoints[1], p) ||
		CalcEngine.pointClickIn(minorPoints[2], p) || CalcEngine.pointClickIn(minorPoints[3], p)) {
			var result =  true
			reSized = result
			clickedPoint = p
			return result
		}
		if (rotateOnPoint(p)) {
			var result = true
			rotated = true
			clickedPoint = p
			return result
		}
		if (CalcEngine.pointOnLine(mainPoints[0], mainPoints[1], p) || CalcEngine.pointOnLine(mainPoints[1], mainPoints[3], p) ||
		CalcEngine.pointOnLine(mainPoints[3], mainPoints[2], p) || CalcEngine.pointOnLine(mainPoints[2], mainPoints[0], p)) {
			var result = true
			selected = result
			clickedPoint = p
			return result
		}
	}

	function handleDrag(p) {
	    var delX = p.x - clickedPoint.x
	    var delY = p.y - clickedPoint.y
	    for (var i = 0; i < mainPoints.length; i++) {
	    	mainPoints[i] = Qt.point(mainPoints[i].x + delX, mainPoints[i].y + delY)
	    }

	    clickedPoint = p
	}
	function handleResize(p) {
		if (reSized) {
			var key = CalcEngine.resizePoint(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3], p)
			if (key == 0) { key = CalcEngine.resizeAnotherPoint(minorPoints[0], minorPoints[1],minorPoints[2],minorPoints[3], p) }
			if (key != 0) {
				/* if the mouse is not in the Resize point, points is undefined */
				var points = CalcEngine.reSizePointPosititon(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3], p, key)
				for (var i = 0; i < 4; i ++) { mainPoints[i] = points[i] }
			}
		}

		clickedPoint = p
	}
	function rotateOnPoint(p) {
		var rotatePoint = CalcEngine.getRotatePoint(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3])
		if (p.x >= rotatePoint.x - 5 && p.x <= rotatePoint.x + 5 && p.y >= rotatePoint.y - 5 && p.y <= rotatePoint.y + 5) {

			rotated = true
		} else {

			rotated = false
		}
		clickedPoint = rotatePoint
		return rotated
	}

	function handleRotate(p) {
		var centerInPoint = Qt.point((mainPoints[0].x + mainPoints[3].x) / 2, (mainPoints[0].y + mainPoints[3].y) / 2)
		var rotatePoint = CalcEngine.getRotatePoint(mainPoints[0], mainPoints[1], mainPoints[2], mainPoints[3])
		var angle = CalcEngine.calcutateAngle(clickedPoint, p, centerInPoint)
		for (var i = 0; i < 4; i++) {
			mainPoints[i] = CalcEngine.pointRotate(centerInPoint, mainPoints[i], angle)
		}

		clickedPoint = p
	}
}