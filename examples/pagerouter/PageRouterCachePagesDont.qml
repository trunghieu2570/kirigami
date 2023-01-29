import QtQuick 2.15
import org.kde.kirigami 2.20 as Kirigami

Kirigami.ApplicationWindow {
    id: root

    Kirigami.PageRouter {
        initialRoute: "home"
        pageStack: root.pageStack.columnView

        // home can't be pushed onto the route twice
        Component.onCompleted: navigateToRoute(["home", "home"])

        Kirigami.PageRoute {
            name: "home"
            cache: true
            Component {
                Kirigami.Page {
                    // Page contents...
                }
            }
        }
    }
}
