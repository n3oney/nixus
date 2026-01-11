import QtQuick
import Quickshell.Io

import "/home/neoney/.config/quickshell/bar/config.js" as Config

Item {
    id: root
    
    // 0 = auto, 1 = force_high (day), 2 = force_low (night)
    property int state: 0
    property bool running: false
    
    visible: root.running
    implicitWidth: root.running ? icon.implicitWidth : 0
    implicitHeight: Config.barHeight
    
    Text {
        id: icon
        anchors.centerIn: parent
        // auto = sun-moon combo, force_high (day) = sun, force_low (night) = moon
        text: root.state === 0 ? "󰔎" : root.state === 1 ? "󰖙" : "󰖔"
        color: Config.foregroundColor
        opacity: mouseArea.containsMouse ? 1.0 : (root.state === 0 ? Config.subtleOpacity : 1.0)
        font.family: "Symbols Nerd Font"
        font.pointSize: 14
        
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            // Cycle through states by sending SIGUSR1 to wlsunset
            signalProc.running = true
        }
    }
    
    // Check if wlsunset is running
    Process {
        id: checkProc
        command: ["pidof", "wlsunset"]
        running: true
        onExited: (exitCode, exitStatus) => {
            root.running = (exitCode === 0)
        }
    }
    
    // Send signal to cycle state
    Process {
        id: signalProc
        command: ["pkill", "-SIGUSR1", "wlsunset"]
        onExited: {
            root.state = (root.state + 1) % 3
        }
    }
    
    // Poll for wlsunset status
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: checkProc.running = true
    }
}
