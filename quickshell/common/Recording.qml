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
        // [ -s ] guard: sh returns 0 for `kill -0 ""` when the file is missing
        command: ["sh", "-c", "f=\"$XDG_RUNTIME_DIR/capture-record.pid\"; [ -s \"$f\" ] && kill -0 \"$(cat \"$f\")\" 2>/dev/null"]
        onExited: code => root.active = code === 0
    }
}
