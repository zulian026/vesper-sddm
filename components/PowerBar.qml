import QtQuick

Row {
    id: root

    property Colors colors
    property var sddmContext: null
    spacing: 8

    readonly property bool showButtons: (typeof config !== "undefined" && config.showPowerButtons) 
        ? (config.showPowerButtons === "true" || config.showPowerButtons === true) 
        : true

    readonly property bool isTestMode: (sddmContext !== null && !sddmContext.canPowerOff && !sddmContext.canReboot && !sddmContext.canSuspend)

    // Suspend
    IconButton {
        visible: root.showButtons && (root.isTestMode || (root.sddmContext ? root.sddmContext.canSuspend : false))
        iconName: "sleep"
        tooltipText: "Suspend"
        colors: root.colors
        onClicked: {
            if (root.sddmContext && root.sddmContext.canSuspend) {
                root.sddmContext.suspend();
            } else {
                console.log("Action: Suspend (not permitted by policy or in test mode)");
            }
        }
    }

    // Reboot
    IconButton {
        visible: root.showButtons && (root.isTestMode || (root.sddmContext ? root.sddmContext.canReboot : false))
        iconName: "restart"
        tooltipText: "Restart"
        colors: root.colors
        onClicked: {
            if (root.sddmContext && root.sddmContext.canReboot) {
                root.sddmContext.reboot();
            } else {
                console.log("Action: Reboot (not permitted by policy or in test mode)");
            }
        }
    }

    // Power Off
    IconButton {
        visible: root.showButtons && (root.isTestMode || (root.sddmContext ? root.sddmContext.canPowerOff : false))
        iconName: "power"
        tooltipText: "Shut Down"
        colors: root.colors
        onClicked: {
            if (root.sddmContext && root.sddmContext.canPowerOff) {
                root.sddmContext.powerOff();
            } else {
                console.log("Action: PowerOff (not permitted by policy or in test mode)");
            }
        }
    }
}
