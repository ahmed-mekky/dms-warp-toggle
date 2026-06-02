import QtQuick
import qs.Common
import qs.Widgets

DankButton {
    id: root
    property bool isConnected: false
    property bool isConnecting: false
    property bool isAvailable: true
    property bool isBusy: false

    buttonHeight: 44
    width: parent.width
    anchors.horizontalCenter: parent.horizontalCenter

    iconName: {
        if (!root.isAvailable)
            return "error";
        if (root.isConnecting)
            return "sync";
        return root.isConnected ? "cloud_off" : "cloud";
    }

    text: {
        if (!root.isAvailable)
            return I18n.tr("Unavailable", "WARP toggle button");
        if (root.isConnecting)
            return I18n.tr("Connecting...", "WARP toggle button");
        return root.isConnected
            ? I18n.tr("Disconnect", "WARP toggle button")
            : I18n.tr("Connect", "WARP toggle button");
    }

    backgroundColor: {
        if (!root.isAvailable || root.isBusy)
            return Theme.surfaceContainer;
        if (root.isConnecting)
            return Theme.warningContainer;
        return Theme.primary;
    }

    textColor: {
        if (!root.isAvailable || root.isBusy)
            return Theme.surfaceVariantText;
        if (root.isConnecting)
            return Theme.warning;
        return Theme.primaryText;
    }

    enabled: root.isAvailable && !root.isBusy
}
