import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins
import "./components"

PluginComponent {
    id: root
    width: 100

    readonly property bool isConnected: WarpToggleService.isConnected
    readonly property bool isConnecting: WarpToggleService.isConnecting
    readonly property bool isAvailable: WarpToggleService.isAvailable
    readonly property bool isBusy: WarpToggleService.isBusy
    readonly property string statusText: WarpToggleService.statusText
    readonly property string networkHealth: WarpToggleService.networkHealth
    readonly property string disconnectReason: WarpToggleService.disconnectReason

    Component.onCompleted: {
        console.log("[dankWarpToggle] Plugin loaded");
    }

    ccWidgetIcon: {
        if (!isAvailable)
            return "error";
        if (isConnecting)
            return "sync";
        return isConnected ? "cloud" : "cloud_off";
    }

    ccWidgetPrimaryText: "WARP"
    ccWidgetSecondaryText: {
        if (!isAvailable)
            return "Unavailable";
        if (isConnecting)
            return "Connecting...";
        return isConnected ? "Connected" : "Disconnected";
    }
    ccWidgetIsActive: isConnected
    pillClickAction: () => WarpToggleService.toggle()
    pillRightClickAction: null
    ccDetailHeight: 200

    onCcWidgetExpanded: {
        WarpToggleService.refresh();
    }

    onCcWidgetToggled: {
        WarpToggleService.toggle();
    }

    // ─── ccDetailContent (Control Center card) ───
    ccDetailContent: Component {
        StyledRect {
            color: Theme.surfaceContainerHigh
            radius: Theme.cornerRadius
            border.width: 0
            height: detailCol.height + Theme.spacingL * 2
            anchors.fill: parent

            Column {
                id: detailCol
                anchors.fill: parent
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingL

                // ── Header row with refresh in top-right ──
                Item {
                    width: parent.width
                    height: 48

                    Row {
                        id: headerLeft
                        spacing: Theme.spacingM
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter

                        StyledRect {
                            width: 48
                            height: 48
                            radius: Theme.cornerRadius
                            color: {
                                if (!root.isAvailable)
                                    return Theme.errorContainer;
                                if (root.isConnecting)
                                    return Theme.warningContainer;
                                return root.isConnected ? Theme.primaryContainer : Theme.surface;
                            }
                            border.width: 0

                            DankIcon {
                                anchors.centerIn: parent
                                rotation: 0
                                name: {
                                    if (!root.isAvailable)
                                        return "error";
                                    if (root.isConnecting)
                                        return "sync";
                                    return root.isConnected ? "cloud" : "cloud_off";
                                }
                                size: 28
                                color: {
                                    if (!root.isAvailable)
                                        return Theme.error;
                                    if (root.isConnecting)
                                        return Theme.warning;
                                    return root.isConnected ? Theme.primary : Theme.surfaceVariantText;
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            StyledText {
                                text: {
                                    if (!root.isAvailable)
                                        return I18n.tr("WARP Unavailable", "WARP status header");
                                    if (root.isConnecting)
                                        return I18n.tr("Connecting...", "WARP status header");
                                return root.isConnected
                                    ? I18n.tr("WARP Connected", "WARP status header")
                                    : I18n.tr("WARP Disconnected", "WARP status header");
                                }
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Bold
                                color: {
                                    if (!root.isAvailable)
                                        return Theme.error;
                                    if (root.isConnecting)
                                        return Theme.warning;
                                    return root.isConnected ? Theme.primary : Theme.surfaceText;
                                }
                            }

                            StyledText {
                                visible: root.isConnected && root.networkHealth
                                text: root.networkHealth
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                            }

                            StyledText {
                                visible: !root.isConnected && !root.isConnecting
                                text: I18n.tr("Disconnected", "WARP disconnected subtitle")
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                            }
                        }
                    }

                    // Right: refresh button
                    DankActionButton {
                        iconName: "refresh"
                        iconColor: Theme.surfaceVariantText
                        buttonSize: 28
                        tooltipText: I18n.tr("Refresh status", "WARP refresh tooltip")
                        tooltipSide: "bottom"
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: WarpToggleService.refresh()
                    }
                }

                // ── Full-width Toggle Button ──
                WarpToggleButton {
                    width: detailCol.parent.width - Theme.spacingL * 2
                    isConnected: root.isConnected
                    isConnecting: root.isConnecting
                    isAvailable: root.isAvailable
                    isBusy: root.isBusy
                    onClicked: WarpToggleService.toggle()
                }
            }
        }
    }

    // ─── Horizontal Bar Pill ───
    horizontalBarPill: Component {
        DankIcon {
            anchors.verticalCenter: parent.verticalCenter
            rotation: 0
            name: {
                if (!root.isAvailable)
                    return "error";
                if (root.isConnecting)
                    return "sync";
                return root.isConnected ? "cloud" : "cloud_off";
            }
            size: Theme.barIconSize(root.barThickness)
            color: {
                if (!root.isAvailable)
                    return Theme.error;
                if (root.isConnecting)
                    return Theme.warning;
                return root.isConnected ? Theme.primary : Theme.surfaceVariantText;
            }
        }
    }

    // ─── Vertical Bar Pill ───
    // ─── Popout Content ───
    popoutContent: Component {
        PopoutComponent {
            id: popout
            headerText: I18n.tr("WARP", "WARP popout header")
            detailsText: root.statusText
            showCloseButton: true

            Column {
                spacing: Theme.spacingL
                width: parent.width
                anchors.top: parent.top
                anchors.topMargin: Theme.spacingM
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.spacingM

                // ── Card ──
                StyledRect {
                    width: parent.width - Theme.spacingM * 2
                    height: cardCol.height + Theme.spacingL * 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.surfaceContainerHigh
                    radius: Theme.cornerRadius
                    border.width: 0

                    Column {
                        id: cardCol
                        anchors.fill: parent
                        anchors.margins: Theme.spacingL
                        spacing: Theme.spacingL

                        // Header with refresh
                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            // Left: icon + text
                            Row {
                                id: popoutHeaderLeft
                                spacing: Theme.spacingM
                                anchors.verticalCenter: parent.verticalCenter

                                StyledRect {
                                    width: 56
                                    height: 56
                                    radius: Theme.cornerRadius
                                    color: {
                                        if (!root.isAvailable)
                                            return Theme.errorContainer;
                                        if (root.isConnecting)
                                            return Theme.warningContainer;
                                        return root.isConnected ? Theme.primaryContainer : Theme.surface;
                                    }
                                    border.width: 0

                                    DankIcon {
                                        anchors.centerIn: parent
                                        rotation: 0
                                        name: {
                                            if (!root.isAvailable)
                                                return "error";
                                            if (root.isConnecting)
                                                return "sync";
                                            return root.isConnected ? "cloud" : "cloud_off";
                                        }
                                        size: 32
                                        color: {
                                            if (!root.isAvailable)
                                                return Theme.error;
                                            if (root.isConnecting)
                                                return Theme.warning;
                                            return root.isConnected ? Theme.primary : Theme.surfaceVariantText;
                                        }
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    StyledText {
                                        text: {
                                            if (!root.isAvailable)
                                                return I18n.tr("WARP Unavailable", "WARP popout status");
                                            if (root.isConnecting)
                                                return I18n.tr("Connecting...", "WARP popout status");
                                            return root.isConnected
                                                ? I18n.tr("Connected", "WARP popout status")
                                                : I18n.tr("Disconnected", "WARP popout status");
                                        }
                                        font.pixelSize: Theme.fontSizeLarge
                                        font.weight: Font.Bold
                                        color: {
                                            if (!root.isAvailable)
                                                return Theme.error;
                                            if (root.isConnecting)
                                                return Theme.warning;
                                            return root.isConnected ? Theme.primary : Theme.surfaceText;
                                        }
                                    }

                                    StyledText {
                                        visible: root.isConnected && root.networkHealth
                                        text: root.networkHealth
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }

                                    StyledText {
                                        visible: !root.isConnected && !root.isConnecting
                                        text: I18n.tr("Disconnected", "WARP disconnected subtitle")
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                    }
                                }
                            }

                            // Right: refresh
                            DankActionButton {
                                iconName: "refresh"
                                iconColor: Theme.surfaceVariantText
                                buttonSize: 28
                                tooltipText: I18n.tr("Refresh status", "WARP refresh tooltip")
                                tooltipSide: "bottom"
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: WarpToggleService.refresh()
                            }
                        }

                        // Full-width toggle
                        WarpToggleButton {
                            width: cardCol.parent.width - Theme.spacingL * 2
                            isConnected: root.isConnected
                            isConnecting: root.isConnecting
                            isAvailable: root.isAvailable
                            isBusy: root.isBusy
                            onClicked: WarpToggleService.toggle()
                        }
                    }
                }
            }
        }
    }

    popoutWidth: 360
    popoutHeight: 300
}
