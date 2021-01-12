import QtQuick 2.10
import QtQuick.Controls 2.12 as QQC2
import org.kde.kirigami 2.16 as Kirigami

QQC2.TextField {
    Kirigami.Clipboard.copy: function() {
        console.log("Ignoring copy...")
        return true
    }
    Kirigami.Clipboard.paste: function(content) {
        if (content.hasText) {
            console.log(content.text)
        }
    }
}