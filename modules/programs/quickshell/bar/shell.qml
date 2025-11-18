import Quickshell // for PanelWindow
import Quickshell.Io
import QtQuick // for Text
import Quickshell.Wayland
import QtQuick.Layouts

import "/home/neoney/.config/quickshell/bar/config.js" as Config

Scope {
    id: root
    property string time

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            WlrLayershell.namespace: "bar-0"

            color: Config.backgroundColor

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 50

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    anchors.centerIn: parent
                    text: root.time
                    color: "white"
                    font.family: "monospace"
                    font.pointSize: 14
                    font.weight: 500
                }

                Text {
                    anchors.centerIn: parent
                    text: "Witam"
                    font.pointSize: 10
                    font.weight: 500
                    color: "#80ffffff"
                }
            }
        }
    }

    Process {
        id: dateProc
        command: ["date", "+%H:%M:%S"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.time = this.text
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: dateProc.running = true
    }
}
