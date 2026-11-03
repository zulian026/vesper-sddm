import QtQuick
import QtQuick.Window
import "components"

Rectangle {
    id: root

    width: 1366
    height: 768
    color: themeColors.background

    // Access global SDDM models cleanly from root scope
    readonly property var sddmUserModel: (typeof userModel !== "undefined") ? userModel : null
    readonly property var sddmSessionModel: (typeof sessionModel !== "undefined") ? sessionModel : null
    readonly property var sddmKeyboard: (typeof keyboard !== "undefined") ? keyboard : null
    readonly property var sddmContext: (typeof sddm !== "undefined") ? sddm : null

    Colors {
        id: themeColors
    }

    FontLoader {
        id: interFont
        source: "assets/fonts/Inter.ttf"
    }

    // -------------------------------------------------------------------------
    // Background Wallpaper with Fallback & Scrim
    // -------------------------------------------------------------------------
    Image {
        id: bgImage
        anchors.fill: parent
        source: (typeof config !== "undefined" && config.background) ? Qt.resolvedUrl(config.background) : "assets/background.png"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        opacity: (status === Image.Ready) ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }
    }

    // Dimming Scrim for legibility
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: (typeof config !== "undefined" && config.dimBackground) ? parseFloat(config.dimBackground) : 0.25
    }

    // Subtle radial vignette
    Rectangle {
        anchors.fill: parent
        color: themeColors.scrim
        opacity: 0.6
    }

    // -------------------------------------------------------------------------
    // Validated Layout Registry (Explicit Allowlist)
    // -------------------------------------------------------------------------
    readonly property var layoutRegistry: ({
        "center": "layouts/CenterLayout.qml",
        "left-editorial": "layouts/LeftEditorial.qml",
        "right-sidebar": "layouts/RightSidebar.qml",
        "split-screen": "layouts/SplitScreen.qml",
        "bottom-center": "layouts/BottomCenter.qml",
        "compact-floating": "layouts/CompactFloating.qml"
    })

    readonly property string configuredLayout: {
        var raw = (typeof config !== "undefined" && config.layout) ? config.layout.toString().trim() : "left-editorial";
        return layoutRegistry.hasOwnProperty(raw) ? raw : "center";
    }

    readonly property string layoutSource: layoutRegistry[configuredLayout] || "layouts/CenterLayout.qml"

    // -------------------------------------------------------------------------
    // Active Layout Loader
    // -------------------------------------------------------------------------
    Loader {
        id: layoutLoader
        anchors.fill: parent
        source: root.layoutSource
        focus: true

        Binding { target: layoutLoader.item; property: "themeColors"; value: themeColors; when: layoutLoader.status === Loader.Ready }
        Binding { target: layoutLoader.item; property: "sddmUserModel"; value: root.sddmUserModel; when: layoutLoader.status === Loader.Ready }
        Binding { target: layoutLoader.item; property: "sddmSessionModel"; value: root.sddmSessionModel; when: layoutLoader.status === Loader.Ready }
        Binding { target: layoutLoader.item; property: "sddmKeyboard"; value: root.sddmKeyboard; when: layoutLoader.status === Loader.Ready }
        Binding { target: layoutLoader.item; property: "sddmContext"; value: root.sddmContext; when: layoutLoader.status === Loader.Ready }
    }

    // Forward login request from layout to native SDDM context
    Connections {
        target: layoutLoader.item
        ignoreUnknownSignals: true
        function onLoginRequested(username, password, sessionIdx) {
            if (root.sddmContext) {
                root.sddmContext.login(username, password, sessionIdx);
            } else {
                console.log("Mock login triggered for:", username, "session:", sessionIdx);
            }
        }
    }

    // -------------------------------------------------------------------------
    // SDDM Greeter Signal Connections
    // -------------------------------------------------------------------------
    Connections {
        target: root.sddmContext
        ignoreUnknownSignals: true

        function onLoginSucceeded() {
            if (layoutLoader.item && typeof layoutLoader.item.triggerSuccess === "function") {
                layoutLoader.item.triggerSuccess();
            }
        }

        function onLoginFailed() {
            if (layoutLoader.item && typeof layoutLoader.item.triggerError === "function") {
                layoutLoader.item.triggerError("Incorrect password. Please try again.");
            }
        }

        function onInformationMessage(message) {
            if (layoutLoader.item && typeof layoutLoader.item.triggerError === "function") {
                layoutLoader.item.triggerError(message);
            }
        }
    }

    // -------------------------------------------------------------------------
    // Smooth Initial Fade-in Animation
    // -------------------------------------------------------------------------
    opacity: 0.0
    Component.onCompleted: {
        root.opacity = 1.0;
    }
    Behavior on opacity {
        NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
    }
}
