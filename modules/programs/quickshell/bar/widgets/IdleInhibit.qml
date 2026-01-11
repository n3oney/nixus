import QtQuick
import Quickshell.Wayland

import "/home/neoney/.config/quickshell/bar/config.js" as Config

Item {
    id: root
    
    property var panelWindow
    property bool active: false
    
    implicitWidth: icon.implicitWidth + 8
    implicitHeight: Config.barHeight
    
    IdleInhibitor {
        id: inhibitor
        window: panelWindow
        enabled: root.active
    }
    
    Text {
        id: icon
        anchors.centerIn: parent
        text: root.active ? "󰈈" : "󰈉"
        color: Config.foregroundColor
        opacity: mouseArea.containsMouse ? 1.0 : (root.active ? 1.0 : Config.mutedOpacity)
        font.family: "Symbols Nerd Font"
        font.pointSize: 14
        
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.active = !root.active
    }
}
