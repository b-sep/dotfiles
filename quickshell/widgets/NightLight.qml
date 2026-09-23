import QtQuick
import Quickshell
import Quickshell.Io
import qs.common
import qs.components

// hyprsunset night light toggle; hidden while the hyprsunset daemon isn't reachable.
BarButton {
    id: root

    property bool available: false
    property int temperature: 6500
    readonly property bool night: temperature < 6000

    visible: available
    text: Theme.icon(0xF050E)
    color: night ? Theme.yellow : Theme.fg
    tooltip: night ? "Desligar luz noturna" : "Luz noturna"

    // Off sets a neutral 6500K instead of `identity`: identity keeps reporting the
    // last temperature, so the state would read back as still on.
    onClicked: {
        var temp = night ? 6500 : 4000
        Quickshell.execDetached(["hyprctl", "hyprsunset", "temperature", String(temp)])
        temperature = temp
    }

    Process {
        id: check
        command: ["hyprctl", "hyprsunset", "temperature"]
        stdout: StdioCollector {
            onStreamFinished: {
                var m = text.match(/^\s*(\d+)/)
                root.available = m !== null
                if (m) root.temperature = parseInt(m[1])
            }
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
