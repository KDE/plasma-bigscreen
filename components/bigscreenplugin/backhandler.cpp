/*
    SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "backhandler.h"

#include <QEvent>
#include <QKeyEvent>
#include <QMetaProperty>
#include <QMouseEvent>
#include <QQuickItem>
#include <QQuickWindow>
#include <QTimer>
#include <QVariant>

BackHandler::BackHandler(QObject *target)
    : QObject(target)
    , m_target(target)
{
    if (m_target) {
        m_target->installEventFilter(this);

        const int visibleChangedIndex = m_target->metaObject()->indexOfSignal("visibleChanged()");
        if (visibleChangedIndex >= 0) {
            QMetaObject::connect(m_target, visibleChangedIndex, this, metaObject()->indexOfSlot("updateWindow()"));
        }
    }

    QTimer::singleShot(0, this, &BackHandler::updateWindow);
}

BackHandler::~BackHandler()
{
    if (m_target) {
        m_target->removeEventFilter(this);
    }
    if (m_window) {
        m_window->removeEventFilter(this);
    }
}

bool BackHandler::enabled() const
{
    return m_enabled;
}

void BackHandler::setEnabled(bool enabled)
{
    if (m_enabled == enabled) {
        return;
    }

    m_enabled = enabled;
    Q_EMIT enabledChanged();
}

bool BackHandler::accepted() const
{
    return m_accepted;
}

void BackHandler::setAccepted(bool accepted)
{
    if (m_accepted == accepted) {
        return;
    }

    m_accepted = accepted;
    Q_EMIT acceptedChanged();
}

BackHandler *BackHandler::qmlAttachedProperties(QObject *object)
{
    return new BackHandler(object);
}

bool BackHandler::eventFilter(QObject *watched, QEvent *event)
{
    if (!m_enabled) {
        return QObject::eventFilter(watched, event);
    }

    bool isBackAction = false;

    if (event->type() == QEvent::KeyPress) {
        auto keyEvent = static_cast<QKeyEvent *>(event);
        isBackAction = keyEvent->key() == Qt::Key_Escape || keyEvent->key() == Qt::Key_Back;
    } else if (event->type() == QEvent::MouseButtonRelease) {
        auto mouseEvent = static_cast<QMouseEvent *>(event);
        isBackAction = mouseEvent->button() == Qt::BackButton;
    }

    if (!isBackAction || (watched == m_window && !shouldHandleKeyEvent())) {
        return QObject::eventFilter(watched, event);
    }

    Q_EMIT activated();
    event->setAccepted(m_accepted);
    return m_accepted;
}

void BackHandler::updateWindow()
{
    auto item = targetItem();
    if (m_targetItem != item) {
        disconnect(m_targetItemWindowChangedConnection);
        m_targetItem = item;

        if (m_targetItem) {
            m_targetItemWindowChangedConnection = connect(m_targetItem, &QQuickItem::windowChanged, this, &BackHandler::updateWindow);
        }
    }

    auto window = targetWindow();
    if (m_window == window) {
        return;
    }

    if (m_window) {
        m_window->removeEventFilter(this);
    }

    m_window = window;

    if (m_window) {
        m_window->installEventFilter(this);
    }
}

bool BackHandler::shouldHandleKeyEvent() const
{
    if (!m_target) {
        return false;
    }

    const QVariant visibleProperty = m_target->property("visible");
    if (visibleProperty.isValid() && !visibleProperty.toBool()) {
        return false;
    }

    auto window = targetWindow();
    if (!window || !window->isActive()) {
        return false;
    }

    auto item = targetItem();
    if (!item) {
        return true;
    }

    auto activeFocusItem = window->activeFocusItem();
    return activeFocusItem && (activeFocusItem == item || item->isAncestorOf(activeFocusItem));
}

QQuickItem *BackHandler::targetItem() const
{
    if (!m_target) {
        return nullptr;
    }

    if (auto item = qobject_cast<QQuickItem *>(m_target)) {
        return item;
    }

    const QVariant contentItem = m_target->property("contentItem");
    return qobject_cast<QQuickItem *>(contentItem.value<QObject *>());
}

QQuickWindow *BackHandler::targetWindow() const
{
    if (!m_target) {
        return nullptr;
    }

    if (auto window = qobject_cast<QQuickWindow *>(m_target)) {
        return window;
    }

    if (auto item = targetItem()) {
        return item->window();
    }

    const QVariant windowProperty = m_target->property("window");
    return qobject_cast<QQuickWindow *>(windowProperty.value<QObject *>());
}

#include "moc_backhandler.cpp"
