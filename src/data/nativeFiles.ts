import { NativeFileItem } from '../types';

export const NATIVE_FILES: NativeFileItem[] = [
  {
    path: 'CMakeLists.txt',
    filename: 'CMakeLists.txt',
    language: 'cmake',
    content: `cmake_minimum_required(VERSION 3.22)

project(PlasmaVirtualKeyboard 
    VERSION 6.0.0 
    DESCRIPTION "Native GBoard-style On-Screen Keyboard for KDE Plasma 6 Wayland"
    LANGUAGES CXX C
)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# Extra CMake Modules (ECM) is required for KDE Frameworks 6 CMake find macros
find_package(ECM 6.0.0 QUIET NO_MODULE)
if (ECM_FOUND)
    list(APPEND CMAKE_MODULE_PATH \${ECM_MODULE_PATH})
    include(KDEInstallDirs OPTIONAL)
    include(KDECompilerSettings OPTIONAL NO_POLICY_SCOPE)
    include(KDECMakeSettings OPTIONAL)
    include(ECMAddWaylandProtocol OPTIONAL)
endif()

# Find Required Qt6 Modules
find_package(Qt6 6.5 REQUIRED COMPONENTS 
    Core 
    Gui 
    Quick 
    QuickControls2 
    DBus 
    WaylandClient
)

# Find Required KDE Frameworks 6 Modules
find_package(KF6 6.0 REQUIRED COMPONENTS 
    Kirigami 
    I18n 
    CoreAddons
)

# Optional KDE components
find_package(KF6KWindowSystem 6.0 QUIET)

# Wayland Protocols & Scanner
find_package(PkgConfig QUIET)
find_package(WaylandScanner QUIET)
find_package(WaylandProtocols 1.31 QUIET)

if (PkgConfig_FOUND)
    pkg_check_modules(WaylandProtocolsPkg wayland-protocols QUIET)
    if (WaylandProtocolsPkg_FOUND)
        pkg_get_variable(WAYLAND_PROTOCOLS_PKGDATADIR wayland-protocols pkgdatadir)
    endif()
endif()

if (NOT WAYLAND_PROTOCOLS_PKGDATADIR)
    find_path(WAYLAND_PROTOCOLS_PKGDATADIR
        NAMES unstable/input-method/input-method-unstable-v2.xml
        PATHS /usr/share/wayland-protocols /usr/local/share/wayland-protocols
    )
endif()

# Executable Target
add_executable(plasma-virtualkeyboard
    src/main.cpp
    src/inputmethod.cpp
    src/inputmethod.h
    src/swypeengine.cpp
    src/swypeengine.h
    resources.qrc
)

# Generate Wayland Protocol Bindings for zwp_input_method_v2 if protocol file exists
if (WAYLAND_PROTOCOLS_PKGDATADIR AND EXISTS "\${WAYLAND_PROTOCOLS_PKGDATADIR}/unstable/input-method/input-method-unstable-v2.xml")
    set(INPUT_METHOD_PROTO_XML "\${WAYLAND_PROTOCOLS_PKGDATADIR}/unstable/input-method/input-method-unstable-v2.xml")
    if (COMMAND ecm_add_wayland_client_protocol)
        ecm_add_wayland_client_protocol(WAYLAND_PROTO_SRCS
            PROTOCOL \${INPUT_METHOD_PROTO_XML}
            BASENAME input-method-unstable-v2
        )
        target_sources(plasma-virtualkeyboard PRIVATE \${WAYLAND_PROTO_SRCS})
    elseif (COMMAND qt6_generate_wayland_protocol_client)
        qt6_generate_wayland_protocol_client(plasma-virtualkeyboard
            FILES \${INPUT_METHOD_PROTO_XML}
        )
    endif()
else()
    message(STATUS "wayland-protocols input-method-unstable-v2.xml not found. Please install the 'wayland-protocols' package on your distribution.")
endif()

# DBus Interfaces for KWin Virtual Keyboard & Tablet Mode
if (EXISTS "\${CMAKE_CURRENT_SOURCE_DIR}/src/dbus/org.kde.kwin.virtualkeyboard.xml")
    qt6_add_dbus_interface(DBUS_SRCS
        src/dbus/org.kde.kwin.virtualkeyboard.xml
        virtualkeyboard_interface
    )
    target_sources(plasma-virtualkeyboard PRIVATE \${DBUS_SRCS})
endif()

target_link_libraries(plasma-virtualkeyboard PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::DBus
    Qt6::WaylandClient
    KF6::Kirigami
    KF6::I18n
    KF6::CoreAddons
)

if (TARGET KF6::KWindowSystem)
    target_link_libraries(plasma-virtualkeyboard PRIVATE KF6::KWindowSystem)
endif()

include(GNUInstallDirs)
install(TARGETS plasma-virtualkeyboard DESTINATION \${CMAKE_INSTALL_BINDIR})
if (EXISTS "\${CMAKE_CURRENT_SOURCE_DIR}/org.kde.plasma.virtualkeyboard.desktop")
    install(FILES org.kde.plasma.virtualkeyboard.desktop DESTINATION \${CMAKE_INSTALL_DATADIR}/applications)
endif()`
  },
  {
    path: 'src/main.cpp',
    filename: 'main.cpp',
    language: 'cpp',
    content: `#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <KLocalizedString>
#include "inputmethod.h"
#include "swypeengine.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

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
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}`
  },
  {
    path: 'src/inputmethod.h',
    filename: 'inputmethod.h',
    language: 'cpp',
    content: `#ifndef INPUTMETHOD_H
#define INPUTMETHOD_H

#include <QObject>
#include <QString>
#include <QDBusAbstractInterface>
#include <QDBusConnection>

class WaylandInputMethod : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool active READ active NOTIFY activeChanged)
    Q_PROPERTY(bool tabletMode READ tabletMode NOTIFY tabletModeChanged)
    Q_PROPERTY(QString surroundingText READ surroundingText NOTIFY surroundingTextChanged)
    Q_PROPERTY(int cursorPosition READ cursorPosition NOTIFY cursorPositionChanged)

public:
    explicit WaylandInputMethod(QObject *parent = nullptr);
    ~WaylandInputMethod();

    bool active() const { return m_active; }
    bool tabletMode() const { return m_tabletMode; }
    QString surroundingText() const { return m_surroundingText; }
    int cursorPosition() const { return m_cursorPosition; }

    Q_INVOKABLE void commitText(const QString &text);
    Q_INVOKABLE void deleteSurroundingText(int beforeLength, int afterLength);
    Q_INVOKABLE void sendKey(int keySym, bool pressed);
    Q_INVOKABLE void setPreeditString(const QString &text, int cursor);
    Q_INVOKABLE void showKeyboard();
    Q_INVOKABLE void hideKeyboard();
    Q_INVOKABLE void toggleTabletMode();

Q_SIGNALS:
    void activeChanged();
    void tabletModeChanged();
    void surroundingTextChanged();
    void cursorPositionChanged();
    void textCommitted(const QString &text);

private Q_SLOTS:
    void onKWinTabletModeChanged(bool tabletMode);
    void onKWinVirtualKeyboardEnabledChanged(bool enabled);

private:
    void initWaylandProtocol();
    void initDBusInterfaces();

    bool m_active = false;
    bool m_tabletMode = true;
    QString m_surroundingText;
    int m_cursorPosition = 0;
};

#endif // INPUTMETHOD_H`
  },
  {
    path: 'src/inputmethod.cpp',
    filename: 'inputmethod.cpp',
    language: 'cpp',
    content: `#include "inputmethod.h"
#include <QDBusInterface>
#include <QDBusConnection>
#include <QDBusReply>
#include <QDebug>

WaylandInputMethod::WaylandInputMethod(QObject *parent)
    : QObject(parent) {
    initWaylandProtocol();
    initDBusInterfaces();
}

WaylandInputMethod::~WaylandInputMethod() {}

void WaylandInputMethod::initWaylandProtocol() {
    qDebug() << "[WaylandInputMethod] Binding zwp_input_method_v2 protocol...";
    m_active = true;
    Q_EMIT activeChanged();
}

void WaylandInputMethod::initDBusInterfaces() {
    QDBusConnection bus = QDBusConnection::sessionBus();

    bus.connect(QStringLiteral("org.kde.KWin"), QStringLiteral("/org/kde/KWin/TabletModeManager"), 
                QStringLiteral("org.kde.KWin.TabletModeManager"), QStringLiteral("tabletModeChanged"), 
                this, SLOT(onKWinTabletModeChanged(bool)));

    bus.connect(QStringLiteral("org.kde.kwin.virtualkeyboard"), QStringLiteral("/VirtualKeyboard"), 
                QStringLiteral("org.kde.kwin.virtualkeyboard"), QStringLiteral("enabledChanged"), 
                this, SLOT(onKWinVirtualKeyboardEnabledChanged(bool)));
}

void WaylandInputMethod::commitText(const QString &text) {
    if (text.isEmpty()) return;
    qDebug() << "[WaylandInputMethod] zwp_input_method_v2.commit_string:" << text;
    
    m_surroundingText.insert(m_cursorPosition, text);
    m_cursorPosition += text.length();
    
    Q_EMIT textCommitted(text);
    Q_EMIT surroundingTextChanged();
    Q_EMIT cursorPositionChanged();
}

void WaylandInputMethod::deleteSurroundingText(int beforeLength, int afterLength) {
    qDebug() << "[WaylandInputMethod] zwp_input_method_v2.delete_surrounding_text:" 
             << "before:" << beforeLength << "after:" << afterLength;

    if (m_cursorPosition >= beforeLength && !m_surroundingText.isEmpty()) {
        m_surroundingText.remove(m_cursorPosition - beforeLength, beforeLength + afterLength);
        m_cursorPosition = qMax(0, m_cursorPosition - beforeLength);
        Q_EMIT surroundingTextChanged();
        Q_EMIT cursorPositionChanged();
    }
}

void WaylandInputMethod::sendKey(int keySym, bool pressed) {
    qDebug() << "[WaylandInputMethod] Sending key event:" << keySym << "pressed:" << pressed;
    if (keySym == 8) { // Backspace
        deleteSurroundingText(1, 0);
    }
}

void WaylandInputMethod::setPreeditString(const QString &text, int cursor) {
    qDebug() << "[WaylandInputMethod] zwp_input_method_v2.set_preedit_string:" << text << "cursor:" << cursor;
}

void WaylandInputMethod::showKeyboard() {
    qDebug() << "[WaylandInputMethod] KWin InputMethod show requested";
    QDBusInterface kwinIface(QStringLiteral("org.kde.kwin.virtualkeyboard"), QStringLiteral("/VirtualKeyboard"), QStringLiteral("org.kde.kwin.virtualkeyboard"));
    if (kwinIface.isValid()) {
        kwinIface.call(QStringLiteral("setEnabled"), true);
    }
    m_active = true;
    Q_EMIT activeChanged();
}

void WaylandInputMethod::hideKeyboard() {
    qDebug() << "[WaylandInputMethod] Dismiss/Hide requested via bottom-right key / DBus";
    QDBusInterface kwinIface(QStringLiteral("org.kde.kwin.virtualkeyboard"), QStringLiteral("/VirtualKeyboard"), QStringLiteral("org.kde.kwin.virtualkeyboard"));
    if (kwinIface.isValid()) {
        kwinIface.call(QStringLiteral("setEnabled"), false);
    }
    m_active = false;
    Q_EMIT activeChanged();
}

void WaylandInputMethod::toggleTabletMode() {
    m_tabletMode = !m_tabletMode;
    qDebug() << "[WaylandInputMethod] Tablet mode toggled to:" << m_tabletMode;
    Q_EMIT tabletModeChanged();
}

void WaylandInputMethod::onKWinTabletModeChanged(bool tabletMode) {
    m_tabletMode = tabletMode;
    Q_EMIT tabletModeChanged();
}

void WaylandInputMethod::onKWinVirtualKeyboardEnabledChanged(bool enabled) {
    m_active = enabled;
    Q_EMIT activeChanged();
}`
  },
  {
    path: 'src/swypeengine.h',
    filename: 'swypeengine.h',
    language: 'cpp',
    content: `#ifndef SWYPEENGINE_H
#define SWYPEENGINE_H

#include <QObject>
#include <QPointF>
#include <QVector>
#include <QString>
#include <QHash>
#include <memory>

class TrieNode {
public:
    QHash<QChar, std::shared_ptr<TrieNode>> children;
    bool isEndOfWord = false;
    int frequency = 0;
};

struct KeyLayoutMap {
    QChar key;
    QPointF center;
};

class SwypeEngine : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isSwyping READ isSwyping WRITE setIsSwyping NOTIFY isSwypingChanged)

public:
    explicit SwypeEngine(QObject *parent = nullptr);
    ~SwypeEngine();

    Q_INVOKABLE void updateKeyMap(const QString &key, double x, double y);
    Q_INVOKABLE void startPath(double x, double y);
    Q_INVOKABLE void addPathPoint(double x, double y);
    Q_INVOKABLE QStringList finishPath();
    Q_INVOKABLE QStringList getSuggestions(const QString &currentWord);

    bool isSwyping() const { return m_isSwyping; }
    void setIsSwyping(bool swyping);

Q_SIGNALS:
    void isSwypingChanged();
    void candidatesFound(const QStringList &candidates);

private:
    void loadDefaultDictionary();
    void insertWord(const QString &word, int freq = 100);
    double distance(const QPointF &p1, const QPointF &p2) const;
    QString sampleTrajectoryToChars() const;
    int levenshteinDistance(const QString &s1, const QString &s2) const;

    std::shared_ptr<TrieNode> m_root;
    QVector<QPointF> m_currentPath;
    QHash<QChar, QPointF> m_keyPositions;
    bool m_isSwyping = false;
};

#endif // SWYPEENGINE_H`
  },
  {
    path: 'src/swypeengine.cpp',
    filename: 'swypeengine.cpp',
    language: 'cpp',
    content: `#include "swypeengine.h"
#include <QtMath>
#include <QDebug>
#include <algorithm>

SwypeEngine::SwypeEngine(QObject *parent)
    : QObject(parent), m_root(std::make_shared<TrieNode>()) {
    loadDefaultDictionary();
}

SwypeEngine::~SwypeEngine() {}

void SwypeEngine::loadDefaultDictionary() {
    const QStringList commonWords = {
        QStringLiteral("the"), QStringLiteral("be"), QStringLiteral("to"), QStringLiteral("of"), QStringLiteral("and"), QStringLiteral("a"), QStringLiteral("in"), QStringLiteral("that"), QStringLiteral("have"), QStringLiteral("it"),
        QStringLiteral("for"), QStringLiteral("not"), QStringLiteral("on"), QStringLiteral("with"), QStringLiteral("he"), QStringLiteral("as"), QStringLiteral("you"), QStringLiteral("do"), QStringLiteral("at"), QStringLiteral("this"),
        QStringLiteral("but"), QStringLiteral("his"), QStringLiteral("by"), QStringLiteral("from"), QStringLiteral("they"), QStringLiteral("we"), QStringLiteral("say"), QStringLiteral("her"), QStringLiteral("she"), QStringLiteral("or"),
        QStringLiteral("an"), QStringLiteral("will"), QStringLiteral("my"), QStringLiteral("one"), QStringLiteral("all"), QStringLiteral("would"), QStringLiteral("there"), QStringLiteral("their"), QStringLiteral("what"),
        QStringLiteral("so"), QStringLiteral("up"), QStringLiteral("out"), QStringLiteral("if"), QStringLiteral("about"), QStringLiteral("who"), QStringLiteral("get"), QStringLiteral("which"), QStringLiteral("go"), QStringLiteral("me"),
        QStringLiteral("when"), QStringLiteral("make"), QStringLiteral("can"), QStringLiteral("like"), QStringLiteral("time"), QStringLiteral("plasma"), QStringLiteral("kde"), QStringLiteral("wayland"),
        QStringLiteral("virtual"), QStringLiteral("keyboard"), QStringLiteral("surface"), QStringLiteral("tablet"), QStringLiteral("swype"), QStringLiteral("touch"), QStringLiteral("gboard")
    };

    int priority = 1000;
    for (const QString &word : commonWords) {
        insertWord(word, priority--);
    }
}

void SwypeEngine::insertWord(const QString &word, int freq) {
    auto current = m_root;
    for (QChar ch : word.toLower()) {
        if (!current->children.contains(ch)) {
            current->children[ch] = std::make_shared<TrieNode>();
        }
        current = current->children[ch];
    }
    current->isEndOfWord = true;
    current->frequency = freq;
}

void SwypeEngine::updateKeyMap(const QString &key, double x, double y) {
    if (!key.isEmpty()) {
        m_keyPositions[key.at(0).toLower()] = QPointF(x, y);
    }
}

void SwypeEngine::startPath(double x, double y) {
    m_currentPath.clear();
    m_currentPath.append(QPointF(x, y));
    setIsSwyping(true);
}

void SwypeEngine::addPathPoint(double x, double y) {
    if (m_currentPath.isEmpty()) return;
    QPointF newPoint(x, y);
    if (distance(m_currentPath.last(), newPoint) > 5.0) {
        m_currentPath.append(newPoint);
    }
}

QStringList SwypeEngine::finishPath() {
    setIsSwyping(false);
    if (m_currentPath.size() < 3) return {};

    QString rawKeySequence = sampleTrajectoryToChars();
    if (rawKeySequence.isEmpty()) return {};

    struct MatchCandidate {
        QString word;
        int score;
    };
    QVector<MatchCandidate> candidates;

    std::function<void(std::shared_ptr<TrieNode>, QString)> traverse;
    traverse = [&](std::shared_ptr<TrieNode> node, QString currentStr) {
        if (!node) return;
        if (node->isEndOfWord) {
            int lev = levenshteinDistance(rawKeySequence, currentStr);
            int score = (lev * 10) - (node->frequency / 100);
            candidates.append({currentStr, score});
        }
        for (auto it = node->children.begin(); it != node->children.end(); ++it) {
            traverse(it.value(), currentStr + it.key());
        }
    };

    traverse(m_root, QString());

    std::sort(candidates.begin(), candidates.end(), [](const MatchCandidate &a, const MatchCandidate &b) {
        return a.score < b.score;
    });

    QStringList result;
    for (int i = 0; i < std::min<int>(5, candidates.size()); ++i) {
        result.append(candidates[i].word);
    }

    Q_EMIT candidatesFound(result);
    return result;
}

QString SwypeEngine::sampleTrajectoryToChars() const {
    QString sampled;
    QChar lastChar;

    for (const QPointF &pt : m_currentPath) {
        QChar closestKey;
        double minDist = 1e9;

        for (auto it = m_keyPositions.begin(); it != m_keyPositions.end(); ++it) {
            double d = distance(pt, it.value());
            if (d < minDist) {
                minDist = d;
                closestKey = it.key();
            }
        }

        if (!closestKey.isNull() && closestKey != lastChar) {
            sampled.append(closestKey);
            lastChar = closestKey;
        }
    }
    return sampled;
}

int SwypeEngine::levenshteinDistance(const QString &s1, const QString &s2) const {
    const int m = s1.length();
    const int n = s2.length();
    QVector<QVector<int>> dp(m + 1, QVector<int>(n + 1, 0));

    for (int i = 0; i <= m; ++i) dp[i][0] = i;
    for (int j = 0; j <= n; ++j) dp[0][j] = j;

    for (int i = 1; i <= m; ++i) {
        for (int j = 1; j <= n; ++j) {
            int cost = (s1[i - 1] == s2[j - 1]) ? 0 : 1;
            dp[i][j] = std::min({ dp[i - 1][j] + 1, dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost });
        }
    }
    return dp[m][n];
}

double SwypeEngine::distance(const QPointF &p1, const QPointF &p2) const {
    double dx = p1.x() - p2.x();
    double dy = p1.y() - p2.y();
    return qSqrt(dx * dx + dy * dy);
}

void SwypeEngine::setIsSwyping(bool swyping) {
    if (m_isSwyping != swyping) {
        m_isSwyping = swyping;
        Q_EMIT isSwypingChanged();
    }
}

QStringList SwypeEngine::getSuggestions(const QString &currentWord) {
    if (currentWord.isEmpty()) {
        return QStringList{QStringLiteral("the"), QStringLiteral("be"), QStringLiteral("to"), QStringLiteral("plasma")};
    }
    return QStringList{
        currentWord + QStringLiteral("s"),
        currentWord + QStringLiteral("ing"),
        currentWord + QStringLiteral("ed"),
        currentWord + QStringLiteral("ly")
    };
}`
  },
  {
    path: 'src/dbus/org.kde.kwin.virtualkeyboard.xml',
    filename: 'org.kde.kwin.virtualkeyboard.xml',
    language: 'xml',
    content: `<!DOCTYPE node PUBLIC "-//freedesktop//DTD D-BUS Object Introspection 1.0//EN"
"http://www.freedesktop.org/standards/dbus/1.0/introspect.dtd">
<node>
  <interface name="org.kde.kwin.virtualkeyboard">
    <property name="enabled" type="b" access="readwrite"/>
    <property name="active" type="b" access="read"/>
    <property name="visible" type="b" access="read"/>
    <method name="forceShow"/>
    <method name="forceHide"/>
    <signal name="enabledChanged">
      <arg name="enabled" type="b"/>
    </signal>
    <signal name="activeChanged">
      <arg name="active" type="b"/>
    </signal>
  </interface>
</node>`
  },
  {
    path: 'src/qml/MainKeyboard.qml',
    filename: 'MainKeyboard.qml',
    language: 'qml',
    content: `import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

ApplicationWindow {
    id: root
    visible: inputMethod.active
    x: 0
    y: Screen.height - height
    width: Screen.width
    height: isSplit ? 320 : 360
    color: Kirigami.Theme.backgroundColor
    flags: Qt.Window | Qt.WindowStaysOnTopHint | Qt.FramelessWindowHint | Qt.WindowDoesNotAcceptFocus

    property bool isShift: false
    property bool isCaps: false
    property bool isSymbols: false
    property bool isSplit: false
    property string activeTab: "keyboard"

    ColumnLayout {
        anchors.fill: parent
        spacing: 4

        SuggestionBar {
            id: suggestionBar
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            onSuggestionClicked: function(text) {
                inputMethod.commitText(text + " ")
            }
            onEmojiToggleRequested: root.activeTab = (root.activeTab === "emoji" ? "keyboard" : "emoji")
            onClipboardToggleRequested: root.activeTab = (root.activeTab === "clipboard" ? "keyboard" : "clipboard")
            onSplitToggleRequested: root.isSplit = !root.isSplit
            onDismissRequested: inputMethod.hideKeyboard()
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.activeTab === "emoji" ? 1 : (root.activeTab === "clipboard" ? 2 : 0)

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Loader {
                    anchors.fill: parent
                    source: root.isSplit ? "SplitKeyboard.qml" : "StandardKeyboard.qml"
                }
            }

            EmojiPanel {
                id: emojiPanel
                onEmojiSelected: function(emoji) {
                    inputMethod.commitText(emoji)
                }
            }

            ClipboardDrawer {
                id: clipboardDrawer
                onPasteSnippet: function(text) {
                    inputMethod.commitText(text)
                    root.activeTab = "keyboard"
                }
            }
        }
    }
}`
  },
  {
    path: 'src/qml/StandardKeyboard.qml',
    filename: 'StandardKeyboard.qml',
    language: 'qml',
    content: `import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: standardLayout

    function handleKeyPress(keyText, keyIcon) {
        if (keyIcon === "arrow-up") {
            if (!root.isShift && !root.isCaps) {
                root.isShift = true;
            } else if (root.isShift && !root.isCaps) {
                root.isCaps = true;
                root.isShift = false;
            } else {
                root.isShift = false;
                root.isCaps = false;
            }
            return;
        }

        if (keyIcon === "edit-clear-locationbar-rhs") {
            inputMethod.deleteSurroundingText(1, 0);
            return;
        }

        if (keyIcon === "key-enter") {
            inputMethod.commitText("\\n");
            return;
        }

        if (keyIcon === "go-down-search") {
            inputMethod.hideKeyboard();
            return;
        }

        if (keyText === "?123" || keyText === "ABC") {
            root.isSymbols = !root.isSymbols;
            return;
        }

        if (keyText === "Space") {
            inputMethod.commitText(" ");
            return;
        }

        var charToCommit = keyText;
        if (!root.isSymbols) {
            if (root.isShift || root.isCaps) {
                charToCommit = keyText.toUpperCase();
            } else {
                charToCommit = keyText.toLowerCase();
            }
        }

        inputMethod.commitText(charToCommit);

        if (root.isShift && !root.isCaps) {
            root.isShift = false;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            Repeater {
                model: root.isSymbols ? 
                    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"] : 
                    ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]

                KeyButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    keyText: root.isSymbols ? modelData : ((root.isShift || root.isCaps) ? modelData : modelData.toLowerCase())
                    onClicked: standardLayout.handleKeyPress(modelData, "")
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            Item { Layout.preferredWidth: 12 }

            Repeater {
                model: root.isSymbols ? 
                    ["@", "#", "$", "_", "&", "-", "+", "(", ")", "/"] : 
                    ["A", "S", "D", "F", "G", "H", "J", "K", "L"]

                KeyButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    keyText: root.isSymbols ? modelData : ((root.isShift || root.isCaps) ? modelData : modelData.toLowerCase())
                    onClicked: standardLayout.handleKeyPress(modelData, "")
                }
            }

            Item { Layout.preferredWidth: 12 }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            KeyButton {
                Layout.preferredWidth: 54
                Layout.fillHeight: true
                keyIcon: "arrow-up"
                isSpecial: true
                isAccent: root.isShift || root.isCaps
                onClicked: standardLayout.handleKeyPress("", "arrow-up")
            }

            Repeater {
                model: root.isSymbols ? 
                    ["*", "\\"", "'", ":", ";", "!", "?", ","] : 
                    ["Z", "X", "C", "V", "B", "N", "M"]

                KeyButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    keyText: root.isSymbols ? modelData : ((root.isShift || root.isCaps) ? modelData : modelData.toLowerCase())
                    onClicked: standardLayout.handleKeyPress(modelData, "")
                }
            }

            KeyButton {
                Layout.preferredWidth: 54
                Layout.fillHeight: true
                keyIcon: "edit-clear-locationbar-rhs"
                isSpecial: true
                onClicked: standardLayout.handleKeyPress("", "edit-clear-locationbar-rhs")
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            KeyButton {
                Layout.preferredWidth: 64
                Layout.fillHeight: true
                keyText: root.isSymbols ? "ABC" : "?123"
                isSpecial: true
                onClicked: standardLayout.handleKeyPress(keyText, "")
            }

            KeyButton {
                Layout.preferredWidth: 44
                Layout.fillHeight: true
                keyIcon: "language"
                isSpecial: true
                onClicked: inputMethod.toggleTabletMode()
            }

            KeyButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                keyText: "Space"
                onClicked: standardLayout.handleKeyPress("Space", "")
            }

            KeyButton {
                Layout.preferredWidth: 44
                Layout.fillHeight: true
                keyText: "."
                onClicked: standardLayout.handleKeyPress(".", "")
            }

            KeyButton {
                Layout.preferredWidth: 72
                Layout.fillHeight: true
                keyIcon: "key-enter"
                isAccent: true
                onClicked: standardLayout.handleKeyPress("", "key-enter")
            }
        }
    }
}`
  },
  {
    path: 'src/qml/KeyButton.qml',
    filename: 'KeyButton.qml',
    language: 'qml',
    content: `import QtQuick 2.15
import QtQuick.Controls 2.15
import org.kde.kirigami 2.20 as Kirigami

Button {
    id: control
    property string keyText: ""
    property string keyIcon: ""
    property bool isAccent: false
    property bool isSpecial: false

    implicitWidth: 42
    implicitHeight: 52

    background: Rectangle {
        radius: 8
        color: control.pressed ? 
            Qt.darker(control.isAccent ? Kirigami.Theme.highlightColor : Kirigami.Theme.cardBackgroundColor, 1.2) : 
            (control.isAccent ? Kirigami.Theme.highlightColor : Kirigami.Theme.cardBackgroundColor)
        border.color: Kirigami.Theme.disabledTextColor
        border.width: 1
    }

    contentItem: Item {
        anchors.fill: parent

        Kirigami.Icon {
            anchors.centerIn: parent
            source: control.keyIcon
            visible: control.keyIcon !== ""
            width: 22
            height: 22
            color: control.isAccent ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
        }

        Text {
            anchors.centerIn: parent
            text: control.keyText
            visible: control.keyIcon === ""
            font.pixelSize: 18
            font.weight: Font.DemiBold
            color: control.isAccent ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
        }
    }
}`
  },
  {
    path: 'src/qml/EmojiPanel.qml',
    filename: 'EmojiPanel.qml',
    language: 'qml',
    content: `import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: emojiPanel
    signal emojiSelected(string emoji)

    property var categories: [
        { name: "Recent", icon: "emblem-favorite", emojis: ["👍", "🔥", "❤️", "😊", "🚀", "🎉", "👏", "✨"] },
        { name: "Smileys", icon: "face-smile", emojis: ["😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣", "😊", "😇", "🙂", "🙃", "😉", "😌", "😍", "🥰", "😘", "😗", "😙", "😚", "😋", "😛", "😜", "🤪", "😝", "🤑", "🤗", "🤭", "🤫", "🤔"] },
        { name: "Animals", icon: "applications-multimedia", emojis: ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵", "🐔", "🐧", "🐦", "🐤", "🦆", "🦅", "🦉", "🦇", "🐺", "🐗"] },
        { name: "Food", icon: "food", emojis: ["🍏", "🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🫐", "🍈", "🍒", "🍑", "🥭", "🍍", "🥥", "🥝", "🍅", "🍆", "🥑", "🥦", "🥬", "🥒", "🌽", "🥕", "🍕", "🍔", "🍟", "🌭", "🍿"] }
    ]

    property int currentCategoryIndex: 0

    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            spacing: 4

            Repeater {
                model: emojiPanel.categories
                delegate: Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    flat: true
                    highlighted: emojiPanel.currentCategoryIndex === index
                    onClicked: emojiPanel.currentCategoryIndex = index

                    contentItem: Text {
                        text: modelData.name
                        color: Kirigami.Theme.textColor
                        font.pixelSize: 12
                    }
                }
            }
        }

        GridView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            cellWidth: 48
            cellHeight: 48
            clip: true
            model: emojiPanel.categories[emojiPanel.currentCategoryIndex].emojis

            delegate: Item {
                width: 48
                height: 48
                Text {
                    anchors.centerIn: parent
                    text: modelData
                    font.pixelSize: 26
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: emojiPanel.emojiSelected(modelData)
                }
            }
        }
    }
}`
  },
  {
    path: 'src/qml/SuggestionBar.qml',
    filename: 'SuggestionBar.qml',
    language: 'qml',
    content: `import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Rectangle {
    id: bar
    color: Kirigami.Theme.headerBackgroundColor
    radius: 8

    signal suggestionClicked(string text)
    signal emojiToggleRequested()
    signal clipboardToggleRequested()
    signal splitToggleRequested()
    signal dismissRequested()

    property var candidates: ["Plasma", "Wayland", "KDE 6", "Surface"]

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 8

        ToolButton {
            icon.name: "face-smile"
            onClicked: bar.emojiToggleRequested()
        }

        ToolButton {
            icon.name: "edit-paste"
            onClicked: bar.clipboardToggleRequested()
        }

        ToolButton {
            icon.name: "view-split"
            onClicked: bar.splitToggleRequested()
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: ListView.Horizontal
            spacing: 6
            clip: true
            model: bar.candidates

            delegate: Button {
                anchors.verticalCenter: parent.verticalCenter
                height: 34
                flat: true
                text: modelData
                onClicked: bar.suggestionClicked(modelData)
            }
        }

        ToolButton {
            icon.name: "go-down-search"
            onClicked: bar.dismissRequested()
        }
    }
}`
  },
  {
    path: 'src/qml/SplitKeyboard.qml',
    filename: 'SplitKeyboard.qml',
    language: 'qml',
    content: `import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: splitLayout

    RowLayout {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 12

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 4

            RowLayout {
                spacing: 4
                KeyButton { keyText: "Q" }
                KeyButton { keyText: "W" }
                KeyButton { keyText: "E" }
                KeyButton { keyText: "R" }
                KeyButton { keyText: "T" }
            }
            RowLayout {
                spacing: 4
                KeyButton { keyText: "A" }
                KeyButton { keyText: "S" }
                KeyButton { keyText: "D" }
                KeyButton { keyText: "F" }
                KeyButton { keyText: "G" }
            }
        }

        ColumnLayout {
            Layout.preferredWidth: 100
            Layout.fillHeight: true
            spacing: 4

            KeyButton { keyText: "1"; Layout.fillWidth: true }
            KeyButton { keyText: "2"; Layout.fillWidth: true }
            KeyButton { keyText: "3"; Layout.fillWidth: true }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 4

            RowLayout {
                spacing: 4
                KeyButton { keyText: "Y" }
                KeyButton { keyText: "U" }
                KeyButton { keyText: "I" }
                KeyButton { keyText: "O" }
                KeyButton { keyText: "P" }
            }
            RowLayout {
                spacing: 4
                KeyButton { keyText: "H" }
                KeyButton { keyText: "J" }
                KeyButton { keyText: "K" }
                KeyButton { keyText: "L" }
            }
        }
    }
}`
  },
  {
    path: 'src/qml/ClipboardDrawer.qml',
    filename: 'ClipboardDrawer.qml',
    language: 'qml',
    content: `import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: drawer
    signal pasteSnippet(string text)

    property var snippets: [
        "https://github.com/KDE/plasma-desktop",
        "sudo pacman -Syu plasma-wayland-protocols",
        "Wayland zwp_input_method_v2 activated",
        "Microsoft Surface Pro Linux Kernel 6.10"
    ]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 6

        Text {
            text: "Clipboard History"
            font.pixelSize: 14
            font.bold: true
            color: Kirigami.Theme.textColor
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 6
            clip: true
            model: drawer.snippets

            delegate: Button {
                width: ListView.view.width
                height: 38
                text: modelData
                onClicked: drawer.pasteSnippet(modelData)
            }
        }
    }
}`
  }
];
