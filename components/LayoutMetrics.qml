import QtQuick

QtObject {
    id: root

    property real viewportWidth: 1366
    property real viewportHeight: 768

    // Scale ratio relative to standard 1366x768 base
    readonly property real scaleRatio: Math.max(1.0, Math.min(2.0, viewportWidth / 1366.0))
    readonly property real verticalScaleRatio: Math.max(1.0, Math.min(2.0, viewportHeight / 768.0))

    // Spacing & Margins
    readonly property real marginHorizontal: Math.round(viewportWidth * 0.06) // 6% left/right margin
    readonly property real marginVertical: Math.round(viewportHeight * 0.06)   // 6% top/bottom margin
    readonly property real spacingLarge: Math.round(32 * verticalScaleRatio)
    readonly property real spacingMedium: Math.round(20 * verticalScaleRatio)
    readonly property real spacingSmall: Math.round(10 * verticalScaleRatio)

    // Typography
    readonly property int clockSizeEditorial: Math.round(Math.min(110, 84 * scaleRatio))
    readonly property int clockSizeStandard: Math.round(Math.min(96, 72 * scaleRatio))
    readonly property int clockSizeCompact: Math.round(Math.min(64, 52 * scaleRatio))
    readonly property int dateSize: Math.round(Math.min(18, 14 * scaleRatio))
    readonly property int labelSize: Math.round(Math.min(15, 12 * scaleRatio))

    // Controls Dimensions
    readonly property real panelWidth: Math.round(Math.min(420, Math.max(340, 360 * scaleRatio)))
    readonly property real panelWidthCompact: Math.round(Math.min(360, Math.max(300, 320 * scaleRatio)))
    readonly property real inputHeight: Math.round(Math.min(56, Math.max(46, 48 * scaleRatio)))
    readonly property real buttonHeight: Math.round(Math.min(50, Math.max(42, 44 * scaleRatio)))
}
