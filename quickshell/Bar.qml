import QtQuick
import Quickshell
import qs.common
import qs.widgets

// Layout inspired by the Omarchy 4 bar:
//   left: workspaces
//   center: clock + weather (always centered as a group), media + recording to their left
//   right: tray drawer, microphone, audio, night light, do-not-disturb
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
        anchors.right: center.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Media {}
        ScreenRecording {}
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

        Tray {}
        Microphone { audioWidget: audio }
        Audio { id: audio }
        NightLight {}
        DoNotDisturb {}
    }
}
