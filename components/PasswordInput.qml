import QtQuick

Rectangle {
    id: root

    property Colors colors
    property var keyboardModel: null
    property alias text: inputField.text
    property bool revealPassword: false
    property bool subtleMode: false
    property bool isCapsOn: (keyboardModel && typeof keyboardModel.capsLock !== "undefined") 
        ? keyboardModel.capsLock 
        : false
    property real customHeight: 0

    signal accepted()

    implicitWidth: 320
    implicitHeight: (customHeight > 0) ? customHeight : 48
    radius: (typeof config !== "undefined" && config.inputRadius) ? parseInt(config.inputRadius) : 8

    color: root.subtleMode ? root.colors.surfaceAltTranslucent : root.colors.surfaceAlt
    border.width: inputField.activeFocus ? 1.5 : 1
    border.color: inputField.activeFocus 
        ? root.colors.accent 
        : (inputHover.hovered ? root.colors.borderHover : (root.subtleMode ? root.colors.borderSubtle : root.colors.border))

    Behavior on border.color {
        ColorAnimation { duration: 150 }
    }
    Behavior on border.width {
        NumberAnimation { duration: 150 }
    }

    HoverHandler {
        id: inputHover
    }

    FontLoader {
        id: interFont
        source: "../assets/fonts/Inter.ttf"
    }

    function forceFocus() {
        inputField.forceActiveFocus();
    }

    function clear() {
        inputField.text = "";
    }

    // Connect to SDDM hardware capsLock state changes
    Connections {
        target: root.keyboardModel
        ignoreUnknownSignals: true
        function onCapsLockStateChanged() {
            if (root.keyboardModel) {
                root.isCapsOn = root.keyboardModel.capsLock;
            }
        }
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 8
        spacing: 10

        // Left Lock Icon
        Icon {
            anchors.verticalCenter: parent.verticalCenter
            name: "lock"
            size: 15
            color: inputField.activeFocus ? root.colors.accent : root.colors.muted
            opacity: inputField.activeFocus ? 1.0 : 0.75
            Behavior on color {
                ColorAnimation { duration: 150 }
            }
            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }
        }

        // Native TextInput
        TextInput {
            id: inputField
            width: parent.width - 76
            height: parent.height
            verticalAlignment: TextInput.AlignVCenter
            font.family: interFont.font.family
            font.pixelSize: 14
            color: root.colors.foreground
            selectionColor: root.colors.accent
            selectedTextColor: root.colors.accentForeground
            clip: true
            echoMode: root.revealPassword ? TextInput.Normal : TextInput.Password
            passwordCharacter: "•"

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Enter password"
                font.family: interFont.font.family
                font.pixelSize: 14
                color: root.colors.muted
                opacity: 0.65
                visible: inputField.text.length === 0
            }

            onAccepted: root.accepted()

            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_CapsLock) {
                    root.isCapsOn = !root.isCapsOn;
                }
            }
        }

        // CapsLock indicator badge
        Item {
            id: capsIndicator
            width: 20
            height: 20
            anchors.verticalCenter: parent.verticalCenter
            visible: root.isCapsOn

            Icon {
                anchors.centerIn: parent
                name: "caps-lock"
                size: 14
                color: root.colors.accent
            }
        }

        // Right Reveal Toggle Button
        IconButton {
            anchors.verticalCenter: parent.verticalCenter
            width: 28
            height: 28
            radius: 6
            iconName: root.revealPassword ? "eye-off" : "eye"
            iconSize: 14
            colors: root.colors
            onClicked: {
                root.revealPassword = !root.revealPassword;
                inputField.forceActiveFocus();
            }
        }
    }
}
