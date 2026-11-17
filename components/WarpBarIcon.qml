import QtQuick
import qs.Common
import qs.Widgets

DankIcon {
    id: root

    property bool isConnected: false
    property bool isConnecting: false
    property bool isBusy: false
    property bool isApplyingMode: false
    property bool isAvailable: false
    property real barThickness: 48

    anchors.verticalCenter: parent.verticalCenter
    property real spinAngle: 0

    rotation: (isConnecting || isBusy || isApplyingMode) ? spinAngle : 0
    name: {
        if (isConnecting || isBusy || isApplyingMode)
            return "sync";
        if (!isAvailable)
            return "error";
        return isConnected ? "cloud" : "cloud_off";
    }
    size: Theme.barIconSize(barThickness)
    color: {
        if (isConnecting || isBusy || isApplyingMode)
            return Theme.warning;
        if (!isAvailable)
            return Theme.error;
        return isConnected ? Theme.primary : Theme.surfaceVariantText;
    }

    NumberAnimation on spinAngle {
        from: 0
        to: 360
        duration: 1000
        loops: Animation.Infinite
        running: isConnecting || isBusy || isApplyingMode
    }
}
