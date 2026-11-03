import QtQuick

Item {
    id: root

    property string name: "power"
    property int size: 18
    property color color: "#ffffff"

    implicitWidth: size
    implicitHeight: size

    FontLoader {
        id: tablerLoader
        source: "../assets/fonts/tabler-icons.ttf"
    }

    readonly property var glyphMap: ({
        "power": "\ueb0d",
        "restart": "\ueb13",
        "reload": "\ueb13",
        "sleep": "\ueaf8",
        "moon": "\ueaf8",
        "user": "\ueb4d",
        "lock": "\ueae2",
        "eye": "\uea9a",
        "eye-off": "\uecf0",
        "keyboard": "\uebd6",
        "session": "\uea5f",
        "chevron-down": "\uea5f",
        "caps-lock": "\uea05",
        "alert": "\uea05",
        "arrow-right": "\uea1f",
        "check": "\uea5e"
    })

    Text {
        anchors.centerIn: parent
        font.family: tablerLoader.font.family
        font.pixelSize: root.size
        color: root.color
        text: root.glyphMap[root.name] || "\ueae2"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
