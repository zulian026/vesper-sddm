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

    // Upper Center: Large Digital Clock & Date
    Item {
        id: upperArea
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: root.height * 0.14
        height: clockComponent.height

        Clock {
            id: clockComponent
            anchors.horizontalCenter: parent.horizontalCenter
            colors: root.themeColors
            horizontalAlignment: Text.AlignHCenter
            customClockFontSize: metrics.clockSizeEditorial
            customDateFontSize: metrics.dateSize
        }
    }

    // Lower Center: Compact Authentication Panel
    LoginPanel {
        id: loginPanel
        anchors.bottom: parent.bottom
        anchors.bottomMargin: metrics.marginVertical + 36
        anchors.horizontalCenter: parent.horizontalCenter
        panelWidth: metrics.panelWidth
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

    // Bottom Bar: Hostname (left) & Power Actions (right)
    Item {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 28
        height: 36

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
