import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
  implicitHeight: sleepButton.height
  implicitWidth: sleepButton.width
  Button {
    id: sleepButton
    height: inputHeight
    width: inputHeight
    hoverEnabled: true
    contentItem: Text {
      text: "󰤄"
      font.family: config.Font
      font.pointSize: config.FontSize * 1.2
      color: config.crust
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
    }
    background: Rectangle {
      id: sleepButtonBg
      color: config.red
      radius: 15
    }
    states: [
      State {
        name: "hovered"
        when: sleepButton.hovered
        PropertyChanges {
          target: sleepButtonBg
          color: config.rosewater
        }
      }
    ]
    transitions: Transition {
      PropertyAnimation {
        properties: "color"
        duration: 300
      }
    }
    onClicked: sddm.suspend()
  }
}
