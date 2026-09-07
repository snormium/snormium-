import QtQuick
Rectangle {
    id: root
    color: "#12101C"
    property int stage
    onStageChanged: if (stage === 1) intro.running = true; else if (stage === 5) outro.running = true
    Image { id: logo; source: "images/logo.png"; anchors.centerIn: parent; width: 160; height: 160; opacity: 0; sourceSize.width: 160; sourceSize.height: 160 }
    Rectangle {
        anchors { top: logo.bottom; topMargin: 32; horizontalCenter: parent.horizontalCenter }
        width: 240; height: 3; radius: 2; color: "#221F35"
        Rectangle { id: fill; width: 0; height: parent.height; radius: 2; color: "#8B5CF6" }
    }
    OpacityAnimator { id: intro; target: logo; from: 0; to: 1; duration: 500; running: false }
    NumberAnimation { target: fill; property: "width"; from: 0; to: 240; duration: 2500; running: true; easing.type: Easing.InOutQuad }
    OpacityAnimator { id: outro; target: root; from: 1; to: 0; duration: 400; running: false }
}
