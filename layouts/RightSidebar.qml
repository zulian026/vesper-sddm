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

    // Top Left indicator on wallpaper side
    Row {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 32
        spacing: 12
        z: 10

        KeyboardSelector {
            colors: root.themeColors
            keyboardModel: root.sddmKeyboard
        }
    }

    // Elevated Right Sidebar Container
    Rectangle {
        id: sidebar
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: Math.min(460, Math.max(380, root.width * 0.32))
        color: root.themeColors.surfaceTranslucent
        border.width: 1
        border.color: root.themeColors.border

        // Left border highlight
        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: 1
            color: root.themeColors.border
        }

        Item {
            anchors.fill: parent
            anchors.margins: metrics.marginVertical

            Column {
                anchors.centerIn: parent
                width: parent.width - 48
                spacing: metrics.spacingLarge

                // Clock inside sidebar
                Clock {
                    anchors.horizontalCenter: parent.horizontalCenter
                    colors: root.themeColors
                    horizontalAlignment: Text.AlignHCenter
                    customClockFontSize: metrics.clockSizeStandard
                    customDateFontSize: metrics.dateSize
                }

                // Frameless LoginPanel centered in sidebar
                LoginPanel {
                    id: loginPanel
                    anchors.horizontalCenter: parent.horizontalCenter
                    panelWidth: parent.width
                    inputHeight: metrics.inputHeight
                    frameless: true
                    showSessionInPanel: true
                    colors: root.themeColors
                    userModel: root.sddmUserModel
                    sessionModel: root.sddmSessionModel
                    keyboardModel: root.sddmKeyboard
                    sessionIndex: (root.sddmSessionModel && root.sddmSessionModel.lastIndex >= 0) ? root.sddmSessionModel.lastIndex : 0

                    onLoginRequested: function(username, password, sessionIdx) {
                        root.loginRequested(username, password, sessionIdx);
                    }
                }
            }

            // Power Actions at bottom of sidebar
            PowerBar {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                colors: root.themeColors
                sddmContext: root.sddmContext
            }
        }
    }
}
