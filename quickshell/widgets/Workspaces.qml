import QtQuick
import Quickshell.Hyprland
import qs.common
import qs.components

// Workspaces 1-5 always, plus any other existing ones up to 10.
// Focused = number in the Hyprland border color, occupied = full opacity, empty = dimmed.
Row {
    id: root

    readonly property var ids: {
        var list = [1, 2, 3, 4, 5]
        var values = Hyprland.workspaces.values
        for (var i = 0; i < values.length; i++) {
            var id = values[i].id
            if (id > 0 && id <= 10 && list.indexOf(id) === -1) list.push(id)
        }
        return list.sort((a, b) => a - b)
    }

    function focusWorkspace(target) {
        Hyprland.dispatch("hl.dsp.focus({ workspace = \"" + target + "\" })")
    }

    Repeater {
        model: root.ids

        BarButton {
            required property int modelData

            readonly property var ws: Hyprland.workspaces.values.find(w => w.id === modelData)
            readonly property bool focused: Hyprland.focusedWorkspace?.id === modelData
            readonly property bool occupied: ws !== undefined && ws.toplevels.values.length > 0

            fixedWidth: 32
            text: modelData === 10 ? "0" : String(modelData)
            pixelSize: Theme.fontSize
            color: focused ? Theme.popupBorder : Theme.fg
            opacity: focused || occupied ? 1 : 0.45

            onClicked: root.focusWorkspace(modelData)
            onWheel: delta => root.focusWorkspace(delta > 0 ? "e-1" : "e+1")
        }
    }
}
