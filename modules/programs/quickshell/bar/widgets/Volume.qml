import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

import "/home/neoney/.config/quickshell/bar/config.js" as Config

Item {
    id: root
    
    implicitWidth: volumeText.implicitWidth
    implicitHeight: Config.barHeight
    
    property var sink: Pipewire.defaultAudioSink
    property int volume: sink?.audio?.volume ? Math.round(sink.audio.volume * 100) : 0
    property bool muted: sink?.audio?.muted ?? false
    
    // Need to track the node to get audio properties
    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }
    
    Text {
        id: volumeText
        anchors.centerIn: parent
        text: root.volume + "%"
        color: Config.foregroundColor
        opacity: root.muted ? Config.mutedOpacity : 1.0
        font.family: Config.fontFamily
        font.pointSize: 12
        font.weight: Font.Bold
    }
}
