//@ pragma UseQApplication
//@ pragma IconTheme breeze-dark

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick

import "/home/neoney/.config/quickshell/bar/config.js" as Config

ShellRoot {
    Variants {
        model: Quickshell.screens.filter(s => s.name !== Config.secondaryMonitor)

        PanelWindow {
            id: barWindow
            required property var modelData
            screen: modelData
            
            // Find the Hyprland monitor matching this screen
            property var hyprlandMonitor: Hyprland.monitors.values.find(m => m.name === modelData.name)
            property var activeWorkspace: hyprlandMonitor?.activeWorkspace
            property bool isNoRoundingWorkspace: Config.noRoundingWorkspaces.includes(activeWorkspace?.id ?? -1)
            property bool isSingleWindow: (activeWorkspace?.toplevels?.values?.length ?? 0) === 1
            property bool isFullSize: isNoRoundingWorkspace || isSingleWindow

            WlrLayershell.namespace: "bar"

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: Config.barHeight + 2
            color: "transparent"

            Bar {
                panelWindow: barWindow
                isWorkspaceOne: barWindow.isFullSize
            }
        }
    }
}
