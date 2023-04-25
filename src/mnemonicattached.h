/*
 *  SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef MNEMONICATTACHED_H
#define MNEMONICATTACHED_H

#include <QObject>
#include <QQuickWindow>
#include <QtQml>

/**
 * @brief This Attached property is used to calculate automated keyboard sequences
 * to trigger actions based upon their text.
 *
 * If an "&" mnemonic is used (ie "&Ok"), the system will attempt to assign
 * the desired letter giving it priority, otherwise a letter among the ones
 * in the label will be used if possible and not conflicting.
 * Different kinds of controls will have different priorities in assigning the
 * shortcut: for instance the "Ok/Cancel" buttons in a dialog will have priority
 * over fields of a FormLayout.
 *
 * @see ::ControlType
 *
 * @brief This attached property allows to define keyboard sequences to trigger
 * actions based upon their text.
 *
 * A mnemonic, otherwise known as an accelerator, is an accessibility feature to
 * signal to the user that a certain action (typically in a menu) can be
 * triggered by pressing Alt + a certain key that is indicated by an ampersand
 * sign (&). For instance, a File menu could be marked in code as &File and
 * would be displayed to the user with an underscore under the letter F. This
 * allows to invoke actions without having to navigate the UI with a mouse.
 *
 * This class automates the management of mnemonics, so if a key is already
 * taken, the next available key is used. Likewise, certain components get
 * increased priority: an "OK/Cancel" buttons in a Dialog will have priority
 * over fields of a FormLayout.
 *
 * Mnemonics are already managed by visual QtQuick and Kirigami controls, so
 * only use this class to implement your own visual QML controls.
 *
 * @since org.kde.kirigami 2.3
 */
class MnemonicAttached : public QObject
{
    Q_OBJECT
    /**
     * @brief This property holds the label of the control that we want to
     * compute a mnemonic for.
     *
     * For example: ``"Label:"`` or ``"&Ok"``
     */
    Q_PROPERTY(QString label READ label WRITE setLabel NOTIFY labelChanged)

    /**
     * @brief This property holds the user-visible final label.
     *
     * The user-visible final label, which will have the shortcut letter
     * underlined, such as "&lt;u&gt;O&lt;/u&gt;k".
     */
    Q_PROPERTY(QString richTextLabel READ richTextLabel NOTIFY richTextLabelChanged)

    /**
     * @brief This property holds the label with an "&" mnemonic in the place
     * which defines the shortcut key.
     *
     * @note The "&" will be automatically added if it is not set by the
     * user.
     */
    Q_PROPERTY(QString mnemonicLabel READ mnemonicLabel NOTIFY mnemonicLabelChanged)

    /**
     * @brief This property sets whether this mnemonic is enabled.
     *
     * Set this to @c false to disable the accelerator marker (&) and its
     * respective shortcut.
     *
     * default: ``true``
     */
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)

    /**
     * @brief This property holds the control type that this mnemonic is
     * attached to.
     *
     * @note Different types of controls have different importance and priority
     * for shortcut assignment.
     *
     * @see ::ControlType
     */
    Q_PROPERTY(MnemonicAttached::ControlType controlType READ controlType WRITE setControlType NOTIFY controlTypeChanged)

    /**
     * @brief This property holds the final key sequence.
     *
     * @note The final key sequence will be Alt+alphanumeric char.
     */
    Q_PROPERTY(QKeySequence sequence READ sequence NOTIFY sequenceChanged)

    /**
     * @brief This property holds whether the user is pressing alt and
     * accelerators should be shown.
     *
     * @since KDE Frameworks 5.72
     * @since org.kde.kirigami 2.15
     */
    Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged)

public:
    enum ControlType {
        ActionElement, /**< pushbuttons, checkboxes etc */
        DialogButton, /**< buttons for dialogs */
        MenuItem, /**< Menu items */
        FormLabel, /**< Buddy label in a FormLayout*/
        SecondaryControl, /**< Other controls that are considered not much important and low priority for shortcuts */
    };
    Q_ENUM(ControlType)

    explicit MnemonicAttached(QObject *parent = nullptr);
    ~MnemonicAttached() override;

    void setLabel(const QString &text);
    QString label() const;

    QString richTextLabel() const;
    QString mnemonicLabel() const;

    void setEnabled(bool enabled);
    bool enabled() const;

    void setControlType(MnemonicAttached::ControlType controlType);
    ControlType controlType() const;

    QKeySequence sequence();

    void setActive(bool active);
    bool active() const;

    // QML attached property
    static MnemonicAttached *qmlAttachedProperties(QObject *object);

protected:
    bool eventFilter(QObject *watched, QEvent *e) override;
    void updateSequence();

Q_SIGNALS:
    void labelChanged();
    void enabledChanged();
    void sequenceChanged();
    void richTextLabelChanged();
    void mnemonicLabelChanged();
    void controlTypeChanged();
    void activeChanged();

private:
    void calculateWeights();
    bool installEventFilterForWindow(QQuickWindow *wnd);
    bool removeEventFilterForWindow(QQuickWindow *wnd);

    // TODO: to have support for DIALOG_BUTTON_EXTRA_WEIGHT etc, a type enum should be exported
    enum {
        // Additional weight for first character in string
        FIRST_CHARACTER_EXTRA_WEIGHT = 50,
        // Additional weight for the beginning of a word
        WORD_BEGINNING_EXTRA_WEIGHT = 50,
        // Additional weight for a 'wanted' accelerator ie string with '&'
        WANTED_ACCEL_EXTRA_WEIGHT = 150,
        // Default weight for an 'action' widget (ie, pushbuttons)
        ACTION_ELEMENT_WEIGHT = 50,
        // Additional weight for the dialog buttons (large, we basically never want these reassigned)
        DIALOG_BUTTON_EXTRA_WEIGHT = 300,
        // Weight for FormLayout labels (low)
        FORM_LABEL_WEIGHT = 20,
        // Weight for Secondary controls which are considered less important (low)
        SECONDARY_CONTROL_WEIGHT = 10,
        // Default weight for menu items
        MENU_ITEM_WEIGHT = 250,
    };

    // order word letters by weight
    int m_weight = 0;
    int m_baseWeight = 0;
    ControlType m_controlType = SecondaryControl;
    QMap<int, QChar> m_weights;

    QString m_label;
    QString m_actualRichTextLabel;
    QString m_richTextLabel;
    QString m_mnemonicLabel;
    QKeySequence m_sequence;
    bool m_enabled = true;
    bool m_active = false;

    QPointer<QQuickWindow> m_window;

    // global mapping of mnemonics
    // TODO: map by QWindow
    static QHash<QKeySequence, MnemonicAttached *> s_sequenceToObject;
};

QML_DECLARE_TYPEINFO(MnemonicAttached, QML_HAS_ATTACHED_PROPERTIES)

#endif // MnemonicATTACHED_H
