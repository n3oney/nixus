import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.DBusMenu
import "/home/neoney/.config/quickshell/bar/config.js" as Config

MouseArea {
    id: root
    required property QsMenuEntry entry
    property alias expanded: childrenRevealer.expanded
    property bool animating: childrenRevealer.animating || (childMenuLoader?.item?.animating ?? false)
    onExpandedChanged: {}
    onAnimatingChanged: {}

    signal close()

    // Map missing icon names to breeze equivalents
    function mapIcon(icon) {
        if (!icon || icon === "") return ""
        const iconName = icon.replace("image://icon/", "")
        const mappings = {
            "bluetooth-symbolic": "network-bluetooth-symbolic",
            "bluetooth-disabled-symbolic": "network-bluetooth-inactive-symbolic",
            "bluetooth-disconnected-symbolic": "network-bluetooth-inactive-symbolic",
            "bluetooth-active-symbolic": "network-bluetooth-activated-symbolic",
            "application-x-addon-symbolic": "extension-symbolic",
            "application-x-addon": "extension-symbolic"
        }
        if (mappings[iconName]) {
            return "image://icon/" + mappings[iconName]
        }
        return icon
    }

    implicitWidth: row.implicitWidth + 4
    implicitHeight: row.implicitHeight + 4

    hoverEnabled: true
    onClicked: {
        if (entry.hasChildren) childrenRevealer.expanded = !childrenRevealer.expanded
        else {
            entry.triggered()
            close()
        }
    }

    ColumnLayout {
        id: row
        anchors.fill: parent
        anchors.margins: 2
        spacing: 0

        RowLayout {
            id: innerRow

            Item {
                implicitWidth: 22
                implicitHeight: 22

                MenuCheckBox {
                    anchors.centerIn: parent
                    visible: entry.buttonType == QsMenuButtonType.CheckBox
                    checkState: entry.checkState
                }

                MenuRadioButton {
                    anchors.centerIn: parent
                    visible: entry.buttonType == QsMenuButtonType.RadioButton
                    checkState: entry.checkState
                }

                MenuChildrenRevealer {
                    id: childrenRevealer
                    anchors.centerIn: parent
                    visible: entry.hasChildren
                    onOpenChanged: entry.showChildren = open
                }
            }

            Text {
                text: entry.text
                color: entry.enabled ? Config.foregroundColor : Config.base03
            }

            Item {
                Layout.fillWidth: true
                implicitWidth: 22
                implicitHeight: 22

                IconImage {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    source: root.mapIcon(entry.icon)
                    visible: source != ""
                    implicitSize: parent.height
                }
            }
        }

        Loader {
            id: childMenuLoader
            Layout.fillWidth: true
            Layout.preferredHeight: active ? item.implicitHeight * childrenRevealer.progress : 0

            readonly property real widthDifference: {
                Math.max(0, (item?.implicitWidth ?? 0) - innerRow.implicitWidth)
            }
            Layout.preferredWidth: active ? innerRow.implicitWidth + (widthDifference * childrenRevealer.progress) : 0

            active: root.expanded || root.animating
            clip: true

            source: "MenuView.qml"
            onLoaded: {
                item.menu = entry
                item.close.connect(root.close)
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        visible: root.containsMouse || childrenRevealer.expanded
        z: -1

        color: Config.base02
        border.width: 1
        border.color: Config.base03
        radius: 5
    }
}
