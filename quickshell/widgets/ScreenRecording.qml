import QtQuick
import Quickshell
import qs.common
import qs.components

// Screen recording indicator: only visible while capture-record is recording, blinking red.
// Left click to stop the recording.
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
    tooltip: "Stop recording"

    // left click only: stops the recording; capture-record then saves, copies and notifies
    onClicked: button => {
        if (button === Qt.LeftButton) Quickshell.execDetached(["capture-record", "stop"])
    }

    Timer {
        interval: 800
        running: Recording.active
        repeat: true
        onTriggered: root.blinkOff = !root.blinkOff
        onRunningChanged: root.blinkOff = false
    }
}
