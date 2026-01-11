import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Services.SystemTray
import Quickshell.Widgets

import "/home/neoney/.config/quickshell/bar/config.js" as Config

RowLayout {
    id: root
    spacing: Config.spacing
    
    property var panelWindow
    
    Repeater {
        model: SystemTray.items
        
        Item {
            id: trayItem
            required property SystemTrayItem modelData
            
            implicitWidth: 28
            implicitHeight: 28
            
            IconImage {
                id: trayIcon
                anchors.centerIn: parent
                source: modelData.icon
                implicitSize: 22
                layer.enabled: true
                layer.effect: MultiEffect {
                    brightness: 0.8
                }
            }
            
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) {
                        // Map coordinates from trayItem to window
                        var mapped = trayItem.mapToItem(null, mouse.x, mouse.y)
                        modelData.display(root.panelWindow, mapped.x, mapped.y)
                    } else {
                        modelData.activate()
                    }
                }
            }
        }
    }
}
