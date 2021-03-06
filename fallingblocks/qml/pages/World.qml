import QtQuick 2.2
import Sailfish.Silica 1.0
import harbour.fallingblocks.SailfishWidgets.armv7hl.SailfishWidgets.Components 3.3
import harbour.fallingblocks.SailfishWidgets.armv7hl.SailfishWidgets.Settings 3.3
import harbour.fallingblocks.SailfishWidgets.armv7hl.SailfishWidgets.JS 3.3
import harbour.fallingblocks.FallingBlocks.Controllers 1.0
import harbour.fallingblocks.FallingBlocks.Sprites 1.0
import harbour.fallingblocks.FallingBlocks.JS 1.0
import harbour.fallingblocks.QmlLogger 2.0

Page {
    property alias gameStatus: game
    property alias lives: player.lives
    property alias scores: levelStatus.score
    property bool forceBackNavigation: false
    property bool initialized: false
    property int currentSpeed: UIConstants.speed
    property int currentInterval: UIConstants.interval
    property variant currentSpawnRatio: UIConstants.spawnRatioEasy

    backNavigation: forceBackNavigation
                    || (!playerControl.pressed
                        && (!!settings ? !settings.disableSwipeToHome : true))
    id: world

    ApplicationSettings {
        id: settings
        applicationName: "harbour-fallingblocks"
        fileName: "settings"

        property int lives: UIConstants.settingsLivesDefault
        property bool disableSwipeToHome: false
        property int highScore1
        property int highScore2
        property int highScore3
        property int highScore4
        property int highScore5

        signal updatedSettings

        onSettingsPropertyUpdated: updatedSettings()
        onSettingsInitialized: updatedSettings()

        onUpdatedSettings: {
            if (settings.disableSwipeToHome == undefined) {
                playerControl.parent = player
            }
            playerControl.parent = settings.disableSwipeToHome ? world : player

            ////////
            //Ignore if game's already in progress
            if (!initialized)
                player.lives = UIConstants.lives[settings.lives]
        }
    }

    Heading {
        anchors.centerIn: parent
        id: gameOver
        text: qsTr("Game Over")
        horizontalAlignment: Text.AlignHCenter
        visible: gameEnded
        z: 1000
    }

    Heading {
        anchors.centerIn: parent
        id: countdown
        horizontalAlignment: Text.AlignHCenter
        visible: levelStatus.invincible
        opacity: 1
        z: 1000
        font.pixelSize: Theme.fontSizeLarge

        Timer {
            id: countdownTimer
            interval: 100
            repeat: true
            triggeredOnStart: true

            property real count: UIConstants.invincibilityDuration / 1000

            onTriggered: {
                if(countdown.opacity > 0)
                    countdown.opacity -= 0.1
                else
                    countdown.opacity = 1

                count -= 0.1
                if(count <= 0) {
                    count = UIConstants.invincibilityDuration / 1000
                    stop()
                }
                
                countdown.text = Math.floor(count).toString()
            }
        }

        onVisibleChanged: {
            opacity: 1                                   
            text = Math.floor(UIConstants.invincibilityDuration / 1000).toString()
            countdownTimer.count = 10

            if(visible) {
                countdownTimer.start()
            }
            else {
                countdownTimer.stop()
            }
        }
    }

    MouseArea {
        onClicked: infoColumn.visible = !infoColumn.visible
        anchors.fill: infoColumn
        acceptedButtons: Qt.AllButtons
        z: 1000
    }

    Column {
        id: infoColumn
        width: parent.width - Theme.paddingLarge * 2
        y: Theme.paddingLarge
        x: Theme.paddingLarge
        z: 1000

        InformationalLabel {
            anchors.right: parent.right
            text: levelStatus.score < UIConstants.scoreInfinite ? qsTr("∞") : levelStatus.score + "  " + qsTr(
                                                    "Score")
        }

        InformationalLabel {
            anchors.right: parent.right
            text: (lives == UIConstants.livesInfinite ? qsTr("∞") : lives) + "  " + qsTr(
                      "Lives")
        }

        InformationalLabel {
            anchors.right: parent.right
            text: qsTr("Difficulty") + " " + function () {
                if (levelStatus.level == UIConstants.levelEasy)
                    return qsTr("Easy")
                if (levelStatus.level == UIConstants.levelMedium)
                    return qsTr("Medium")
                if (levelStatus.level == UIConstants.levelHard)
                    return qsTr("Hard")
                if (levelStatus.level == UIConstants.levelExtreme)
                    return qsTr("Extreme")
                return qsTr("Nightmare")
            }()
        }

    }


    CreationController {
        animate: game.gameStarted
        id: createLoop
        interval: currentInterval
        speed: currentSpeed
        spawnRatio: currentSpawnRatio
        repeat: true
        spriteParent: world
        triggeredOnStart: true

        onObjectCompleted: {
            initialized = true
            //Create a new collision object
            object.collision.interval = UIConstants.collisionInterval
            object.collision.repeat = true
            object.collision.triggeredOnStart = true
            object.collision.source = player
            object.collisionDetected.connect(function () {
                if(object.objectName === UIConstants.blockNameStar)
                    levelStatus.invincible = true

                levelStatus.score += levelStatus.invincible ? Math.abs(object.points) : object.points
                if (lives != UIConstants.livesInfinite && !levelStatus.invincible)
                    lives -= object.objectName === UIConstants.blockNameEvil ? 1 : 0

                object.animate = false
                object.visible = false
                object.destroy()
            })
            object.collision.start()
        }
    }

    GameController {
        id: game
        onAppStatusChanged: {
            if (!gameEnded && !gameStarted && pageStack.currentPage === world) {
                forceBackNavigation = true
                pageStack.navigateBack()
                forceBackNavigation = false
            }
        }

        onGameStartedChanged: gameStarted ? createLoop.start(
                                                ) : createLoop.stop()

        onGameEndedChanged: {
            forceBackNavigation = true
            if(!!levelStatus && levelStatus.score != null) {
                var settingHighScore = [settings.highScore1,
                        settings.highScore2,
                        settings.highScore3,
                        settings.highScore4,
                        settings.highScore5,
                        levelStatus.score]
                settingHighScore.sort(function(a, b){return b - a})
                settings.highScore1 = settingHighScore[0]
                settings.highScore2 = settingHighScore[1]
                settings.highScore3 = settingHighScore[2]
                settings.highScore4 = settingHighScore[3]
                settings.highScore5 = settingHighScore[4]
            }
        }
    }

    LevelController {
        id: levelStatus

        property int lastScore: 0

        Timer {
            id: timer
            repeat: true
            interval: UIConstants.invincibilityInterval
            triggeredOnStart: true
            property int length: 0

            onTriggered: {
                if(length == 0)
                    Console.info("Starting invincibility")

                length += UIConstants.invincibilityInterval
                player.color = ["yellow","gold","purple", "orange"][MathHelper.randomInt(0, 4)]
                if(length >= UIConstants.invincibilityDuration) {
                    stop()
                    length = 0
                    player.color = "white"
                    levelStatus.invincible = false

                    Console.info("Stopping invincibility")
                }
            }
        }
        onScoreChanged: {
            if(score > (lastScore + 50000)) {
                player.lives++
                lastScore += 50000
            }
            if(score < 0)
                game.endGame()
        }

        onInvincibleChanged: {
            Console.log("Player is invincible " + invincible)
            if(invincible) {
                timer.start()
            }
        }

        onLevelChanged: {
            currentSpeed = UIConstants.levelSpeeds[level]
            currentInterval = UIConstants.intervals[level]
            currentSpawnRatio = UIConstants.spawnRatios[level]
        }
    }

    MouseArea {
        anchors.fill: parent
        drag.target: player
        drag.axis: Drag.XAxis
        drag.minimumX: 0
        drag.maximumX: world.width - player.width
        enabled: !gameEnded
        id: playerControl
    }

    PlayerBlock {
        property int lives

        id: player
        x: (parent.width - width) / 2
        y: parent.height - height - Theme.paddingLarge

        onLivesChanged: if (!lives)
                            game.endGame()
    }
}
