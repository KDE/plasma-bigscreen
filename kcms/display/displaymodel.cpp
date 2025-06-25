// SPDX-FileCopyrightText: 2024 Aditya Mehra <aix.m@outlook.com>
// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "displaymodel.h"

#include <QDBusMessage>
#include <QDBusConnection>
#include <QDBusArgument>
#include <QProcess>

#include <kscreen/configmonitor.h>
#include <kscreen/getconfigoperation.h>
#include <kscreen/mode.h>
#include <kscreen/output.h>
#include <kscreen/setconfigoperation.h>

DisplayModel::DisplayModel(QObject *parent)
    : QAbstractListModel(parent)
{
    loadDisplayInformation();
}

DisplayModel::~DisplayModel()
{
}


int DisplayModel::rowCount(const QModelIndex &) const
{
    return m_displays.size();
}

QVariant DisplayModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    if (index.row() >= m_displays.size()) {
        return QVariant();
    }

    KScreen::OutputPtr display = m_displays.at(index.row());

    switch (role) {
    case IdRole:
        return display->id();
    case OutputNameRole:
        return display->name();
    case EnabledRole:
        return display->isEnabled();
    case OutputRole:
        return QVariant::fromValue(display);
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> DisplayModel::roleNames() const
{
    return {{IdRole, "id"}, {OutputNameRole, "outputName"}, {EnabledRole, "enabled"}, {OutputRole, "output"}};
}

KScreen::OutputPtr DisplayModel::selectedDisplay() const
{
    for (KScreen::OutputPtr display : m_displays) {
        if (display->id() == m_selectedDisplayId) {
            return display;
        }
    }

    return nullptr;
}

int DisplayModel::selectedDisplayId() const
{
    return m_selectedDisplayId;
}

void DisplayModel::setSelectedDisplayId(int id)
{
    for (KScreen::OutputPtr display : m_displays) {
        if (display->id() == id) {
            m_selectedDisplayId = id;
            Q_EMIT selectedDisplayChanged();
        }
    }
}

QString DisplayModel::selectedDisplayName() const
{
    auto display = selectedDisplay();
    if (!display) {
        return {};
    }
    return display->name();
}

bool DisplayModel::selectedDisplayEnabled() const
{
    auto display = selectedDisplay();
    if (!display) {
        return false;
    }
    return display->isEnabled();
}

void DisplayModel::setSelectedDisplayEnabled(bool enabled)
{
    auto display = selectedDisplay();
    if (!display) {
        return;
    }
    display->setEnabled(enabled);
}

double DisplayModel::selectedDisplayScale() const
{
    auto display = selectedDisplay();
    if (!display) {
        return 0;
    }
    return display->scale();
}

void DisplayModel::setSelectedDisplayScale(double scale)
{
    auto display = selectedDisplay();
    if (!display) {
        return;
    }
    display->setScale(scale);
}

QStringList DisplayModel::selectedDisplayAvailableModes() const
{
    auto display = selectedDisplay();
    if (!display) {
        return {};
    }

    QStringList list;
    for (const auto &mode : display->modes()) {
        if (!list.contains(mode->name())) {
            list.append(mode->name());
        }
    }
    std::sort(list.begin(), list.end());
    return list;
}

QString DisplayModel::selectedDisplayMode() const
{
    auto display = selectedDisplay();
    if (!display) {
        return {};
    }

    for (const auto &mode : display->modes()) {
        if (mode->id() == display->currentModeId()) {
            return mode->name();
        }
    }
    return QString{};
}

void DisplayModel::setSelectedDisplayMode(const QString &modeName)
{
    auto display = selectedDisplay();
    if (!display) {
        return;
    }

    for (const auto &mode : display->modes()) {
        if (mode->name() == modeName) {
            display->setCurrentModeId(mode->id());
        }
    }
}

void DisplayModel::syncDisplayOptions()
{
    auto setop = new KScreen::SetConfigOperation(m_config, this);
    setop->exec();

    // Reload options
    loadDisplayInformation();
}

void DisplayModel::loadDisplayInformation()
{
    connect(new KScreen::GetConfigOperation(), &KScreen::GetConfigOperation::finished, this, [this](auto *op) {
        beginResetModel();
        m_displays.clear();

        m_config = qobject_cast<KScreen::GetConfigOperation *>(op)->config();

        for (KScreen::OutputPtr output : m_config->outputs()) {
            m_displays.append(output);
        }

        // Check if selected display still exists
        if (m_selectedDisplayId == -1) {
            bool found = false;
            for (KScreen::OutputPtr display : m_displays) {
                if (display->id() == m_selectedDisplayId) {
                    found = true;
                }
            }

            // Reset to empty string if not found
            if (!found) {
                m_selectedDisplayId = -1;
            }
        }

        if (m_selectedDisplayId == -1 && m_displays.size() > 0) {
            // Select first display
            m_selectedDisplayId = m_displays[0]->id();
        }
        // Always trigger property updates
        Q_EMIT selectedDisplayChanged();

        endResetModel();
        Q_EMIT countChanged();
    });
}
