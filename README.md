# ⌨️ KDE Plasma 6 Wayland Virtual Keyboard

[![AI Engineered](https://img.shields.io/badge/Engineered%20With-Google%20Antigravity%20AI-4285F4?style=for-the-badge&logo=google)](https://deepmind.google/)
[![KDE Plasma](https://img.shields.io/badge/KDE%20Plasma-6.0%2B-3daee9?style=for-the-badge&logo=kde)](https://kde.org/plasma-desktop/)
[![License](https://img.shields.io/badge/License-GPLv3-blue.svg?style=for-the-badge)](LICENSE)

A high-performance, native Gboard-style On-Screen Virtual Keyboard built specifically for **KDE Plasma 6 Wayland** (tested on CachyOS, Arch Linux, Fedora, openSUSE, and all Plasma 6 Linux distributions).

---

> [!NOTE]
> 🤖 **Built with AI Pair-Programming**  
> This native C++/Qt6/QML project was fully designed, architected, and engineered in pair-programming collaboration with **Google Antigravity AI**. From low-level Linux `/dev/uinput` USB kernel drivers and Wayland protocol integration to Hunspell British English dictionary parsing and Kirigami QML UI design, the entire codebase was iteratively crafted with AI assistance.

---

## 🌟 Key Features

- **Universal Typing Dispatch**: Dual architecture utilizing Wayland `zwp_input_method_v1`/`v2` and Linux Kernel `/dev/uinput` USB hardware keyboard driver fallback for 100% typing compatibility across Chrome, Konsole, Steam, Discord, and password fields.
- **Window Auto-Push & Restore**: Automatically resizes and pushes active application windows upward while typing so focused text fields remain visible, restoring window height when dismissed (`setExclusiveZone(360)`).
- **Hardware Keyboard Auto-Suppression**: Monitors KWin's `TabletModeManager` to auto-suppress virtual keyboard popups when a physical USB or Bluetooth keyboard is attached.
- **CachyOS Super Key**: Row 4 Super/Meta key featuring the official CachyOS SVG logo for launching KRunner or the Plasma Application Launcher.
- **British English (`en_GB`) Auto-Correct & Self-Learning**:
  - Official Hunspell British English dictionary (`en_GB-large.dic`) with 40,000+ words (`colour`, `centre`, `favour`, `realise`).
  - Instant pronoun & contraction auto-correction (`i` $\rightarrow$ `I`, `dont` $\rightarrow$ `don't`, `im` $\rightarrow$ `I'm`, `ive` $\rightarrow$ `I've`, `cant` $\rightarrow$ `can't`, `wont` $\rightarrow$ `won't`).
  - Fuzzy Levenshtein spell checking (`speling` $\rightarrow$ `spelling`).
  - Sentence auto-capitalisation and double-space period shortcut (`. `).
  - Learns user typing habits persistently to `~/.local/share/plasma-virtualkeyboard/user_dictionary.json`.
- **GBoard Ergonomic Layouts & Modes**:
  - **Gboard Tablet Split Mode**: Dual thumb clusters + central ergonomic gap + dual spacebars.
  - **One-Handed Mode**: Anchors keyboard to 65% width on the left or right side.
  - **Floating Window Mode**: Undocks into a floating window with a top drag handle bar.
  - **Top 123 Number Row**: Toggleable 5th row (`1 2 3 4 5 6 7 8 9 0`).
  - **International Layout Switcher**: QWERTY, QWERTZ, AZERTY, DVORAK.
  - **Gboard Theme Customizer**: Breeze Dark, AMOLED Pitch Black, Material Blue, Cyberpunk Purple.
- **Audio & Visual Polish**:
  - Audio keyclick sound feedback (`canberra-gtk-play`).
  - Syncs highlights directly with **KDE Plasma 6 System Accent Color** (`Kirigami.Theme.highlightColor`).
  - Long-press accent & number popups (`E` $\rightarrow$ `é`, `3`; `A` $\rightarrow$ `ä`, `@`).
  - Clipboard history with bookmark snippet pinning.
- **Clear UI Controls**: `Tools & Modes` menu featuring rich Kirigami icons paired directly beside text labels and status badges.

---

## 🛠️ Building & Installing

### Prerequisites

Install required Qt6 and KDE Frameworks 6 packages:

```bash
# Arch Linux / CachyOS
sudo pacman -S cmake extra-cmake-modules qt6-base qt6-declarative qt6-wayland kirigami ki18n kcoreaddons wayland-protocols hunspell-en_gb libcanberra

# Fedora
sudo dnf install cmake extra-cmake-modules qt6-qtdeclarative-devel qt6-qtwayland-devel kf6-kirigami-devel kf6-ki18n-devel wayland-protocols-devel hunspell-en-GB libcanberra-devel
```

### 1. Build

```bash
mkdir -p build && cd build
cmake ..
cmake --build .
```

### 2. Install to Local User Directory (`~/.local`)

```bash
cmake --install . --prefix ~/.local
```

Or install system-wide:
```bash
sudo cmake --install . --prefix /usr
```

---

## ⚙️ Enabling in KDE System Settings

1. Open **System Settings** (`systemsettings`).
2. Navigate to **Keyboard** $\rightarrow$ **Virtual Keyboard**.
3. Under the **Virtual Keyboard** dropdown menu, select **Plasma Virtual Keyboard**.
4. Click **Apply**.

---

## 📄 License

GPL-3.0-or-later. Built with Qt6, Kirigami, and KDE Frameworks 6.