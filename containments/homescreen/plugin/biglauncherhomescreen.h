/*
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>


    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include <Plasma/Containment>

class ApplicationListModel;
class SessionManagement;

class HomeScreen : public Plasma::Containment
{
    Q_OBJECT
    Q_PROPERTY(ApplicationListModel *applicationListModel READ applicationListModel CONSTANT)

public:
    HomeScreen(QObject *parent, const QVariantList &args);
    ~HomeScreen() override;

    ApplicationListModel *applicationListModel() const;

public Q_SLOTS:
    void executeCommand(const QString &command);
    void requestShutdown();

private:
    ApplicationListModel *m_applicationListModel;
    SessionManagement *m_session;
};
