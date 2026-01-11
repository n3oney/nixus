import QtQuick
import QtQuick.Layouts
import Quickshell.Io

import "/home/neoney/.config/quickshell/bar/config.js" as Config

ColumnLayout {
    id: root
    spacing: 2
    
    property string time: ""
    property string date: ""
    
    Text {
        Layout.alignment: Qt.AlignHCenter
        text: root.time
        color: Config.foregroundColor
        font.family: Config.fontFamily
        font.pointSize: 12
        font.weight: Font.Bold
    }
    
    Text {
        Layout.alignment: Qt.AlignHCenter
        text: root.date
        color: Config.foregroundColor
        opacity: Config.subtleOpacity
        font.family: Config.fontFamily
        font.pointSize: 9
    }
    
    Process {
        id: timeProc
        command: ["date", "+%H:%M"]
        running: true
        stdout: SplitParser {
            onRead: data => root.time = data
        }
    }
    
    Process {
        id: dateProc
        command: ["date", "+%B %d"]
        running: true
        stdout: SplitParser {
            onRead: data => root.date = data
        }
    }
    
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            timeProc.running = true
            dateProc.running = true
        }
    }
}
