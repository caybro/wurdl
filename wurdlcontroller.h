#pragma once

#include <QObject>
#include <QmlTypeAndRevisionsRegistration>

class WurdlController : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(Wurdl)
    QML_SINGLETON

    Q_PROPERTY(int totalRows READ totalRows CONSTANT)
    Q_PROPERTY(int totalColumns READ totalColumns CONSTANT)
    Q_PROPERTY(int totalCells READ totalCells CONSTANT)

public:
    explicit WurdlController(QObject *parent = nullptr);

    constexpr int totalRows() const { return 6; }
    constexpr int totalColumns() const { return 5; }
    constexpr int totalCells() const { return totalRows() * totalColumns(); }
};
