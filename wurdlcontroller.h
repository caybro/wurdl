#pragma once

#include <QDate>
#include <QObject>
#include <QmlTypeAndRevisionsRegistration>
#include <QJsonObject>

#include <map>
#include <vector>

class WurdlController : public QObject {
  Q_OBJECT
  QML_NAMED_ELEMENT(Wurdl)
  QML_SINGLETON

  Q_PROPERTY(int totalRows READ totalRows CONSTANT)
  Q_PROPERTY(int totalColumns READ totalColumns CONSTANT)
  Q_PROPERTY(int totalCells READ totalCells CONSTANT)

 public:
  explicit WurdlController(QObject* parent = nullptr);
  ~WurdlController() override;

  Q_INVOKABLE int todaysWordIndex() const;
  Q_INVOKABLE int randomWordIndex() const;
  Q_INVOKABLE QString getWord(int index) const;

  Q_INVOKABLE bool checkWord(const QString& word) const;

  Q_INVOKABLE int getScore(int gameId) const;
  Q_INVOKABLE void setScore(int gameId, int score);
  Q_INVOKABLE QJsonObject getScores() const;
  Q_INVOKABLE void shareCurrentGame(const QString& boardTweet);
  Q_INVOKABLE QJsonObject getScoreStats() const;

 private:
  constexpr int totalRows() const { return 6; }
  constexpr int totalColumns() const { return 5; }
  constexpr int totalCells() const { return totalRows() * totalColumns(); }

  void loadWords();
  void loadDict();

  void loadScores();
  void saveScores();

  const QDate m_birthDate{2021, 02, 02};
  std::vector<QString> m_gameWords;
  std::vector<QString> m_dict;
  std::map<int, int> m_scores;
};
