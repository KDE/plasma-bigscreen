#pragma once

#include <QObject>
#include <QAbstractListModel>
#include <QDBusArgument>
#include <QProcess>

class DisplayModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum DisplayRoles {
        IdRole = Qt::UserRole + 1,
        OutputNameRole = Qt::UserRole + 2,
        ConnectedRole = Qt::UserRole + 3,
        EnabledRole = Qt::UserRole + 4,
        CurrentModeIdRole = Qt::UserRole + 5,
        SizeRole = Qt::UserRole + 6,
        ScaleRole = Qt::UserRole + 7,
        ModesRole = Qt::UserRole + 8,
    };
    Q_ENUM(DisplayRoles);
    
    DisplayModel(QObject *parent = nullptr);
    ~DisplayModel() override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;    
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void refresh();
    Q_INVOKABLE void setResolutionConfiguration(int modeId, const QString &outputName);
    Q_INVOKABLE void setScaleConfiguration(qreal scale, const QString &outputName);
    Q_INVOKABLE QString getCurrentRefreshRate(int currentModeId);

Q_SIGNALS:
    void countChanged();
    void displayConfigurationChanged();
    void displayScaleChanged();

private:
    void loadDisplayInformation();
    QVariantMap deserializeMap(QDBusArgument arg);
    QVariantList deserializeMapsList(QDBusArgument arg);
    QList<QVariantMap> m_displays;
    QHash<int, QByteArray> m_roleNames;
};

