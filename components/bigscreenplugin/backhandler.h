/*
    SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef BACKHANDLER_H
#define BACKHANDLER_H

#include <QObject>
#include <QPointer>
#include <QQmlEngine>
#include <qqmlregistration.h>

class QQuickItem;
class QQuickWindow;

class BackHandler : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged FINAL)
    Q_PROPERTY(bool accepted READ accepted WRITE setAccepted NOTIFY acceptedChanged FINAL)
    QML_ELEMENT
    QML_UNCREATABLE("Attached property only")
    QML_ATTACHED(BackHandler)

public:
    explicit BackHandler(QObject *target);
    ~BackHandler() override;

    bool enabled() const;
    void setEnabled(bool enabled);

    bool accepted() const;
    void setAccepted(bool accepted);

    static BackHandler *qmlAttachedProperties(QObject *object);

Q_SIGNALS:
    void activated();
    void enabledChanged();
    void acceptedChanged();

protected:
    bool eventFilter(QObject *watched, QEvent *event) override;

private Q_SLOTS:
    void updateWindow();

private:
    bool shouldHandleKeyEvent() const;
    QQuickItem *targetItem() const;
    QQuickWindow *targetWindow() const;

    QPointer<QObject> m_target;
    QPointer<QQuickItem> m_targetItem;
    QPointer<QQuickWindow> m_window;
    QMetaObject::Connection m_targetItemWindowChangedConnection;
    bool m_enabled = true;
    bool m_accepted = true;
};

QML_DECLARE_TYPEINFO(BackHandler, QML_HAS_ATTACHED_PROPERTIES)

#endif // BACKHANDLER_H
