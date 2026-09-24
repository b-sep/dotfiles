pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Screen recording state, pushed by capture-record:
//   qs -c bar ipc call recording set true|false
Singleton {
    id: root

    property bool active: false

    IpcHandler {
        target: "recording"
        function set(active: bool): void { root.active = active }
    }

    // pick up a recording already running when the shell (re)starts
    Process {
        running: true
        command: ["pgrep", "-x", "gpu-screen-recorder"]
        onExited: code => root.active = code === 0
    }
}
