#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QWindow>
#include <QScreen>
#include <KLocalizedString>

#if defined(HAVE_LAYERSHELLQT)
#include <LayerShellQt/Window>
#endif

#include "inputmethod.h"
#include "swypeengine.h"

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);

    app.setOrganizationName(QStringLiteral("KDE"));
    app.setOrganizationDomain(QStringLiteral("kde.org"));
    app.setApplicationName(QStringLiteral("plasma-virtualkeyboard"));

    KLocalizedString::setApplicationDomain("plasma-virtualkeyboard");

    WaylandInputMethod inputMethod;
    SwypeEngine swypeEngine;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("inputMethod"), &inputMethod);
    engine.rootContext()->setContextProperty(QStringLiteral("swypeEngine"), &swypeEngine);

    const QUrl url(QStringLiteral("qrc:/src/qml/MainKeyboard.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url, &inputMethod](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl) {
            QCoreApplication::exit(-1);
            return;
        }

        QWindow *window = qobject_cast<QWindow*>(obj);
        if (window) {
            inputMethod.setWindow(window);
            window->setFlags(Qt::Window | Qt::WindowStaysOnTopHint | Qt::FramelessWindowHint | Qt::WindowDoesNotAcceptFocus);
#if defined(HAVE_LAYERSHELLQT)
            LayerShellQt::Window *layerWindow = LayerShellQt::Window::get(window);
            if (layerWindow) {
                layerWindow->setScope(QStringLiteral("input-method"));
                layerWindow->setLayer(LayerShellQt::Window::LayerOverlay);
                LayerShellQt::Window::Anchors anchors(LayerShellQt::Window::AnchorBottom | LayerShellQt::Window::AnchorLeft | LayerShellQt::Window::AnchorRight);
                layerWindow->setAnchors(anchors);
                layerWindow->setKeyboardInteractivity(LayerShellQt::Window::KeyboardInteractivityNone);
                layerWindow->setExclusiveZone(320);
            }
#endif
            window->setVisible(inputMethod.active());
        }
    }, Qt::DirectConnection);

    engine.load(url);

    return app.exec();
}
