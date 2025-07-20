import QtQuick 2.15

    // Hora (Horas grandes)
    Text {
      id: hours
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 150
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
      font.pixelSize: 150
      color: "#b4befe"
      text: Qt.formatDateTime(new Date(), "mm")
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: hours.bottom
      anchors.topMargin: 30 // Bajado más
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

