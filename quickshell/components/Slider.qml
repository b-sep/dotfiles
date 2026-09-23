import QtQuick
import qs.common

// Flat horizontal slider over 0..1; emits moved(value) while dragging or scrolling.
Item {
    id: root

    property real value: 0
    property bool dimmed: false

    signal moved(real value)

    implicitWidth: 240
    implicitHeight: 22

    function setFromX(x) {
        root.moved(Math.max(0, Math.min(1, x / width)))
    }

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 6
        color: Theme.bgAlt

        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, root.value))
            height: parent.height
            color: root.dimmed ? Theme.muted : Theme.accent
        }
    }

    Rectangle {
        x: Math.max(0, Math.min(root.width - width, track.width * root.value - width / 2))
        anchors.verticalCenter: parent.verticalCenter
        width: 14
        height: 14
        color: root.dimmed ? Theme.muted : Theme.fgBright
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        preventStealing: true
        onPressed: m => root.setFromX(m.x)
        onPositionChanged: m => { if (pressed) root.setFromX(m.x) }
        onWheel: w => root.moved(Math.max(0, Math.min(1, root.value + (w.angleDelta.y > 0 ? 0.05 : -0.05))))
    }
}
