import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.common
import qs.components

// Clipboard history (cliphist, stored by the home-manager services.cliphist units).
// Click = popup with the history, newest first; clicking an entry puts it back on
// the clipboard (it also moves to the top, since cliphist dedupes on store).
BarButton {
    id: root

    // [{ line, text, image }]; `line` is the raw "id\tpreview" that cliphist decode takes
    property var entries: []

    function copy(entry) {
        Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | cliphist decode | wl-copy", "sh", entry.line])
        popup.close()
    }

    function wipe() {
        Quickshell.execDetached(["cliphist", "wipe"])
        entries = []
    }

    text: Theme.icon(0xF0A38)
    tooltip: "Área de transferência"

    onClicked: popup.toggle()

    Process {
        id: list
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.entries = text.split("\n").filter(line => line.indexOf("\t") > 0).map(line => {
                    var preview = line.slice(line.indexOf("\t") + 1)
                    // images are listed as "[[ binary data 12 KiB png 1920x1080 ]]"
                    var bin = preview.match(/^\[\[ binary data (.*) \]\]$/)
                    return { line: line, text: bin ? "Imagem · " + bin[1] : preview.trim(), image: bin !== null }
                })
            }
        }
    }

    BarPopup {
        id: popup
        anchorItem: root

        onOpenChanged: if (open) list.running = true

        RowLayout {
            Layout.preferredWidth: 420
            spacing: 8

            SectionLabel { text: "Histórico" }
            Item { Layout.fillWidth: true }
            Text {
                visible: root.entries.length > 0
                text: "Limpar"
                color: wipeMouse.containsMouse ? Theme.red : Theme.muted
                font.family: Theme.font
                font.pixelSize: Theme.popupSmallSize

                MouseArea {
                    id: wipeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.wipe()
                }
            }
        }

        Text {
            visible: root.entries.length === 0
            text: "Nada copiado ainda"
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: Theme.popupSmallSize + 1
        }

        ListView {
            visible: root.entries.length > 0
            Layout.preferredWidth: 420
            Layout.preferredHeight: Math.min(contentHeight, 440)
            clip: true
            spacing: 4
            boundsBehavior: Flickable.StopAtBounds
            model: root.entries

            delegate: Rectangle {
                id: item
                required property var modelData
                required property int index

                width: ListView.view.width
                implicitHeight: label.implicitHeight + 16
                color: itemMouse.containsMouse ? Theme.alpha(Theme.fg, 0.08) : "transparent"
                border.color: index === 0 ? Theme.accent : Theme.border
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    Text {
                        visible: item.modelData.image
                        text: Theme.icon(0xF02E9)
                        color: Theme.muted
                        font.family: Theme.font
                        font.pixelSize: Theme.popupFontSize
                    }

                    Text {
                        id: label
                        Layout.fillWidth: true
                        text: item.modelData.text
                        color: index === 0 ? Theme.fgBright : Theme.fg
                        font.family: Theme.font
                        font.pixelSize: Theme.popupSmallSize + 1
                        textFormat: Text.PlainText
                        wrapMode: Text.WrapAnywhere
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    id: itemMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.copy(item.modelData)
                }
            }
        }
    }
}
