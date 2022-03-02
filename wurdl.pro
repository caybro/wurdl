QT += quick quickcontrols2
QT -= widgets

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

VERSION = 1.21
DEFINES += VERSION_NUMBER=\\\"$${VERSION}\\\"

SOURCES += \
        main.cpp \
        wurdlcontroller.cpp

HEADERS += \
    wurdlcontroller.h

RESOURCES += qml.qrc

TRANSLATIONS = i18n/base.ts \
               i18n/qml_cs.ts

OTHER_FILES = *.qml

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

# Android specific
android {
    ANDROID_VERSION_NAME = $${VERSION}
    ANDROID_VERSION_CODE = 14

    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

    DISTFILES += \
      android/AndroidManifest.xml \
      android/build.gradle \
      android/gradle.properties \
      android/gradle/wrapper/gradle-wrapper.jar \
      android/gradle/wrapper/gradle-wrapper.properties \
      android/gradlew \
      android/gradlew.bat \
      android/res/values/libs.xml
}
