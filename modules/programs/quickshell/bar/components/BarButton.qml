import QtQuick
import QtQuick.Layouts

import "/home/neoney/.config/quickshell/bar/config.js" as Config

Item {
    id: root
    
    property alias text: label.text
    property alias icon: label.text
    property real fontSize: Config.fontSize
    property color textColor: Config.foregroundColor
    property real textOpacity: 1.0
    property bool hovered: mouseArea.containsMouse
    
    signal clicked()
    signal rightClicked()
    
    implicitWidth: label.implicitWidth + 16
    implicitHeight: Config.barHeight
    
    Text {
        id: label
        anchors.centerIn: parent
        color: root.textColor
        opacity: root.textOpacity
        font.family: Config.fontFamily
        font.pointSize: root.fontSize
        font.weight: 500
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                root.rightClicked()
            } else {
                root.clicked()
            }
        }
    }
}
