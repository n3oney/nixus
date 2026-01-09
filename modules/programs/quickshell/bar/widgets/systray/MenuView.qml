import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.DBusMenu
import "/home/neoney/.config/quickshell/bar/config.js" as Config

ColumnLayout {
    id: root
    property alias menu: menuView.menu
    property Item animatingItem: null
    property bool animating: animatingItem != null

    signal close()
    signal submenuExpanded(item: var)

    QsMenuOpener { id: menuView }

    spacing: 0

    Repeater {
        model: menuView.children

        Loader {
            required property var modelData

            property var item: Component {
                MenuItem {
                    id: menuItem
                    entry: modelData

                    onClose: root.close()
                    onExpandedChanged: {
                        if (menuItem.expanded) root.submenuExpanded(menuItem)
                    }
                    onAnimatingChanged: {
                        if (menuItem.animating) {
                            root.animatingItem = menuItem
                        } else if (root.animatingItem == menuItem) {
                            root.animatingItem = null
                        }
                    }

                    Connections {
                        target: root

                        function onSubmenuExpanded(expandedItem) {
                            if (menuItem != expandedItem) menuItem.expanded = false
                        }
                    }
                }
            }

            property var separator: Component {
                Item {
                    implicitHeight: seprect.height + 6

                    Rectangle {
                        id: seprect

                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            right: parent.right
                        }

                        color: Config.base03
                        height: 1
                    }
                }
            }

            sourceComponent: modelData.isSeparator ? separator : item
            Layout.fillWidth: true
        }
    }
}
