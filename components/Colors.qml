import QtQuick

QtObject {
    id: root

    // =========================================================================
    // Semantic Color Tokens (Adaptive Palette with Material Design Fallbacks)
    // =========================================================================

    // Base background color
    readonly property color background: (typeof config !== "undefined" && config.colorBackground) 
        ? config.colorBackground : "#141314"

    // Primary container / card surface
    readonly property color surface: (typeof config !== "undefined" && config.colorSurface) 
        ? config.colorSurface : "#201f20"

    // Elevated surface / interactive element background
    readonly property color surfaceAlt: (typeof config !== "undefined" && config.colorSurfaceAlt) 
        ? config.colorSurfaceAlt : "#2b292b"

    // Primary text / foreground content
    readonly property color foreground: (typeof config !== "undefined" && config.colorForeground) 
        ? config.colorForeground : "#e6e1e3"

    // Secondary / subtle text and inactive outlines
    readonly property color muted: (typeof config !== "undefined" && config.colorMuted) 
        ? config.colorMuted : "#948f96"

    // Accent brand color (Primary action, active borders, clock accent)
    readonly property color accent: (typeof config !== "undefined" && config.colorAccent) 
        ? config.colorAccent : "#ccc3d7"

    // Contrast text on top of accent color
    readonly property color accentForeground: (typeof config !== "undefined" && config.colorAccentForeground) 
        ? config.colorAccentForeground : "#342e3d"

    // Subtle container border
    readonly property color border: (typeof config !== "undefined" && config.colorBorder) 
        ? config.colorBorder : "#49454b"

    // Error state color
    readonly property color error: (typeof config !== "undefined" && config.colorError) 
        ? config.colorError : "#ffb4ab"

    // =========================================================================
    // Derived Semi-Transparent Colors for UI Elevation & Glass
    // =========================================================================
    readonly property color surfaceTranslucent: Qt.rgba(surface.r, surface.g, surface.b, 0.82)
    readonly property color surfaceAltTranslucent: Qt.rgba(surfaceAlt.r, surfaceAlt.g, surfaceAlt.b, 0.65)
    readonly property color borderSubtle: Qt.rgba(border.r, border.g, border.b, 0.45)
    readonly property color borderHover: Qt.rgba(accent.r, accent.g, accent.b, 0.70)
    readonly property color scrim: Qt.rgba(background.r * 0.4, background.g * 0.4, background.b * 0.4, 0.40)
}
