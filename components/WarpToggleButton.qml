import QtQuick
import qs.Common
import qs.Widgets

Rectangle {
    id: root
    height: Theme.iconSizeLarge + Theme.spacingM
    width: parent.width
    radius: Theme.cornerRadius
    color: mouseArea.containsMouse
        ? (root.isConnected ? Theme.errorHover : Theme.primaryHoverLight)
        : Theme.surfaceLight
    border.width: {
        if (isBusy)
            return 0;
        if (isConnecting)
            return 2;
        return isConnected ? 2 : 1;
    }
    border.color: {
        if (isBusy)
            return "transparent";
        if (isConnecting)
            return Theme.warning;
        return isConnected ? Theme.error : Theme.primary;
    }

    property bool isConnected: false
    property bool isConnecting: false
    property bool isBusy: false
    property string pendingAction: ""

    signal clicked

    Row {
        anchors.centerIn: parent
        spacing: Theme.spacingS

        DankIcon {
            anchors.verticalCenter: parent.verticalCenter
            property real spinAngle: 0
            rotation: (root.isConnecting || root.isBusy) ? spinAngle : 0
            name: {
                if (root.isConnecting || root.isBusy)
                    return "sync";
                return root.isConnected ? "cloud_off" : "cloud";
            }
            size: Theme.iconSizeSmall + Theme.spacingXS
            color: {
                if (root.isBusy)
                    return Theme.surfaceVariantText;
                if (root.isConnecting)
                    return Theme.warning;
                return root.isConnected ? Theme.error : Theme.primary;
            }
            NumberAnimation on spinAngle {
                from: 0
                to: 360
                duration: 1000
                loops: Animation.Infinite
                running: root.isConnecting || root.isBusy
            }
        }

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            text: {
                if (root.isBusy)
                    return root.pendingAction === "disconnect"
                        ? I18n.tr("Disconnecting...", "WARP toggle button")
                        : I18n.tr("Connecting...", "WARP toggle button");
                if (root.isConnecting)
                    return I18n.tr("Connecting...", "WARP toggle button");
                return root.isConnected
                    ? I18n.tr("Disconnect", "WARP toggle button")
                    : I18n.tr("Connect", "WARP toggle button");
            }
            font.pixelSize: Theme.fontSizeMedium
            font.weight: Font.Medium
            color: {
                if (root.isBusy)
                    return Theme.surfaceVariantText;
                if (root.isConnecting)
                    return Theme.warning;
                return root.isConnected ? Theme.error : Theme.primary;
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.isBusy ? Qt.BusyCursor : Qt.PointingHandCursor
        enabled: !root.isBusy
        onClicked: root.clicked()
    }
}
