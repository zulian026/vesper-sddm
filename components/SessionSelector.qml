import QtQuick

Item {
    id: root

    property Colors colors
    property var sessionModel: null
    property int currentIndex: (sessionModel && sessionModel.lastIndex >= 0) ? sessionModel.lastIndex : 0
    property string currentSessionName: "Niri"
    property bool menuOpen: false
    property bool quietMode: false

    signal sessionChanged(int index)

    FontLoader {
        id: interFont
        source: "../assets/fonts/Inter.ttf"
    }

    function getSessionName(idx) {
        if (!sessionModel || sessionModel.count === 0) return "Niri";
        if (idx < 0 || idx >= sessionModel.count) idx = 0;
        var modelIndex = sessionModel.index(idx, 0);
        // Qt.UserRole + 4 holds the human-readable session name (e.g. "Niri", "Plasma")
        var name = sessionModel.data(modelIndex, Qt.UserRole + 4);
        if (!name || name.trim() === "") {
            var file = sessionModel.data(modelIndex, Qt.UserRole + 2) || "";
            name = file.replace(/^.*[\\\/]/, '').replace(/\.desktop$/, '');
        }
        return name || "Session";
    }

    function syncSessionName() {
        currentSessionName = getSessionName(currentIndex);
    }

    Component.onCompleted: syncSessionName()
    onCurrentIndexChanged: syncSessionName()

    implicitWidth: pillBtn.width
    implicitHeight: root.quietMode ? 32 : 34

    // Pill Button
    Rectangle {
        id: pillBtn
        height: root.quietMode ? 32 : 34
        width: contentRow.width + (root.quietMode ? 16 : 20)
        radius: root.quietMode ? 6 : 8
        color: btnMouse.containsMouse || root.menuOpen 
            ? root.colors.surfaceAlt 
            : (root.quietMode ? root.colors.surfaceAltTranslucent : Qt.rgba(root.colors.surfaceAlt.r, root.colors.surfaceAlt.g, root.colors.surfaceAlt.b, 0.6))
        border.width: 1
        border.color: root.menuOpen 
            ? root.colors.accent 
            : (btnMouse.containsMouse ? root.colors.border : (root.quietMode ? root.colors.borderSubtle : root.colors.border))

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
        Behavior on border.color {
            ColorAnimation { duration: 150 }
        }

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: root.quietMode ? 5 : 6

            Text {
                text: root.currentSessionName
                font.family: interFont.font.family
                font.pixelSize: root.quietMode ? 12 : 13
                font.weight: Font.Medium
                color: (btnMouse.containsMouse || root.menuOpen) 
                    ? root.colors.foreground 
                    : (root.quietMode ? root.colors.muted : root.colors.foreground)
            }

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                name: "chevron-down"
                size: root.quietMode ? 11 : 13
                color: root.colors.muted
            }
        }

        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.menuOpen = !root.menuOpen
        }
    }

    // Dropdown Menu
    Rectangle {
        id: popupMenu
        visible: root.menuOpen && root.sessionModel && root.sessionModel.count > 0
        width: Math.max(160, pillBtn.width)
        height: Math.min(220, (root.sessionModel ? root.sessionModel.count : 1) * 32 + 12)
        anchors.top: pillBtn.bottom
        anchors.topMargin: 6
        anchors.left: root.quietMode ? pillBtn.left : undefined
        anchors.horizontalCenter: root.quietMode ? undefined : pillBtn.horizontalCenter
        radius: 8
        color: root.colors.surface
        border.width: 1
        border.color: root.quietMode ? root.colors.borderSubtle : root.colors.border
        clip: true
        z: 100

        ListView {
            id: menuList
            anchors.fill: parent
            anchors.margins: 6
            model: root.sessionModel
            spacing: 2

            delegate: Rectangle {
                id: delegateItem
                readonly property int itemIndex: index
                readonly property string itemName: root.getSessionName(index)
                readonly property bool isCurrent: (itemIndex === root.currentIndex)

                width: menuList.width
                height: 30
                radius: 6
                color: itemMouse.containsMouse ? root.colors.surfaceAlt : "transparent"

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 24
                        text: delegateItem.itemName
                        font.family: interFont.font.family
                        font.pixelSize: 12
                        font.weight: delegateItem.isCurrent ? Font.DemiBold : Font.Normal
                        color: delegateItem.isCurrent ? root.colors.accent : root.colors.foreground
                        elide: Text.ElideRight
                    }

                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: "check"
                        size: 13
                        color: root.colors.accent
                        visible: delegateItem.isCurrent
                    }
                }

                MouseArea {
                    id: itemMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.currentIndex = delegateItem.itemIndex;
                        root.currentSessionName = delegateItem.itemName;
                        root.sessionChanged(delegateItem.itemIndex);
                        root.menuOpen = false;
                    }
                }
            }
        }
    }
}
