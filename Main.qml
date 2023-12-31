import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Dialogs
import QtMultimedia

Window {
    id: root

    function round(num) {
        return Math.floor(num*100)/100
    }
    function msToTime(s) {

        // Pad to 2 or 3 digits, default is 2
        function pad(n, z) {
            z = z || 2;
            return ('00' + n).slice(-z);
        }

        var ms = s % 1000;
        s = (s - ms) / 1000;
        var secs = s % 60;
        s = (s - secs) / 60;
        var mins = s % 60;
        var hrs = (s - mins) / 60;

        return pad(hrs) + ':' + pad(mins) + ':' + pad(secs) + '.' + pad(ms, 3);
    }

    width: 960
    height: 600
    visible: true
    title: "AD Player"
    Material.accent: Material.Indigo

    FileDialog {
        id: fileDialog
        title: "Please choose a file"
    }

    MediaPlayer {
        id: player
        source: fileDialog.selectedFile
        audioOutput: AudioOutput {}
        onSourceChanged: {
            repeatRangeSlider.from = 0
            repeatRangeSlider.to = player.duration
            repeatRangeSlider.first.value = 0
            repeatRangeSlider.second.value = player.duration
        }
        onPositionChanged: {
            if(player.position >= repeatRangeSlider.second.value ||
                    player.position < repeatRangeSlider.first.value) {
                player.position = repeatRangeSlider.first.value
            }
        }
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.centerIn: parent
        anchors.margins: 20
        spacing: 30
        focus: true
        onActiveFocusChanged: forceActiveFocus()
        Keys.onPressed: (event)=> {
                            switch(event.key) {
                                case Qt.Key_Left:
                                player.position -= volumeSlider.value*1000
                                break;
                                case Qt.Key_Right:
                                player.position += volumeSlider.value*1000
                                break;
                                case Qt.Key_Up:
                                speedSlider.increase()
                                break;
                                case Qt.Key_Down:
                                speedSlider.decrease()
                                break;
                                case Qt.Key_I:
                                zoomInButton.clicked()
                                break;
                                case Qt.Key_O:
                                zoomOutButton.clicked()
                                break;
                                case Qt.Key_Space:
                                if(player.playing) {
                                    player.pause()
                                } else {
                                    player.play()
                                }
                                break;
                                case Qt.Key_R:
                                player.position = repeatRangeSlider.first.value
                                break;
                            }
                            event.accepted = true
                        }
        ColumnLayout {
            id: buttonLayout
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 170
            spacing: 10
            Button {
                id: chooseFileBtn
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width * 0.2
                Layout.preferredHeight: 100
                Layout.alignment: Qt.AlignHCenter
                contentItem: Text {
                    text: "Choose file!"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 10
                    font.pixelSize: 24
                }
                onClicked: fileDialog.open()
            }
            Label {
                id: filenameTxt
                Layout.fillHeight: true
                Layout.preferredWidth: 0.5 * parent.width
                Layout.preferredHeight: 40
                Layout.alignment: Qt.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                fontSizeMode: Text.Fit
                minimumPixelSize: 10
                font.pixelSize: 24
                text: String(fileDialog.currentFile) ? (String(fileDialog.currentFile) + " - seekable: " + player.seekable) : "filename"
            }
            RowLayout {
                id: controlLayout
                Layout.fillWidth: false
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width * 0.8
                Layout.preferredHeight: 100
                Layout.alignment: Qt.AlignHCenter
                spacing: 20
                Button {
                    id: previousButton
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    contentItem: Text {
                        text: root.round(volumeSlider.value) + " <<"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 10
                        font.pixelSize: 24
                    }
                    onClicked: player.position -= volumeSlider.value*1000

                }
                Button {
                    id: playButton
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    contentItem: Text {
                        text: player.playbackState == MediaPlayer.PlayingState ? "Pause" : "Play"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 10
                        font.pixelSize: 24
                    }
                    onClicked: {
                        if(player.playing) {
                            player.pause()
                        } else {
                            player.play()
                        }
                    }
                }
                Button {
                    id: resetButton
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    contentItem: Text {
                        text: "Reset"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 10
                        font.pixelSize: 24
                    }
                    onClicked: player.position = repeatRangeSlider.first.value
                }
                Button {
                    id: nextButton
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    contentItem: Text {
                        text: ">> " + root.round(volumeSlider.value)
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 10
                        font.pixelSize: 24
                    }
                    onClicked: player.position += volumeSlider.value*1000
                }
            }
        }
        ColumnLayout {
            id: sliderLayout
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 430
            property int fontSize: fromProgressLabel.fontInfo.pixelSize
            ColumnLayout {
                id: progressLayout
                Layout.preferredHeight: 100
                RowLayout {
                    id: progressLabelLayout
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    Layout.fillHeight: true
                    Layout.preferredHeight: 50
                    Text {
                        id: fromProgressLabel
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 1
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 10
                        font.pixelSize: 24
                        verticalAlignment: Text.AlignVCenter
                        text: msToTime(progressSlider.from)
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 1
                        font.pixelSize: sliderLayout.fontSize
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: msToTime(progressSlider.value)
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 1
                        font.pixelSize: sliderLayout.fontSize
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        text: msToTime(progressSlider.to)
                    }
                }
                Slider {
                    id: progressSlider
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 50
                    from: Math.floor(repeatRangeSlider.first.value)
                    to: Math.floor(repeatRangeSlider.second.value)
                    stepSize: 1
                    value: pressed ? value : player.position
                    onValueChanged: {
                        if(pressed) {
                            player.position = progressSlider.value
                            player.play()
                        }
                    }
                }
            }
            ColumnLayout {
                id: repeatRangeLayout
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: 100
                RowLayout {
                    id: repeatRangeLabelLayout
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    Layout.preferredHeight: 50
                    spacing: 10
                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 10
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: sliderLayout.fontSize
                        text: "Repeat Range:"
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 6
                        Layout.leftMargin: 1
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: sliderLayout.fontSize
                        text:msToTime(repeatRangeSlider.first.value)
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 3
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: sliderLayout.fontSize
                        text: "-->"
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 6
                        Layout.rightMargin: 1
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: sliderLayout.fontSize
                        text: msToTime(repeatRangeSlider.second.value)
                    }
                    Button {
                        id: zoomOutButton
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 4
                        contentItem: Text {
                            text: "-"
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            fontSizeMode: Text.Fit
                            minimumPixelSize: 14
                            font.pixelSize: 24
                        }
                        autoRepeat: true
                        onClicked: {
                            var delta = 0.1 * (repeatRangeSlider.to - repeatRangeSlider.from)
                            repeatRangeSlider.from = Math.max(0, repeatRangeSlider.from - delta)
                            repeatRangeSlider.to = Math.min(player.duration, repeatRangeSlider.to + delta)
                        }
                        onPressAndHold: clicked()

                    }
                    Button {
                        id: zoomInButton
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 4
                        contentItem: Text {
                            text: "+"
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            fontSizeMode: Text.Fit
                            minimumPixelSize: 14
                            font.pixelSize: 24
                        }
                        autoRepeat: true
                        onClicked: {
                            var delta = 0.1 * (repeatRangeSlider.to - repeatRangeSlider.from)
                            if(repeatRangeSlider.from < repeatRangeSlider.first.value) {
                                repeatRangeSlider.from = Math.min(repeatRangeSlider.first.value, repeatRangeSlider.from + delta)
                            }
                            if(repeatRangeSlider.to > repeatRangeSlider.second.value) {
                                repeatRangeSlider.to = Math.max(repeatRangeSlider.second.value, repeatRangeSlider.to - delta)
                            }
                        }
                        onPressAndHold: clicked()

                    }
                }
                RangeSlider {
                    id: repeatRangeSlider
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 50
                    from: 0
                    to: 0
                    stepSize: 1
                }
            }
            ColumnLayout {
                id: speedLayout
                Layout.preferredHeight: 100
                Text {
                    id: speedLabel
                    Layout.leftMargin: 10
                    Layout.fillHeight: true
                    Layout.preferredHeight: 50
                    Layout.alignment: Qt.AlignBottom
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: sliderLayout.fontSize
                    text: "Speed: " + root.round(speedSlider.value)
                }
                Slider {
                    id: speedSlider
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 50
                    from: 0.5
                    to: 1.5
                    stepSize: 0.01
                    value: 1
                    onValueChanged: player.playbackRate = value
                }
            }
            ColumnLayout {
                id: volumeLayout
                Layout.preferredHeight: 100
                Text {
                    id: volumeLabel
                    Layout.leftMargin: 10
                    Layout.fillHeight: true
                    Layout.preferredHeight: 50
                    Layout.alignment: Qt.AlignBottom
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: sliderLayout.fontSize
                    text: "VolPreNex: " + root.round(volumeSlider.value)
                }
                Slider {
                    id: volumeSlider
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 50
                    from: 0
                    to: 10
                    stepSize: 0.1
                    value: 2
                }
            }
        }
    }

    Rectangle {
        id: popup
        visible: false
        height: 200
        width: 400
        radius: 20
        border.color: "black"
        anchors.centerIn: parent
        Text {
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 14
            text: "Created by: mnaduc@gmail.com\n\nSupported keys\nKey_R: Reset\nKey_Space: Play/Pause\n Key_Left/Right: Change progress position\nKey_Up/Down: Increase/decrease speed\nKey_I/O: zoom In/Out repeatRange"
        }
    }

    MouseArea {
        id: infoButton
        height: 30
        width: 30
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        hoverEnabled: true
        Rectangle {
            id: backgroundInfoButton
            anchors.fill: parent
            radius: 15
            Text {
                id: contentInfoButton
                text: "!"
                anchors.fill: parent
                font.pixelSize: 20
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    Item {
        states: [
            State {
                name: "activeInfoPopup"
                when: infoButton.containsMouse || infoButton.pressed
                PropertyChanges {target: layout; opacity: 0.5}
                PropertyChanges {target: backgroundInfoButton; border.color: "black"}
                PropertyChanges {target: contentInfoButton; color: "black"}
                PropertyChanges {target: popup; visible: true}
            },
            State {
                name: "inactiveInfoPopup"
                when: !(infoButton.containsMouse || infoButton.pressed)
                PropertyChanges {target: layout; opacity: 1}
                PropertyChanges {target: backgroundInfoButton; border.color: "grey"}
                PropertyChanges {target: contentInfoButton; color: "grey"}
                PropertyChanges {target: popup; visible: false}
            }
        ]
    }
}
