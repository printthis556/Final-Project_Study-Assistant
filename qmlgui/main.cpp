#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "BoardManager.h"
#include "StudyController.h"

int main(int argc, char *argv[])
{
    // Set the Quick Controls 2 style to a non-native one so contentItem
    // customization is supported (Fusion, Basic, Material, etc.).
    // Do this BEFORE the engine loads any QML.
    qputenv("QT_QUICK_CONTROLS_STYLE", "Fusion");
    // If you want a more minimal base style, use:
    // qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    BoardManager boardManager;
    StudyController studyController(&boardManager);

    engine.rootContext()->setContextProperty("boardManager", &boardManager);
    engine.rootContext()->setContextProperty("studyController", &studyController);

    const QUrl url(u"qrc:/StudyAssistant/qml/main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && objUrl == url)
                             QCoreApplication::exit(-1);
                     });

    engine.load(url);

    return app.exec();
}
