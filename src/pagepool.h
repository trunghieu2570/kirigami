/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */
#pragma once

#include <QObject>
#include <QPointer>
#include <QQuickItem>

/**
 * @brief A Pool of Page objects, pages will be unique per url and the items
 * will be kept around unless explicitly deleted.
 *
 * Instances are C++ owned and can be deleted only manually using deletePage()
 * Instance are unique per url: if you need 2 different instances for a page
 * url, you should instantiate them in the traditional way
 * or use a different PagePool instance.
 *
 * @see kirigami::PagePoolAction
 */
class PagePool : public QObject
{
    Q_OBJECT
    /**
     * @brief This property holds the last url that was loaded with
     * ::loadPage().
     *
     * This is useful when you need to have a "checked" state for buttons or
     * list items that load the page when clicked.
     */
    Q_PROPERTY(QUrl lastLoadedUrl READ lastLoadedUrl NOTIFY lastLoadedUrlChanged)

    /**
     * @brief This property holds the last item that was loaded with loadPage.
     */
    Q_PROPERTY(QQuickItem *lastLoadedItem READ lastLoadedItem NOTIFY lastLoadedItemChanged)

    /**
     * @brief This property holds a list of all items either loaded or managed
     * by the PagePool.
     *
     * @since KDE Frameworks 5.84
     */
    Q_PROPERTY(QList<QObject *> items READ items NOTIFY itemsChanged)

    /**
     * @brief This property holds a list of all page URLs either loaded or
     * managed by the PagePool.
     *
     * @since KDE Frameworks 5.84
     */
    Q_PROPERTY(QList<QUrl> urls READ urls NOTIFY urlsChanged)

    /**
     * @brief This property sets whether to cache pages.
     *
     * If @c true (default) the pages will be kept around, will have C++
     * ownership and only one instance per page will be created.
     * If @c false the pages will have Javascript ownership (thus deleted on pop
     * by the page stacks) and each call to ::loadPage() will create a new page
     * instance. When ::cachePages is false, Components get cached nevertheless.
     *
     * default: ``true``
     */
    Q_PROPERTY(bool cachePages READ cachePages WRITE setCachePages NOTIFY cachePagesChanged)

public:
    PagePool(QObject *parent = nullptr);
    ~PagePool() override;

    QUrl lastLoadedUrl() const;
    QQuickItem *lastLoadedItem() const;
    QList<QObject *> items() const;
    QList<QUrl> urls() const;

    void setCachePages(bool cache);
    bool cachePages() const;

    /**
     * @brief This method loads the specified page and returns the page's instance
     * defined in the QML file.
     *
     * @note If cachePages is set to true, only one instance will be made per url.
     * @note If the url is remote (i.e. http), do not rely on the return value but
     * use the async callback instead.
     *
     * @param url full url of the item: it can be a well formed Url, an
     * absolute path or a relative one to the path of the qml file the
     * PagePool is instantiated from.
     * @param callback If we are loading a remote url, we can't have the
     * item immediately but will be passed as a parameter to the provided
     * callback. Normally, don't set a callback, use it only in case of
     * remote urls.
     * @returns the page instance that will have been created if necessary.
     * If the url is remote it will return null, as well will return null
     * if the callback has been provided.
     */
    Q_INVOKABLE QQuickItem *loadPage(const QString &url, QJSValue callback = QJSValue());

    /**
     * @brief This method loads the specified page and returns the page's instance
     * defined in the QML file with specified properties.
     *
     * @note If cachePages is set to true, only one instance will be made per url.
     * @note If the url is remote (i.e. https), do not rely on the return value but
     * use the async callback instead.
     *
     * @param url The full url of the item: it can be a well formed Url, an
     * absolute path or a relative path to the QML file the
     * PagePool is instantiated from.
     * @param callback If we are loading a remote url, we can't have the
     * item immediately but it will be passed as a parameter to the provided
     * callback. Normally, don't set a callback, use it only in case of
     * remote urls.
     * @param properties This is a <a href="https://doc.qt.io/qt-6/qvariant.html#QVariantMap-typedef">QVariantMap</a> object that sets the properties of the
     * page.
     * @param callback A method that is called after the page instance is created.
     * @returns The page instance that will be created if necessary.
     * If the url is remote or if the callback was provided, it will return null.
     */
    Q_INVOKABLE QQuickItem *loadPageWithProperties(const QString &url, const QVariantMap &properties, QJSValue callback = QJSValue());

    /**
     * @brief This method returns the url of the page for the given instance.
     * 
     * The returned value will be empty if there is no match.
     * @param item Page representing the QUrl you want.
     */
    Q_INVOKABLE QUrl urlForPage(QQuickItem *item) const;

    /**
     * @brief This method return the the page associated with a given URL, @c nullptr if there is no correspondence
     * @param url Url representing the Kirigami.Page you want.
     */
    Q_INVOKABLE QQuickItem *pageForUrl(const QUrl &url) const;

    /**
     * @brief This method returns whether the specified page is managed by the PagePool.
     * @param the page can be either a QQuickItem or an url
     */
    Q_INVOKABLE bool contains(const QVariant &page) const;

    /**
     * @brief This method deletes the specified page if it is managed by the PagePool.
     * @param page either the url or the instance of the page
     */
    Q_INVOKABLE void deletePage(const QVariant &page);

    /**
     * @brief This method returns the full url from an absolute or relative path.
     * @param file File path you want to convert to absolute path.
     */
    Q_INVOKABLE QUrl resolvedUrl(const QString &file) const;

    /**
     * @brief This method returns whether the URL is a local resource.
     *
     * The given URL is a local resource when it links to a local file, does
     * not have a set URL scheme, or when the scheme is set to  "qrc".
     * 
     * @see QUrl.scheme
     *
     * @param url The url you want to check.
     */
    Q_INVOKABLE bool isLocalUrl(const QUrl &url);

    /**
     * @brief This method deletes all pages managed by the PagePool.
     */
    Q_INVOKABLE void clear();

Q_SIGNALS:
    void lastLoadedUrlChanged();
    void lastLoadedItemChanged();
    void itemsChanged();
    void urlsChanged();
    void cachePagesChanged();

private:
    QQuickItem *createFromComponent(QQmlComponent *component, const QVariantMap &properties);

    QUrl m_lastLoadedUrl;
    QPointer<QQuickItem> m_lastLoadedItem;
    QHash<QUrl, QQuickItem *> m_itemForUrl;
    QHash<QUrl, QQmlComponent *> m_componentForUrl;
    QHash<QQuickItem *, QUrl> m_urlForItem;

    bool m_cachePages = true;
};
