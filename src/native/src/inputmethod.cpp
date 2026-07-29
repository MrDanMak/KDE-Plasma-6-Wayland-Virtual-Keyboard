#include "inputmethod.h"
#include <QDBusInterface>
#include <QDBusConnection>
#include <QDBusReply>
#include <QDebug>
#include <QGuiApplication>
#include <QScreen>
#include <QMenu>
#include <QAction>
#include <QProcess>
#include <QtCore/qnativeinterface.h>

#if defined(HAVE_LAYERSHELLQT)
#include <LayerShellQt/Window>
#endif

#include <linux/input.h>
#include <linux/uinput.h>
#include <fcntl.h>
#include <unistd.h>

#if defined(HAVE_WAYLAND_PROTOCOLS) || true
#include "wayland-input-method-unstable-v2-client-protocol.h"
#endif

static void input_method_activate(void *data, struct zwp_input_method_v1 *im, struct zwp_input_method_context_v1 *context) {
    Q_UNUSED(im);
    WaylandInputMethod *self = static_cast<WaylandInputMethod*>(data);
    if (self) {
        self->setContext(context);
    }
}

static void input_method_deactivate(void *data, struct zwp_input_method_v1 *im, struct zwp_input_method_context_v1 *context) {
    Q_UNUSED(im);
    WaylandInputMethod *self = static_cast<WaylandInputMethod*>(data);
    if (self) {
        self->clearContext(context);
    }
}

static const struct zwp_input_method_v1_listener input_method_listener = {
    input_method_activate,
    input_method_deactivate
};

static void registry_handle_global(void *data, struct wl_registry *registry, uint32_t name, const char *interface, uint32_t version) {
    WaylandInputMethod *self = static_cast<WaylandInputMethod*>(data);
    if (!self) return;

    if (strcmp(interface, "zwp_input_method_v1") == 0) {
        qDebug() << "[WaylandInputMethod] Bound zwp_input_method_v1 interface from Wayland registry!";
        struct zwp_input_method_v1 *im = static_cast<struct zwp_input_method_v1*>(
            wl_registry_bind(registry, name, &zwp_input_method_v1_interface, qMin<uint32_t>(version, 1))
        );
        if (im) {
            zwp_input_method_v1_add_listener(im, &input_method_listener, self);
        }
    }
}

static void registry_handle_global_remove(void *, struct wl_registry *, uint32_t) {}

static const struct wl_registry_listener registry_listener = {
    registry_handle_global,
    registry_handle_global_remove
};

static int charToLinuxKeycode(QChar c, bool &outIsShift) {
    outIsShift = c.isUpper();
    char ch = c.toLower().toLatin1();
    if (ch >= 'a' && ch <= 'z') {
        static const int letterKeycodes[] = {
            KEY_A, KEY_B, KEY_C, KEY_D, KEY_E, KEY_F, KEY_G, KEY_H, KEY_I,
            KEY_J, KEY_K, KEY_L, KEY_M, KEY_N, KEY_O, KEY_P, KEY_Q, KEY_R,
            KEY_S, KEY_T, KEY_U, KEY_V, KEY_W, KEY_X, KEY_Y, KEY_Z
        };
        return letterKeycodes[ch - 'a'];
    }
    if (ch >= '1' && ch <= '9') return KEY_1 + (ch - '1');
    if (ch == '0') return KEY_0;
    if (ch == ' ') return KEY_SPACE;
    if (ch == '\n') return KEY_ENTER;
    if (ch == '.') return KEY_DOT;
    if (ch == ',') return KEY_COMMA;
    if (ch == '-') return KEY_MINUS;
    if (ch == '=') return KEY_EQUAL;
    if (ch == '/') return KEY_SLASH;
    return 0;
}

WaylandInputMethod::WaylandInputMethod(QObject *parent)
    : QObject(parent) {
    initWaylandProtocol();
    initDBusInterfaces();
    initSystemTray();
    initUInput();
}

WaylandInputMethod::~WaylandInputMethod() {
    if (m_uinputFd >= 0) {
        ioctl(m_uinputFd, UI_DEV_DESTROY);
        close(m_uinputFd);
    }
}

void WaylandInputMethod::setOneHanded(bool enabled, bool isRight) {
    qDebug() << "[WaylandInputMethod] Setting one-handed mode enabled:" << enabled << "isRight:" << isRight;
#if defined(HAVE_LAYERSHELLQT)
    if (m_window) {
        LayerShellQt::Window *layerWindow = LayerShellQt::Window::get(m_window);
        if (layerWindow) {
            if (enabled) {
                if (isRight) {
                    layerWindow->setAnchors(LayerShellQt::Window::Anchors(LayerShellQt::Window::AnchorBottom | LayerShellQt::Window::AnchorRight));
                } else {
                    layerWindow->setAnchors(LayerShellQt::Window::Anchors(LayerShellQt::Window::AnchorBottom | LayerShellQt::Window::AnchorLeft));
                }
            } else {
                layerWindow->setAnchors(LayerShellQt::Window::Anchors(LayerShellQt::Window::AnchorBottom | LayerShellQt::Window::AnchorLeft | LayerShellQt::Window::AnchorRight));
            }
        }
    }
#endif
}

void WaylandInputMethod::setWindowPosition(int x, int y) {
    if (m_window) {
        m_window->setX(x);
        m_window->setY(y);
    }
}

void WaylandInputMethod::setWindowSize(int w, int h) {
    if (m_window) {
        m_window->setWidth(w);
        m_window->setHeight(h);
    }
}

void WaylandInputMethod::setFloating(bool floating) {
    if (m_isFloating != floating) {
        m_isFloating = floating;
        qDebug() << "[WaylandInputMethod] Setting floating mode to:" << m_isFloating;
        Q_EMIT isFloatingChanged();
    }
}

void WaylandInputMethod::playClickSound() {
    QProcess::startDetached(QStringLiteral("canberra-gtk-play"), QStringList{QStringLiteral("-i"), QStringLiteral("button-pressed")});
}

void WaylandInputMethod::initUInput() {
    m_uinputFd = open("/dev/uinput", O_WRONLY | O_NONBLOCK);
    if (m_uinputFd < 0) {
        qDebug() << "[WaylandInputMethod] Could not open /dev/uinput:" << strerror(errno);
        return;
    }

    ioctl(m_uinputFd, UI_SET_EVBIT, EV_KEY);
    ioctl(m_uinputFd, UI_SET_EVBIT, EV_SYN);

    for (int i = 1; i < 248; ++i) {
        ioctl(m_uinputFd, UI_SET_KEYBIT, i);
    }

    struct uinput_setup usetup;
    memset(&usetup, 0, sizeof(usetup));
    usetup.id.bustype = BUS_USB;
    usetup.id.vendor = 0x1234;
    usetup.id.product = 0x5678;
    strcpy(usetup.name, "Plasma Virtual Keyboard Device");

    ioctl(m_uinputFd, UI_DEV_SETUP, &usetup);
    ioctl(m_uinputFd, UI_DEV_CREATE);
    qDebug() << "[WaylandInputMethod] Created /dev/uinput virtual hardware keyboard device!";
}

void WaylandInputMethod::emitUInputKey(int linuxKeycode, bool isShift) {
    if (m_uinputFd < 0 || linuxKeycode <= 0) return;

    struct input_event ie;
    auto sendEv = [this, &ie](uint16_t type, uint16_t code, int32_t val) {
        memset(&ie, 0, sizeof(ie));
        ie.type = type;
        ie.code = code;
        ie.value = val;
        write(m_uinputFd, &ie, sizeof(ie));
    };

    if (isShift) sendEv(EV_KEY, KEY_LEFTSHIFT, 1);
    sendEv(EV_KEY, linuxKeycode, 1); // Down
    sendEv(EV_SYN, SYN_REPORT, 0);

    sendEv(EV_KEY, linuxKeycode, 0); // Up
    if (isShift) sendEv(EV_KEY, KEY_LEFTSHIFT, 0);
    sendEv(EV_SYN, SYN_REPORT, 0);
}

void WaylandInputMethod::setWindow(QWindow *window) {
    m_window = window;
}

void WaylandInputMethod::setContext(struct zwp_input_method_context_v1 *context) {
    m_context = context;
    qDebug() << "[WaylandInputMethod] Input method context activated by KWin Wayland.";
    if (m_tabletMode) {
        showKeyboard();
    }
}

void WaylandInputMethod::clearContext(struct zwp_input_method_context_v1 *context) {
    if (m_context == context) {
        m_context = nullptr;
    }
}

void WaylandInputMethod::initWaylandProtocol() {
    qDebug() << "[WaylandInputMethod] Initializing Wayland input_method protocol...";
    m_active = false;

    auto waylandApp = qApp->nativeInterface<QNativeInterface::QWaylandApplication>();
    if (waylandApp) {
        struct wl_display *display = waylandApp->display();
        if (display) {
            struct wl_registry *registry = wl_display_get_registry(display);
            if (registry) {
                wl_registry_add_listener(registry, &registry_listener, this);
            }
        }
    }

    Q_EMIT activeChanged();
}

void WaylandInputMethod::initDBusInterfaces() {
    QDBusConnection bus = QDBusConnection::sessionBus();

    QDBusInterface tabletIface(QStringLiteral("org.kde.KWin"), 
                               QStringLiteral("/org/kde/KWin/TabletModeManager"), 
                               QStringLiteral("org.kde.KWin.TabletModeManager"));
    if (tabletIface.isValid()) {
        m_tabletMode = tabletIface.property("tabletMode").toBool();
        qDebug() << "[WaylandInputMethod] Query KWin TabletMode state:" << m_tabletMode;
    } else {
        m_tabletMode = false;
    }

    bus.connect(QStringLiteral("org.kde.KWin"), QStringLiteral("/org/kde/KWin/TabletModeManager"), 
                QStringLiteral("org.kde.KWin.TabletModeManager"), QStringLiteral("tabletModeChanged"), 
                this, SLOT(onKWinTabletModeChanged(bool)));

    bus.connect(QStringLiteral("org.kde.kwin.virtualkeyboard"), QStringLiteral("/VirtualKeyboard"), 
                QStringLiteral("org.kde.kwin.virtualkeyboard"), QStringLiteral("enabledChanged"), 
                this, SLOT(onKWinVirtualKeyboardEnabledChanged(bool)));

    bus.connect(QStringLiteral("org.kde.kwin.virtualkeyboard"), QStringLiteral("/VirtualKeyboard"), 
                QStringLiteral("org.kde.kwin.virtualkeyboard"), QStringLiteral("activeChanged"), 
                this, SLOT(onKWinVirtualKeyboardActiveChanged(bool)));

    bus.connect(QStringLiteral("org.kde.kwin.virtualkeyboard"), QStringLiteral("/VirtualKeyboard"), 
                QStringLiteral("org.kde.kwin.virtualkeyboard"), QStringLiteral("visibleChanged"), 
                this, SLOT(onKWinVirtualKeyboardActiveChanged(bool)));

    bus.registerService(QStringLiteral("org.kde.plasma.virtualkeyboard"));
}

void WaylandInputMethod::initSystemTray() {
#if defined(HAVE_KSTATUSNOTIFIERITEM)
    qDebug() << "[WaylandInputMethod] Creating KStatusNotifierItem system tray icon...";
    m_trayItem = new KStatusNotifierItem(QStringLiteral("plasma-virtualkeyboard"), this);
    m_trayItem->setIconByName(QStringLiteral("input-keyboard-virtual"));
    m_trayItem->setToolTip(QStringLiteral("input-keyboard-virtual"), 
                           QStringLiteral("Plasma Virtual Keyboard"), 
                           QStringLiteral("Tap to toggle On-Screen Virtual Keyboard"));
    m_trayItem->setStatus(KStatusNotifierItem::Active);
    m_trayItem->setCategory(KStatusNotifierItem::Hardware);

    connect(m_trayItem, &KStatusNotifierItem::activateRequested, this, [this](bool, const QPoint &) {
        if (m_active) {
            hideKeyboard();
        } else {
            showKeyboard();
        }
    });

    QMenu *menu = m_trayItem->contextMenu();
    if (menu) {
        QAction *toggleAction = menu->addAction(QIcon::fromTheme(QStringLiteral("input-keyboard-virtual")), QStringLiteral("Toggle Virtual Keyboard"));
        connect(toggleAction, &QAction::triggered, this, [this]() {
            if (m_active) {
                hideKeyboard();
            } else {
                showKeyboard();
            }
        });

        QAction *tabletAction = menu->addAction(QIcon::fromTheme(QStringLiteral("input-tablet")), QStringLiteral("Toggle Tablet Mode"));
        connect(tabletAction, &QAction::triggered, this, &WaylandInputMethod::toggleTabletMode);
    }
#endif
}

void WaylandInputMethod::commitText(const QString &text) {
    if (text.isEmpty()) return;
    qDebug() << "[WaylandInputMethod] Committing string to target text field:" << text;
    
    if (m_context) {
        zwp_input_method_context_v1_commit_string(m_context, m_serial++, text.toUtf8().constData());
    } else {
        for (QChar c : text) {
            bool isShift = false;
            int kcode = charToLinuxKeycode(c, isShift);
            if (kcode > 0) {
                emitUInputKey(kcode, isShift);
            }
        }
    }

    m_surroundingText.insert(m_cursorPosition, text);
    m_cursorPosition += text.length();
    
    Q_EMIT textCommitted(text);
    Q_EMIT surroundingTextChanged();
    Q_EMIT cursorPositionChanged();
}

void WaylandInputMethod::deleteSurroundingText(int beforeLength, int afterLength) {
    qDebug() << "[WaylandInputMethod] delete_surrounding_text:" 
             << "before:" << beforeLength << "after:" << afterLength;

    if (m_context) {
        // If deleting a multi-byte Unicode emoji or surrogate pair, request 2 or 4 byte deletion
        int count = (beforeLength >= 2) ? 2 : 1;
        zwp_input_method_context_v1_delete_surrounding_text(m_context, -count, count + afterLength);
    }
    
    // Always emit uinput backspace keypresses as fallback
    int countKeys = (beforeLength >= 2) ? 2 : 1;
    for (int i = 0; i < countKeys; ++i) {
        emitUInputKey(KEY_BACKSPACE, false);
    }

    if (m_cursorPosition >= beforeLength && !m_surroundingText.isEmpty()) {
        m_surroundingText.remove(m_cursorPosition - beforeLength, beforeLength + afterLength);
        m_cursorPosition = qMax(0, m_cursorPosition - beforeLength);
        Q_EMIT surroundingTextChanged();
        Q_EMIT cursorPositionChanged();
    }
}

void WaylandInputMethod::sendKey(int keySym, bool pressed) {
    qDebug() << "[WaylandInputMethod] Sending key event:" << keySym << "pressed:" << pressed;
    if (m_context) {
        uint32_t state = pressed ? 1 : 0;
        zwp_input_method_context_v1_keysym(m_context, m_serial++, 0, keySym, state, 0);
    } else {
        if (keySym == 133 || keySym == 65515) {
            emitUInputKey(KEY_LEFTMETA, false);
        } else if (keySym == 8) {
            emitUInputKey(KEY_BACKSPACE, false);
        } else if (keySym == 13 || keySym == 10) {
            emitUInputKey(KEY_ENTER, false);
        }
    }
}

void WaylandInputMethod::setPreeditString(const QString &text, int cursor) {
    qDebug() << "[WaylandInputMethod] set_preedit_string:" << text << "cursor:" << cursor;
    if (m_context) {
        zwp_input_method_context_v1_preedit_string(m_context, m_serial++, text.toUtf8().constData(), "");
        zwp_input_method_context_v1_preedit_cursor(m_context, cursor);
    }
}

void WaylandInputMethod::showKeyboard() {
    qDebug() << "[WaylandInputMethod] Showing virtual keyboard window...";
    m_active = true;
    if (m_window) {
        m_window->setVisible(true);
        m_window->raise();
    }
    Q_EMIT activeChanged();
}

void WaylandInputMethod::hideKeyboard() {
    qDebug() << "[WaylandInputMethod] Hiding virtual keyboard window...";
    m_active = false;
    if (m_window) {
        m_window->setVisible(false);
    }
    Q_EMIT activeChanged();
}

void WaylandInputMethod::toggleTabletMode() {
    m_tabletMode = !m_tabletMode;
    qDebug() << "[WaylandInputMethod] Tablet mode toggled to:" << m_tabletMode;
    if (!m_tabletMode) {
        hideKeyboard();
    }
    Q_EMIT tabletModeChanged();
}

void WaylandInputMethod::onKWinTabletModeChanged(bool tabletMode) {
    m_tabletMode = tabletMode;
    qDebug() << "[WaylandInputMethod] KWin TabletMode changed to:" << m_tabletMode;
    if (!m_tabletMode) {
        hideKeyboard();
    }
    Q_EMIT tabletModeChanged();
}

void WaylandInputMethod::onKWinVirtualKeyboardEnabledChanged(bool enabled) {
    m_active = enabled;
    if (m_window) {
        m_window->setVisible(enabled);
    }
    Q_EMIT activeChanged();
}

void WaylandInputMethod::onKWinVirtualKeyboardActiveChanged(bool active) {
    if (!active) {
        hideKeyboard();
    } else if (m_tabletMode) {
        showKeyboard();
    }
}
