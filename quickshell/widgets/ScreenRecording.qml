import QtQuick
import Quickshell
import Quickshell.Io
import qs.common
import qs.components

// Screen recording toggle (screenshot-menu): dimmed while idle, blinking red while recording.
BarButton {
    id: root

    property bool recording: false
    property bool blinkOff: false

    fixedWidth: 30
    pixelSize: Theme.iconSize - 2
    text: Theme.icon(0xF0EC2)
    color: recording ? Theme.red : Theme.fg
    opacity: recording ? (blinkOff ? 0.35 : 1) : hovered ? 0.8 : 0.4
    Behavior on opacity { NumberAnimation { duration: 150 } }
    tooltip: recording ? "Parar gravação" : "Gravar tela"

    onClicked: {
        Quickshell.execDetached(["screenshot-menu", recording ? "stop" : "record"])
        recording = !recording
    }

    Timer {
        interval: 800
        running: root.recording
        repeat: true
        onTriggered: root.blinkOff = !root.blinkOff
        onRunningChanged: root.blinkOff = false
    }

    Process {
        id: check
        command: ["sh", "-c", "[ -f /tmp/gpu-screen-recorder.pid ] && kill -0 $(cat /tmp/gpu-screen-recorder.pid) 2>/dev/null"]
        onExited: code => root.recording = code === 0
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: check.running = true
    }
}
