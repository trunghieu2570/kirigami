import QtQuick
import QtQuick.Controls
import QtQuick.Window
import org.kde.kirigami as Kirigami
import QtTest
import "../tests"

TestCase {
    id: testCase

    Kirigami.MnemonicData.enabled: true
    Kirigami.MnemonicData.label: "设置(&S)"

    width: 400
    height: 400

    function test_press() {
        compare(Kirigami.MnemonicData.richTextLabel, "设置")
    }
}
