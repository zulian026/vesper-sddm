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

    // Top Right Auxiliary: Keyboard Selector
    Row {
        id: topAux
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: metrics.marginVertical
        spacing: 12
        z: 50

        KeyboardSelector {
            colors: root.themeColors
            keyboardModel: root.sddmKeyboard
        }
    }

    // Main Left Column Container
    Item {
        id: leftColumn
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.topMargin: metrics.marginVertical
        anchors.bottomMargin: metrics.marginVertical
        anchors.leftMargin: metrics.marginHorizontal
        width: metrics.panelWidth

        // 1. Top-left: Minimal Editorial Wordmark
        Row {
            id: wordmarkRow
            anchors.top: parent.top
            anchors.left: parent.left
            spacing: 8
            opacity: 0.85

            Rectangle {
                width: 6
                height: 6
                radius: 3
                color: root.themeColors.accent
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "V E S P E R"
                font.family: interFont.font.family
                font.pixelSize: 11
                font.weight: Font.DemiBold
                color: root.themeColors.muted
            }
        }

        // 2. Upper-left: Large Digital Clock & Date
        Clock {
            id: clockComponent
            anchors.top: wordmarkRow.bottom
            anchors.topMargin: metrics.spacingMedium
            anchors.left: parent.left
            colors: root.themeColors
            horizontalAlignment: Text.AlignLeft
            customClockFontSize: metrics.clockSizeEditorial
            customDateFontSize: metrics.dateSize
        }

        // 3. Middle-left: Authentication Area
        Item {
            id: authArea
            anchors.top: clockComponent.bottom
            anchors.topMargin: metrics.spacingLarge
            anchors.left: parent.left
            anchors.right: parent.right
            height: loginPanel.height
            z: 20

            LoginPanel {
                id: loginPanel
                anchors.left: parent.left
                panelWidth: leftColumn.width
                inputHeight: metrics.inputHeight
                frameless: true
                editorialMode: true
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

        // 4. Bottom-left: Power Actions & Hostname
        Item {
            id: bottomArea
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 42

            Row {
                anchors.fill: parent
                spacing: 16

                PowerBar {
                    anchors.verticalCenter: parent.verticalCenter
                    colors: root.themeColors
                    sddmContext: root.sddmContext
                }

                Item { width: 1; height: 1 } // Spacer

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: (root.sddmContext && root.sddmContext.hostName) ? root.sddmContext.hostName : "cachyos"
                    color: root.themeColors.muted
                    font.family: interFont.font.family
                    font.pixelSize: 12
                    opacity: 0.6
                }
            }
        }
    }
}
