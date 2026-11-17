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
    readonly property bool isApplyingMode: WarpToggleService.isApplyingMode
    readonly property string pendingAction: WarpToggleService.pendingAction
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

    function openPopout() {
        const action = pillClickAction;
        pillClickAction = null;
        try {
            triggerPopout();
        } finally {
            pillClickAction = action;
        }
    }

    ccWidgetIcon: {
        if (isConnecting || isBusy || isApplyingMode)
            return "sync";
        if (!isAvailable)
            return "error";
        return isConnected ? "cloud" : "cloud_off";
    }

    ccWidgetPrimaryText: "WARP"
    ccWidgetSecondaryText: {
        if (isApplyingMode)
            return "Applying mode...";
        if (isBusy)
            return pendingAction === "disconnect" ? "Disconnecting..." : "Connecting...";
        if (!isAvailable)
            return "Unavailable";
        if (isConnecting)
            return "Connecting...";
        if (isConnected)
            return operationMode === "warp" ? "Connected" : operationModeLabel;
        return "Disconnected";
    }
    ccWidgetIsActive: isConnected
    pillClickAction: () => WarpToggleService.toggle()
    pillRightClickAction: () => root.openPopout()
    ccDetailHeight: Theme.iconSize * 14 + Theme.spacingM

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
            isApplyingMode: root.isApplyingMode
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
            onModeRequested: mode => WarpToggleService.setMode(mode)
        }
    }

    // ─── Horizontal Bar Pill ───
    horizontalBarPill: Component {
        WarpBarIcon {
            barThickness: root.barThickness
            isConnected: root.isConnected
            isConnecting: root.isConnecting
            isBusy: root.isBusy
            isApplyingMode: root.isApplyingMode
            isAvailable: root.isAvailable
        }
    }

    // ─── Vertical Bar Pill ───
    verticalBarPill: Component {
        WarpBarIcon {
            barThickness: root.barThickness
            isConnected: root.isConnected
            isConnecting: root.isConnecting
            isBusy: root.isBusy
            isApplyingMode: root.isApplyingMode
            isAvailable: root.isAvailable
        }
    }

    // ─── Popout Content ───
    popoutContent: Component {
        PopoutComponent {
            id: popout
            headerText: I18n.tr("WARP", "WARP popout header")
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
                    isApplyingMode: root.isApplyingMode
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
                    onModeRequested: mode => WarpToggleService.setMode(mode)
                    Component.onCompleted: WarpToggleService.refresh()
                }
            }
        }
    }

    popoutWidth: Theme.iconSize * 16
}
