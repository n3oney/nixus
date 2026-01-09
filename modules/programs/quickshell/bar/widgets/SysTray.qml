import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Widgets

import "/home/neoney/.config/quickshell/bar/config.js" as Config
import "systray"

RowLayout {
    id: root
    spacing: Config.spacing
    
    property var panelWindow
    
    // Map app IDs to themed icons (for apps that send ugly pixmaps)
    function getThemedIcon(item) {
        const id = item.id.toLowerCase()
        if (id.includes("blueman")) {
            return "image://icon/network-bluetooth-symbolic"
        }
        return item.icon
    }
    
    Repeater {
        model: SystemTray.items
        
        Item {
            id: trayItem
            required property SystemTrayItem modelData
            property bool menuOpen: false
            
            implicitWidth: 28
            implicitHeight: 28
            
            IconImage {
                id: trayIcon
                anchors.centerIn: parent
                source: root.getThemedIcon(modelData)
                implicitSize: 22
            }
            
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton && modelData.hasMenu) {
                        trayItem.menuOpen = !trayItem.menuOpen
                    } else if (mouse.button === Qt.MiddleButton) {
                        modelData.secondaryActivate()
                    } else {
                        modelData.activate()
                    }
                }
                
                onWheel: (event) => {
                    event.accepted = true
                    const points = event.angleDelta.y / 120
                    modelData.scroll(points, false)
                }
            }
            
            PopupWindow {
                id: menuPopup
                visible: trayItem.menuOpen
                anchor.window: root.panelWindow
                anchor.rect.x: trayItem.mapToItem(root.panelWindow.contentItem, 0, 0).x
                anchor.rect.y: root.panelWindow.height
                
                implicitWidth: menuRect.implicitWidth
                implicitHeight: menuRect.implicitHeight
                
                color: Config.base00
                
                Rectangle {
                    id: menuRect
                    implicitWidth: menuContent.implicitWidth + 16
                    implicitHeight: menuContent.implicitHeight + 16
                    color: Config.base00
                    border.width: 1
                    border.color: Config.base03
                    radius: Config.rounding
                    
                    MenuView {
                        id: menuContent
                        anchors.fill: parent
                        anchors.margins: 8
                        menu: trayItem.modelData.menu
                        onClose: trayItem.menuOpen = false
                    }
                }
                
                HyprlandFocusGrab {
                    id: focusGrab
                    active: trayItem.menuOpen
                    windows: [menuPopup, root.panelWindow]
                    onCleared: trayItem.menuOpen = false
                }
            }
        }
    }
}
