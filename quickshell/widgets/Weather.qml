import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.common
import qs.components

// Current weather from wttr.in (location auto-detected by IP when `location` is empty).
// Left = forecast popup, right = refresh.
BarButton {
    id: root

    // City name or "lat,lon"; empty = IP geolocation.
    property string location: ""

    property var data: null
    readonly property var current: data?.current_condition?.[0] ?? null
    readonly property var area: data?.nearest_area?.[0] ?? null
    readonly property var days: data?.weather ?? []

    function desc(entry) {
        return entry?.lang_pt?.[0]?.value ?? entry?.weatherDesc?.[0]?.value ?? ""
    }

    // WWO weather codes (used by wttr.in) → Material Design weather glyphs.
    function glyph(code, night) {
        var c = parseInt(code)
        if (c === 113) return Theme.icon(night ? 0xF0594 : 0xF0599)
        if (c === 116) return Theme.icon(night ? 0xF0F31 : 0xF0595)
        if (c === 119 || c === 122) return Theme.icon(0xF0590)
        if ([143, 248, 260].includes(c)) return Theme.icon(0xF0591)
        if ([200, 386, 389, 392, 395].includes(c)) return Theme.icon(0xF067E)
        if ([176, 263, 266, 293, 296, 353].includes(c)) return Theme.icon(0xF0F33)
        if ([299, 302, 305, 308, 356, 359].includes(c)) return Theme.icon(0xF0596)
        if ([281, 284, 311, 314, 317, 320, 362, 365].includes(c)) return Theme.icon(0xF067F)
        if ([350, 374, 377].includes(c)) return Theme.icon(0xF0592)
        if ([179, 182, 185, 227, 230, 323, 326, 329, 332, 335, 338, 368, 371].includes(c)) return Theme.icon(0xF0598)
        return Theme.icon(0xF0597)
    }

    function isNight() {
        var h = new Date().getHours()
        return h < 6 || h >= 18
    }

    function weekday(dateString) {
        var p = dateString.split("-")
        var d = new Date(parseInt(p[0]), parseInt(p[1]) - 1, parseInt(p[2]))
        var s = Theme.locale.toString(d, "ddd").replace(".", "")
        return s.charAt(0).toUpperCase() + s.slice(1)
    }

    visible: current !== null
    text: current ? glyph(current.weatherCode, isNight()) + " " + current.temp_C + "°" : ""
    pixelSize: Theme.fontSize
    tooltip: current ? desc(current) : ""

    onClicked: button => {
        if (button === Qt.RightButton) fetch.running = true
        else popup.toggle()
    }

    Process {
        id: fetch
        command: ["curl", "-sf", "--max-time", "15",
            "https://wttr.in/" + encodeURIComponent(root.location) + "?format=j1&lang=pt"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var parsed = JSON.parse(text)
                    if (parsed.current_condition) root.data = parsed
                } catch (e) {
                    // Keep the last good reading; wttr.in occasionally returns HTML errors.
                }
            }
        }
    }

    Timer {
        interval: 30 * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: fetch.running = true
    }

    BarPopup {
        id: popup
        anchorItem: root

        ColumnLayout {
            spacing: 2

            RowLayout {
                spacing: 6
                Text {
                    text: Theme.icon(0xF034E)
                    color: Theme.muted
                    font.family: Theme.font
                    font.pixelSize: Theme.smallSize + 1
                }
                Text {
                    text: {
                        var name = root.area?.areaName?.[0]?.value ?? ""
                        var region = root.area?.region?.[0]?.value ?? ""
                        return region !== "" && region !== name ? name + ", " + region : name
                    }
                    color: Theme.muted
                    font.family: Theme.font
                    font.pixelSize: Theme.smallSize + 1
                }
            }

            RowLayout {
                spacing: 14

                Text {
                    text: root.current ? root.glyph(root.current.weatherCode, root.isNight()) : ""
                    color: Theme.accent
                    font.family: Theme.font
                    font.pixelSize: 64
                }

                ColumnLayout {
                    spacing: 0
                    Text {
                        text: (root.current?.temp_C ?? "") + "°C"
                        color: Theme.fgBright
                        font.family: Theme.font
                        font.pixelSize: 38
                        font.bold: true
                    }
                    Text {
                        text: root.desc(root.current)
                        color: Theme.fg
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize
                    }
                }
            }
        }

        RowLayout {
            spacing: 16

            Repeater {
                model: [
                    { icon: 0xF050F, text: "Sensação " + (root.current?.FeelsLikeC ?? "") + "°" },
                    { icon: 0xF058C, text: (root.current?.humidity ?? "") + "%" },
                    { icon: 0xF059D, text: (root.current?.windspeedKmph ?? "") + " km/h" }
                ]

                Text {
                    required property var modelData
                    text: Theme.icon(modelData.icon) + " " + modelData.text
                    color: Theme.fg
                    font.family: Theme.font
                    font.pixelSize: Theme.smallSize + 1
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Theme.border
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            Repeater {
                model: root.days

                ColumnLayout {
                    required property var modelData
                    required property int index
                    readonly property var noon: modelData.hourly?.[4]

                    Layout.fillWidth: true
                    Layout.minimumWidth: 136
                    spacing: 4

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: index === 0 ? "Hoje" : root.weekday(modelData.date)
                        color: Theme.muted
                        font.family: Theme.font
                        font.pixelSize: Theme.smallSize + 1
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: root.glyph(noon?.weatherCode, false)
                        color: Theme.fg
                        font.family: Theme.font
                        font.pixelSize: 32
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: modelData.maxtempC + "° / " + modelData.mintempC + "°"
                        color: Theme.fg
                        font.family: Theme.font
                        font.pixelSize: Theme.smallSize + 1
                    }
                }
            }
        }
    }
}
