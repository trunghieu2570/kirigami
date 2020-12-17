import QtQuick 2.12
import QtQuick.Controls 2.12 as QQC2
import org.kde.kirigami 2.12 as Kirigami
import org.kde.kirigami.private 2.13
import QtTest 1.0

Kirigami.PageRow {
    id: root
    TestCase {
        name: "AvatarTests"
        function test_latin_name() {
            compare(NameUtils.isStringUnsuitableForInitials("Nate Martin"), false)
            compare(NameUtils.initialsFromString("Nate Martin"), "NM")

            compare(NameUtils.isStringUnsuitableForInitials("Kalanoka"), false)
            compare(NameUtils.initialsFromString("Kalanoka"), "K")

            compare(NameUtils.isStringUnsuitableForInitials("Why would anyone use such a long not name in the field of the Name"), false)
            compare(NameUtils.initialsFromString("Why would anyone use such a long not name in the field of the Name"), "WN")

            compare(NameUtils.isStringUnsuitableForInitials("Live-CD User"), false)
            compare(NameUtils.initialsFromString("Live-CD User"), "LU")
        }
        // these are just randomly sampled names from internet pages in the
        // source languages of the name
        function test_jp_name() {
            compare(NameUtils.isStringUnsuitableForInitials("北里 柴三郎"), false)
            compare(NameUtils.initialsFromString("北里 柴三郎"), "北")

            compare(NameUtils.isStringUnsuitableForInitials("小野田 寛郎"), false)
            compare(NameUtils.initialsFromString("小野田 寛郎"), "小")
        }
        function test_cn_name() {
            compare(NameUtils.isStringUnsuitableForInitials("蔣經國"), false)
            compare(NameUtils.initialsFromString("蔣經國"), "蔣")
        }
        function test_bad_names() {
            compare(NameUtils.isStringUnsuitableForInitials("151231023"), true)
        }
    }
}
