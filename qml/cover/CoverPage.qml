import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.fallingblocks.QmlLogger 2.0
import harbour.fallingblocks.SailfishWidgets.Components 1.2
import harbour.fallingblocks.SailfishWidgets.JS 1.2

StandardCover {
    coverTitle: qsTr("Falling Blocks")
    imageSource: "qrc:///images/desktop.png"

    property bool inProgress
    signal startNewGame()

    Subtext {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: label.top
        anchors.bottomMargin: Theme.paddingSmall
        text: inProgress ? qsTr("In Progress") : ""
    }

    CoverActionList {
        CoverAction {
            iconSource: IconThemes.iconCoverNew
            onTriggered: {
                Console.debug("CoverPage: new game action")
                startNewGame()
            }
        }
    }
}
