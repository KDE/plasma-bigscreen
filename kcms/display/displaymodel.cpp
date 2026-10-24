// SPDX-FileCopyrightText: 2024 Aditya Mehra <aix.m@outlook.com>
// SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "displaymodel.h"

#include <QDBusArgument>
#include <QDBusConnection>
#include <QDBusMessage>
#include <QDebug>
#include <QProcess>

#include <algorithm>

#include <kscreen/config.h>
#include <kscreen/configmonitor.h>
#include <kscreen/getconfigoperation.h>
#include <kscreen/mode.h>
#include <kscreen/output.h>
#include <kscreen/setconfigoperation.h>

DisplayModel::DisplayModel(QObject *parent)
    : QAbstractListModel(parent)
{
    // Switching or reloading the selected display changes all of its properties
    connect(this, &DisplayModel::selectedDisplayChanged, this, [this]() {
        Q_EMIT selectedDisplayEnabledChanged();
        Q_EMIT selectedDisplayScaleChanged();
        Q_EMIT selectedDisplayModeChanged();
    });

    connect(KScreen::ConfigMonitor::instance(), &KScreen::ConfigMonitor::configurationChanged, this, &DisplayModel::loadDisplayInformation);
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
    if (m_selectedDisplayId == id) {
        return;
    }

    for (KScreen::OutputPtr display : m_displays) {
        if (display->id() == id) {
            m_selectedDisplayId = id;
            Q_EMIT selectedDisplayChanged();
            return;
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
    if (!display || display->isEnabled() == enabled) {
        return;
    }

    if (!enabled) {
        // Don't allow disabling the last enabled display, we would be left with no screen
        bool otherEnabled = std::any_of(m_displays.cbegin(), m_displays.cend(), [&display](const KScreen::OutputPtr &output) {
            return output != display && output->isEnabled();
        });
        if (!otherEnabled) {
            return;
        }
    }
    if (!display->currentMode()) {
        display->setCurrentModeId(display->preferredModeId());
    }

    display->setEnabled(enabled);
    Q_EMIT selectedDisplayEnabledChanged();
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
    Q_EMIT selectedDisplayScaleChanged();
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
            Q_EMIT selectedDisplayModeChanged();
            return;
        }
    }
}

void DisplayModel::syncDisplayOptions()
{
    if (!m_config) {
        return;
    }

    if (!KScreen::Config::canBeApplied(m_config)) {
        qWarning() << "Display configuration can't be applied, reverting";
        loadDisplayInformation();
        return;
    }

    // Reload options once applied
    connect(new KScreen::SetConfigOperation(m_config), &KScreen::ConfigOperation::finished, this, [this](KScreen::ConfigOperation *op) {
        if (op->hasError()) {
            qWarning() << "Failed to apply display configuration:" << op->errorString();
        }
        loadDisplayInformation();
    });
}

void DisplayModel::loadDisplayInformation()
{
    connect(new KScreen::GetConfigOperation(), &KScreen::GetConfigOperation::finished, this, [this](KScreen::ConfigOperation *op) {
        if (op->hasError()) {
            qWarning() << "Failed to load display configuration:" << op->errorString();
            return;
        }

        beginResetModel();
        m_displays.clear();

        if (m_config) {
            KScreen::ConfigMonitor::instance()->removeConfig(m_config);
        }
        m_config = qobject_cast<KScreen::GetConfigOperation *>(op)->config();
        KScreen::ConfigMonitor::instance()->addConfig(m_config);

        for (KScreen::OutputPtr output : m_config->outputs()) {
            m_displays.append(output);
        }

        // Check if selected display still exists
        if (m_selectedDisplayId != -1) {
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
        endResetModel();

        Q_EMIT countChanged();
        Q_EMIT selectedDisplayChanged();
    });
}
