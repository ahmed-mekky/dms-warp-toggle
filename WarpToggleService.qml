pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services

Singleton {
    id: root

    readonly property string pluginId: "warpToggle"
    readonly property string cliBinary: "warp-cli"

    property bool isConnected: false
    property bool isConnecting: false
    property bool isAvailable: false
    property bool isBusy: false
    property bool isSwitchingMode: false
    property string pendingAction: ""
    property string statusText: "Unknown"
    property string networkHealth: ""
    property string disconnectReason: ""
    property string operationMode: "warp"
    property string accountType: ""
    property bool isManaged: false
    property string organization: ""
    property string tunnelProtocol: ""
    property string colo: ""
    property string latency: ""
    property string loss: ""
    property string sentTraffic: ""
    property string receivedTraffic: ""
    property bool listenerEnabled: true
    property int restartInterval: 5000

    signal statusChanged
    signal availabilityChanged

    readonly property bool isDisconnected: !isConnected && !isConnecting
    readonly property var modeOptions: [
        {
            "value": "warp",
            "label": I18n.tr("WARP", "WARP operation mode")
        },
        {
            "value": "doh",
            "label": I18n.tr("DoH only", "WARP operation mode")
        },
        {
            "value": "warp+doh",
            "label": I18n.tr("WARP + DoH", "WARP operation mode")
        },
        {
            "value": "dot",
            "label": I18n.tr("DoT only", "WARP operation mode")
        },
        {
            "value": "warp+dot",
            "label": I18n.tr("WARP + DoT", "WARP operation mode")
        },
        {
            "value": "proxy",
            "label": I18n.tr("SOCKS5 proxy", "WARP operation mode")
        },
        {
            "value": "tunnel_only",
            "label": I18n.tr("Tunnel only", "WARP operation mode")
        }
    ]
    readonly property string operationModeLabel: {
        for (let i = 0; i < modeOptions.length; i++) {
            if (modeOptions[i].value === operationMode)
                return modeOptions[i].label;
        }
        return operationMode ? operationMode : I18n.tr("Unknown", "Unknown WARP mode");
    }

    Component.onCompleted: {
        loadSettings();
        checkAvailability();
    }

    Connections {
        target: PluginService
        function onPluginDataChanged(pluginId) {
            if (pluginId === root.pluginId) {
                loadSettings();
            }
        }
    }

    onListenerEnabledChanged: {
        if (listenerEnabled) {
            listenerProcess.running = true;
        } else {
            listenerProcess.running = false;
        }
    }

    function loadSettings() {
        listenerEnabled = PluginService.loadPluginData(pluginId, "listenerEnabled") ?? true;
        restartInterval = PluginService.loadPluginData(pluginId, "restartInterval") ?? 5000;
        restartTimer.interval = restartInterval;
    }

    function saveSettings() {
        PluginService.savePluginData(pluginId, "listenerEnabled", listenerEnabled);
        PluginService.savePluginData(pluginId, "restartInterval", restartInterval);
    }

    function checkAvailability() {
        Proc.runCommand(`${pluginId}.availabilityCheck`, [cliBinary, "status"], (stdout, exitCode) => {
            const wasAvailable = isAvailable;
            isAvailable = exitCode === 0;
            if (isAvailable) {
                parseStatusLine(stdout);
                refreshDetails();
                if (listenerEnabled && !listenerProcess.running) {
                    listenerProcess.running = true;
                }
            } else {
                isConnected = false;
                isConnecting = false;
                statusText = "Unavailable";
                clearDetails();
            }
            if (wasAvailable !== isAvailable) {
                availabilityChanged();
            }
        }, 100);
    }

    function parseStatusLine(line) {
        const trimmed = line.trim();
        if (!trimmed)
            return;

        // Parse "Status update: Connected"
        if (trimmed.startsWith("Status update:")) {
            const state = trimmed.replace("Status update:", "").trim();
            switch (state) {
            case "Connected":
                isConnected = true;
                isConnecting = false;
                statusText = "Connected";
                disconnectReason = "";
                Qt.callLater(() => root.refreshDetails());
                break;
            case "Connecting":
                isConnecting = true;
                isConnected = false;
                statusText = "Connecting...";
                networkHealth = "";
                clearTunnelStats();
                break;
            case "Disconnected":
                isConnected = false;
                isConnecting = false;
                statusText = "Disconnected";
                networkHealth = "";
                clearTunnelStats();
                break;
            }
            statusChanged();
            return;
        }

        // Parse "Network: healthy"
        if (trimmed.startsWith("Network:")) {
            networkHealth = trimmed.replace("Network:", "").trim();
            return;
        }

        // Parse "Reason: Settings Changed"
        if (trimmed.startsWith("Reason:")) {
            disconnectReason = trimmed.replace("Reason:", "").trim();
            return;
        }
    }

    function refreshDetails() {
        if (!isAvailable)
            return;
        loadSettingsInfo();
        loadRegistrationInfo();
        if (isConnected)
            loadTunnelStats();
    }

    function loadSettingsInfo() {
        Proc.runCommand(`${pluginId}.settingsInfo`, [cliBinary, "-j", "settings", "list"], (stdout, exitCode) => {
            if (exitCode !== 0)
                return;
            try {
                const data = JSON.parse(stdout);
                const mode = data && data.settings && data.settings.operation_mode;
                if (mode)
                    operationMode = mode;
            } catch (e) {
                console.warn(`[${pluginId}] Failed to parse settings:`, e);
            }
        }, 100);
    }

    function loadRegistrationInfo() {
        Proc.runCommand(`${pluginId}.registrationInfo`, [cliBinary, "-j", "registration", "show"], (stdout, exitCode) => {
            if (exitCode !== 0) {
                accountType = "";
                isManaged = false;
                organization = "";
                return;
            }
            try {
                const data = JSON.parse(stdout);
                accountType = (data.account && data.account.type) || "";
                isManaged = data.managed === true;
                if (isManaged)
                    loadOrganization();
                else
                    organization = "";
            } catch (e) {
                console.warn(`[${pluginId}] Failed to parse registration:`, e);
            }
        }, 100);
    }

    function loadOrganization() {
        Proc.runCommand(`${pluginId}.organization`, [cliBinary, "registration", "organization"], (stdout, exitCode) => {
            organization = exitCode === 0 ? stdout.trim() : "";
        }, 100);
    }

    function loadTunnelStats() {
        Proc.runCommand(`${pluginId}.tunnelStats`, [cliBinary, "tunnel", "stats"], (stdout, exitCode) => {
            if (exitCode !== 0) {
                clearTunnelStats();
                return;
            }
            const lines = stdout.split("\n");
            for (let i = 0; i < lines.length; i++) {
                const line = lines[i].trim();
                if (line.startsWith("Tunnel Protocol:"))
                    tunnelProtocol = line.substring("Tunnel Protocol:".length).trim();
                else if (line.startsWith("Estimated latency:"))
                    latency = line.substring("Estimated latency:".length).trim();
                else if (line.startsWith("Estimated loss:"))
                    loss = line.substring("Estimated loss:".length).trim();
                else if (line.startsWith("Colo:"))
                    colo = line.substring("Colo:".length).trim();
                else if (line.startsWith("Sent:")) {
                    const match = line.match(/^Sent:\s*(.*?);\s*Received:\s*(.*)$/);
                    if (match) {
                        sentTraffic = match[1].trim();
                        receivedTraffic = match[2].trim();
                    }
                }
            }
        }, 100);
    }

    function clearTunnelStats() {
        tunnelProtocol = "";
        colo = "";
        latency = "";
        loss = "";
        sentTraffic = "";
        receivedTraffic = "";
    }

    function clearDetails() {
        clearTunnelStats();
        networkHealth = "";
        disconnectReason = "";
        operationMode = "";
        accountType = "";
        isManaged = false;
        organization = "";
    }

    function setMode(mode) {
        if (!isAvailable || isSwitchingMode || mode === operationMode)
            return;
        const wasConnected = isConnected;
        isSwitchingMode = true;
        Proc.runCommand(`${pluginId}.setMode`, [cliBinary, "mode", mode], (stdout, exitCode) => {
            isSwitchingMode = false;
            if (exitCode !== 0) {
                console.warn(`[${pluginId}] mode change failed:`, stdout);
                ToastService.showError(
                    I18n.tr("WARP mode change failed", "WARP mode error title"),
                    stdout || I18n.tr("Command failed", "Generic command failure")
                );
                return;
            }
            operationMode = mode;
            if (wasConnected)
                modeReconnectTimer.restart();
            Qt.callLater(() => {
                root.checkAvailability();
                root.refreshDetails();
            });
        }, 100);
    }

    function toggle() {
        if (isBusy)
            return;
        runToggle((isConnected || isConnecting) ? "disconnect" : "connect");
    }

    function runToggle(command) {
        if (isBusy)
            return;

        const wasConnected = isConnected;
        const wasConnecting = isConnecting;
        const previousStatus = statusText;

        isBusy = true;
        pendingAction = command;
        if (command === "connect") {
            isConnecting = true;
            statusText = "Connecting...";
        } else {
            statusText = "Disconnecting...";
        }

        Proc.runCommand(`${pluginId}.${command}`, [cliBinary, command], (stdout, exitCode) => {
            isBusy = false;
            pendingAction = "";
            if (exitCode !== 0) {
                isConnected = wasConnected;
                isConnecting = wasConnecting;
                statusText = previousStatus;
                console.warn(`[${pluginId}] ${command} failed:`, stdout);
                ToastService.showError(
                    I18n.tr("WARP toggle failed", "WARP toggle error title"),
                    stdout || I18n.tr("Command failed", "Generic command failure")
                );
            } else {
                Qt.callLater(() => {
                    checkAvailability();
                });
            }
        }, 100, 15000);
    }

    function refresh() {
        checkAvailability();
    }

    // Long-running listener process
    Process {
        id: listenerProcess
        command: [root.cliBinary, "-l", "status"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                root.parseStatusLine(data);
            }
        }

        onRunningChanged: {
            if (!running) {
                console.log(`[${root.pluginId}] Listener process stopped`);
                if (root.isAvailable && root.listenerEnabled) {
                    restartTimer.start();
                }
            }
        }
    }

    Timer {
        id: restartTimer
        interval: root.restartInterval
        running: false
        repeat: false
        onTriggered: {
            if (root.isAvailable && root.listenerEnabled && !listenerProcess.running) {
                console.log(`[${root.pluginId}] Restarting listener...`);
                listenerProcess.running = true;
            }
        }
    }

    Timer {
        id: modeReconnectTimer
        interval: 1000
        running: false
        repeat: false
        onTriggered: {
            if (root.isBusy || root.isConnected || root.isConnecting)
                return;
            root.runToggle("connect");
        }
    }
}
