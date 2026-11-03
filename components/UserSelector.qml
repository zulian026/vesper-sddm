import QtQuick

Item {
    id: root

    property Colors colors
    property var userModel
    property string currentUsername: (userModel && userModel.lastUser) ? userModel.lastUser : "zyan"
    property string currentRealName: ""
    property string currentAvatar: ""
    property bool editorialMode: false

    signal userChanged(string username)

    implicitWidth: 320
    implicitHeight: root.editorialMode ? 36 : 64

    FontLoader {
        id: interFont
        source: "../assets/fonts/Inter.ttf"
    }

    function syncUser() {
        if (!userModel || userModel.count === 0) return;
        var idx = userModel.lastIndex;
        if (idx < 0) idx = 0;
        currentUsername = userModel.data(userModel.index(idx, 0), Qt.UserRole + 1) || userModel.lastUser || "";
        currentRealName = userModel.data(userModel.index(idx, 0), Qt.UserRole + 2) || currentUsername;
        currentAvatar = userModel.data(userModel.index(idx, 0), Qt.UserRole + 4) || "";
    }

    Component.onCompleted: syncUser()

    Row {
        id: mainRow
        anchors.left: root.editorialMode ? parent.left : undefined
        anchors.centerIn: root.editorialMode ? undefined : parent
        spacing: root.editorialMode ? 10 : 14

        // User Avatar / Initial circle
        Rectangle {
            width: root.editorialMode ? 32 : 48
            height: root.editorialMode ? 32 : 48
            radius: root.editorialMode ? 16 : 24
            color: root.editorialMode ? root.colors.surfaceAltTranslucent : root.colors.surfaceAlt
            border.width: 1
            border.color: root.editorialMode ? root.colors.borderSubtle : root.colors.border

            Image {
                id: faceImg
                anchors.fill: parent
                anchors.margins: 1
                source: root.currentAvatar
                visible: status === Image.Ready && root.currentAvatar.length > 0
                fillMode: Image.PreserveAspectCrop
            }

            Text {
                anchors.centerIn: parent
                visible: !faceImg.visible
                text: (root.currentRealName.length > 0) ? root.currentRealName.charAt(0).toUpperCase() : (root.currentUsername.length > 0 ? root.currentUsername.charAt(0).toUpperCase() : "U")
                font.family: interFont.font.family
                font.pixelSize: root.editorialMode ? 13 : 18
                font.weight: Font.DemiBold
                color: root.colors.accent
            }
        }

        // User Name display
        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: root.editorialMode ? 1 : 2

            Text {
                text: root.currentUsername.length > 0 ? root.currentUsername : "User"
                font.family: interFont.font.family
                font.pixelSize: root.editorialMode ? 17 : 16
                font.weight: root.editorialMode ? Font.DemiBold : Font.Medium
                color: root.colors.foreground
            }

            Text {
                text: (root.currentRealName.length > 0 && root.currentRealName !== root.currentUsername) 
                    ? root.currentRealName 
                    : "@" + root.currentUsername
                font.family: interFont.font.family
                font.pixelSize: root.editorialMode ? 11 : 12
                color: root.colors.muted
                opacity: root.editorialMode ? 0.65 : 1.0
            }
        }
    }

    // Optional cycling click when multiple users exist in the model
    MouseArea {
        anchors.fill: parent
        enabled: (root.userModel && root.userModel.count > 1)
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (!root.userModel || root.userModel.count <= 1) return;
            var nextIdx = ((root.userModel.lastIndex >= 0 ? root.userModel.lastIndex : 0) + 1) % root.userModel.count;
            root.userModel.lastIndex = nextIdx;
            root.syncUser();
            root.userChanged(root.currentUsername);
        }
    }
}
