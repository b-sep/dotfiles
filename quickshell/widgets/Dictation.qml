import QtQuick
import Quickshell
import Quickshell.Io
import qs.common
import qs.components

// Dictation indicator (voxtype): only visible while recording (red) or transcribing (yellow).
// Left click stops and transcribes, right click cancels.
BarButton {
    id: root

    // idle | recording | transcribing | stopped (daemon not running)
    property string status: "stopped"
    readonly property bool recording: status === "recording"

    visible: recording || status === "transcribing"
    fixedWidth: 30
    text: Theme.icon(recording ? 0xF036C : 0xF051F)
    color: recording ? Theme.red : Theme.yellow
    tooltip: recording ? "Ditando · clique para transcrever, direito para cancelar" : "Transcrevendo"

    onClicked: button => {
        if (button === Qt.LeftButton && recording) Quickshell.execDetached(["voxtype", "record", "stop"])
        else if (button === Qt.RightButton) Quickshell.execDetached(["voxtype", "record", "cancel"])
    }

    // prints the current state, then one line per change; keeps running across
    // daemon restarts. pdeathsig: don't leave it orphaned when the bar restarts
    Process {
        id: follow
        running: true
        command: ["setpriv", "--pdeathsig", "TERM", "voxtype", "status", "--follow"]
        stdout: SplitParser {
            onRead: line => root.status = line.trim()
        }
        // voxtype missing or crashed: try again later
        onExited: {
            root.status = "stopped"
            retry.start()
        }
    }

    Timer {
        id: retry
        interval: 5000
        onTriggered: follow.running = true
    }
}
