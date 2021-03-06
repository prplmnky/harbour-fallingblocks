import QtQuick 2.2
import Sailfish.Silica 1.0
import harbour.fallingblocks.QmlLogger 2.0
import harbour.fallingblocks.SailfishWidgets.armv7hl.SailfishWidgets.Components 3.3
import harbour.fallingblocks.FallingBlocks.JS 1.0
import harbour.fallingblocks.FallingBlocks.Sprites 1.0

Dialog {

    PageColumn {
        title: qsTr("Help")

        Heading {
            text: qsTr("How to play")
        }

        Paragraph {
            text: qsTr("It's simple! Catch as many blocks as you can while avoiding the mysterious 'evil block'.")
        }

        Paragraph {
            text: qsTr("Move your player by pressing and holding the stationary block at the bottom of the screen. You may move left and right in order to align yourself to the falling block above. Upon successful alignment you will increase your score. However, touching the 'evil block' will descrease your score and the number of lives you have. The game ends once all lives are depleted.")
        }

        Heading {
            text: qsTr("Scoring")
        }

        Grid {
            columns: 2
            spacing: Theme.paddingSmall

            EasyBlock {
            }
            InformationalLabel {
                text: qsTr("Slowest block") + " +" + UIConstants.pointsEasy
            }

            MediumBlock {
            }
            InformationalLabel {
                text: qsTr("Slightly faster") + " +" + UIConstants.pointsMedium
            }

            HardBlock {
            }
            InformationalLabel {
                text: qsTr("Fastest") + " +" + UIConstants.pointsHard
            }

            EvilBlock {
            }
            InformationalLabel {
                text: qsTr("Takes a life") + " " + UIConstants.pointsEvil
            }

            StarBlock {
            }
            InformationalLabel {
                text: qsTr("Grants invincibility") + " " + UIConstants.pointsStar
            }
        }
    }

}
