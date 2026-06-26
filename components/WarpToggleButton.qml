import QtQuick
import qs.Common
import qs.Widgets

Rectangle {
    id: root
    height: 44
    width: parent.width
    radius: Theme.cornerRadius
    color: mouseArea.containsMouse
        ? Theme.primaryHoverLight
        : Theme.surfaceLight
    border.width: {
        if (!isAvailable || isBusy)
            return 0;
        if (isConnecting)
            return 2;
        return isConnected ? 2 : 1;
    }
    border.color: {
        if (!isAvailable || isBusy)
            return "transparent";
        if (isConnecting)
            return Theme.warning;
        return mouseArea.containsMouse
            ? Theme.primary
            : (isConnected ? Theme.primary : Theme.outlineLight);
    }

    property bool isConnected: false
    property bool isConnecting: false
    property bool isAvailable: true
    property bool isBusy: false

    signal clicked

    Row {
        anchors.centerIn: parent
        spacing: Theme.spacingS

        DankIcon {
            anchors.verticalCenter: parent.verticalCenter
            property real spinAngle: 0
            rotation: root.isConnecting ? spinAngle : 0
            name: {
                if (!root.isAvailable)
                    return "error";
                if (root.isConnecting)
                    return "sync";
                return root.isConnected ? "cloud_off" : "cloud";
            }
            size: 20
            color: {
                if (!root.isAvailable || root.isBusy)
                    return Theme.surfaceVariantText;
                if (root.isConnecting)
                    return Theme.warning;
                return root.isConnected ? Theme.primary : Theme.surfaceText;
            }
            NumberAnimation on spinAngle {
                from: 0
                to: 360
                duration: 1000
                loops: Animation.Infinite
                running: root.isConnecting
            }
        }

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            text: {
                if (!root.isAvailable)
                    return I18n.tr("Unavailable", "WARP toggle button");
                if (root.isConnecting)
                    return I18n.tr("Connecting...", "WARP toggle button");
                return root.isConnected
                    ? I18n.tr("Disconnect", "WARP toggle button")
                    : I18n.tr("Connect", "WARP toggle button");
            }
            font.pixelSize: Theme.fontSizeMedium
            font.weight: Font.Medium
            color: {
                if (!root.isAvailable || root.isBusy)
                    return Theme.surfaceVariantText;
                if (root.isConnecting)
                    return Theme.warning;
                return root.isConnected ? Theme.primary : Theme.surfaceText;
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.isAvailable && !root.isBusy ? Qt.PointingHandCursor : Qt.ForbiddenCursor
        enabled: root.isAvailable && !root.isBusy
        onClicked: root.clicked()
    }
}
