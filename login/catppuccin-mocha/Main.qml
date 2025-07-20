import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import "Components"

Item {
  id: root
  height: Screen.height
  width: Screen.width
  Rectangle {
    id: background
    anchors.fill: parent
    height: parent.height
    width: parent.width
    z: 0
    color: config.base
  }
  Image {
    id: backgroundImage
    anchors.fill: parent
    height: parent.height
    width: parent.width
    fillMode: Image.PreserveAspectCrop
    visible: config.CustomBackground == "true" ? true : false
    z: 1
    source: config.Background
    asynchronous: false
    cache: true
    mipmap: true
    clip: true
  }
  Item {
    id: mainPanel
    z: 3
    anchors {
      fill: parent
    }
    // Hora (Horas grandes)
    Text {
      id: hours
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 200
      font.bold: true
      color: "#b4befe"
      text: Qt.formatDateTime(new Date(), "hh")
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: parent.top
      anchors.topMargin: 180 // Bajado más
    }

    // Minutos (Debajo de horas)
    Text {
      id: minutes
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 200
      font.bold: true
      color: "#b4befe"
      text: Qt.formatDateTime(new Date(), "mm")
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: hours.bottom
      anchors.topMargin: 5 // Bajado más
    }

    // Actualizador del reloj
    Timer {
      interval: 1000
      running: true
      repeat: true
      onTriggered: {
        hours.text = Qt.formatDateTime(new Date(), "hh")
        minutes.text = Qt.formatDateTime(new Date(), "mm")
      }
    }
    LoginPanel {
      id: loginPanel
      anchors.fill: parent
    }
  }
}
