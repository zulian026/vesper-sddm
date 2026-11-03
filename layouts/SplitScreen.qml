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

    LayoutMetrics {
        id: metrics
        viewportWidth: root.width
        viewportHeight: root.height
    }

    // Left Half: Clock, Date, and Ambient Branding
    Item {
        id: leftPane
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: parent.width * 0.52

        // Top-left Keyboard
        Row {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: metrics.marginVertical
            spacing: 10

            KeyboardSelector {
                colors: root.themeColors
                keyboardModel: root.sddmKeyboard
            }
        }

        // Center-Left Clock
        Column {
            anchors.centerIn: parent
            spacing: metrics.spacingMedium
            width: parent.width - (metrics.marginHorizontal * 2)

            Clock {
                anchors.horizontalCenter: parent.horizontalCenter
                colors: root.themeColors
                horizontalAlignment: Text.AlignHCenter
                customClockFontSize: metrics.clockSizeEditorial
                customDateFontSize: metrics.dateSize
            }
        }

        // Bottom-left Hostname
        Text {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.margins: metrics.marginVertical
            text: (root.sddmContext && root.sddmContext.hostName) ? root.sddmContext.hostName : "cachyos"
            color: root.themeColors.muted
            font.family: interFont.font.family
            font.pixelSize: 13
            opacity: 0.7
        }
    }

    // Subtle Vertical Separation Line
    Rectangle {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: leftPane.right
        width: 1
        color: root.themeColors.border
        opacity: 0.5
    }

    // Right Half: Authentication Card & Controls
    Item {
        id: rightPane
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: parent.width * 0.48

        // Top-right Session
        Row {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: metrics.marginVertical
            spacing: 10
            z: 50

            SessionSelector {
                id: sessionSel
                colors: root.themeColors
                sessionModel: root.sddmSessionModel
                onSessionChanged: function(index) {
                    loginPanel.sessionIndex = index;
                }
            }
        }

        // Centered Auth Panel
        LoginPanel {
            id: loginPanel
            anchors.centerIn: parent
            panelWidth: Math.min(380, rightPane.width - 64)
            inputHeight: metrics.inputHeight
            frameless: false
            showSessionInPanel: false
            colors: root.themeColors
            userModel: root.sddmUserModel
            sessionModel: root.sddmSessionModel
            keyboardModel: root.sddmKeyboard
            sessionIndex: sessionSel.currentIndex

            onLoginRequested: function(username, password, sessionIdx) {
                root.loginRequested(username, password, sessionIdx);
            }
        }

        // Bottom-right Power Actions
        PowerBar {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: metrics.marginVertical
            colors: root.themeColors
            sddmContext: root.sddmContext
        }
    }
}
