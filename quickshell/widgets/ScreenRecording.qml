import QtQuick
import Quickshell
import qs.common
import qs.components

// Screen recording indicator: only visible while capture-record is recording, blinking red.
// Click to stop the recording.
BarButton {
    id: root

    property bool blinkOff: false

    visible: Recording.active
    fixedWidth: 30
    pixelSize: Theme.iconSize - 2
    text: Theme.icon(0xF0EC2)
    color: Theme.red
    opacity: blinkOff ? 0.35 : 1
    Behavior on opacity { NumberAnimation { duration: 150 } }
    tooltip: "Parar gravação"

    // capture-record toggles: while recording, running it stops and saves
    onClicked: Quickshell.execDetached(["capture-record"])

    Timer {
        interval: 800
        running: Recording.active
        repeat: true
        onTriggered: root.blinkOff = !root.blinkOff
        onRunningChanged: root.blinkOff = false
    }
}
