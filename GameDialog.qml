import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

Dialog {
    parent: Overlay.overlay
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    width: parent.width * 0.95
    modal: true
    standardButtons: Dialog.Ok
}
