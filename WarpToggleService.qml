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
    property string statusText: "Unknown"
    property string networkHealth: ""
    property string disconnectReason: ""
    property bool listenerEnabled: true
    property int restartInterval: 5000

    signal statusChanged
    signal availabilityChanged

    readonly property bool isDisconnected: !isConnected && !isConnecting

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
                if (listenerEnabled && !listenerProcess.running) {
                    listenerProcess.running = true;
                }
            } else {
                isConnected = false;
                isConnecting = false;
                statusText = "Unavailable";
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
                break;
            case "Connecting":
                isConnecting = true;
                isConnected = false;
                statusText = "Connecting...";
                break;
            case "Disconnected":
                isConnected = false;
                isConnecting = false;
                statusText = "Disconnected";
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

    function toggle() {
        if (isBusy)
            return;

        isBusy = true;
        const command = (isConnected || isConnecting) ? "disconnect" : "connect";

        Proc.runCommand(`${pluginId}.${command}`, [cliBinary, command], (stdout, exitCode) => {
            isBusy = false;
            if (exitCode !== 0) {
                console.warn(`[${pluginId}] ${command} failed:`, stdout);
                ToastService.showError(
                    I18n.tr("WARP toggle failed", "WARP toggle error title"),
                    stdout || I18n.tr("Command failed", "Generic command failure")
                );
            } else {
                // Trigger a quick refresh after toggle
                Qt.callLater(() => {
                    checkAvailability();
                });
            }
        }, 100);
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
}
