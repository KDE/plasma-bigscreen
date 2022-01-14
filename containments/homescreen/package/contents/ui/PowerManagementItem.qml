/*
    SPDX-FileCopyrightText: 2020 Aditya Mehra <aix.m@outlook.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL

*/

import QtQuick.Layouts 1.14
import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.14
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami 2.12 as Kirigami
import org.kde.kcm 1.2 as KCM
import org.kde.mycroft.bigscreen 1.0 as BigScreen

Item {
    id: powerManagementItem
    property int cookie1: -1
    property int cookie2: -1
    property bool inhibit

    property QtObject pmSource: PlasmaCore.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: sources
        onSourceAdded: {
            disconnectSource(source);
            connectSource(source);
        }
        onSourceRemoved: {
            disconnectSource(source);
        }
    }

    onInhibitChanged: {
        const service = pmSource.serviceForSource("PowerDevil");
        if (inhibit) {
            const reason = i18n("Bigscreen has enabled system-wide inhibition");
            const op1 = service.operationDescription("beginSuppressingSleep");
            op1.reason = reason;
            const op2 = service.operationDescription("beginSuppressingScreenPowerManagement");
            op2.reason = reason;

            const job1 = service.startOperationCall(op1);
            job1.finished.connect(job => {
                cookie1 = job.result;
            });

            const job2 = service.startOperationCall(op2);
            job2.finished.connect(job => {
                cookie2 = job.result;
            });
            console.log("Power Inhibition Activated By Bigscreen");
        } else {
            const op1 = service.operationDescription("stopSuppressingSleep");
            op1.cookie = cookie1;
            const op2 = service.operationDescription("stopSuppressingScreenPowerManagement");
            op2.cookie = cookie2;

            const job1 = service.startOperationCall(op1);
            job1.finished.connect(job => {
                cookie1 = -1;
            });

            const job2 = service.startOperationCall(op2);
            job2.finished.connect(job => {
                cookie2 = -1;
            });
            console.log("Power Inhibition Deactivated By Bigscreen");
        }
    }
}
