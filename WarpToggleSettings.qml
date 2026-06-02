import QtQuick
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

PluginSettings {
    id: root
    pluginId: WarpToggleService.pluginId

    StyledText {
        width: parent.width
        text: I18n.tr("WARP Toggle Settings", "WARP settings title")
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: I18n.tr("Configure how Cloudflare WARP status is monitored and toggled from your bar.", "WARP settings description")
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    ToggleSetting {
        settingKey: "listenerEnabled"
        label: I18n.tr("Real-time Listener", "WARP settings listener label")
        description: I18n.tr("Enable the live warp-cli status listener for instant updates. Disabling falls back to manual refresh only.", "WARP settings listener description")
        defaultValue: true
    }

    SliderSetting {
        settingKey: "restartInterval"
        label: I18n.tr("Restart Interval", "WARP settings interval label")
        description: I18n.tr("How long to wait before restarting the listener if it crashes.", "WARP settings interval description")
        defaultValue: 5000
        minimum: 1000
        maximum: 30000
        step: 1000
        unit: "ms"
        leftIcon: "schedule"
    }

    StyledRect {
        width: parent.width
        height: statusColumn.height + Theme.spacingL * 2
        radius: Theme.cornerRadius
        color: Theme.surfaceContainer
        border.width: 0

        Column {
            id: statusColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingS

            StyledText {
                text: I18n.tr("Current Status", "WARP settings status label")
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
                color: Theme.surfaceVariantText
            }

            StyledText {
                text: WarpToggleService.statusText
                font.pixelSize: Theme.fontSizeMedium
                color: {
                    if (!WarpToggleService.isAvailable)
                        return Theme.error;
                    if (WarpToggleService.isConnecting)
                        return Theme.warning;
                    return WarpToggleService.isConnected ? Theme.primary : Theme.surfaceText;
                }
            }

            StyledText {
                visible: WarpToggleService.isConnected && WarpToggleService.networkHealth
                text: WarpToggleService.networkHealth
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }

            StyledText {
                visible: !WarpToggleService.isConnected && WarpToggleService.disconnectReason && !WarpToggleService.isConnecting
                text: WarpToggleService.disconnectReason
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }
        }
    }
}
