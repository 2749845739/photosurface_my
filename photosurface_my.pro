QT += quick

CONFIG += c++11

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

#pro文件中换行时，必须使用反斜杠
#SOURCES += \
#main.cpp
SOURCES += main.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    resources/photosurface.icns




#TEMPLATE = app

#QT += qml quick
#android: qtHaveModule(androidextras) {
#    QT += androidextras
#    DEFINES += REQUEST_PERMISSIONS_ON_ANDROID
#}
#qtHaveModule(widgets): QT += widgets
#SOURCES += main.cpp
#RESOURCES += photosurface.qrc

#target.path = $$[QT_INSTALL_EXAMPLES]/demos/photosurface
#INSTALLS += target
#ICON = resources/icon.png
#macos: ICON = resources/photosurface.icns
#win32: RC_FILE = resources/photosurface.rc


