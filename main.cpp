#include <QGuiApplication>
#include <QIcon>
#include <QLibraryInfo>
#include <QLoggingCategory>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QTouchDevice>
#include <QTranslator>

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
  QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
  QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);

  QGuiApplication app(argc, argv);
  app.setApplicationDisplayName(QStringLiteral("Wurdl"));
  app.setOrganizationName(QStringLiteral("caybro"));
  app.setApplicationVersion(VERSION_NUMBER);
  app.setWindowIcon(QIcon(QStringLiteral(":/icons/alphabet-w.svg")));

#ifdef QT_DEBUG
  QLoggingCategory::setFilterRules(
      QStringLiteral("*.debug=true\nqt.*.debug=false"));
#endif

  QQuickStyle::setStyle(QStringLiteral("Material"));

  if (QTouchDevice::devices().isEmpty()) {
    qputenv("QT_QUICK_CONTROLS_HOVER_ENABLED", QByteArrayLiteral("1"));
    qputenv("QT_QUICK_CONTROLS_MATERIAL_VARIANT", QByteArrayLiteral("Dense"));
  }

  QTranslator qtTranslator;
  qtTranslator.load(QLocale::system(), QStringLiteral("qt_"), QString(),
                    QLibraryInfo::location(QLibraryInfo::TranslationsPath));
  app.installTranslator(&qtTranslator);

  QQmlApplicationEngine engine;
  const QUrl url(QStringLiteral("qrc:/main.qml"));
  QObject::connect(
      &engine, &QQmlApplicationEngine::objectCreated, &app,
      [url](QObject* obj, const QUrl& objUrl) {
        if (!obj && url == objUrl)
          QCoreApplication::exit(-1);
      },
      Qt::QueuedConnection);
  engine.load(url);

  return app.exec();
}
