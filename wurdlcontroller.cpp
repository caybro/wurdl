#include "wurdlcontroller.h"

#include <algorithm>

#include <QDebug>
#include <QElapsedTimer>
#include <QFile>
#include <QRandomGenerator>

//#define _PROFILE

WurdlController::WurdlController(QObject* parent) : QObject{parent} {
  loadWords();
  loadDict();
}

int WurdlController::todaysWordIndex() const {
  const auto offset = m_birthDate.daysTo(QDate::currentDate());
  if (offset >= 0 && offset < static_cast<int>(m_gameWords.size()))
    return offset;
  return -1;
}

int WurdlController::randomWordIndex() const {
  return QRandomGenerator::global()->bounded(0, m_gameWords.size());
}

QString WurdlController::getWord(int index) const {
  return m_gameWords[index];
}

bool WurdlController::checkWord(const QString& word) const {
  const auto result =
      std::find(m_dict.cbegin(), m_dict.cend(), word) != m_dict.cend();
  qDebug() << "Checking word:" << word << "; result:" << result;
  return result;
}

void WurdlController::loadWords() {
#ifdef _PROFILE
  QElapsedTimer timer;
  timer.start();
#endif
  QFile file(":/data/cs_CZ.words5");
  if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
    return;

  while (!file.atEnd()) {
    const QString line = file.readLine().trimmed();
    m_gameWords.push_back(line);
  }
  qDebug() << "Loaded" << m_gameWords.size() << "game words";
#ifdef _PROFILE
  qDebug() << "in" << timer.elapsed() / 1000.f << "s";
#endif
}

void WurdlController::loadDict() {
#ifdef _PROFILE
  QElapsedTimer timer;
  timer.start();
#endif
  QFile file(":/data/cs_CZ.dict");
  if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
    return;

  while (!file.atEnd()) {
    const QString line = file.readLine().trimmed();
    m_dict.push_back(line);
  }
  qDebug() << "Loaded dictionary of" << m_dict.size() << "words";
#ifdef _PROFILE
  qDebug() << "in" << timer.elapsed() / 1000.f << "s";
#endif
}
