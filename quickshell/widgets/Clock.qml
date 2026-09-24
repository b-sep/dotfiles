import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.components

// Weekday + time; click = calendar popup.
BarButton {
    id: root

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    readonly property date now: clock.date
    readonly property real yearProgress: {
        var start = new Date(now.getFullYear(), 0, 1)
        var end = new Date(now.getFullYear() + 1, 0, 1)
        return (now - start) / (end - start)
    }

    text: Theme.locale.toString(now, "dddd HH:mm")
    pixelSize: Theme.fontSize
    color: Theme.fgBright
    padding: 12

    onClicked: button => {
        if (button === Qt.LeftButton) popup.toggle()
    }

    component Label: Text {
        color: Theme.muted
        font.family: Theme.font
        font.pixelSize: Theme.popupSmallSize
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    BarPopup {
        id: popup
        anchorItem: root
        spacing: 14

        property int month: root.now.getMonth()
        property int year: root.now.getFullYear()

        function step(delta) {
            var d = new Date(year, month + delta, 1)
            month = d.getMonth()
            year = d.getFullYear()
        }
        function reset() {
            month = root.now.getMonth()
            year = root.now.getFullYear()
        }

        onOpenChanged: if (open) reset()

        // Header: big "23 de setembro".
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 14

            Text {
                text: Theme.icon(0xF00ED)
                color: Theme.fg
                font.family: Theme.font
                font.pixelSize: 36
            }
            Text {
                text: Theme.locale.toString(root.now, "d 'de' MMMM")
                color: Theme.fgBright
                font.family: Theme.font
                font.pixelSize: 32
                font.bold: true
            }
        }

        // Year progress.
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Label { text: root.now.getFullYear() }
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 6
                color: Theme.bgAlt
                Rectangle {
                    width: parent.width * root.yearProgress
                    height: parent.height
                    color: Theme.fg
                }
            }
            Label { text: Math.round(root.yearProgress * 100) + "%" }
        }

        GridLayout {
            columns: 2
            columnSpacing: 0
            rowSpacing: 6

            Label {
                Layout.preferredWidth: 36
                text: "S"
            }

            DayOfWeekRow {
                Layout.fillWidth: true
                locale: Theme.locale
                delegate: Label {
                    required property string shortName
                    text: shortName.replace(".", "").toUpperCase()
                    font.letterSpacing: 1
                }
            }

            WeekNumberColumn {
                Layout.preferredWidth: 36
                Layout.fillHeight: true
                month: popup.month
                year: popup.year
                locale: Theme.locale
                background: Item {
                    Rectangle {
                        anchors.right: parent.right
                        width: 1
                        height: parent.height
                        color: Theme.border
                    }
                }
                delegate: Label {
                    required property int weekNumber
                    text: weekNumber
                    opacity: 0.7
                }
            }

            MonthGrid {
                month: popup.month
                year: popup.year
                locale: Theme.locale
                spacing: 0
                implicitWidth: 7 * 48
                implicitHeight: 6 * 34

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    onWheel: w => popup.step(w.angleDelta.y > 0 ? -1 : 1)
                }

                delegate: Item {
                    required property var model
                    readonly property bool inMonth: model.month === popup.month

                    implicitWidth: 48
                    implicitHeight: 34

                    Rectangle {
                        anchors.centerIn: parent
                        width: 40
                        height: 28
                        color: "transparent"
                        border.color: Theme.fg
                        border.width: 1
                        visible: model.today
                    }

                    Text {
                        anchors.centerIn: parent
                        text: model.day
                        color: model.today ? Theme.fgBright
                             : inMonth ? Theme.fg : Theme.alpha(Theme.muted, 0.6)
                        font.family: Theme.font
                        font.pixelSize: Theme.popupFontSize - 1
                        font.bold: model.today
                    }
                }
            }
        }

        // Footer: month navigation; click the label to jump back to today.
        RowLayout {
            Layout.fillWidth: true

            BarButton {
                text: Theme.icon(0xF0141)
                onClicked: popup.step(-1)
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: Theme.locale.toString(new Date(popup.year, popup.month, 1), "MMMM yyyy").toUpperCase()
                color: Theme.muted
                font.family: Theme.font
                font.pixelSize: Theme.popupSmallSize
                font.letterSpacing: 2

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: popup.reset()
                    onWheel: w => popup.step(w.angleDelta.y > 0 ? -1 : 1)
                }
            }

            BarButton {
                text: Theme.icon(0xF0142)
                onClicked: popup.step(1)
            }
        }
    }
}
