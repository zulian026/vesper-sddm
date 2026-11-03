import QtQuick

Rectangle {
    id: root

    property Colors colors
    property var userModel: null
    property var sessionModel: null
    property var keyboardModel: null
    property int sessionIndex: 0
    property string errorMessage: ""
    property bool isLoggingIn: false

    property real panelWidth: 360
    property real inputHeight: 46
    property bool frameless: false
    property bool editorialMode: false
    property bool showSessionInPanel: false

    readonly property bool hasUsers: (userModel !== null && userModel.count > 0)
    readonly property bool isActuallyFrameless: (root.frameless || root.editorialMode)

    signal loginRequested(string username, string password, int sessionIndex)
    signal sessionChanged(int sessionIndex)

    FontLoader {
        id: interFont
        source: "../assets/fonts/Inter.ttf"
    }

    width: root.panelWidth
    height: contentCol.height + (root.isActuallyFrameless ? 0 : 48)
    radius: root.isActuallyFrameless ? 0 : ((typeof config !== "undefined" && config.panelRadius) ? parseInt(config.panelRadius) : 14)
    color: root.isActuallyFrameless ? "transparent" : root.colors.surfaceTranslucent
    border.width: root.isActuallyFrameless ? 0 : 1
    border.color: root.isActuallyFrameless ? "transparent" : root.colors.border

    // Subtle drop shadow border simulation (only for framed cards)
    Rectangle {
        visible: !root.isActuallyFrameless
        anchors.fill: parent
        anchors.margins: -1
        radius: root.radius + 1
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(root.colors.border.r, root.colors.border.g, root.colors.border.b, 0.2)
        z: -1
    }

    // Shake animation for error feedback
    SequentialAnimation {
        id: errorShakeAnim
        NumberAnimation { target: root; property: "x"; to: root.x - 8; duration: 40; easing.type: Easing.OutQuad }
        NumberAnimation { target: root; property: "x"; to: root.x + 8; duration: 50; easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "x"; to: root.x - 6; duration: 45; easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "x"; to: root.x + 6; duration: 45; easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "x"; to: root.x - 2; duration: 40; easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "x"; to: root.x; duration: 40; easing.type: Easing.OutQuad }
    }

    function triggerError(msg) {
        root.isLoggingIn = false;
        root.errorMessage = msg || "Authentication failed";
        passwordBox.clear();
        errorShakeAnim.restart();
        passwordBox.forceFocus();
    }

    function triggerSuccess() {
        root.isLoggingIn = false;
        root.errorMessage = "";
    }

    function doLogin() {
        var user = root.hasUsers ? userSel.currentUsername : manualUserInput.text.trim();
        if (user.length === 0) {
            triggerError("Please enter a username");
            return;
        }
        root.isLoggingIn = true;
        root.errorMessage = "";
        root.loginRequested(user, passwordBox.text, root.sessionIndex);
    }

    Column {
        id: contentCol
        anchors.left: root.editorialMode ? parent.left : undefined
        anchors.centerIn: root.editorialMode ? undefined : parent
        width: root.isActuallyFrameless ? parent.width : (parent.width - 48)
        spacing: root.editorialMode ? 12 : 16

        // 1. User Identity Section
        UserSelector {
            id: userSel
            visible: root.hasUsers
            anchors.left: root.editorialMode ? parent.left : undefined
            anchors.horizontalCenter: root.editorialMode ? undefined : parent.horizontalCenter
            editorialMode: root.editorialMode
            colors: root.colors
            userModel: root.userModel
        }

        // Manual Username Input (fallback when userModel.count == 0)
        Rectangle {
            id: manualUserBox
            visible: !root.hasUsers
            width: parent.width
            height: root.inputHeight
            radius: (typeof config !== "undefined" && config.inputRadius) ? parseInt(config.inputRadius) : 8
            color: root.editorialMode ? root.colors.surfaceAltTranslucent : root.colors.surfaceAlt
            border.width: manualUserInput.activeFocus ? 1.5 : 1
            border.color: manualUserInput.activeFocus 
                ? root.colors.accent 
                : (root.editorialMode ? root.colors.borderSubtle : root.colors.border)

            Row {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 12
                spacing: 10

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "user"
                    size: 16
                    color: manualUserInput.activeFocus ? root.colors.accent : root.colors.muted
                }

                TextInput {
                    id: manualUserInput
                    width: parent.width - 40
                    height: parent.height
                    verticalAlignment: TextInput.AlignVCenter
                    font.family: interFont.font.family
                    font.pixelSize: 14
                    color: root.colors.foreground
                    clip: true
                    onAccepted: passwordBox.forceFocus()

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Enter username"
                        font.family: interFont.font.family
                        font.pixelSize: 14
                        color: root.colors.muted
                        visible: manualUserInput.text.length === 0
                    }
                }
            }
        }

        // 2. Password Input Field
        PasswordInput {
            id: passwordBox
            width: parent.width
            customHeight: root.inputHeight
            subtleMode: root.editorialMode
            colors: root.colors
            keyboardModel: root.keyboardModel
            onAccepted: root.doLogin()
            Component.onCompleted: {
                if (root.hasUsers) {
                    passwordBox.forceFocus();
                } else {
                    manualUserInput.forceActiveFocus();
                }
            }
        }

        // 3. Error Feedback Text
        Text {
            id: errorLabel
            anchors.left: root.editorialMode ? parent.left : undefined
            anchors.horizontalCenter: root.editorialMode ? undefined : parent.horizontalCenter
            width: parent.width
            horizontalAlignment: root.editorialMode ? Text.AlignLeft : Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: root.errorMessage
            font.family: interFont.font.family
            font.pixelSize: 12
            font.weight: Font.Medium
            color: root.colors.error
            visible: root.errorMessage.length > 0
            opacity: visible ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }
        }

        // 4. Editorial Mode: Integrated Quiet Action Row (Session Selector + Refined Submit)
        Item {
            id: editorialActionRow
            visible: root.editorialMode
            width: parent.width
            height: 34

            // Visually quiet Session Selector on the left
            SessionSelector {
                id: editorialSessionSel
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                quietMode: true
                colors: root.colors
                sessionModel: root.sessionModel
                currentIndex: root.sessionIndex
                onSessionChanged: function(index) {
                    root.sessionIndex = index;
                    root.sessionChanged(index);
                }
            }

            // Restrained Sign In Action Button on the right
            Rectangle {
                id: editorialSubmitBtn
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: 34
                width: editorialSubmitRow.width + 26
                radius: (typeof config !== "undefined" && config.inputRadius) ? parseInt(config.inputRadius) : 7
                color: editorialSubmitMouse.containsPress 
                    ? Qt.darker(root.colors.accent, 1.15) 
                    : (editorialSubmitMouse.containsMouse ? Qt.lighter(root.colors.accent, 1.08) : root.colors.accent)
                border.width: editorialSubmitBtn.activeFocus ? 1.5 : 0
                border.color: root.colors.foreground

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                Row {
                    id: editorialSubmitRow
                    anchors.centerIn: parent
                    spacing: 7

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.isLoggingIn ? "Signing in…" : "Sign In"
                        font.family: interFont.font.family
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: root.colors.accentForeground
                    }

                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: "arrow-right"
                        size: 13
                        color: root.colors.accentForeground
                        visible: !root.isLoggingIn
                    }
                }

                MouseArea {
                    id: editorialSubmitMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.doLogin()
                }

                Keys.onReturnPressed: root.doLogin()
                Keys.onEnterPressed: root.doLogin()
            }
        }

        // 5. Classic Mode: Standalone Session Selector
        SessionSelector {
            id: innerSessionSel
            visible: !root.editorialMode && root.showSessionInPanel
            anchors.horizontalCenter: parent.horizontalCenter
            colors: root.colors
            sessionModel: root.sessionModel
            currentIndex: root.sessionIndex
            onSessionChanged: function(index) {
                root.sessionIndex = index;
                root.sessionChanged(index);
            }
        }

        // 6. Classic Mode: Full-width Submit Button
        Rectangle {
            id: submitBtn
            visible: !root.editorialMode
            width: parent.width
            height: Math.max(42, root.inputHeight - 4)
            radius: (typeof config !== "undefined" && config.inputRadius) ? parseInt(config.inputRadius) : 8
            color: submitMouse.containsPress 
                ? Qt.darker(root.colors.accent, 1.15) 
                : (submitMouse.containsMouse ? Qt.lighter(root.colors.accent, 1.08) : root.colors.accent)

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            Row {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.isLoggingIn ? "Signing in…" : "Sign In"
                    font.family: interFont.font.family
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: root.colors.accentForeground
                }

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "arrow-right"
                    size: 15
                    color: root.colors.accentForeground
                    visible: !root.isLoggingIn
                }
            }

            MouseArea {
                id: submitMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.doLogin()
            }
        }
    }
}
