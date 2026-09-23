import QtQuick
import qs.common

// Icon/text slot in the bar: hover fill, tooltip, any-button click and wheel.
Item {
    id: root

    property string text: ""
    property color color: Theme.fg
    property int pixelSize: Theme.iconSize
    property string tooltip: ""
    property int padding: 6
    property int fixedWidth: -1
    readonly property alias hovered: mouse.containsMouse

    signal clicked(int button)
    signal wheel(int delta)

    implicitWidth: fixedWidth > 0 ? fixedWidth : label.implicitWidth + padding * 2
    implicitHeight: Theme.barHeight

    Rectangle {
        anchors.fill: parent
        color: Theme.fg
        opacity: mouse.containsMouse ? 0.08 : 0
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: root.color
        font.family: Theme.font
        font.pixelSize: root.pixelSize
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: m => root.clicked(m.button)
        onWheel: w => root.wheel(w.angleDelta.y)
        onContainsMouseChanged: {
            if (containsMouse && root.tooltip !== "") Ui.showTooltip(root)
            else Ui.hideTooltip(root)
        }
    }
}
