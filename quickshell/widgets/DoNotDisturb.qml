import QtQuick
import Quickshell
import Quickshell.Io
import qs.common
import qs.components

// Dunst do-not-disturb toggle: bell normally, crossed-out yellow bell while paused.
BarButton {
    id: root

    property bool dnd: false

    text: Theme.icon(dnd ? 0xF009B : 0xF009A)
    color: dnd ? Theme.yellow : Theme.fg
    tooltip: dnd ? "Não perturbe ativado" : "Não perturbe"

    onClicked: {
        Quickshell.execDetached(["dunstctl", "set-paused", "toggle"])
        dnd = !dnd
    }

    Process {
        id: check
        command: ["dunstctl", "is-paused"]
        stdout: StdioCollector {
            onStreamFinished: root.dnd = text.trim() === "true"
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: check.running = true
    }
}
