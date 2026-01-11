import QtQuick
import QtQuick.Layouts

import "/home/neoney/.config/quickshell/bar/config.js" as Config
import "widgets"

Item {
    id: root
    anchors.fill: parent
    
    property var panelWindow
    property bool isWorkspaceOne: false
    property bool ready: false
    
    Timer {
        interval: 100
        running: true
        onTriggered: root.ready = true
    }
    
    Rectangle {
        id: barRect
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: isWorkspaceOne ? 0 : -2
        
        width: isWorkspaceOne ? parent.width : parent.width - Config.gap * 2
        
        Behavior on width { enabled: root.ready; NumberAnimation { duration: Config.animationDuration / 2; easing.type: Easing.Bezier; easing.bezierCurve: Config.animationBezier } }
        Behavior on anchors.topMargin { enabled: root.ready; NumberAnimation { duration: Config.animationDuration / 2; easing.type: Easing.Bezier; easing.bezierCurve: Config.animationBezier } }
        
        color: Config.backgroundColor ?? "#1e1e2e"
        topLeftRadius: 0
        topRightRadius: 0
        bottomLeftRadius: isWorkspaceOne ? 0 : Config.rounding
        bottomRightRadius: isWorkspaceOne ? 0 : Config.rounding
        
        Behavior on bottomLeftRadius { enabled: root.ready; NumberAnimation { duration: Config.animationDuration / 2; easing.type: Easing.Bezier; easing.bezierCurve: Config.animationBezier } }
        Behavior on bottomRightRadius { enabled: root.ready; NumberAnimation { duration: Config.animationDuration / 2; easing.type: Easing.Bezier; easing.bezierCurve: Config.animationBezier } }
        
        // Border drawn with Canvas
        Canvas {
            id: borderCanvas
            anchors.fill: parent
            contextType: "2d"
            
            property real animatedRadius: isWorkspaceOne ? 0 : Config.rounding
            property real sideOpacity: isWorkspaceOne ? 0 : 1
            property color strokeColor: Config.accentColor ?? "#a6e3a1"
            
            Behavior on animatedRadius { enabled: root.ready; NumberAnimation { duration: Config.animationDuration / 2; easing.type: Easing.Bezier; easing.bezierCurve: Config.animationBezier } }
            Behavior on sideOpacity { enabled: root.ready; NumberAnimation { duration: Config.animationDuration / 2; easing.type: Easing.Bezier; easing.bezierCurve: Config.animationBezier } }
            
            onAnimatedRadiusChanged: requestPaint()
            onSideOpacityChanged: requestPaint()
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            onStrokeColorChanged: requestPaint()
            onAvailableChanged: if (available) requestPaint()
            
            onPaint: {
                var ctx = getContext("2d");
                if (!ctx) return;
                
                ctx.reset();
                ctx.lineWidth = 2;
                
                var r = animatedRadius;
                
                // Bottom line (always full opacity)
                ctx.strokeStyle = strokeColor;
                ctx.beginPath();
                ctx.moveTo(r, height - 1);
                ctx.lineTo(width - r, height - 1);
                ctx.stroke();
                
                // Side borders and corners (faded)
                if (r >= 1) {
                    ctx.strokeStyle = Qt.rgba(strokeColor.r, strokeColor.g, strokeColor.b, sideOpacity);
                    ctx.beginPath();
                    
                    // Left side + corner
                    ctx.moveTo(1, 0);
                    ctx.lineTo(1, height - r - 1);
                    ctx.arcTo(1, height - 1, r + 1, height - 1, r);
                    
                    // Right corner + side
                    ctx.moveTo(width - r - 1, height - 1);
                    ctx.arcTo(width - 1, height - 1, width - 1, height - r - 1, r);
                    ctx.lineTo(width - 1, 0);
                    
                    ctx.stroke();
                }
            }
        }
        
        // Left section
        RowLayout {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 16
            anchors.topMargin: root.isWorkspaceOne ? 0 : 2
            spacing: 8
            
            PowerMenu {}
            IdleInhibit { panelWindow: root.panelWindow }
        }
        
        // Center section
        Clock {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: root.isWorkspaceOne ? 0 : 1
        }
        
        // Right section
        RowLayout {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.rightMargin: 16
            anchors.topMargin: root.isWorkspaceOne ? 0 : 2
            spacing: 12
            
            SysTray { panelWindow: root.panelWindow }
            Sunset {}
            Battery {}
            Volume {}
        }
    }
}
