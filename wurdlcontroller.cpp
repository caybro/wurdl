#include "wurdlcontroller.h"

#include <algorithm>

#include <QDebug>
#include <QFile>
#include <QRandomGenerator>

WurdlController::WurdlController(QObject* parent) : QObject{parent} {
  loadWords();
  loadDict();
}

int WurdlController::todaysWordIndex() const {
  const auto offset = m_birthDate.daysTo(QDate::currentDate());
  if (offset >= 0 && offset < static_cast<int>(m_gameWords.size()))
    return offset;
  else  // ran out of words?
    return randomWordIndex();
}

int WurdlController::randomWordIndex() const {
  return QRandomGenerator::global()->bounded(0, m_gameWords.size());
}

QString WurdlController::todaysGameWord() const {
  return m_gameWords[todaysWordIndex()];
}

QString WurdlController::randomGameWord() const {
  return m_gameWords[randomWordIndex()];
}

bool WurdlController::checkWord(const QString& word) const {
  const auto result =
      std::find(m_dict.cbegin(), m_dict.cend(), word) != m_dict.cend();
  // qInfo() << "Checking word:" << word << "; result:" << result;
  return result;
}

void WurdlController::loadWords() {
  QFile file(":/data/cs_CZ.words5");
  if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
    return;

  while (!file.atEnd()) {
    const QString line = file.readLine().trimmed();
    m_gameWords.push_back(line);
  }
  qInfo() << "Loaded" << m_gameWords.size() << "game words";
}

void WurdlController::loadDict() {
  QFile file(":/data/cs_CZ.dict");
  if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
    return;

  while (!file.atEnd()) {
    const QString line = file.readLine().trimmed();
    m_dict.push_back(line);
  }
  qInfo() << "Dictionary contains" << m_dict.size() << "words";
}
