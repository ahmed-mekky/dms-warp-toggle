import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins
import "./components"

PluginComponent {
    id: root

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
        return isConnected ? "vpn_key" : "vpn_key_off";
    }

    ccWidgetPrimaryText: I18n.tr("WARP", "WARP name")

    ccWidgetSecondaryText: {
        if (!isAvailable)
            return I18n.tr("Unavailable", "WARP unavailable status");
        if (isConnecting)
            return I18n.tr("Connecting...", "WARP connecting status");
        return isConnected ? I18n.tr("Connected", "WARP connected status") : I18n.tr("Disconnected", "WARP disconnected status");
    }

    ccWidgetIsActive: isConnected
    ccDetailHeight: 240

    onCcWidgetExpanded: {
        WarpToggleService.refresh();
    }

    // ─── ccDetailContent (Control Center card) ───
    ccDetailContent: Component {
        StyledRect {
            color: Theme.surfaceContainerHigh
            radius: Theme.cornerRadius
            border.width: 0
            height: detailCol.height + Theme.spacingL * 2
            width: parent.width

            Column {
                id: detailCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingL

                // ── Header row ──
                Row {
                    spacing: Theme.spacingM
                    anchors.horizontalCenter: parent.horizontalCenter

                    StyledRect {
                        width: 48
                        height: 48
                        radius: Theme.cornerRadius
                        color: {
                            if (!root.isAvailable)
                                return Theme.errorContainer;
                            if (root.isConnecting)
                                return Theme.warningContainer;
                            return root.isConnected ? Theme.primaryContainer : Theme.surfaceContainer;
                        }
                        border.width: 0

                        DankIcon {
                            anchors.centerIn: parent
                            name: {
                                if (!root.isAvailable)
                                    return "error";
                                if (root.isConnecting)
                                    return "sync";
                                return root.isConnected ? "vpn_key" : "vpn_key_off";
                            }
                            size: 28
                            color: {
                                if (!root.isAvailable)
                                    return Theme.error;
                                if (root.isConnecting)
                                    return Theme.warning;
                                return root.isConnected ? Theme.primary : Theme.surfaceVariantText;
                            }

                            RotationAnimation on rotation {
                                running: root.isConnecting
                                from: 0
                                to: 360
                                duration: 1000
                                loops: Animation.Infinite
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
                            visible: !root.isConnected && root.disconnectReason && !root.isConnecting
                            text: root.disconnectReason
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                        }
                    }
                }

                // ── Toggle Button ──
                WarpToggleButton {
                    isConnected: root.isConnected
                    isConnecting: root.isConnecting
                    isAvailable: root.isAvailable
                    isBusy: root.isBusy
                    onClicked: WarpToggleService.toggle()
                }

                // ── Refresh row ──
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Theme.spacingS

                    DankActionButton {
                        iconName: "refresh"
                        iconColor: Theme.surfaceVariantText
                        buttonSize: 28
                        tooltipText: I18n.tr("Refresh status", "WARP refresh tooltip")
                        tooltipSide: "bottom"
                        onClicked: WarpToggleService.refresh()
                    }

                    StyledText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: I18n.tr("Refresh", "WARP refresh label")
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                    }
                }
            }
        }
    }

    // ─── Horizontal Bar Pill ───
    horizontalBarPill: Component {
        MouseArea {
            id: barMouse
            implicitWidth: barRow.implicitWidth
            implicitHeight: barRow.implicitHeight
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: WarpToggleService.toggle()

            Row {
                id: barRow
                spacing: (root.barConfig?.noBackground ?? false) ? 1 : 2
                anchors.verticalCenter: parent.verticalCenter

                // ── Icon badge ──
                StyledRect {
                    width: iconBadge.height
                    height: iconBadge.height
                    radius: Theme.cornerRadius
                    color: {
                        if (!root.isAvailable)
                            return Theme.errorContainer;
                        if (root.isConnecting)
                            return Theme.warningContainer;
                        return root.isConnected ? Theme.primaryContainer : Theme.surfaceContainer;
                    }
                    border.width: 0

                    DankIcon {
                        id: iconBadge
                        anchors.centerIn: parent
                        name: {
                            if (!root.isAvailable)
                                return "error";
                            if (root.isConnecting)
                                return "sync";
                            return root.isConnected ? "vpn_key" : "vpn_key_off";
                        }
                        size: Theme.barIconSize(root.barThickness, -4)
                        color: {
                            if (!root.isAvailable)
                                return Theme.error;
                            if (root.isConnecting)
                                return Theme.warning;
                            return root.isConnected ? Theme.primary : Theme.surfaceVariantText;
                        }

                        RotationAnimation on rotation {
                            running: root.isConnecting
                            from: 0
                            to: 360
                            duration: 1000
                            loops: Animation.Infinite
                        }
                    }
                }

                // ── Text column ──
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0

                    StyledText {
                        visible: root.isConnected || root.isConnecting
                        text: root.isConnecting ? "..." : "WARP"
                        font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale)
                        color: root.isConnecting ? Theme.warning : Theme.widgetTextColor
                    }

                    StyledText {
                        visible: root.isConnected || root.isConnecting
                        text: {
                            if (root.isConnecting)
                                return I18n.tr("Connecting...", "WARP bar status");
                            return root.isConnected
                                ? I18n.tr("Connected", "WARP bar status")
                                : I18n.tr("Disconnected", "WARP bar status");
                        }
                        font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale) - 2
                        color: Theme.widgetTextColor
                        opacity: 0.7
                    }
                }
            }
        }
    }

    // ─── Vertical Bar Pill ───
    verticalBarPill: Component {
        MouseArea {
            id: vBarMouse
            implicitWidth: vBarCol.implicitWidth
            implicitHeight: vBarCol.implicitHeight
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: WarpToggleService.toggle()

            Column {
                id: vBarCol
                spacing: 1
                anchors.horizontalCenter: parent.horizontalCenter

                StyledRect {
                    width: iconBadgeV.height
                    height: iconBadgeV.height
                    radius: Theme.cornerRadius
                    color: {
                        if (!root.isAvailable)
                            return Theme.errorContainer;
                        if (root.isConnecting)
                            return Theme.warningContainer;
                        return root.isConnected ? Theme.primaryContainer : Theme.surfaceContainer;
                    }
                    border.width: 0

                    DankIcon {
                        id: iconBadgeV
                        anchors.centerIn: parent
                        name: {
                            if (!root.isAvailable)
                                return "error";
                            if (root.isConnecting)
                                return "sync";
                            return root.isConnected ? "vpn_key" : "vpn_key_off";
                        }
                        size: Theme.barIconSize(root.barThickness)
                        color: {
                            if (!root.isAvailable)
                                return Theme.error;
                            if (root.isConnecting)
                                return Theme.warning;
                            return root.isConnected ? Theme.primary : Theme.surfaceVariantText;
                        }

                        RotationAnimation on rotation {
                            running: root.isConnecting
                            from: 0
                            to: 360
                            duration: 1000
                            loops: Animation.Infinite
                        }
                    }
                }

                StyledText {
                    visible: root.isConnected || root.isConnecting
                    text: root.isConnecting ? "..." : "WARP"
                    font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale)
                    color: root.isConnecting ? Theme.warning : Theme.widgetTextColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    // ─── Popout Content ───
    popoutContent: Component {
        PopoutComponent {
            id: popout
            headerText: I18n.tr("WARP", "WARP popout header")
            detailsText: root.statusText
            showCloseButton: true

            headerActions: Component {
                DankActionButton {
                    iconName: "refresh"
                    iconColor: Theme.surfaceVariantText
                    buttonSize: 28
                    tooltipText: I18n.tr("Refresh status", "WARP refresh tooltip")
                    tooltipSide: "bottom"
                    onClicked: WarpToggleService.refresh()
                }
            }

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
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: Theme.spacingL
                        spacing: Theme.spacingL

                        // Header
                        Row {
                            spacing: Theme.spacingM
                            anchors.horizontalCenter: parent.horizontalCenter

                            StyledRect {
                                width: 56
                                height: 56
                                radius: Theme.cornerRadius
                                color: {
                                    if (!root.isAvailable)
                                        return Theme.errorContainer;
                                    if (root.isConnecting)
                                        return Theme.warningContainer;
                                    return root.isConnected ? Theme.primaryContainer : Theme.surfaceContainer;
                                }
                                border.width: 0

                                DankIcon {
                                    anchors.centerIn: parent
                                    name: {
                                        if (!root.isAvailable)
                                            return "error";
                                        if (root.isConnecting)
                                            return "sync";
                                        return root.isConnected ? "vpn_key" : "vpn_key_off";
                                    }
                                    size: 32
                                    color: {
                                        if (!root.isAvailable)
                                            return Theme.error;
                                        if (root.isConnecting)
                                            return Theme.warning;
                                        return root.isConnected ? Theme.primary : Theme.surfaceVariantText;
                                    }

                                    RotationAnimation on rotation {
                                        running: root.isConnecting
                                        from: 0
                                        to: 360
                                        duration: 1000
                                        loops: Animation.Infinite
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
                                    visible: !root.isConnected && root.disconnectReason && !root.isConnecting
                                    text: root.disconnectReason
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                }
                            }
                        }

                        // Toggle
                        WarpToggleButton {
                            isConnected: root.isConnected
                            isConnecting: root.isConnecting
                            isAvailable: root.isAvailable
                            isBusy: root.isBusy
                            onClicked: WarpToggleService.toggle()
                        }

                        // Refresh row
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: Theme.spacingS

                            DankActionButton {
                                iconName: "refresh"
                                iconColor: Theme.surfaceVariantText
                                buttonSize: 28
                                tooltipText: I18n.tr("Refresh status", "WARP refresh tooltip")
                                tooltipSide: "bottom"
                                onClicked: WarpToggleService.refresh()
                            }

                            StyledText {
                                anchors.verticalCenter: parent.verticalCenter
                                text: I18n.tr("Refresh", "WARP refresh label")
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                            }
                        }
                    }
                }
            }
        }
    }

    popoutWidth: 360
    popoutHeight: 320
}
