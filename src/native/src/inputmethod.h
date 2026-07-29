#ifndef INPUTMETHOD_H
#define INPUTMETHOD_H

#include <QObject>
#include <QString>
#include <QDBusAbstractInterface>
#include <QDBusConnection>
#include <QWindow>

#if defined(HAVE_KSTATUSNOTIFIERITEM)
#include <KStatusNotifierItem>
#endif

struct zwp_input_method_v1;
struct zwp_input_method_context_v1;

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

    void setWindow(QWindow *window);
    void setContext(struct zwp_input_method_context_v1 *context);
    void clearContext(struct zwp_input_method_context_v1 *context);

    Q_INVOKABLE void commitText(const QString &text);
    Q_INVOKABLE void deleteSurroundingText(int beforeLength, int afterLength);
    Q_INVOKABLE void sendKey(int keySym, bool pressed);
    Q_INVOKABLE void setPreeditString(const QString &text, int cursor);
    Q_INVOKABLE void showKeyboard();
    Q_INVOKABLE void hideKeyboard();
    Q_INVOKABLE void toggleTabletMode();
    Q_INVOKABLE void playClickSound();

Q_SIGNALS:
    void activeChanged();
    void tabletModeChanged();
    void surroundingTextChanged();
    void cursorPositionChanged();
    void textCommitted(const QString &text);

private Q_SLOTS:
    void onKWinTabletModeChanged(bool tabletMode);
    void onKWinVirtualKeyboardEnabledChanged(bool enabled);
    void onKWinVirtualKeyboardActiveChanged(bool active);

private:
    void initWaylandProtocol();
    void initDBusInterfaces();
    void initSystemTray();
    void initUInput();
    void emitUInputKey(int linuxKeycode, bool isShift);

    QWindow *m_window = nullptr;
    struct zwp_input_method_v1 *m_inputMethod = nullptr;
    struct zwp_input_method_context_v1 *m_context = nullptr;
    uint32_t m_serial = 1;
    int m_uinputFd = -1;

#if defined(HAVE_KSTATUSNOTIFIERITEM)
    KStatusNotifierItem *m_trayItem = nullptr;
#endif
    bool m_active = false;
    bool m_tabletMode = false;
    QString m_surroundingText;
    int m_cursorPosition = 0;
};

#endif // INPUTMETHOD_H
