#pragma once

#include <QDate>
#include <QObject>
#include <QmlTypeAndRevisionsRegistration>

class QFile;

class WurdlController : public QObject {
  Q_OBJECT
  QML_NAMED_ELEMENT(Wurdl)
  QML_SINGLETON

  Q_PROPERTY(int totalRows READ totalRows CONSTANT)
  Q_PROPERTY(int totalColumns READ totalColumns CONSTANT)
  Q_PROPERTY(int totalCells READ totalCells CONSTANT)

  Q_PROPERTY(int todaysWordIndex READ todaysWordIndex CONSTANT)
  Q_PROPERTY(QString todaysGameWord READ todaysGameWord CONSTANT)

 public:
  explicit WurdlController(QObject* parent = nullptr);

  Q_INVOKABLE QString randomGameWord() const;

  Q_INVOKABLE bool checkWord(const QString& word) const;

 private:
  constexpr int totalRows() const { return 6; }
  constexpr int totalColumns() const { return 5; }
  constexpr int totalCells() const { return totalRows() * totalColumns(); }

  int todaysWordIndex() const;
  int randomWordIndex() const;
  QString todaysGameWord() const;

  void loadWords();
  void loadDict();

  const QDate m_birthDate{2022, 02, 02};
  std::vector<QString> m_gameWords;
  std::vector<QString> m_dict;
};
