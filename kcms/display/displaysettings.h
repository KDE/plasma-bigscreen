#pragma once

#include <KQuickConfigModule>
#include <QObject>

class DisplayModel;
class DisplaySettings : public KQuickConfigModule
{
    Q_OBJECT
    Q_PROPERTY(DisplayModel *displayModel READ displayModel CONSTANT)

public:
    explicit DisplaySettings(QObject *parent, const KPluginMetaData &data);
    DisplayModel *displayModel();

private:
    DisplayModel *m_displayModel;

};
