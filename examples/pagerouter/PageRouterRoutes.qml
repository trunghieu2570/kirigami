import QtQuick 2.15
import org.kde.kirigami 2.20 as Kirigami

Kirigami.ApplicationWindow {
    id: root

    Kirigami.PageRouter {
        pageStack: root.pageStack.columnView

        Kirigami.PageRoute {
            name: "routeOne"
            Component {
                Kirigami.Page {
                    // Page contents...
                }
            }
        }
        Kirigami.PageRoute {
            name: "routeTwo"
            Component {
                Kirigami.Page {
                    // Page contents...
                }
            }
        }
        Kirigami.PageRoute {
            name: "routeThree"
            Component {
                Kirigami.Page {
                    // Page contents...
                }
            }
        }
    }
}
