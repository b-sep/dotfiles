pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// Tokyo Night palette + sizing tokens. The popup border follows Hyprland's
// general:col.active_border and refreshes whenever Hyprland reloads its config.
Singleton {
    id: root

    readonly property color bg: "#1a1b26"
    readonly property color bgAlt: "#24283b"
    readonly property color fg: "#a9b1d6"
    readonly property color fgBright: "#c0caf5"
    readonly property color muted: "#565f89"
    readonly property color border: "#414868"

    readonly property color cyan: "#0db9d7"
    readonly property color blue: "#7aa2f7"
    readonly property color yellow: "#e0af68"
    readonly property color red: "#f7768e"
    readonly property color green: "#9ece6a"
    // Highlight color everywhere (active workspace, sliders, checks, icons) follows
    // the Hyprland border, like the popup borders.
    readonly property color accent: popupBorder

    property color popupBorder: blue
    readonly property int popupBorderWidth: 2

    readonly property string font: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 17
    readonly property int iconSize: 19
    readonly property int smallSize: 14

    readonly property int popupFontSize: 15
    readonly property int popupSmallSize: 12

    readonly property int barHeight: 34
    readonly property int popupGap: 6
    readonly property int popupPadding: 26

    readonly property var locale: Qt.locale("pt_BR")

    // Nerd Font glyph by codepoint, so icons survive editors that strip private-use chars.
    function icon(cp) {
        return String.fromCodePoint(cp)
    }

    function alpha(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a)
    }

    Process {
        id: borderProc
        running: true
        command: ["hyprctl", "getoption", "general:col.active_border", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    // Hyprland stores colors as AARRGGBB, e.g. {"gradient": "ed33ffc8 0deg"};
                    // the first stop of a gradient is used.
                    var opt = JSON.parse(text)
                    var raw = String(opt.gradient ?? (opt.int !== undefined ? (opt.int >>> 0).toString(16) : ""))
                    var m = raw.match(/[0-9a-fA-F]{8}/)
                    if (m) {
                        var c = Qt.color("#" + m[0])
                        root.popupBorder = Qt.rgba(c.r, c.g, c.b, 1)
                    }
                } catch (e) {}
            }
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "configreloaded") borderProc.running = true
        }
    }
}
