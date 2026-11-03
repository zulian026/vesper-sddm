import QtQuick

Item {
    id: root

    property Colors colors
    property var keyboardModel: null
    property string currentLayoutName: {
        if (keyboardModel && keyboardModel.layouts && keyboardModel.layouts.length > 0) {
            var idx = keyboardModel.currentLayout;
            if (idx >= 0 && idx < keyboardModel.layouts.length) {
                return keyboardModel.layouts[idx].toUpperCase();
            }
        }
        return "US";
    }

    readonly property bool showSelector: (typeof config !== "undefined" && config.showKeyboardSelect)
        ? (config.showKeyboardSelect === "true" || config.showKeyboardSelect === true)
        : true

    visible: root.showSelector && (keyboardModel ? (keyboardModel.enabled && keyboardModel.layouts && keyboardModel.layouts.length > 0) : true)

    implicitWidth: pillBtn.width
    implicitHeight: 34

    FontLoader {
        id: interFont
        source: "../assets/fonts/Inter.ttf"
    }

    Rectangle {
        id: pillBtn
        height: 34
        width: contentRow.width + 18
        radius: 8
        color: btnMouse.containsMouse ? root.colors.surfaceAlt : Qt.rgba(root.colors.surfaceAlt.r, root.colors.surfaceAlt.g, root.colors.surfaceAlt.b, 0.6)
        border.width: 1
        border.color: root.colors.border

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: 6

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                name: "keyboard"
                size: 14
                color: root.colors.muted
            }

            Text {
                text: root.currentLayoutName
                font.family: interFont.font.family
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: root.colors.foreground
            }
        }

        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.keyboardModel && root.keyboardModel.layouts && root.keyboardModel.layouts.length > 1) {
                    var nextIdx = (root.keyboardModel.currentLayout + 1) % root.keyboardModel.layouts.length;
                    root.keyboardModel.currentLayout = nextIdx;
                }
            }
        }
    }
}
