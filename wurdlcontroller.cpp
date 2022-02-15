#include "wurdlcontroller.h"

#include <algorithm>

#include <QDebug>
#include <QElapsedTimer>
#include <QFile>
#include <QRandomGenerator>
#include <QSettings>

WurdlController::WurdlController(QObject* parent) : QObject{parent} {
  loadWords();
  loadDict();
  loadScores();
}

WurdlController::~WurdlController() {
  saveScores();
}

int WurdlController::todaysWordIndex() const {
  const auto offset = m_birthDate.daysTo(QDate::currentDate());
  if (offset >= 0 && offset < static_cast<int>(m_gameWords.size()))
    return offset;
  return -1;
}

int WurdlController::randomWordIndex() const {
  return QRandomGenerator::global()->bounded(0u, m_gameWords.size());
}

QString WurdlController::getWord(int index) const {
  return m_gameWords[index];
}

bool WurdlController::checkWord(const QString& word) const {
  const auto result =
      std::find(m_dict.cbegin(), m_dict.cend(), word) != m_dict.cend();
  // qDebug() << "Checking word:" << word << "; result:" << result;
  return result;
}

int WurdlController::getScore(int gameId) const {
  try {
    return m_scores.at(gameId);
  } catch (const std::out_of_range&) {
    return -1;
  }
}

void WurdlController::setScore(int gameId, int score) {
  m_scores[gameId] = score;
}

void WurdlController::loadWords() {
#ifdef QT_DEBUG
  QElapsedTimer timer;
  timer.start();
#endif
  QFile file(QStringLiteral(":/data/cs_CZ.words5"));
  if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
    return;

  while (!file.atEnd()) {
    const QString line = file.readLine().trimmed();
    m_gameWords.push_back(line);
  }
  qDebug() << "Loaded" << m_gameWords.size() << "game words";
#ifdef QT_DEBUG
  qDebug() << "in" << timer.elapsed() / 1000.f << "s";
#endif
}

void WurdlController::loadDict() {
#ifdef QT_DEBUG
  QElapsedTimer timer;
  timer.start();
#endif
  QFile file(QStringLiteral(":/data/cs_CZ.dict"));
  if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
    return;

  while (!file.atEnd()) {
    const QString line = file.readLine().trimmed();
    m_dict.push_back(line);
  }
  qDebug() << "Loaded dictionary of" << m_dict.size() << "words";
#ifdef QT_DEBUG
  qDebug() << "in" << timer.elapsed() / 1000.f << "s";
#endif
}

void WurdlController::loadScores() {
  QSettings settings;
  settings.beginGroup(QStringLiteral("Scores"));
  const auto keys = settings.childKeys();
  for (const auto& gameId : keys) {
    m_scores[gameId.toInt()] = settings.value(gameId).toInt();
  }
  settings.endGroup();
  qDebug() << "Loaded" << m_scores.size() << "score entries";
}

void WurdlController::saveScores() {
  QSettings settings;
  settings.beginGroup(QStringLiteral("Scores"));
  for (const auto& [gameId, score] : m_scores) {
    settings.setValue(QString::number(gameId), score);
  }
  settings.endGroup();
  qDebug() << "Saved" << m_scores.size() << "score entries";
}
