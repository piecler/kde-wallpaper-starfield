/*
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Shapes
import Qt.labs.folderlistmodel
import org.kde.plasma.plasmoid

WallpaperItem {
    id: wallpaper

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "black"

        readonly property int    starCount:      wallpaper.configuration.StarCount
        readonly property double speedMult:      wallpaper.configuration.Speed
        readonly property int    direction:      wallpaper.configuration.Direction
        readonly property int    tinyW:          wallpaper.configuration.TinyStars
        readonly property int    smallW:         wallpaper.configuration.SmallStars
        readonly property int    mediumW:        wallpaper.configuration.MediumStars
        readonly property int    largeW:         wallpaper.configuration.LargeStars
        readonly property double colorThreshold: wallpaper.configuration.ColorThreshold
        readonly property int    nebulaCount:    wallpaper.configuration.NebulaCount
        readonly property double nebulaOpacity:  wallpaper.configuration.NebulaOpacity
        readonly property double nebulaOpacityMin: wallpaper.configuration.NebulaOpacityMin
        readonly property double nebulaSize:    wallpaper.configuration.NebulaSize
        readonly property double nebulaSpawn:   wallpaper.configuration.NebulaSpawnProbability
        readonly property double nebulaRotAvg:  wallpaper.configuration.NebulaRotSpeedAvg
        readonly property double nebulaRotVar:  wallpaper.configuration.NebulaRotSpeedVar
        readonly property bool   debugMode:     wallpaper.configuration.DebugMode
        readonly property int    shipCount:     wallpaper.configuration.ShipCount
        readonly property double shipSpawn:     wallpaper.configuration.ShipSpawnProbability
        readonly property int    shipSize:      wallpaper.configuration.ShipSize
        readonly property double shipSpeed:     wallpaper.configuration.ShipSpeed

        readonly property bool isYAxis: direction === 0 || direction === 1

        // ── Star helpers ──────────────────────────────────────────────────────

        function randomRadius() {
            var total = tinyW + smallW + mediumW + largeW
            if (total === 0) return 0.5
            var r = Math.random() * total
            if (r < tinyW)   return 0.15 + Math.random() * 0.35
            r -= tinyW
            if (r < smallW)  return 0.50 + Math.random() * 0.80
            r -= smallW
            if (r < mediumW) return 1.30 + Math.random() * 0.70
            return                   2.00 + Math.random() * 1.50
        }

        function randomSpectralColor() {
            var v = Math.random(), r, g, b
            if      (v < 0.04) { r = 0.55 + Math.random()*0.15; g = 0.67 + Math.random()*0.12; b = 1.0 }
            else if (v < 0.22) { r = 0.78 + Math.random()*0.14; g = 0.86 + Math.random()*0.10; b = 1.0 }
            else if (v < 0.52) { r = 1.0;  g = 0.97 + Math.random()*0.03; b = 0.88 + Math.random()*0.12 }
            else if (v < 0.67) { r = 1.0;  g = 0.92 + Math.random()*0.06; b = 0.60 + Math.random()*0.18 }
            else if (v < 0.82) { r = 1.0;  g = 0.66 + Math.random()*0.14; b = 0.30 + Math.random()*0.14 }
            else               { r = 1.0;  g = 0.38 + Math.random()*0.18; b = 0.14 + Math.random()*0.12 }
            return Qt.rgba(r, g, b, 1.0)
        }

        function randomGreyColor() {
            var g = 0.72 + Math.random() * 0.28
            return Qt.rgba(g, g, g, 1.0)
        }

        // ── Debug helpers ─────────────────────────────────────────────────────

        function pad(val, width) {
            var s = Math.round(val).toString()
            while (s.length < width) s = " " + s
            return s
        }

        // ── Nebula helpers ────────────────────────────────────────────────────

        // 3-color palettes based on real emission line spectra
        function randomNebulaPalette() {
            var t = Math.floor(Math.random() * 5)
            if (t === 0) return [   // H II emission — Hα red, OIII teal, Hβ blue
                Qt.rgba(0.95, 0.14, 0.24, 1), Qt.rgba(0.04, 0.86, 0.72, 1), Qt.rgba(0.26, 0.42, 1.00, 1)]
            if (t === 1) return [   // Planetary — OIII teal, Hα red ring, Hβ blue
                Qt.rgba(0.00, 0.88, 0.82, 1), Qt.rgba(0.90, 0.10, 0.36, 1), Qt.rgba(0.14, 0.64, 0.96, 1)]
            if (t === 2) return [   // Supernova remnant — SII orange, Hα red, OIII teal
                Qt.rgba(1.00, 0.34, 0.04, 1), Qt.rgba(0.92, 0.08, 0.16, 1), Qt.rgba(0.06, 0.72, 0.92, 1)]
            if (t === 3) return [   // Wolf-Rayet bubble — HeII blue, OIII teal, He purple
                Qt.rgba(0.22, 0.32, 1.00, 1), Qt.rgba(0.00, 0.88, 0.76, 1), Qt.rgba(0.68, 0.18, 1.00, 1)]
            return [                // Reflection — cold scattered starlight blues
                Qt.rgba(0.34, 0.50, 1.00, 1), Qt.rgba(0.18, 0.32, 0.90, 1), Qt.rgba(0.58, 0.70, 1.00, 1)]
        }

        // ── Config-change reload ──────────────────────────────────────────────

        Connections {
            target: bg
            function onSpeedMultChanged()       { starsLoader.active   = false; starsLoader.active   = true
                                                  nebulasLoader.active = false; nebulasLoader.active = true
                                                  shipsLoader.active   = false; shipsLoader.active   = true }
            function onDirectionChanged()       { starsLoader.active   = false; starsLoader.active   = true
                                                  nebulasLoader.active = false; nebulasLoader.active = true
                                                  shipsLoader.active   = false; shipsLoader.active   = true }
            function onTinyWChanged()           { starsLoader.active = false; starsLoader.active = true }
            function onSmallWChanged()          { starsLoader.active = false; starsLoader.active = true }
            function onMediumWChanged()         { starsLoader.active = false; starsLoader.active = true }
            function onLargeWChanged()          { starsLoader.active = false; starsLoader.active = true }
            function onColorThresholdChanged()  { starsLoader.active = false; starsLoader.active = true }
            function onNebulaCountChanged()     { nebulasLoader.active = false; nebulasLoader.active = true }
            function onNebulaOpacityChanged()   { nebulasLoader.active = false; nebulasLoader.active = true }
            function onNebulaOpacityMinChanged(){ nebulasLoader.active = false; nebulasLoader.active = true }
            function onNebulaSizeChanged()      { nebulasLoader.active = false; nebulasLoader.active = true }
            function onNebulaSpawnChanged()     { nebulasLoader.active = false; nebulasLoader.active = true }
            function onNebulaRotAvgChanged()    { nebulasLoader.active = false; nebulasLoader.active = true }
            function onNebulaRotVarChanged()    { nebulasLoader.active = false; nebulasLoader.active = true }
            function onShipCountChanged()       { shipsLoader.active = false; shipsLoader.active = true }
            function onShipSpawnChanged()       { shipsLoader.active = false; shipsLoader.active = true }
            function onShipSizeChanged()        { shipsLoader.active = false; shipsLoader.active = true }
            function onShipSpeedChanged()       { shipsLoader.active = false; shipsLoader.active = true }
        }

        FolderListModel {
            id: shipFiles
            folder: Qt.resolvedUrl("../data/ships/")
            nameFilters: ["*.png"]
            showDirs: false
        }

        // ── Stars ─────────────────────────────────────────────────────────────

        Loader {
            id: starsLoader
            anchors.fill: parent
            active: bg.width > 0 && bg.height > 0
            sourceComponent: starsComponent
        }

        Component {
            id: starsComponent
            Item {
                anchors.fill: parent
                Repeater {
                    model: bg.starCount
                    delegate: Item {
                        id: star

                        property real  starRadius:  0
                        property color starColor:   "white"
                        property bool  hasGlow:     false
                        property real  starOpacity: 1.0
                        property real  speed:       30

                        readonly property real axisSpan: bg.isYAxis ? bg.height : bg.width
                        readonly property real crossMax: bg.isYAxis ? bg.width  : bg.height
                        readonly property real mainFrom: bg.direction === 0 ? axisSpan + 10 :
                                                         bg.direction === 1 ? -10 :
                                                         bg.direction === 2 ? -10 : axisSpan + 10
                        readonly property real mainTo:   bg.direction === 0 ? -10 :
                                                         bg.direction === 1 ? axisSpan + 10 :
                                                         bg.direction === 2 ? axisSpan + 10 : -10
                        readonly property real initMain: Math.random() * axisSpan

                        function respawn() {
                            starRadius  = bg.randomRadius()
                            hasGlow     = starRadius >= bg.colorThreshold
                            starColor   = hasGlow ? bg.randomSpectralColor() : bg.randomGreyColor()
                            starOpacity = 0.4 + Math.random() * 0.6
                            speed       = (15 + (starRadius / 3.5) * 70 + (Math.random() - 0.5) * 20) * bg.speedMult
                        }

                        Shape {
                            visible: star.hasGlow
                            anchors.centerIn: parent
                            width: star.starRadius * 12; height: star.starRadius * 12
                            ShapePath {
                                strokeColor: "transparent"
                                fillGradient: RadialGradient {
                                    centerX: star.starRadius * 6; centerY: star.starRadius * 6
                                    centerRadius: star.starRadius * 6; focalX: centerX; focalY: centerY
                                    GradientStop { position: 0.0; color: Qt.rgba(star.starColor.r, star.starColor.g, star.starColor.b, 0.50) }
                                    GradientStop { position: 0.4; color: Qt.rgba(star.starColor.r, star.starColor.g, star.starColor.b, 0.15) }
                                    GradientStop { position: 1.0; color: Qt.rgba(star.starColor.r, star.starColor.g, star.starColor.b, 0.00) }
                                }
                                PathAngleArc {
                                    centerX: star.starRadius * 6; centerY: star.starRadius * 6
                                    radiusX: star.starRadius * 6; radiusY: star.starRadius * 6
                                    startAngle: 0; sweepAngle: 360
                                }
                            }
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: star.starRadius * 2; height: star.starRadius * 2
                            radius: star.starRadius; color: star.starColor; opacity: star.starOpacity
                        }

                        SequentialAnimation {
                            id: starAnim
                            running: false
                            NumberAnimation {
                                target: star; property: bg.isYAxis ? "y" : "x"; to: star.mainTo
                                duration: Math.abs(star.initMain - star.mainTo) / star.speed * 1000
                                easing.type: Easing.Linear
                            }
                            SequentialAnimation {
                                loops: Animation.Infinite
                                ScriptAction { script: {
                                    star.respawn()
                                    if (bg.isYAxis) { star.x = Math.random() * star.crossMax; star.y = star.mainFrom }
                                    else            { star.y = Math.random() * star.crossMax; star.x = star.mainFrom }
                                }}
                                NumberAnimation {
                                    target: star; property: bg.isYAxis ? "y" : "x"; to: star.mainTo
                                    duration: (star.axisSpan + 20) / star.speed * 1000
                                    easing.type: Easing.Linear
                                }
                            }
                        }

                        Component.onCompleted: {
                            respawn()
                            if (bg.isYAxis) { x = Math.random() * crossMax; y = initMain }
                            else            { y = Math.random() * crossMax; x = initMain }
                            starAnim.start()
                        }
                    }
                }
            }
        }

        // ── Ships ─────────────────────────────────────────────────────────────

        Loader {
            id: shipsLoader
            anchors.fill: parent
            active: bg.width > 0 && bg.height > 0
            sourceComponent: shipsComponent
        }

        Component {
            id: shipsComponent
            Item {
                anchors.fill: parent
                Repeater {
                    model: bg.shipCount
                    delegate: Item {
                        id: ship

                        property string imageSource: ""
                        property real   shipSize:    60
                        property real   speed:       80
                        property bool   isActive:    true

                        // Animation parameters — plain mutable properties, set only in calcAnimParams().
                        // Kept out of the reactive binding graph so that shipSize changes during respawn()
                        // cannot update a running animation's `to` or `duration` mid-flight.
                        property real animFrom:     0
                        property real animTo:       0
                        property int  animDuration: 10000

                        readonly property real axisSpan: bg.isYAxis ? bg.height : bg.width
                        readonly property real crossMax: bg.isYAxis ? bg.width  : bg.height
                        readonly property real initMain: Math.random() * axisSpan
                        // PNG faces right; rotate for other travel directions
                        readonly property real baseRotation: bg.direction === 0 ? -90 :
                                                              bg.direction === 1 ?  90 :
                                                              bg.direction === 2 ?   0 : 180

                        function calcAnimParams() {
                            var half = shipSize / 2
                            var axis = axisSpan
                            if (bg.direction === 0 || bg.direction === 3) {
                                animFrom = axis + half
                                animTo   = -half
                            } else {
                                animFrom = -half
                                animTo   = axis + half
                            }
                            animDuration = Math.max(1, Math.round((axis + shipSize) / speed * 1000))
                        }

                        function respawn() {
                            shipSize    = bg.shipSize * (0.5 + Math.random() * 0.75)
                            speed       = bg.shipSpeed * (0.7 + Math.random() * 0.6) * bg.speedMult
                            isActive    = true
                            var n = shipFiles.count
                            if (n > 0) {
                                imageSource = "file://" + shipFiles.get(Math.floor(Math.random() * n), "filePath")
                            }
                            calcAnimParams()
                        }

                        Image {
                            source: ship.imageSource
                            width:  ship.shipSize
                            height: ship.shipSize
                            x: -ship.shipSize / 2
                            y: -ship.shipSize / 2
                            rotation: ship.baseRotation
                            opacity:  ship.isActive ? 1.0 : 0.0
                            smooth: true
                            Behavior on opacity { NumberAnimation { duration: 500 } }
                        }

                        SequentialAnimation {
                            id: shipAnim
                            running: false

                            // Lead-in: start from random position on screen, travel to exit edge
                            NumberAnimation {
                                target: ship; property: bg.isYAxis ? "y" : "x"
                                to: ship.animTo
                                duration: Math.max(1, Math.round(Math.abs(ship.initMain - ship.animTo) / ship.speed * 1000))
                                easing.type: Easing.Linear
                            }

                            SequentialAnimation {
                                loops: Animation.Infinite
                                ScriptAction { script: {
                                    if (Math.random() < bg.shipSpawn) {
                                        ship.respawn()   // updates animFrom/animTo/animDuration
                                    } else {
                                        ship.isActive = false
                                        // animFrom/animTo/animDuration keep previous values — still valid
                                    }
                                    if (bg.isYAxis) { ship.x = Math.random() * ship.crossMax; ship.y = ship.animFrom }
                                    else            { ship.y = Math.random() * ship.crossMax; ship.x = ship.animFrom }
                                }}
                                NumberAnimation {
                                    target: ship; property: bg.isYAxis ? "y" : "x"
                                    to: ship.animTo
                                    duration: ship.animDuration
                                    easing.type: Easing.Linear
                                }
                            }
                        }

                        Component.onCompleted: {
                            respawn()
                            if (Math.random() >= bg.shipSpawn) { isActive = false }
                            if (bg.isYAxis) { x = Math.random() * crossMax; y = initMain }
                            else            { y = Math.random() * crossMax; x = initMain }
                            shipAnim.start()
                        }

                        // Debug label pinned to screen-left, below all nebula rows
                        Text {
                            visible: bg.debugMode
                            z: 1000
                            x: -ship.x + 10
                            y: -ship.y + 28 + (bg.nebulaCount + index) * 14
                            color: ship.isActive ? "#00ffff" : "#008888"
                            font.family: "monospace"
                            font.pixelSize: 10
                            text: "Shp " + index + ": x=" + bg.pad(ship.x, 5) +
                                  "  y=" + bg.pad(ship.y, 5) +
                                  "  sz=" + bg.pad(ship.shipSize, 3) +
                                  "  " + (ship.isActive ? "ACTIVE" : "inactive")
                        }
                    }
                }
            }
        }

        // ── Nebulas ───────────────────────────────────────────────────────────

        Loader {
            id: nebulasLoader
            anchors.fill: parent
            active: bg.width > 0 && bg.height > 0
            sourceComponent: nebulasComponent
        }

        Component {
            id: nebulasComponent
            Item {
                anchors.fill: parent
                Repeater {
                    model: bg.nebulaCount
                    delegate: Item {
                        id: neb

                        // Mutable — re-randomised each respawn
                        property var  nebColors:     []
                        property var  blobs:         []
                        property real nebulaBase:    150
                        property real nebulaOpacity: 0.0
                        property real rotSpeed:      80000
                        property bool rotCW:         true
                        property real speed:         8
                        property bool isActive:      true
                        readonly property real diameter: nebulaBase * 2.2  // blob offset (0.35) + radius (0.75) = 1.1 × 2

                        // Fixed geometry
                        readonly property real axisSpan:   bg.isYAxis ? bg.height : bg.width
                        readonly property real crossMax:   bg.isYAxis ? bg.width  : bg.height
                        // Actual content radius: blob offset (0.35) + max blob radius (0.75) = 1.1 × nebulaBase
                        // Reactive: updates when nebulaBase changes in respawn()
                        readonly property real canvasHalf: nebulaBase * 1.1 + 20
                        readonly property real mainFrom:   bg.direction === 0 ? axisSpan + canvasHalf :
                                                           bg.direction === 1 ? -canvasHalf :
                                                           bg.direction === 2 ? -canvasHalf : axisSpan + canvasHalf
                        readonly property real mainTo:     bg.direction === 0 ? -canvasHalf :
                                                           bg.direction === 1 ? axisSpan + canvasHalf :
                                                           bg.direction === 2 ? axisSpan + canvasHalf : -canvasHalf
                        readonly property real initMain:   Math.random() * axisSpan

                        function respawn() {
                            nebulaBase    = 80 + Math.random() * bg.nebulaSize
                            nebulaOpacity = bg.nebulaOpacityMin +
                                            Math.random() * Math.max(0, bg.nebulaOpacity - bg.nebulaOpacityMin)
                            var secs = Math.max(5, bg.nebulaRotAvg + (Math.random() * 2 - 1) * bg.nebulaRotVar)
                            rotSpeed  = secs * 1000
                            rotCW     = Math.random() >= 0.5
                            speed     = (2 + Math.random() * 10) * bg.speedMult
                            nebColors = bg.randomNebulaPalette()
                            isActive  = true

                            var n = 5 + Math.floor(Math.random() * 4)   // 5–8 blobs
                            var b = []
                            for (var i = 0; i < n; i++) {
                                var angle = Math.random() * Math.PI * 2
                                var dist  = Math.random() * nebulaBase * 0.35
                                b.push({
                                    dx:       Math.cos(angle) * dist,
                                    dy:       Math.sin(angle) * dist,
                                    r:        nebulaBase * (0.30 + Math.random() * 0.45),
                                    colorIdx: Math.floor(Math.random() * 3),
                                    a:        0.38 + Math.random() * 0.32
                                })
                            }
                            blobs = b   // triggers onBlobsChanged → repaint + rotation restart
                        }

                        // Rotation wrapper — pure GPU transform, keeps canvas out of the rotation path.
                        // Sized to actual nebula content so texture memory scales with nebulaBase.
                        Item {
                            id: nebRotator
                            // diameter + 40px padding each side
                            width:  neb.diameter + 40
                            height: neb.diameter + 40
                            x: -width  / 2
                            y: -height / 2
                            opacity: neb.isActive ? neb.nebulaOpacity : 0
                            visible: opacity > 0

                            Behavior on opacity { NumberAnimation { duration: 1000; easing.type: Easing.InOutQuad } }

                            Canvas {
                                id: nebCanvas
                                anchors.fill: parent

                                onAvailableChanged: if (available && neb.blobs.length > 0) requestPaint()

                                onPaint: {
                                    var sz = width
                                    var cx = sz / 2, cy = sz / 2
                                    var ctx = getContext("2d")
                                    ctx.clearRect(0, 0, sz, sz)
                                    var bArr   = neb.blobs
                                    var colors = neb.nebColors
                                    if (!bArr || !colors || colors.length === 0) return
                                    for (var i = 0; i < bArr.length; i++) {
                                        var b    = bArr[i]
                                        var c    = colors[b.colorIdx] || Qt.rgba(1, 1, 1, 1)
                                        var r255 = Math.round(c.r * 255)
                                        var g255 = Math.round(c.g * 255)
                                        var b255 = Math.round(c.b * 255)
                                        var bx   = cx + b.dx
                                        var by   = cy + b.dy
                                        var grad = ctx.createRadialGradient(bx, by, 0, bx, by, b.r)
                                        grad.addColorStop(0,   "rgba(" + r255 + "," + g255 + "," + b255 + "," + b.a.toFixed(3) + ")")
                                        grad.addColorStop(0.5, "rgba(" + r255 + "," + g255 + "," + b255 + "," + (b.a * 0.3).toFixed(3) + ")")
                                        grad.addColorStop(1,   "rgba(" + r255 + "," + g255 + "," + b255 + ",0)")
                                        ctx.fillStyle = grad
                                        ctx.beginPath()
                                        ctx.arc(bx, by, b.r, 0, Math.PI * 2)
                                        ctx.fill()
                                    }
                                }
                            }
                        }

                        // Continuous rotation on the wrapper Item — pure GPU transform
                        NumberAnimation {
                            id: rotAnim
                            target: nebRotator
                            property: "rotation"
                            from: 0; to: 360
                            loops: Animation.Infinite
                            running: false
                        }

                        // Repaint and restart rotation (with correct direction) whenever blobs change
                        onBlobsChanged: {
                            nebCanvas.requestPaint()
                            rotAnim.stop()
                            nebRotator.rotation = 0
                            rotAnim.to       = neb.rotCW ? 360 : -360
                            rotAnim.duration = neb.rotSpeed
                            rotAnim.start()
                        }

                        // Position animation — mirrors the star pattern: one-shot lead-in, then infinite loop
                        SequentialAnimation {
                            id: nebAnim
                            running: false

                            // Lead-in: from wherever the nebula starts to off-screen
                            NumberAnimation {
                                target: neb; property: bg.isYAxis ? "y" : "x"
                                to: neb.mainTo
                                duration: Math.abs(neb.initMain - neb.mainTo) / neb.speed * 1000
                                easing.type: Easing.Linear
                            }

                            // Infinite loop: roll spawn probability, reposition, traverse
                            SequentialAnimation {
                                loops: Animation.Infinite
                                ScriptAction { script: {
                                    if (Math.random() < bg.nebulaSpawn) {
                                        neb.respawn()   // sets isActive = true, triggers rotation restart
                                    } else {
                                        neb.isActive = false   // hide; rotation keeps running
                                    }
                                    // Always reposition to entry edge for the next traverse
                                    if (bg.isYAxis) { neb.x = Math.random() * neb.crossMax; neb.y = neb.mainFrom }
                                    else            { neb.y = Math.random() * neb.crossMax; neb.x = neb.mainFrom }
                                }}
                                NumberAnimation {
                                    target: neb; property: bg.isYAxis ? "y" : "x"
                                    to: neb.mainTo
                                    duration: (neb.axisSpan + 2 * neb.canvasHalf) / neb.speed * 1000
                                    easing.type: Easing.Linear
                                }
                            }
                        }

                        Component.onCompleted: {
                            respawn()   // also triggers onBlobsChanged → rotAnim starts
                            // Honor spawn probability even on initial appearance
                            if (Math.random() >= bg.nebulaSpawn) {
                                isActive = false
                            }
                            if (bg.isYAxis) { x = Math.random() * crossMax; y = initMain }
                            else            { y = Math.random() * crossMax; x = initMain }
                            nebAnim.start()
                        }

                        // Debug label — offset by -neb.x/-neb.y to stay pinned at screen-left column
                        Text {
                            visible: bg.debugMode
                            z: 1000
                            x: -neb.x + 10
                            y: -neb.y + 28 + index * 14
                            color: neb.isActive ? "#00ff00" : "#888800"
                            font.family: "monospace"
                            font.pixelSize: 10
                            text: "Neb " + index + ": x=" + bg.pad(neb.x, 5) +
                                  "  y=" + bg.pad(neb.y, 5) +
                                  "  b=" + bg.pad(neb.nebulaBase, 3) +
                                  "  op=" + neb.nebulaOpacity.toFixed(2) +
                                  "  " + (neb.isActive ? "ACTIVE" : "inactive")
                        }
                    }
                }
            }
        }

        // Debug header — always top-left
        Text {
            visible: bg.debugMode
            z: 1000
            x: 10; y: 10
            color: "#00ff00"
            font.family: "monospace"
            font.pixelSize: 11
            text: "DEBUG — Nebula / Ship Positions"
        }

    }
}
