import QtQuick
import QtQuick.Layouts
import Quickshell.Io

import "/home/neoney/.config/quickshell/bar/config.js" as Config

Item {
    id: root
    
    property bool expanded: hoverArea.containsMouse || powerOffMouse.containsMouse || rebootMouse.containsMouse
    
    implicitWidth: layout.width
    implicitHeight: Config.barHeight
    
    // Invisible hover detection area - extends beyond visual content (must be before layout to be underneath)
    MouseArea {
        id: hoverArea
        anchors {
            fill: parent
            leftMargin: -10
            rightMargin: -10
        }
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }
    
    Row {
        id: layout
        anchors.centerIn: parent
        spacing: root.expanded ? 8 : 0
        
        Behavior on spacing { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        
        // Power off button
        Text {
            id: powerOff
            text: "󰐥"
            color: powerOffMouse.containsMouse ? Config.base08 : Config.foregroundColor
            opacity: powerOffMouse.containsMouse ? 1.0 : Config.mutedOpacity
            font.family: "Symbols Nerd Font"
            font.pointSize: 14
            
            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on opacity { NumberAnimation { duration: 150 } }
            
            MouseArea {
                id: powerOffMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: powerOffProc.running = true
            }
        }
        
        // Reboot button
        Text {
            id: reboot
            text: "󰜉"
            color: rebootMouse.containsMouse ? Config.base0D : Config.foregroundColor
            opacity: rebootMouse.containsMouse ? 1.0 : Config.mutedOpacity
            font.family: "Symbols Nerd Font"
            font.pointSize: 14
            width: root.expanded ? implicitWidth : 0
            clip: true
            
            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on opacity { NumberAnimation { duration: 150 } }
            Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            
            MouseArea {
                id: rebootMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: rebootProc.running = true
            }
        }
    }
    
    Process {
        id: powerOffProc
        command: ["poweroff"]
    }
    
    Process {
        id: rebootProc
        command: ["reboot"]
    }
}
