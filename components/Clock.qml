import QtQuick

Column {
    id: root

    spacing: 6

    FontLoader {
        id: interFont
        source: "../assets/fonts/Inter.ttf"
    }

    property Colors colors
    property int horizontalAlignment: Text.AlignHCenter
    property int customClockFontSize: 0
    property int customDateFontSize: 0
    property bool showDate: true

    property string timeString: ""
    property string dateString: ""

    function updateTime() {
        var now = new Date();
        var hours = now.getHours();
        var minutes = now.getMinutes();
        var hStr = hours < 10 ? "0" + hours : hours.toString();
        var mStr = minutes < 10 ? "0" + minutes : minutes.toString();
        timeString = hStr + ":" + mStr;

        dateString = Qt.formatDateTime(now, "dddd, d MMMM yyyy");
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updateTime()
    }

    Text {
        id: clockText
        text: root.timeString
        color: root.colors ? root.colors.foreground : "#ffffff"
        font.family: interFont.font.family
        font.pixelSize: (root.customClockFontSize > 0) 
            ? root.customClockFontSize 
            : ((typeof config !== "undefined" && config.clockFontSize) ? parseInt(config.clockFontSize) : 76)
        font.weight: Font.DemiBold
        renderType: Text.NativeRendering
        anchors.horizontalCenter: (root.horizontalAlignment === Text.AlignHCenter) ? parent.horizontalCenter : undefined
    }

    Text {
        id: dateText
        visible: root.showDate
        text: root.dateString
        color: root.colors ? root.colors.muted : "#999999"
        font.family: interFont.font.family
        font.pixelSize: (root.customDateFontSize > 0) 
            ? root.customDateFontSize 
            : ((typeof config !== "undefined" && config.dateFontSize) ? parseInt(config.dateFontSize) : 15)
        font.weight: Font.Normal
        renderType: Text.NativeRendering
        anchors.horizontalCenter: (root.horizontalAlignment === Text.AlignHCenter) ? parent.horizontalCenter : undefined
    }
}
