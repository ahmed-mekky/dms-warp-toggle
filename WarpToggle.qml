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
    readonly property bool isSwitchingMode: WarpToggleService.isSwitchingMode
    readonly property string pendingAction: WarpToggleService.pendingAction
    readonly property string statusText: WarpToggleService.statusText
    readonly property string networkHealth: WarpToggleService.networkHealth
    readonly property string disconnectReason: WarpToggleService.disconnectReason
    readonly property string operationMode: WarpToggleService.operationMode
    readonly property string operationModeLabel: WarpToggleService.operationModeLabel
    readonly property string accountType: WarpToggleService.accountType
    readonly property bool isManaged: WarpToggleService.isManaged
    readonly property string organization: WarpToggleService.organization
    readonly property string tunnelProtocol: WarpToggleService.tunnelProtocol
    readonly property string colo: WarpToggleService.colo
    readonly property string latency: WarpToggleService.latency
    readonly property string loss: WarpToggleService.loss
    readonly property string sentTraffic: WarpToggleService.sentTraffic
    readonly property string receivedTraffic: WarpToggleService.receivedTraffic

    Component.onCompleted: {
        console.log("[warpToggle] Plugin loaded");
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
        return isConnected ? operationModeLabel : "Disconnected";
    }
    ccWidgetIsActive: isConnected
    pillClickAction: () => WarpToggleService.toggle()
    pillRightClickAction: () => root.triggerPopout()
    ccDetailHeight: 350

    onCcWidgetExpanded: {
        WarpToggleService.refresh();
    }

    onCcWidgetToggled: {
        WarpToggleService.toggle();
    }

    // ─── ccDetailContent (Control Center card) ───
    ccDetailContent: Component {
        WarpStatusCard {
            anchors.fill: parent
            compact: true
            isConnected: root.isConnected
            isConnecting: root.isConnecting
            isAvailable: root.isAvailable
            isBusy: root.isBusy
            isSwitchingMode: root.isSwitchingMode
            pendingAction: root.pendingAction
            networkHealth: root.networkHealth
            disconnectReason: root.disconnectReason
            operationMode: root.operationMode
            accountType: root.accountType
            isManaged: root.isManaged
            organization: root.organization
            tunnelProtocol: root.tunnelProtocol
            colo: root.colo
            latency: root.latency
            loss: root.loss
            sentTraffic: root.sentTraffic
            receivedTraffic: root.receivedTraffic
            modeOptions: WarpToggleService.modeOptions
            onToggleRequested: WarpToggleService.toggle()
            onRefreshRequested: WarpToggleService.refresh()
            onModeRequested: mode => WarpToggleService.setMode(mode)
        }
    }

    // ─── Horizontal Bar Pill ───
    horizontalBarPill: Component {
        DankIcon {
            anchors.verticalCenter: parent.verticalCenter
            property real spinAngle: 0
            rotation: root.isConnecting ? spinAngle : 0
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
                return root.isConnected ? Theme.success : Theme.surfaceVariantText;
            }
            NumberAnimation on spinAngle {
                from: 0
                to: 360
                duration: 1000
                loops: Animation.Infinite
                running: root.isConnecting
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
                width: parent.width
                topPadding: Theme.spacingM
                bottomPadding: Theme.spacingM

                WarpStatusCard {
                    width: parent.width
                    compact: false
                    isConnected: root.isConnected
                    isConnecting: root.isConnecting
                    isAvailable: root.isAvailable
                    isBusy: root.isBusy
                    isSwitchingMode: root.isSwitchingMode
                    pendingAction: root.pendingAction
                    networkHealth: root.networkHealth
                    disconnectReason: root.disconnectReason
                    operationMode: root.operationMode
                    accountType: root.accountType
                    isManaged: root.isManaged
                    organization: root.organization
                    tunnelProtocol: root.tunnelProtocol
                    colo: root.colo
                    latency: root.latency
                    loss: root.loss
                    sentTraffic: root.sentTraffic
                    receivedTraffic: root.receivedTraffic
                    modeOptions: WarpToggleService.modeOptions
                    onToggleRequested: WarpToggleService.toggle()
                    onRefreshRequested: WarpToggleService.refresh()
                    onModeRequested: mode => WarpToggleService.setMode(mode)
                    Component.onCompleted: WarpToggleService.refresh()
                }
            }
        }
    }

    popoutWidth: 380
}
