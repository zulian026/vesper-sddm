import QtQuick

Rectangle {
    id: root

    property string iconName: "power"
    property string tooltipText: ""
    property int iconSize: 18
    property Colors colors
    property bool isActive: false

    signal clicked()

    implicitWidth: 38
    implicitHeight: 38
    radius: 10

    color: {
        if (mouseArea.containsPress) return Qt.rgba(colors.accent.r, colors.accent.g, colors.accent.b, 0.25);
        if (mouseArea.containsMouse || root.isActive) return colors.surfaceAlt;
        return "transparent";
    }

    border.width: 1
    border.color: (mouseArea.containsMouse || root.isActive) ? colors.border : "transparent"

    Behavior on color {
        ColorAnimation { duration: 150 }
    }
    Behavior on border.color {
        ColorAnimation { duration: 150 }
    }

    Icon {
        anchors.centerIn: parent
        name: root.iconName
        size: root.iconSize
        color: (mouseArea.containsMouse || root.isActive) ? colors.accent : colors.foreground
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
