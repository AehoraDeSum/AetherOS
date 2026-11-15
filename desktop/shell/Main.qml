import QtQuick 6.0
import QtQuick.Window 6.0

Window {
    id: shell

    visible: true
    visibility: Window.FullScreen
    color: warmTheme ? "#15130f" : "#080d18"
    title: "Aether Shell Preview"

    property int tapCount: 0
    property string lastAction: "Ready"
    property string clockText: Qt.formatDateTime(new Date(), "HH:mm")
    property string page: "home"
    property bool warmTheme: false
    property bool showTouchPanel: true

    function pageTitle(name) {
        switch (name) {
        case "files": return "Files"
        case "settings": return "Settings"
        case "terminal": return "Terminal"
        case "about": return "About AetherOS"
        default: return "AetherOS"
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: shell.clockText = Qt.formatDateTime(new Date(), "HH:mm")
    }

    Rectangle {
        anchors.fill: parent
        color: shell.warmTheme ? "#15130f" : "#080d18"

        Rectangle {
            anchors.fill: parent
            opacity: 0.45
            gradient: Gradient {
                GradientStop { position: 0.0; color: shell.warmTheme ? "#463422" : "#17294a" }
                GradientStop { position: 0.52; color: shell.warmTheme ? "#15130f" : "#080d18" }
                GradientStop { position: 1.0; color: shell.warmTheme ? "#30241b" : "#15223b" }
            }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 44
            spacing: 30

            Item {
                width: parent.width
                height: 92

                Text {
                    text: "AETHEROS"
                    color: "#f4f7ff"
                    font.pixelSize: 28
                    font.weight: Font.DemiBold
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "RAM SESSION  ·  " + shell.clockText
                    color: "#aebbd3"
                    font.pixelSize: 20
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Column {
                width: parent.width
                spacing: 8

                Text {
                    text: "Hello, Aether"
                    color: "#f4f7ff"
                    font.pixelSize: 54
                    font.weight: Font.DemiBold
                }

                Text {
                    text: "A touch-first Linux shell, running on iPhone 11"
                    color: "#aebbd3"
                    font.pixelSize: 22
                    wrapMode: Text.Wrap
                    width: parent.width
                }
            }

            Rectangle {
                width: parent.width
                height: 150
                radius: 26
                color: "#182641"
                border.color: "#314767"
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 18

                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: "#59e0b1"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8
                        Text {
                            text: "Display and touch are online"
                            color: "#f4f7ff"
                            font.pixelSize: 24
                            font.weight: Font.Medium
                        }
                        Text {
                            text: "simpledrm  ·  software rendering  ·  " + shell.lastAction
                            color: "#aebbd3"
                            font.pixelSize: 17
                            wrapMode: Text.Wrap
                            width: shell.width - 160
                        }
                    }
                }
            }

            Text {
                text: "QUICK LAUNCH"
                color: "#8798b4"
                font.pixelSize: 16
                font.weight: Font.DemiBold
                font.letterSpacing: 2
            }

            Grid {
                id: launcher
                width: parent.width
                columns: 2
                spacing: 20

                Repeater {
                    model: [
                        { label: "Files", symbol: "▤", tint: "#24365b", page: "files" },
                        { label: "Settings", symbol: "⚙", tint: "#293957", page: "settings" },
                        { label: "Terminal", symbol: ">_", tint: "#263c4b", page: "terminal" },
                        { label: "About AetherOS", symbol: "✦", tint: "#3a315b", page: "about" }
                    ]

                    delegate: Rectangle {
                        required property var modelData
                        width: (launcher.width - launcher.spacing) / 2
                        height: 205
                        radius: 26
                        color: modelData.tint
                        border.color: "#405477"
                        border.width: 1

                        Column {
                            anchors.fill: parent
                            anchors.margins: 24
                            spacing: 16

                            Text {
                                text: modelData.symbol
                                color: "#dce8ff"
                                font.pixelSize: 38
                            }
                            Text {
                                text: modelData.label
                                color: "#f4f7ff"
                                font.pixelSize: 23
                                font.weight: Font.Medium
                                wrapMode: Text.Wrap
                                width: parent.width
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                shell.page = modelData.page
                                shell.lastAction = modelData.label + " opened"
                                shell.tapCount += 1
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 172
                radius: 28
                color: "#dce8ff"
                visible: shell.showTouchPanel

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        shell.tapCount += 1
                        shell.lastAction = "Touch input confirmed"
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 8
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Touch test  ·  " + shell.tapCount
                        color: "#111a2b"
                        font.pixelSize: 30
                        font.weight: Font.DemiBold
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Tap this panel to verify the live UI path"
                        color: "#344563"
                        font.pixelSize: 17
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 70
                radius: 20
                color: "#121c30"

                Text {
                    anchors.centerIn: parent
                    text: "Return to Linux console"
                    color: "#c7d4ea"
                    font.pixelSize: 18
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Qt.quit()
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        visible: shell.page !== "home"
        color: shell.warmTheme ? "#15130f" : "#080d18"

        Column {
            anchors.fill: parent
            anchors.margins: 44
            spacing: 28

            Row {
                width: parent.width
                height: 88
                spacing: 20

                Rectangle {
                    width: 112
                    height: 72
                    radius: 22
                    color: "#243653"
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        anchors.centerIn: parent
                        text: "‹  Home"
                        color: "#f4f7ff"
                        font.pixelSize: 20
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: shell.page = "home"
                    }
                }

                Text {
                    text: shell.pageTitle(shell.page)
                    color: "#f4f7ff"
                    font.pixelSize: 32
                    font.weight: Font.DemiBold
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Column {
                width: parent.width
                spacing: 20
                visible: shell.page === "files"

                Text {
                    text: "RAM session"
                    color: "#f4f7ff"
                    font.pixelSize: 28
                    font.weight: Font.DemiBold
                }
                Text {
                    width: parent.width
                    text: "This preview runs from memory. The iPhone's iOS storage is not mounted. A file browser will follow after storage access and permissions are defined."
                    color: "#b9c6dc"
                    font.pixelSize: 21
                    wrapMode: Text.Wrap
                    lineHeight: 1.25
                }
                Rectangle {
                    width: parent.width
                    height: 96
                    radius: 22
                    color: "#182641"
                    Text {
                        anchors.fill: parent
                        anchors.margins: 22
                        verticalAlignment: Text.AlignVCenter
                        text: "/opt/aetheros/shell  ·  preview files"
                        color: "#dce8ff"
                        font.pixelSize: 19
                    }
                }
            }

            Column {
                width: parent.width
                spacing: 20
                visible: shell.page === "settings"

                Text {
                    text: "Shell appearance"
                    color: "#f4f7ff"
                    font.pixelSize: 28
                    font.weight: Font.DemiBold
                }

                Rectangle {
                    width: parent.width
                    height: 112
                    radius: 22
                    color: "#182641"
                    Row {
                        anchors.fill: parent
                        anchors.margins: 22
                        Text {
                            text: "Warm color palette"
                            color: "#f4f7ff"
                            font.pixelSize: 21
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: shell.warmTheme ? "ON" : "OFF"
                            color: shell.warmTheme ? "#ffd39c" : "#aebbd3"
                            font.pixelSize: 20
                            font.weight: Font.DemiBold
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: shell.warmTheme = !shell.warmTheme
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 112
                    radius: 22
                    color: "#182641"
                    Row {
                        anchors.fill: parent
                        anchors.margins: 22
                        Text {
                            text: "Show touch test panel"
                            color: "#f4f7ff"
                            font.pixelSize: 21
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: shell.showTouchPanel ? "ON" : "OFF"
                            color: shell.showTouchPanel ? "#59e0b1" : "#aebbd3"
                            font.pixelSize: 20
                            font.weight: Font.DemiBold
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: shell.showTouchPanel = !shell.showTouchPanel
                    }
                }

                Text {
                    width: parent.width
                    text: "These preview settings change the shell only; they do not alter hardware controls or persistent storage."
                    color: "#8798b4"
                    font.pixelSize: 18
                    wrapMode: Text.Wrap
                }
            }

            Column {
                width: parent.width
                spacing: 20
                visible: shell.page === "terminal"

                Text {
                    text: "Linux serial console"
                    color: "#f4f7ff"
                    font.pixelSize: 28
                    font.weight: Font.DemiBold
                }
                Text {
                    width: parent.width
                    text: "The USB serial session is the real system terminal for this prototype. Exit Aether Shell to return to the Linux prompt."
                    color: "#b9c6dc"
                    font.pixelSize: 21
                    wrapMode: Text.Wrap
                    lineHeight: 1.25
                }
                Rectangle {
                    width: parent.width
                    height: 100
                    radius: 22
                    color: "#182641"
                    Text {
                        anchors.centerIn: parent
                        text: "USB serial  ·  root shell"
                        color: "#dce8ff"
                        font.pixelSize: 21
                    }
                }
                Rectangle {
                    width: parent.width
                    height: 104
                    radius: 22
                    color: "#dce8ff"
                    Text {
                        anchors.centerIn: parent
                        text: "Return to Linux console"
                        color: "#111a2b"
                        font.pixelSize: 21
                        font.weight: Font.DemiBold
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: Qt.quit()
                    }
                }
            }

            Column {
                width: parent.width
                spacing: 18
                visible: shell.page === "about"

                Text {
                    text: "A touch-first shell prototype"
                    color: "#f4f7ff"
                    font.pixelSize: 28
                    font.weight: Font.DemiBold
                }
                Text {
                    width: parent.width
                    text: "AetherOS is running as a RAM-based Linux session on iPhone 11. This screen uses Qt Quick software rendering over Weston and simpledrm."
                    color: "#b9c6dc"
                    font.pixelSize: 21
                    wrapMode: Text.Wrap
                    lineHeight: 1.25
                }
                Text {
                    text: "Touch taps received: " + shell.tapCount
                    color: "#59e0b1"
                    font.pixelSize: 21
                }
            }
        }
    }

    Shortcut {
        sequence: "Escape"
        onActivated: {
            if (shell.page !== "home")
                shell.page = "home"
            else
                Qt.quit()
        }
    }
}
