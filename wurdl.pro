QT += quick quickcontrols2

CONFIG += c++17

# automatically handle l10n
CONFIG += lrelease embed_translations

# auto register QML types
CONFIG += qmltypes
QML_IMPORT_NAME = org.caybro.wurdl
QML_IMPORT_MAJOR_VERSION = 1

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        main.cpp \
        wurdlcontroller.cpp

RESOURCES += qml.qrc

TRANSLATIONS = i18n/base.ts \
               i18n/qml_cs.ts

lupdate_only {
  SOURCES = *.qml
}

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    wurdlcontroller.h

DISTFILES += \
    Cell.qml \
    KbdLetter.qml \
    KbdRow.qml
