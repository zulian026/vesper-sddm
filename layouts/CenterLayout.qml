import QtQuick
import "../components"

Item {
    id: root

    property Colors themeColors
    property var sddmUserModel: null
    property var sddmSessionModel: null
    property var sddmKeyboard: null
    property var sddmContext: null

    signal loginRequested(string username, string password, int sessionIndex)

    function triggerError(msg) {
        loginPanel.triggerError(msg);
    }

    function triggerSuccess() {
        loginPanel.triggerSuccess();
    }

    FontLoader {
        id: interFont
        source: "../assets/fonts/Inter.ttf"
    }

    // Top Bar: Session & Keyboard Selectors
    Row {
        id: topBar
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 28
        spacing: 10
        z: 50

        KeyboardSelector {
            colors: root.themeColors
            keyboardModel: root.sddmKeyboard
        }

        SessionSelector {
            id: sessionSel
            colors: root.themeColors
            sessionModel: root.sddmSessionModel
            onSessionChanged: function(index) {
                loginPanel.sessionIndex = index;
            }
        }
    }

    // Center Content: Clock, Date, and Login Panel
    Item {
        id: centerContainer
        width: 380
        anchors.centerIn: parent

        Column {
            anchors.centerIn: parent
            spacing: 28

            Clock {
                id: clockComponent
                anchors.horizontalCenter: parent.horizontalCenter
                colors: root.themeColors
                horizontalAlignment: Text.AlignHCenter
            }

            LoginPanel {
                id: loginPanel
                anchors.horizontalCenter: parent.horizontalCenter
                colors: root.themeColors
                userModel: root.sddmUserModel
                sessionModel: root.sddmSessionModel
                keyboardModel: root.sddmKeyboard
                sessionIndex: sessionSel.currentIndex

                onLoginRequested: function(username, password, sessionIdx) {
                    root.loginRequested(username, password, sessionIdx);
                }
            }
        }
    }

    // Bottom Bar: Hostname info (left) & Power Actions (right)
    Item {
        id: bottomBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 28
        height: 40

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: (root.sddmContext && root.sddmContext.hostName) ? root.sddmContext.hostName : "cachyos"
            color: root.themeColors.muted
            font.family: interFont.font.family
            font.pixelSize: 13
            opacity: 0.8
        }

        PowerBar {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            colors: root.themeColors
            sddmContext: root.sddmContext
        }
    }
}
