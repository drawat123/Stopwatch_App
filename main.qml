import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import com.company.stopwatch 1.0

ApplicationWindow {
    id: root
    width: 600
    height: 800
    visible: true
    title: "Stopwatch"
    color: "#303030"
    property color mainLabelColor: "#CCC3D6"
    property color lapLabelColor: "#E6DBD7"
    property var stopwatchStates: ["Start", "Resume", "Running"]
    property string stopwatchState: stopwatchStates[0]
    property real lapDataWidth: appButtonRow.width

    Backend {
        id: mainStopwatchTimer
        onNotice: {
            mainStopwatchLabel.text = data
        }
        Component.onCompleted: {
            reset()
        }
    }

    Backend {
        id: lapStopwatchTimer
        onNotice: {
            lapStopwatchLabel.text = data
        }
        Component.onCompleted: {
            reset()
        }
    }

    Column {
        id: column
        spacing: 25
        width: parent.width
        height: parent.height - appButtonRow.height - spacing

        Label {
            id: mainStopwatchLabel
            text: ""
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 40
            font.bold: true
            color: mainLabelColor
            topPadding: lapDetailsData.count > 0 ? column.spacing : root.height / 3
            Behavior on topPadding {
                NumberAnimation {
                    duration: 300
                }
            }
        }

        Label {
            id: lapStopwatchLabel
            text: ""
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 20
            font.bold: true
            visible: lapDetailsData.count > 0
            color: lapLabelColor
        }

        Item {
            width: lapDataWidth
            height: children[0].implicitHeight
            anchors.left: lapsView.left
            visible: lapDetailsData.count > 0
            Label {
                text: "Lap"
                font.pointSize: 14
                color: lapLabelColor
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Lap times"
                font.pointSize: 14
                color: lapLabelColor
            }
            Label {
                anchors.right: parent.right
                text: "Overall time"
                font.pointSize: 14
                color: lapLabelColor
            }
        }

        Rectangle {
            width: lapDataWidth
            height: 2
            anchors.left: lapsView.left
            visible: lapDetailsData.count > 0
            color: lapLabelColor
        }

        ListView {
            id: lapsView
            width: lapDataWidth + vBar.width
            height: parent.height - y
            anchors.horizontalCenter: parent.horizontalCenter
            visible: lapDetailsData.count > 0
            clip: true

            model: ListModel {
                id: lapDetailsData
            }

            ScrollBar.vertical: ScrollBar {
                id: vBar
                active: true
            }

            delegate: Item {
                width: lapDataWidth
                height: children[0].implicitHeight
                visible: lapDetailsData.count > 0
                Label {
                    text: lapNum
                    font.pointSize: 14
                    color: lapLabelColor
                    bottomPadding: 15
                }
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: lapTime
                    font.pointSize: 14
                    color: lapLabelColor
                }
                Label {
                    anchors.right: parent.right
                    text: overallTime
                    font.pointSize: 14
                    color: mainLabelColor
                }
            }

            add: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1.0
                    duration: 400
                }
            }

            displaced: Transition {
                NumberAnimation {
                    properties: "x,y"
                    duration: 400
                    easing.type: Easing.OutBack
                }

                NumberAnimation {
                    property: "opacity"
                    to: 1.0
                }
                NumberAnimation {
                    property: "scale"
                    to: 1.0
                }
            }
        }
    }

    Row {
        id: appButtonRow
        spacing: 10
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        bottomPadding: column.spacing
        RoundButton {
            id: startBtn
            text: stopwatchState
            font.pointSize: 15
            horizontalPadding: 30
            highlighted: stopwatchState !== stopwatchStates[0]
            onPressed: {
                if (stopwatchState === stopwatchStates[0]
                        || stopwatchState === stopwatchStates[1]) {

                    if (stopwatchState === stopwatchStates[0]) {
                        mainStopwatchTimer.start()
                    } else {
                        mainStopwatchTimer.resume()
                        if (lapDetailsData.count > 0) {
                            lapStopwatchTimer.resume()
                        }
                    }

                    stopwatchState = stopwatchStates[2]
                }
            }
        }

        RoundButton {
            id: stopBtn
            text: "Stop"
            font.pointSize: startBtn.font.pointSize
            enabled: stopwatchState === stopwatchStates[2]
            horizontalPadding: startBtn.horizontalPadding
            onPressed: {
                mainStopwatchTimer.stop()
                if (lapDetailsData.count > 0) {
                    lapStopwatchTimer.stop()
                }

                stopwatchState = stopwatchStates[1]
            }
        }

        RoundButton {
            id: resetBtn
            text: "Reset"
            font.pointSize: startBtn.font.pointSize
            enabled: stopwatchState === stopwatchStates[1]
            horizontalPadding: startBtn.horizontalPadding
            onPressed: {
                mainStopwatchTimer.reset()
                lapStopwatchTimer.reset()
                lapDetailsData.clear()

                stopwatchState = stopwatchStates[0]
            }
        }

        RoundButton {
            id: lapBtn
            text: "Lap"
            font.pointSize: startBtn.font.pointSize
            enabled: stopwatchState === stopwatchStates[2]
            horizontalPadding: startBtn.horizontalPadding
            onPressed: {
                // Not more than 99 laps
                if (lapDetailsData.count > 98) {
                    return
                }

                let lN = (lapDetailsData.count + 1).toString()
                if (lapDetailsData.count < 9) {
                    lN = "0" + lN
                }

                let lT = lapDetailsData.count > 0 ? lapStopwatchLabel.text : mainStopwatchLabel.text
                lapDetailsData.insert(0, {
                                          "lapNum": lN,
                                          "lapTime": lT,
                                          "overallTime": mainStopwatchLabel.text
                                      })

                lapStopwatchTimer.reset()
                lapStopwatchTimer.start()
            }
        }
    }
}
