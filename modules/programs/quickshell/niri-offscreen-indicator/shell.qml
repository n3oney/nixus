import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

ShellRoot {
    id: root

    property int revision: 0
    property var windows: ({})     // { windowId: { workspaceId, column } }
    property var workspaces: ({})  // { workspaceId: { output, isActive, activeWindowId } }

    function syncModel(listModel, target) {
        while (listModel.count < target) listModel.append({});
        while (listModel.count > target) listModel.remove(listModel.count - 1);
    }

    function getDotsForOutput(outputName) {
        let result = { left: 0, right: 0 };

        let activeWsId = null;
        for (let wsId in workspaces) {
            let ws = workspaces[wsId];
            if (ws.isActive && ws.output === outputName) {
                activeWsId = parseInt(wsId);
                break;
            }
        }
        if (activeWsId == null) return result;

        let ws = workspaces[activeWsId];
        if (ws.activeWindowId == null) return result;

        let focusedWin = windows[ws.activeWindowId];
        if (!focusedWin) return null; // not in our map yet (event ordering), keep previous state
        let refColumn = focusedWin.column;

        for (let wid in windows) {
            let w = windows[wid];
            if (w.workspaceId !== activeWsId) continue;
            if (w.column < refColumn) result.left++;
            else if (w.column > refColumn) result.right++;
        }

        return result;
    }

    function handleEvent(data) {
        let event;
        try { event = JSON.parse(data); } catch (e) { return; }

        if (event.WorkspacesChanged)
            handleWorkspacesChanged(event.WorkspacesChanged.workspaces);
        else if (event.WindowsChanged)
            handleWindowsChanged(event.WindowsChanged.windows);
        else if (event.WorkspaceActivated)
            handleWorkspaceActivated(event.WorkspaceActivated);
        else if (event.WorkspaceActiveWindowChanged)
            handleWorkspaceActiveWindowChanged(event.WorkspaceActiveWindowChanged);
        else if (event.WindowOpenedOrChanged)
            handleWindowOpenedOrChanged(event.WindowOpenedOrChanged.window);
        else if (event.WindowClosed)
            handleWindowClosed(event.WindowClosed);
        else if (event.WindowLayoutsChanged)
            handleWindowLayoutsChanged(event.WindowLayoutsChanged.changes);
    }

    function handleWorkspacesChanged(wsList) {
        let ws = {};
        for (let w of wsList) {
            ws[w.id] = {
                output: w.output,
                isActive: w.is_active,
                activeWindowId: w.active_window_id ?? null
            };
        }
        workspaces = ws;
        revision++;
    }

    function handleWindowsChanged(winList) {
        let win = {};
        for (let w of winList) {
            if (w.is_floating) continue;
            let col = w.layout?.pos_in_scrolling_layout?.[0];
            if (col == null) continue;
            win[w.id] = { workspaceId: w.workspace_id, column: col };
        }
        windows = win;
        revision++;
    }

    function handleWorkspaceActivated(ev) {
        let target = workspaces[ev.id];
        if (!target) return;

        for (let wsId in workspaces) {
            if (workspaces[wsId].output === target.output)
                workspaces[wsId].isActive = false;
        }
        workspaces[ev.id].isActive = true;
        revision++;
    }

    function handleWorkspaceActiveWindowChanged(ev) {
        if (!workspaces[ev.workspace_id]) return;
        workspaces[ev.workspace_id].activeWindowId = ev.active_window_id ?? null;
        revision++;
    }

    function handleWindowOpenedOrChanged(w) {
        if (w.is_floating) {
            if (windows[w.id]) {
                delete windows[w.id];
                revision++;
            }
            return;
        }

        let col = w.layout?.pos_in_scrolling_layout?.[0];
        if (col == null) return;

        windows[w.id] = { workspaceId: w.workspace_id, column: col };
        revision++;
    }

    function handleWindowClosed(ev) {
        if (!windows[ev.id]) return;
        delete windows[ev.id];
        revision++;
    }

    function handleWindowLayoutsChanged(changes) {
        let changed = false;
        for (let [wid, layout] of changes) {
            if (!windows[wid]) continue;
            let col = layout.pos_in_scrolling_layout?.[0];
            if (col == null) continue;
            windows[wid].column = col;
            changed = true;
        }
        if (changed) revision++;
    }

    Process {
        command: ["niri", "msg", "-j", "event-stream"]
        running: true
        stdout: SplitParser {
            onRead: data => root.handleEvent(data)
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            property int leftDots: 0
            property int rightDots: 0

            function updateDots() {
                let d = root.getDotsForOutput(modelData.name);
                if (d === null) return;
                leftDots = d.left;
                rightDots = d.right;
            }

            property int _rev: root.revision
            on_RevChanged: updateDots()

            color: "transparent"

            WlrLayershell.namespace: "niri-offscreen-indicator"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            anchors { top: true; bottom: true; left: true; right: true }
            exclusiveZone: 0
            mask: Region {}

            ListModel { id: leftModel }
            ListModel { id: rightModel }

            onLeftDotsChanged: root.syncModel(leftModel, leftDots)
            onRightDotsChanged: root.syncModel(rightModel, rightDots)

            ListView {
                id: leftList
                x: 3
                y: (parent.height - displayHeight) / 2
                width: 6; height: contentHeight
                spacing: 6; interactive: false

                property real displayHeight: 0
                onContentHeightChanged: if (contentHeight > 0) displayHeight = contentHeight
                Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                model: leftModel
                add: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 150; easing.type: Easing.OutCubic } }
                remove: Transition { NumberAnimation { property: "opacity"; from: 1.0; to: 0; duration: 150; easing.type: Easing.OutCubic } }
                delegate: Rectangle { width: 6; height: 6; radius: 3; color: "white" }
            }

            ListView {
                id: rightList
                x: parent.width - width - 3
                y: (parent.height - displayHeight) / 2
                width: 6; height: contentHeight
                spacing: 6; interactive: false

                property real displayHeight: 0
                onContentHeightChanged: if (contentHeight > 0) displayHeight = contentHeight
                Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                model: rightModel
                add: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 150; easing.type: Easing.OutCubic } }
                remove: Transition { NumberAnimation { property: "opacity"; from: 1.0; to: 0; duration: 150; easing.type: Easing.OutCubic } }
                delegate: Rectangle { width: 6; height: 6; radius: 3; color: "white" }
            }
        }
    }
}
