import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

import "/home/neoney/.config/quickshell/bar/config.js" as Config

Item {
    id: root
    
    // Only show if there's a battery device with valid percentage
    visible: UPower.displayDevice != null && UPower.displayDevice.percentage > 0
    implicitWidth: batteryText.implicitWidth
    implicitHeight: Config.barHeight
    
    property var device: UPower.displayDevice
    property int percentage: device ? Math.round(device.percentage) : 0
    property bool isCharging: device ? device.state === UPowerDeviceState.Charging : false
    property bool isCharged: device ? device.state === UPowerDeviceState.FullyCharged : false
    
    Text {
        id: batteryText
        anchors.centerIn: parent
        text: root.percentage + "%"
        color: root.isCharging ? Config.accentColor : 
               root.isCharged ? Config.base0B :
               root.percentage <= 20 ? Config.base08 : Config.foregroundColor
        font.family: Config.fontFamily
        font.pointSize: 12
        font.weight: Font.Bold
    }
}
