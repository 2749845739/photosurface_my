import QtQuick 2.15
import QtQuick.Window 2.15
import Qt.labs.folderlistmodel 2.12
import QtQuick.Dialogs 1.0

Window {
    id: root
    visible: true
    width: 1024
    height: 600
    color: "gray"
    title: qsTr(" Photo Surface")
    property int highestZ: 0
    property real defaultSize: 200
    property var currentFrame: undefined
    property real surfaceViewportRatio: 1.5
    property var imageNameFilters: ["*.png", "*.jpg", "*.gif"]
    property string picturesLocation: ""

    // 窗口打开后 默认开启文件选择对话框，没找到图片？
    FileDialog {
        id: fileDialog
        title: "choose a folder with some images"
        selectFolder: true
        //自定义的变量是斜体黑字
        folder: picturesLocation
        //        系统标准路径  not workR
        //        folder: StandardPaths.standardLocations(
        //                    StandardPaths.PicturesLocation)[0]
        onAccepted: {
            //            console.log("You choose: " + fileDialog.fileUrl)
            folderModel.folder = fileUrl + "/"
            console.log("folderModel.folder = " + folderModel.folder)
        }
    }

    // 可拖拽的区域--常用于触摸屏
    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width * surfaceViewportRatio
        contentHeight: height * surfaceViewportRatio

        // 重复器   每一个model都是一个
        Repeater {
            model: FolderListModel {
                id: folderModel
                objectName: "folderModel"
                showDirs: true
                nameFilters: imageNameFilters
            }

            //equal to delegate
            Rectangle {
                id: photoFrame
                width: image.width * (1 + 0.1 * image.height / image.width)
                height: image.height * 1.1
                scale: defaultSize / Math.max(image.sourceSize.width,
                                              image.sourceSize.height)
                Behavior on scale {
                    // 数值动画变化 200毫秒内变化完成
                    NumberAnimation {
                        duration: 200
                    }
                }
                Behavior on x {
                    NumberAnimation {
                        duration: 200
                    }
                }
                Behavior on y {
                    NumberAnimation {
                        duration: 200
                    }
                }

                border.color: "black"
                border.width: 5
                smooth: true
                antialiasing: true
                // rectangle creation process is complete
                Component.onCompleted: {
                    x = Math.random() * root.width - width / 2
                    y = Math.random() * root.height - height / 2
                    rotation = Math.random() * 13 - 6
                    console.log(image.source + "--component creation process is completed")
                }

                // 一定要在rectangle-photoframe内部
                Image {
                    id: image
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    //搜索图片的路径
                    source: folderModel.folder + fileName
                    // more clear
                    antialiasing: true
                }
                //delegate 里面规定了触摸姿势的规则
                PinchArea {
                    anchors.fill: parent
                    pinch.target: photoFrame
                    pinch.minimumRotation: -360
                    pinch.maximumRotation: 360
                    pinch.minimumScale: 0.1
                    pinch.maximumScale: 10
                    pinch.dragAxis: Pinch.XAndYAxis
                    onPinchStarted: setFrameColor()
                    property real zRestore: 0
                    //zoom---缩放
                    onSmartZoom: {
                        if (pinch.scale > 0) {
                            photoFrame.rotation = 0
                            photoFrame.scale = Math.min(root.width,
                                                        root.height) / Math.max(
                                        image.sourceSize.width,
                                        image.sourceSize.height) * 0.85
                            photoFrame.x = flick.contentX + (flick.width - photoFrame.width) / 2
                            photoFrame.y = flick.contentY + (flick.height - photoFrame.height) / 2
                            zRestore = photoFrame.z
                            photoFrame.z = ++root.highestZ
                        } else {
                            photoFrame.rotation = pinch.previousAngle
                            photoFrame.scale = pinch.previousScale
                            photoFrame.x = pinch.previousCenter.x - photoFrame.width / 2
                            photoFrame.y = pinch.previousCenter.y - photoFrame.height / 2
                            photoFrame.z = zRestore
                            --root.highestZ
                        }
                    }
                    //鼠标区域用于拖拽 drag
                    MouseArea {
                        //                        id: dragArea
                        hoverEnabled: true
                        anchors.fill: parent
                        drag.target: photoFrame
                        scrollGestureEnabled: false //2-finger-flick gesture should pass through to the Flickable
                        onPressed: {
                            photoFrame.z = ++root.highestZ
                            parent.setFrameColor()
                        }
                        onEntered: parent.setFrameColor()
                        onWheel: {
                            if (wheel.modifiers & Qt.ControlModifier) {
                                photoFrame.rotation += wheel.angleDelta.y / 120 * 5
                                if (Math.abs(photoFrame.rotation) < 4)
                                    photoFrame.rotation = 0
                            } else {
                                photoFrame.rotation += wheel.angleDelta.x / 120
                                if (Math.abs(photoFrame.rotation) < 0.6)
                                    photoFrame.rotation = 0
                                var scaleBefore = photoFrame.scale
                                photoFrame.scale += photoFrame.scale * wheel.angleDelta.y / 120 / 10
                            }
                        }
                    }

                    function setFrameColor() {
                        console.log("emit setFrameColor")
                        if (currentFrame)
                            currentFrame.border.color = "black"
                        currentFrame = photoFrame
                        currentFrame.border.color = "red"
                    }
                }
            }
        }
    }

    // 触摸区以外  垂直滚动条
    Rectangle {
        id: verticalScrollDecorator
        anchors.right: parent.right
        anchors.margins: 2
        color: "white"
        border.color: "black"
        border.width: 1
        width: 10
        radius: 2 //半径
        antialiasing: true
        height: flick.height * (flick.height / flick.contentHeight) - (width - anchors.margins) * 2
        y: (flick.contentY - flick.originY) * (flick.height / flick.contentHeight)
        // 不透明性
        NumberAnimation on opacity {
            id: vfade
            to: 0 // 0.2s内变成透明的
            duration: 200
        }
        onYChanged: {
            // 不透明 完全显现
            opacity = 1
            scrollFadeTimer.restart()
        }
    }

    // 水平滚动条
    Rectangle {
        id: horizontalScrollDecorator
        anchors.bottom: parent.bottom
        anchors.margins: 2
        color: "white"
        border.color: "black"
        border.width: 1
        height: 10
        radius: 2
        antialiasing: true
        width: flick.width * (flick.width / flick.contentWidth) - (height - anchors.margins) * 2
        x: (flick.contentX - flick.originX) * (flick.width / flick.contentWidth)
        NumberAnimation on opacity {
            id: hfade
            to: 0
            duration: 500
        }
        onXChanged: {
            opacity = 1.0
            scrollFadeTimer.restart()
        }
    }

    Timer {
        id: scrollFadeTimer
        interval: 1000
        onTriggered: {
            hfade.start()
            vfade.start()
        }
    }

    Image {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 10 //边距
        //resources 和 photosurface.qml同级
        source: "resources/folder.png"

        MouseArea {
            anchors.fill: parent
            anchors.margins: -10
            onClicked: fileDialog.open()
            hoverEnabled: true // 悬停
            onPositionChanged: {
                console.log("emit onPositionChanged")
                tooltip.visible = false
                hoverTimer.start()
            }
            onExited: {
                tooltip.visible = false
                hoverTimer.stop()
            }

            Timer {
                id: hoverTimer //悬停计时器
                interval: 1000
                onTriggered: {
                    tooltip.x = parent.mouseX
                    tooltip.y = parent.mouseY
                    tooltip.visible = true
                }
            }

            Rectangle {
                id: tooltip
                border.color: "black"
                color: "beige"
                width: tooltipText.implicitWidth + 8
                height: tooltipText.implicitHeight + 8
                visible: false
                Text {
                    id: tooltipText
                    anchors.centerIn: parent
                    text: "open an image directory (" + openShortcut.sequenceString + ")"
                }
            }
        }

        // 快捷键
        Shortcut {
            id: openShortcut
            sequence: StandardKey.Open
            onActivated: fileDialog.open()
        }
    }

    Text {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        color: "darkgrey"
        wrapMode: Text.WordWrap
        font.pointSize: 8
        text: "On a touchscreen: use two fingers to zoom and rotate, one finger to drag\n"
              + "With a mouse: drag normally, use the vertical wheel to zoom, horizontal wheel to rotate, or hold Ctrl while using the vertical wheel to rotate"
    }

    Shortcut {
        sequence: StandardKey.Quit
        onActivated: Qt.quit()
    }

    //    Component.onCompleted: {
    //        if (typeof contextInitiaUrl != 'undefined') {
    //            // Launched from C++ with context properties set.
    //            imageNameFilters = contextImageNameFilters
    //            picturesLocation = contextPicturesLOcation
    //            if (contextInitialUrl == "")
    //                fileDialog.open()
    //            else
    //                folderModel.folder = contextInitialUrl + "/"
    //        } else {
    //            fileDialog.open()
    //        }
    //    }
}
