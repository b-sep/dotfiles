import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import qs.common
import qs.components

// MPRIS now-playing. Left = play/pause, middle = next, scroll = prev/next,
// right = popup with cover art and controls. Hidden when no player exists.
BarButton {
    id: root

    readonly property var players: Mpris.players.values
    // Prefer whatever is playing; otherwise the first player that has a track.
    readonly property MprisPlayer player: players.find(p => p.isPlaying)
        ?? players.find(p => p.trackTitle !== "")
        ?? players[0] ?? null

    readonly property string title: player?.trackTitle ?? ""
    readonly property string artist: player?.trackArtist ?? ""

    function fmtTime(seconds) {
        if (!(seconds > 0)) return "0:00"
        var s = Math.floor(seconds)
        var h = Math.floor(s / 3600)
        var m = Math.floor(s / 60) % 60
        var ss = String(s % 60).padStart(2, "0")
        return h > 0 ? h + ":" + String(m).padStart(2, "0") + ":" + ss : m + ":" + ss
    }

    visible: player !== null && title !== ""
    fixedWidth: Math.min(content.implicitWidth + padding * 2, 380)
    padding: 8
    tooltip: artist !== "" ? title + " — " + artist : title

    onClicked: button => {
        if (button === Qt.RightButton) popup.toggle()
        else if (button === Qt.MiddleButton) player?.next()
        else player?.togglePlaying()
    }
    onWheel: delta => delta > 0 ? player?.previous() : player?.next()

    RowLayout {
        id: content
        anchors.centerIn: parent
        width: Math.min(implicitWidth, root.width - root.padding * 2)
        spacing: 6

        Text {
            text: Theme.icon(root.player?.isPlaying ? 0xF075A : 0xF03E4)
            color: root.player?.isPlaying ? Theme.accent : Theme.muted
            font.family: Theme.font
            font.pixelSize: Theme.iconSize
        }

        Text {
            Layout.fillWidth: true
            text: root.artist !== "" ? root.title + " · " + root.artist : root.title
            elide: Text.ElideRight
            color: root.player?.isPlaying ? Theme.fg : Theme.muted
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 1
        }
    }

    BarPopup {
        id: popup
        anchorItem: root

        // Mpris position is not pushed by players; poll it while visible.
        Timer {
            running: popup.visible && (root.player?.isPlaying ?? false)
            interval: 1000
            repeat: true
            triggeredOnStart: true
            onTriggered: root.player?.positionChanged()
        }

        RowLayout {
            spacing: 14

            Rectangle {
                implicitWidth: 150
                implicitHeight: 150
                color: Theme.bgAlt

                Text {
                    anchors.centerIn: parent
                    visible: art.status !== Image.Ready
                    text: Theme.icon(0xF075A)
                    color: Theme.muted
                    font.family: Theme.font
                    font.pixelSize: 56
                }

                Image {
                    id: art
                    anchors.fill: parent
                    source: root.player?.trackArtUrl ?? ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    sourceSize.width: 300
                    sourceSize.height: 300
                }
            }

            ColumnLayout {
                spacing: 4
                Layout.preferredWidth: 320

                Text {
                    Layout.fillWidth: true
                    text: root.title
                    elide: Text.ElideRight
                    color: Theme.fgBright
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                    font.bold: true
                }

                Text {
                    Layout.fillWidth: true
                    text: root.artist
                    visible: text !== ""
                    elide: Text.ElideRight
                    color: Theme.fg
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 1
                }

                Text {
                    Layout.fillWidth: true
                    text: root.player?.trackAlbum ?? ""
                    visible: text !== ""
                    elide: Text.ElideRight
                    color: Theme.muted
                    font.family: Theme.font
                    font.pixelSize: Theme.smallSize
                }

                Item { Layout.fillHeight: true }

                RowLayout {
                    spacing: 0

                    BarButton {
                        text: Theme.icon(0xF04AE)
                        opacity: root.player?.canGoPrevious ? 1 : 0.4
                        onClicked: root.player?.previous()
                    }
                    BarButton {
                        text: Theme.icon(root.player?.isPlaying ? 0xF03E4 : 0xF040A)
                        pixelSize: Theme.iconSize + 4
                        color: Theme.fgBright
                        onClicked: root.player?.togglePlaying()
                    }
                    BarButton {
                        text: Theme.icon(0xF04AD)
                        opacity: root.player?.canGoNext ? 1 : 0.4
                        onClicked: root.player?.next()
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: root.player?.identity ?? ""
                        color: Theme.muted
                        font.family: Theme.font
                        font.pixelSize: Theme.smallSize
                    }
                }
            }
        }

        ColumnLayout {
            visible: root.player?.lengthSupported ?? false
            Layout.fillWidth: true
            spacing: 2

            Slider {
                Layout.fillWidth: true
                value: root.player && root.player.length > 0 ? root.player.position / root.player.length : 0
                onMoved: v => {
                    if (root.player?.canSeek) root.player.position = v * root.player.length
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: root.fmtTime(root.player?.position ?? 0)
                    color: Theme.muted
                    font.family: Theme.font
                    font.pixelSize: Theme.smallSize
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: root.fmtTime(root.player?.length ?? 0)
                    color: Theme.muted
                    font.family: Theme.font
                    font.pixelSize: Theme.smallSize
                }
            }
        }
    }
}
