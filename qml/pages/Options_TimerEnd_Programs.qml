import QtQuick 2.0
import Sailfish.Silica 1.0

import QtMultimedia 5.0


import "../lib/"


Page {
    id: page
    property var options
    property var appstate
    property var firstPage

    allowedOrientations: firstPage.allowedOrientations
    orientation: firstPage.orientation

    SilicaListView {
        id: listView

        anchors.fill: parent
        contentHeight: mainColumn.height

        VerticalScrollDecorator{}
        PageHeader {
            title: qsTr("Run Programs")
        }

    }
}
