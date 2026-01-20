/*
 *   SPDX-FileCopyrightText: 2026 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <QObject>
#include <QString>

class SdlController;

#ifdef HAS_LIBCEC
class CECController;
#endif

/**
 * @brief DBus interface for the input handler daemon
 *
 * Provides methods to query controller status and signals for controller events.
 * Registered on the session bus at org.kde.plasma.bigscreen.inputhandler
 * on the path /InputHandler
 */
class InputHandlerDBus : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.kde.plasma.bigscreen.inputhandler")
    Q_PROPERTY(bool inputSuppressed READ isInputSuppressed WRITE setInputSuppressed NOTIFY inputSuppressedChanged)

public:
    explicit InputHandlerDBus(QObject *parent = nullptr);
    ~InputHandlerDBus() override;

    void setSdlController(SdlController *controller);

#ifdef HAS_LIBCEC
    void setCecController(CECController *controller);
#endif

    bool isInputSuppressed() const;
    void setInputSuppressed(bool suppress);

public Q_SLOTS:
    // DBus methods
    Q_SCRIPTABLE bool isSdlControllerConnected() const;
    Q_SCRIPTABLE bool isCecControllerConnected() const;

Q_SIGNALS:
    // DBus signals
    Q_SCRIPTABLE void sdlControllerAdded(const QString &name);
    Q_SCRIPTABLE void sdlControllerRemoved(const QString &name);
    Q_SCRIPTABLE void cecControllerAdded(const QString &name);
    Q_SCRIPTABLE void cecControllerRemoved(const QString &name);
    Q_SCRIPTABLE void inputSuppressedChanged(bool suppressed);
    Q_SCRIPTABLE void homeActionRequested();

private:
    SdlController *m_sdlController = nullptr;

#ifdef HAS_LIBCEC
    CECController *m_cecController = nullptr;
#endif
};
