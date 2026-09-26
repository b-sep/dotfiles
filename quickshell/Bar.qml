import QtQuick
import Quickshell
import qs.common
import qs.widgets

PanelWindow {
    id: bar

    required property ShellScreen modelData

    screen: modelData
    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: Theme.barHeight
    color: Theme.bg

    Workspaces {
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
    }

    Row {
        id: center
        anchors.centerIn: parent

        Clock {}
        Weather {}
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.verticalCenter: parent.verticalCenter

        Media {}
        Tray {}
        ScreenRecording {}
        Dictation {}
        Microphone { audioWidget: audio }
        Audio { id: audio }
        Network {}
        NightLight {}
        DoNotDisturb {}
        Clipboard {}
    }
}
