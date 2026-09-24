import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.common
import qs.components

// Wired connection status. Click = popup with ping, throughput, totals,
// addresses and a DNS provider switch. The provider is written to the
// NetworkManager connection profile (nmcli), so it survives reboots and rebuilds.
BarButton {
    id: root

    property string device: ""
    property string connection: ""
    property bool connected: false
    property string address: ""
    property string gateway: ""
    property int speed: 0
    property bool autoDns: true
    property var configuredDns: []
    property var nameservers: []

    property real ping: -1
    property real packetLoss: -1
    property real rxRate: 0
    property real txRate: 0
    property real rxTotal: 0
    property real txTotal: 0
    property real lastSample: 0

    readonly property var providers: [
        { name: "DHCP", v4: "", v6: "" },
        { name: "Cloudflare", v4: "1.1.1.1 1.0.0.1", v6: "2606:4700:4700::1111 2606:4700:4700::1001" },
        { name: "Google", v4: "8.8.8.8 8.8.4.4", v6: "2001:4860:4860::8888 2001:4860:4860::8844" },
        { name: "Quad9", v4: "9.9.9.9 149.112.112.112", v6: "2620:fe::fe 2620:fe::9" }
    ]

    readonly property string activeProvider: {
        if (autoDns && configuredDns.length === 0) return "DHCP"
        var first = configuredDns[0] ?? ""
        var match = providers.find(p => p.v4 !== "" && p.v4.split(" ")[0] === first)
        return match ? match.name : ""
    }

    function formatRate(bps) {
        if (bps >= 1e6) return (bps / 1e6).toFixed(1) + " MB/s"
        if (bps >= 1e3) return (bps / 1e3).toFixed(1) + " KB/s"
        return Math.round(bps) + " B/s"
    }

    function formatBytes(b) {
        if (b >= 1e9) return (b / 1e9).toFixed(2) + " GB"
        if (b >= 1e6) return (b / 1e6).toFixed(1) + " MB"
        return (b / 1e3).toFixed(0) + " KB"
    }

    function setProvider(p) {
        if (connection === "" || apply.running) return
        var ignore = p.v4 === "" ? "no" : "yes"
        apply.command = ["sh", "-c",
            "nmcli connection modify \"$1\" ipv4.dns \"$3\" ipv4.ignore-auto-dns \"$5\" " +
            "ipv6.dns \"$4\" ipv6.ignore-auto-dns \"$5\" && nmcli device reapply \"$2\"",
            "sh", connection, device, p.v4, p.v6, ignore]
        apply.running = true
    }

    text: Theme.icon(0xF1087)
    color: connected ? Theme.fg : Theme.red
    tooltip: connected ? "Ethernet · " + address : "Ethernet desconectada"

    onClicked: popup.toggle()

    // Device, addresses and DNS configuration of the first ethernet device.
    Process {
        id: status
        command: ["sh", "-c", `
            dev=$(nmcli -t -f DEVICE,TYPE device | awk -F: '$2=="ethernet"{print $1; exit}')
            [ -z "$dev" ] && exit 0
            echo "dev:$dev"
            echo "speed:$(cat /sys/class/net/$dev/speed 2>/dev/null)"
            nmcli -t -f GENERAL.STATE,GENERAL.CONNECTION,IP4.ADDRESS,IP4.GATEWAY device show "$dev"
            con=$(nmcli -g GENERAL.CONNECTION device show "$dev")
            if [ -n "$con" ]; then
                echo "cfgdns:$(nmcli -g ipv4.dns connection show "$con")"
                echo "ignoreauto:$(nmcli -g ipv4.ignore-auto-dns connection show "$con")"
            fi
            grep '^nameserver' /etc/resolv.conf | awk '{print "ns:" $2}'
        `]
        stdout: StdioCollector {
            onStreamFinished: {
                var ns = []
                root.address = ""
                root.gateway = ""
                root.connection = ""
                root.configuredDns = []
                text.split("\n").forEach(line => {
                    var i = line.indexOf(":")
                    if (i < 0) return
                    var key = line.slice(0, i)
                    var value = line.slice(i + 1).trim()
                    if (key === "dev") root.device = value
                    else if (key === "speed") root.speed = parseInt(value) || 0
                    else if (key === "GENERAL.STATE") root.connected = value.startsWith("100")
                    else if (key === "GENERAL.CONNECTION") root.connection = value
                    else if (key.startsWith("IP4.ADDRESS") && root.address === "") root.address = value.split("/")[0]
                    else if (key === "IP4.GATEWAY") root.gateway = value
                    else if (key === "cfgdns") root.configuredDns = value === "" ? [] : value.split(",")
                    else if (key === "ignoreauto") root.autoDns = value !== "yes"
                    else if (key === "ns") ns.push(value)
                })
                root.nameservers = ns
            }
        }
    }

    Process {
        id: apply
        onExited: status.running = true
    }

    // Interface byte counters → current rates and totals since boot.
    Process {
        id: traffic
        command: ["sh", "-c", "cat /sys/class/net/" + root.device + "/statistics/rx_bytes /sys/class/net/" + root.device + "/statistics/tx_bytes"]
        stdout: StdioCollector {
            onStreamFinished: {
                var v = text.trim().split("\n").map(Number)
                if (v.length < 2) return
                var now = Date.now()
                var dt = (now - root.lastSample) / 1000
                if (root.lastSample > 0 && dt > 0) {
                    root.rxRate = Math.max(0, (v[0] - root.rxTotal) / dt)
                    root.txRate = Math.max(0, (v[1] - root.txTotal) / dt)
                }
                root.rxTotal = v[0]
                root.txTotal = v[1]
                root.lastSample = now
            }
        }
    }

    Process {
        id: pinger
        command: ["ping", "-n", "-q", "-c", "5", "-i", "0.2", "-W", "1", "8.8.8.8"]
        stdout: StdioCollector {
            onStreamFinished: {
                var loss = text.match(/([\d.]+)% packet loss/)
                var rtt = text.match(/= [\d.]+\/([\d.]+)\//)
                root.packetLoss = loss ? parseFloat(loss[1]) : -1
                root.ping = rtt ? parseFloat(rtt[1]) : -1
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: status.running = true
    }

    Timer {
        interval: 1000
        running: popup.visible && root.device !== ""
        repeat: true
        triggeredOnStart: true
        onTriggered: traffic.running = true
        onRunningChanged: if (!running) root.lastSample = 0
    }

    Timer {
        interval: 5000
        running: popup.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!pinger.running) pinger.running = true
    }

    component Stat: RowLayout {
        property string label
        property string value

        Layout.fillWidth: true
        spacing: 8

        Text {
            text: parent.label
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: Theme.popupSmallSize + 1
        }
        Item { Layout.fillWidth: true }
        Text {
            text: parent.value
            color: Theme.fg
            font.family: Theme.font
            font.pixelSize: Theme.popupSmallSize + 1
        }
    }

    BarPopup {
        id: popup
        anchorItem: root

        RowLayout {
            spacing: 14

            Text {
                text: Theme.icon(0xF1087)
                color: root.connected ? Theme.fgBright : Theme.red
                font.family: Theme.font
                font.pixelSize: 30
            }

            ColumnLayout {
                spacing: 2
                Text {
                    text: root.connected ? root.connection : "Desconectado"
                    color: Theme.fgBright
                    font.family: Theme.font
                    font.pixelSize: Theme.popupFontSize
                    font.bold: true
                }
                SectionLabel {
                    text: root.device + (root.speed > 0 ? " · " + (root.speed >= 1000 ? root.speed / 1000 + " Gbps" : root.speed + " Mbps") : "")
                }
            }
        }

        GridLayout {
            Layout.preferredWidth: 400
            columns: 2
            columnSpacing: 28
            rowSpacing: 6

            Stat { label: "Ping"; value: root.ping >= 0 ? Math.round(root.ping) + " ms" : "—" }
            Stat { label: "Perda"; value: root.packetLoss >= 0 ? root.packetLoss + "%" : "—" }
            Stat { label: "Recebendo"; value: root.formatRate(root.rxRate) }
            Stat { label: "Enviando"; value: root.formatRate(root.txRate) }
            Stat { label: "Baixado"; value: root.formatBytes(root.rxTotal) }
            Stat { label: "Enviado"; value: root.formatBytes(root.txTotal) }
            Stat { label: "IP"; value: root.address || "—" }
            Stat { label: "Gateway"; value: root.gateway || "—" }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Theme.border
        }

        SectionLabel { text: "Provedor DNS" }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: root.providers

                Rectangle {
                    id: option
                    required property var modelData
                    readonly property bool selected: root.activeProvider === modelData.name

                    Layout.fillWidth: true
                    implicitHeight: 32
                    color: selected ? Theme.alpha(Theme.fg, 0.12) : optionMouse.containsMouse ? Theme.alpha(Theme.fg, 0.06) : "transparent"
                    border.color: selected ? Theme.fg : Theme.border
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: option.modelData.name
                        color: option.selected ? Theme.fgBright : Theme.fg
                        font.family: Theme.font
                        font.pixelSize: Theme.popupSmallSize + 1
                    }

                    MouseArea {
                        id: optionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.setProvider(option.modelData)
                    }
                }
            }
        }

        Text {
            Layout.fillWidth: true
            text: "Em uso: " + (root.nameservers.length > 0 ? root.nameservers.join(", ") : "—")
            wrapMode: Text.Wrap
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: Theme.popupSmallSize
        }
    }
}
