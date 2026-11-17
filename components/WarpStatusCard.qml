import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets

StyledRect {
    id: root

    property bool isConnected: false
    property bool isConnecting: false
    property bool isAvailable: false
    property bool isBusy: false
    property bool isSwitchingMode: false
    property string pendingAction: ""
    property bool compact: false
    property string networkHealth: ""
    property string disconnectReason: ""
    property string operationMode: ""
    property string accountType: ""
    property bool isManaged: false
    property string organization: ""
    property string tunnelProtocol: ""
    property string colo: ""
    property string latency: ""
    property string loss: ""
    property string sentTraffic: ""
    property string receivedTraffic: ""
    property var modeOptions: []

    signal toggleRequested
    signal modeRequested(string mode)

    readonly property var modeLabels: {
        const labels = [];
        for (let i = 0; i < modeOptions.length; i++)
            labels.push(modeOptions[i].label);
        return labels;
    }

    readonly property color statusColor: {
        if (isBusy || isConnecting)
            return Theme.warning;
        if (!isAvailable)
            return Theme.error;
        if (isConnected)
            return Theme.primary;
        return Theme.surfaceVariantText;
    }

    readonly property color statusContainerColor: {
        if (isBusy || isConnecting)
            return Theme.withAlpha(Theme.warning, 0.15);
        if (!isAvailable)
            return Theme.withAlpha(Theme.error, 0.15);
        if (isConnected)
            return Theme.withAlpha(Theme.primary, 0.15);
        return Theme.surfaceContainerHighest;
    }

    readonly property color statusDotColor: {
        if (isBusy || isConnecting)
            return Theme.warning;
        if (!isAvailable)
            return Theme.error;
        if (isConnected)
            return Theme.primary;
        return Theme.outline;
    }

    readonly property string statusTitle: {
        if (isBusy || isConnecting)
            return pendingAction === "disconnect"
                ? I18n.tr("Disconnecting...", "WARP status header")
                : I18n.tr("Connecting...", "WARP status header");
        if (!isAvailable)
            return I18n.tr("WARP Unavailable", "WARP status header");
        return isConnected
            ? I18n.tr("WARP Connected", "WARP status header")
            : I18n.tr("WARP Disconnected", "WARP status header");
    }

    readonly property string statusSubtitle: {
        if (isBusy)
            return I18n.tr("Applying change", "WARP status subtitle");
        if (!isAvailable)
            return I18n.tr("warp-cli is not available", "WARP status subtitle");
        if (isConnecting)
            return I18n.tr("Establishing tunnel", "WARP status subtitle");
        if (isConnected)
            return networkHealth ? networkHealth : I18n.tr("Network healthy", "WARP status subtitle");
        return disconnectReason ? friendlyDisconnectReason(disconnectReason) : I18n.tr("Not connected", "WARP status subtitle");
    }

    readonly property string accountLabel: {
        if (!accountType)
            return I18n.tr("Not registered", "WARP account label");
        switch (accountType.toLowerCase()) {
        case "free":
            return I18n.tr("Free", "WARP account type");
        case "team":
            return I18n.tr("Teams", "WARP account type");
        case "enterprise":
            return I18n.tr("Enterprise", "WARP account type");
        default:
            return accountType;
        }
    }

    readonly property string accountDetail: {
        if (isManaged && organization)
            return organization;
        if (isManaged)
            return I18n.tr("Managed", "WARP managed account");
        return "";
    }

    readonly property var statItems: {
        const items = [];
        if (tunnelProtocol)
            items.push({
                "label": I18n.tr("Protocol", "WARP tunnel stat"),
                "value": tunnelProtocol
            });
        if (latency)
            items.push({
                "label": I18n.tr("Latency", "WARP tunnel stat"),
                "value": latency
            });
        if (loss)
            items.push({
                "label": I18n.tr("Loss", "WARP tunnel stat"),
                "value": loss
            });
        if (colo)
            items.push({
                "label": I18n.tr("Colo", "WARP tunnel stat"),
                "value": colo
            });
        if (!compact) {
            if (sentTraffic)
                items.push({
                    "label": I18n.tr("Sent", "WARP tunnel stat"),
                    "value": sentTraffic
                });
            if (receivedTraffic)
                items.push({
                    "label": I18n.tr("Received", "WARP tunnel stat"),
                    "value": receivedTraffic
                });
        }
        return items;
    }

    readonly property bool hasStats: isConnected && statItems.length > 0

    function modeLabel(value) {
        for (let i = 0; i < modeOptions.length; i++) {
            if (modeOptions[i].value === value)
                return modeOptions[i].label;
        }
        return value ? value : I18n.tr("Unknown", "Unknown WARP mode");
    }

    function modeValue(label) {
        for (let i = 0; i < modeOptions.length; i++) {
            if (modeOptions[i].label === label)
                return modeOptions[i].value;
        }
        return label;
    }

    function friendlyDisconnectReason(reason) {
        switch (reason) {
        case "Settings Changed":
            return I18n.tr("Settings changed — reconnect to apply", "WARP disconnect reason");
        case "Admin directed disconnect":
            return I18n.tr("Disconnected by administrator", "WARP disconnect reason");
        case "The network is not available":
            return I18n.tr("Network unavailable", "WARP disconnect reason");
        case "Paused":
            return I18n.tr("Paused", "WARP disconnect reason");
        default:
            return reason;
        }
    }

    implicitHeight: contentColumn.implicitHeight + Theme.spacingL * 2
    height: implicitHeight
    radius: Theme.cornerRadius
    color: Theme.surfaceContainerHigh
    border.width: 0

    Column {
        id: contentColumn

        anchors.fill: parent
        anchors.margins: Theme.spacingL
        spacing: root.compact ? Theme.spacingM : Theme.spacingL

        RowLayout {
            width: parent.width
            spacing: Theme.spacingM

            StyledRect {
                Layout.preferredWidth: Theme.iconSize * 2
                Layout.preferredHeight: Theme.iconSize * 2
                radius: Theme.cornerRadius
                color: root.statusContainerColor
                border.width: 0

                DankIcon {
                    anchors.centerIn: parent
                    property real spinAngle: 0

                    rotation: (root.isConnecting || root.isBusy) ? spinAngle : 0
                    name: {
                        if (root.isConnecting || root.isBusy)
                            return "sync";
                        if (!root.isAvailable)
                            return "error";
                        return root.isConnected ? "cloud" : "cloud_off";
                    }
                    size: Theme.iconSize + Theme.spacingXS
                    color: root.statusColor

                    NumberAnimation on spinAngle {
                        from: 0
                        to: 360
                        duration: 1000
                        loops: Animation.Infinite
                        running: root.isConnecting || root.isBusy
                    }
                }
            }

            Column {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: Theme.spacingXS

                StyledText {
                    width: parent.width
                    text: root.statusTitle
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Bold
                    color: Theme.surfaceText
                    elide: Text.ElideRight
                }

                Row {
                    width: parent.width
                    spacing: Theme.spacingS

                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        color: root.statusDotColor
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        width: parent.width - 8 - Theme.spacingS
                        text: root.statusSubtitle
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        elide: Text.ElideRight
                    }
                }
            }

            DankToggle {
                hideText: true
                checked: root.isConnected
                toggling: root.isBusy || root.isConnecting
                enabled: !root.isBusy
                Layout.alignment: Qt.AlignVCenter
                onClicked: root.toggleRequested()
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.withAlpha(Theme.outline, 0.12)
        }

        RowLayout {
            width: parent.width
            spacing: Theme.spacingM

            DankIcon {
                name: "tune"
                size: Theme.iconSizeSmall + Theme.spacingXS
                color: Theme.surfaceVariantText
                Layout.alignment: Qt.AlignVCenter
            }

            StyledText {
                text: I18n.tr("Mode", "WARP mode label")
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }

            DankIcon {
                visible: root.isSwitchingMode
                name: "sync"
                size: Theme.iconSizeSmall + Theme.spacingXS
                color: Theme.warning
                Layout.alignment: Qt.AlignVCenter
                property real spinAngle: 0

                rotation: spinAngle

                NumberAnimation on spinAngle {
                    from: 0
                    to: 360
                    duration: 1000
                    loops: Animation.Infinite
                    running: root.isSwitchingMode
                }
            }

            DankDropdown {
                compactMode: true
                dropdownWidth: 180
                currentValue: root.isSwitchingMode ? I18n.tr("Applying...", "WARP mode applying") : root.modeLabel(root.operationMode)
                options: root.modeLabels
                enabled: root.isAvailable && !root.isSwitchingMode
                Layout.alignment: Qt.AlignVCenter
                onValueChanged: value => root.modeRequested(root.modeValue(value))
            }
        }

        RowLayout {
            width: parent.width
            spacing: Theme.spacingM

            DankIcon {
                name: "account_circle"
                size: Theme.iconSizeSmall + Theme.spacingXS
                color: Theme.surfaceVariantText
                Layout.alignment: Qt.AlignVCenter
            }

            StyledText {
                text: I18n.tr("Account", "WARP account label")
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }

            StyledText {
                text: root.accountLabel
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Medium
                color: Theme.surfaceText
                Layout.alignment: Qt.AlignVCenter
            }

            StyledText {
                visible: !root.compact && root.accountDetail.length > 0
                text: root.accountDetail
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                Layout.maximumWidth: 160
                Layout.alignment: Qt.AlignVCenter
                elide: Text.ElideRight
            }
        }

        StyledText {
            visible: root.hasStats
            text: I18n.tr("Tunnel", "WARP tunnel section")
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
            color: Theme.surfaceVariantText
        }

        Grid {
            id: statsGrid

            width: parent.width
            columns: 2
            columnSpacing: Theme.spacingS
            rowSpacing: Theme.spacingS
            visible: root.hasStats

            Repeater {
                model: root.statItems

                delegate: StyledRect {
                    required property var modelData

                    width: (statsGrid.width - statsGrid.columnSpacing) / 2
                    height: statColumn.implicitHeight + Theme.spacingM * 2
                    radius: Theme.cornerRadius
                    color: Theme.surfaceContainer
                    border.width: 0

                    Column {
                        id: statColumn

                        anchors.fill: parent
                        anchors.margins: Theme.spacingM
                        spacing: Theme.spacingXS

                        StyledText {
                            text: modelData.label
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                        }

                        StyledText {
                            width: parent.width
                            text: modelData.value
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }
}
