import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as P5Support

PlasmoidItem {
    id: root
    property string summary: "🔋 …"
    property string details: ""
    readonly property string cmd: "$HOME/.local/bin/device-batteries"

    preferredRepresentation: fullRepresentation
    toolTipMainText: "Device Batteries"
    toolTipSubText: details

    fullRepresentation: MouseArea {
        Layout.minimumWidth: label.implicitWidth + 8
        Layout.preferredWidth: label.implicitWidth + 8
        onClicked: root.refresh()
        PlasmaComponents.Label {
            id: label
            anchors.centerIn: parent
            text: root.summary
        }
    }

    P5Support.DataSource {
        id: exec
        engine: "executable"
        connectedSources: []
        onNewData: (source, data) => {
            const lines = (data["stdout"] || "").trim().split("\n");
            root.summary = lines[0] || "🔋 —";
            root.details = lines.slice(1).join("\n");
            disconnectSource(source);
        }
    }

    function refresh() { exec.connectSource(cmd) }

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
