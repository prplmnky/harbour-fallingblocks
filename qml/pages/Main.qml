import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.fallingblocks.SailfishWidgets.Components 1.1

Page {
    Column {
        anchors.fill: parent
        x: Theme.paddingLarge
        y: Theme.paddingLarge

        PageHeader { title: qsTr("Start") }
    }

    Heading {
        anchors.centerIn: parent
        text: qsTr("Falling blocks")
    }
}