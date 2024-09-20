/*
 *  SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef FORMLAYOUTATTACHED_H
#define FORMLAYOUTATTACHED_H

#include <QObject>
#include <QQmlEngine>

class QQuickItem;

/*!
 * This attached property contains the information for decorating a org::kde::kirigami::FormLayout:
 *
 * It contains the text labels of fields and information about sections.
 *
 * Some of its properties can be used with other <a href="https://doc.qt.io/qt-6/qml-qtquick-layouts-layout.html">Layout</a> types.
 * \code{.qml}
 * import org.kde.kirigami as Kirigami
 *
 * Kirigami.FormLayout {
 *    TextField {
 *       Kirigami.FormData.label: "User:"
 *    }
 *    TextField {
 *       Kirigami.FormData.label: "Password:"
 *    }
 * }
 * \endcode
 * \sa org::kde::kirigami::FormLayout
 * \since Kirigami 2.3
 */
class FormLayoutAttached : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(FormData)
    QML_ATTACHED(FormLayoutAttached)
    QML_UNCREATABLE("")
    /*!
     * The label for a org::kde::kirigami::FormLayout field
     */
    Q_PROPERTY(QString label READ label WRITE setLabel NOTIFY labelChanged FINAL)
    /*!
     * The alignment for the label of a org::kde::kirigami::FormLayout field
     */
    Q_PROPERTY(int labelAlignment READ labelAlignment WRITE setLabelAlignment NOTIFY labelAlignmentChanged FINAL)
    /*!
     * If true, the child item of a org::kde::kirigami::FormLayout becomes a section separator, and
     * may have different looks:
     * * To make it just a space between two fields, just put an empty item with FormData.isSection:
     * \code
     * TextField {
     *     Kirigami.FormData.label: "Label:"
     * }
     * Item {
     *     Kirigami.FormData.isSection: true
     * }
     * TextField {
     *     Kirigami.FormData.label: "Label:"
     * }
     * \endcode
     *
     * * To make it a space with a section title:
     * \code
     * TextField {
     *     Kirigami.FormData.label: "Label:"
     * }
     * Item {
     *     Kirigami.FormData.label: "Section Title"
     *     Kirigami.FormData.isSection: true
     * }
     * TextField {
     *     Kirigami.FormData.label: "Label:"
     * }
     * \endcode
     *
     * * To make it a space with a section title and a separator line:
     * \code
     * TextField {
     *     Kirigami.FormData.label: "Label:"
     * }
     * Kirigami.Separator {
     *     Kirigami.FormData.label: "Section Title"
     *     Kirigami.FormData.isSection: true
     * }
     * TextField {
     *     Kirigami.FormData.label: "Label:"
     * }
     * \endcode
     * \sa org::kde::kirigami::FormLayout
     */
    Q_PROPERTY(bool isSection READ isSection WRITE setIsSection NOTIFY isSectionChanged FINAL)

    /*!
     * This property can only be used
     * in conjunction with a Kirigami.FormData.label,
     * often in a layout that is a child of a org::kde::kirigami::FormLayout.
     *
     * It then turns the item specified into a "buddy"
     * of the label, making it work as if it were
     * a child of the org::kde::kirigami::FormLayout.
     *
     * A buddy item is useful for instance when the label has a keyboard accelerator,
     * which when triggered provides active keyboard focus to the buddy item.
     *
     * By default buddy is the item that Kirigami.FormData is attached to.
     * Custom buddy can only be a direct child of that item; nested components
     * are not supported at the moment.
     *
     * \code
     * Kirigami.FormLayout {
     *     Layouts.ColumnLayout {
     *         // If the accelerator is in the letter S,
     *         // pressing Alt+S gives focus to the slider.
     *         Kirigami.FormData.label: "Slider label:"
     *         Kirigami.FormData.buddyFor: slider
     *
     *         QQC2.Slider {
     *             id: slider
     *             from: 0
     *             to: 100
     *             value: 50
     *         }
     *     }
     * }
     * \endcode
     */
    Q_PROPERTY(QQuickItem *buddyFor READ buddyFor WRITE setBuddyFor NOTIFY buddyForChanged FINAL)

public:
    explicit FormLayoutAttached(QObject *parent = nullptr);
    ~FormLayoutAttached() override;

    void setLabel(const QString &text);
    QString label() const;

    void setIsSection(bool section);
    bool isSection() const;

    QQuickItem *buddyFor() const;
    void setBuddyFor(QQuickItem *aBuddyFor);

    int labelAlignment() const;
    void setLabelAlignment(int alignment);

    // QML attached property
    static FormLayoutAttached *qmlAttachedProperties(QObject *object);

Q_SIGNALS:
    void labelChanged();
    void isSectionChanged();
    void buddyForChanged();
    void labelAlignmentChanged();

private:
    void resetBuddyFor();

    QString m_label;
    QString m_actualDecoratedLabel;
    QString m_decoratedLabel;
    QPointer<QQuickItem> m_buddyFor;
    bool m_isSection = false;
    int m_labelAlignment = 0;
};

QML_DECLARE_TYPEINFO(FormLayoutAttached, QML_HAS_ATTACHED_PROPERTIES)

#endif // FORMLAYOUTATTACHED_H
