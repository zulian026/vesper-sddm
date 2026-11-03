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

    // Top-Left: Discrete Independent Clock & Date
    Item {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 36
        width: 220
        height: 60

        Clock {
            anchors.left: parent.left
            colors: root.themeColors
            horizontalAlignment: Text.AlignLeft
            customClockFontSize: 36
            customDateFontSize: 12
        }
    }

    // Top-Right: Session & Keyboard Selectors
    Row {
        id: topBar
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 36
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

    // Center: Compact Floating Card
    LoginPanel {
        id: loginPanel
        anchors.centerIn: parent
        panelWidth: metrics.panelWidthCompact
        inputHeight: 44
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

    // Bottom Bar: Power Actions
    PowerBar {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 36
        colors: root.themeColors
        sddmContext: root.sddmContext
    }
}
