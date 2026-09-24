import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.common
import qs.components

// Output volume. Left/middle = popup (master, devices, per-app mixer),
// right = mute, scroll = volume.
BarButton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource
    readonly property bool muted: sink?.audio?.muted ?? true
    readonly property real volume: sink?.audio?.volume ?? 0

    readonly property var nodes: Pipewire.nodes.values
    readonly property var sinks: nodes.filter(n => n.audio && n.isSink && !n.isStream)
    readonly property var sources: nodes.filter(n => n.audio && !n.isSink && !n.isStream)
    // Playback streams publish as sinks; capture streams (incl. our own meters) don't.
    readonly property var streams: nodes.filter(n => n.audio && n.isSink && n.isStream)

    function openPopup() { popup.open = true }

    function volumeIcon(isMuted, vol) {
        if (isMuted) return Theme.icon(0xF075F)
        if (vol < 0.34) return Theme.icon(0xF057F)
        if (vol < 0.67) return Theme.icon(0xF0580)
        return Theme.icon(0xF057E)
    }

    function setVolume(node, v) {
        if (!node?.audio) return
        node.audio.volume = Math.max(0, Math.min(1, v))
        if (node.audio.muted && v > 0) node.audio.muted = false
    }

    function deviceLabel(node) {
        return node.nickname || node.description || node.name
    }

    function streamLabel(node) {
        var app = node.ready ? node.properties["application.name"] : ""
        return app || node.description || node.name
    }

    PwObjectTracker {
        objects: popup.visible ? root.sinks.concat(root.sources, root.streams) : [root.sink]
    }

    visible: sink !== null
    text: volumeIcon(muted, volume)
    color: muted ? Theme.muted : Theme.fg
    tooltip: muted ? "Mudo" : "Volume " + Math.round(volume * 100) + "%"

    onClicked: button => {
        if (button === Qt.RightButton) { if (sink?.audio) sink.audio.muted = !sink.audio.muted }
        else popup.toggle()
    }
    onWheel: delta => setVolume(sink, volume + (delta > 0 ? 0.05 : -0.05))

    component VolumeRow: RowLayout {
        id: row
        required property PwNode node
        property string label: ""
        property string icon: ""

        Layout.fillWidth: true
        spacing: 8

        BarButton {
            text: row.icon !== "" ? row.icon : root.volumeIcon(row.node?.audio?.muted ?? false, row.node?.audio?.volume ?? 0)
            color: row.node?.audio?.muted ? Theme.muted : Theme.fg
            fixedWidth: 30
            onClicked: if (row.node?.audio) row.node.audio.muted = !row.node.audio.muted
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                visible: row.label !== ""
                text: row.label
                elide: Text.ElideRight
                color: Theme.fg
                font.family: Theme.font
                font.pixelSize: Theme.popupSmallSize + 1
            }

            Slider {
                Layout.fillWidth: true
                value: row.node?.audio?.volume ?? 0
                dimmed: row.node?.audio?.muted ?? false
                onMoved: v => root.setVolume(row.node, v)
            }
        }

        Text {
            Layout.preferredWidth: 44
            horizontalAlignment: Text.AlignRight
            text: Math.round((row.node?.audio?.volume ?? 0) * 100) + "%"
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: Theme.popupSmallSize + 1
        }
    }

    component DeviceRow: Item {
        id: dev
        required property PwNode node
        required property bool selected
        signal picked()

        Layout.fillWidth: true
        implicitHeight: 30

        Rectangle {
            anchors.fill: parent
            color: Theme.fg
            opacity: dev.selected ? 0.1 : devMouse.containsMouse ? 0.06 : 0
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.right: check.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: root.deviceLabel(dev.node)
            elide: Text.ElideRight
            color: dev.selected ? Theme.fgBright : Theme.fg
            font.family: Theme.font
            font.pixelSize: Theme.popupSmallSize + 1
        }

        Text {
            id: check
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: Theme.icon(0xF012C)
            visible: dev.selected
            color: Theme.accent
            font.family: Theme.font
            font.pixelSize: Theme.popupFontSize
        }

        MouseArea {
            id: devMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: dev.picked()
        }
    }

    BarPopup {
        id: popup
        anchorItem: root
        spacing: 8

        Item { implicitWidth: 380; implicitHeight: 0 }

        SectionLabel { text: "Saída" }

        VolumeRow { node: root.sink }

        Repeater {
            model: root.sinks
            DeviceRow {
                required property PwNode modelData
                node: modelData
                selected: modelData === root.sink
                onPicked: Pipewire.preferredDefaultAudioSink = modelData
            }
        }

        SectionLabel {
            Layout.topMargin: 6
            text: "Entrada"
            visible: root.sources.length > 0
        }

        VolumeRow {
            visible: root.source !== null
            node: root.source
            icon: Theme.icon(node?.audio?.muted ? 0xF036D : 0xF036C)
        }

        Repeater {
            model: root.sources
            DeviceRow {
                required property PwNode modelData
                node: modelData
                selected: modelData === root.source
                onPicked: Pipewire.preferredDefaultAudioSource = modelData
            }
        }

        SectionLabel {
            Layout.topMargin: 6
            text: "Aplicativos"
            visible: root.streams.length > 0
        }

        Repeater {
            model: root.streams
            VolumeRow {
                required property PwNode modelData
                node: modelData
                label: root.streamLabel(modelData)
            }
        }
    }
}
