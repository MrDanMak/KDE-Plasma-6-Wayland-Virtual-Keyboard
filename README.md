# ⌨️ KDE Plasma 6 Wayland Virtual Keyboard

[![AI Engineered](https://img.shields.io/badge/Engineered%20With-Google%20Antigravity%20AI-4285F4?style=for-the-badge&logo=google)](https://deepmind.google/)
[![KDE Plasma](https://img.shields.io/badge/KDE%20Plasma-6.0%2B-3daee9?style=for-the-badge&logo=kde)](https://kde.org/plasma-desktop/)
[![Release](https://img.shields.io/badge/Release-v1.1.0-brightgreen.svg?style=for-the-badge)](https://github.com/MrDanMak/KDE-Plasma-6-Wayland-Virtual-Keyboard/releases)
[![License](https://img.shields.io/badge/License-GPLv3-blue.svg?style=for-the-badge)](LICENSE)

A high-performance, native Gboard-style On-Screen Virtual Keyboard built specifically for **KDE Plasma 6 Wayland** (tested on CachyOS, Arch Linux, Fedora, openSUSE, and all Plasma 6 Linux distributions).

---

> [!NOTE]
> 🤖 **Built with AI Pair-Programming**  
> This native C++/Qt6/QML project was fully designed, architected, and engineered in pair-programming collaboration with **Google Antigravity AI**. From low-level Linux `/dev/uinput` USB kernel drivers and Wayland protocol integration to Hunspell dictionary parsing and Kirigami QML UI design, the entire codebase was iteratively crafted with AI assistance.

---

## 🌟 Key Features

- **Universal Typing Dispatch**: Dual architecture utilizing Wayland `zwp_input_method_v1`/`v2` and Linux Kernel `/dev/uinput` USB hardware keyboard driver fallback for 100% typing compatibility across Chrome, Konsole, Steam, Discord, and password fields.
- **Window Auto-Push & Restore**: Automatically resizes and pushes active application windows upward while typing so focused text fields remain visible (`setExclusiveZone(320)`).
- **Hardware Keyboard Auto-Suppression**: Monitors KWin's `TabletModeManager` to auto-suppress virtual keyboard popups when a physical USB or Bluetooth keyboard is attached.
- **CachyOS Super Key**: Row 4 Super/Meta key featuring the official CachyOS SVG logo for launching KRunner or the Plasma Application Launcher.
- **Multi-Language Auto-Correct Engine**:
  - Multi-language dictionary switching (`en_GB`, `de_DE`, `fr_FR`, `es_ES`).
  - Automatic layout-to-language pairing (`QWERTY` $\rightarrow$ `en_GB`, `QWERTZ` $\rightarrow$ `de_DE`, `AZERTY` $\rightarrow$ `fr_FR`).
  - Pronoun & contraction auto-correction (`i` $\rightarrow$ `I`, `dont` $\rightarrow$ `don't`, `im` $\rightarrow$ `I'm`, `ive` $\rightarrow$ `I've`, `cant` $\rightarrow$ `can't`, `wont` $\rightarrow$ `won't`).
  - Sentence auto-capitalisation and double-space period shortcut (`. `).
  - Learns user typing habits persistently to `~/.local/share/plasma-virtualkeyboard/user_dictionary.json`.
- **450+ High-Definition Gboard Emojis**:
  - Over 450+ Unicode emojis categorized across 8 tabs: ⭐ Recent, 😊 Smileys, 👋 People, 🐶 Animals, 🍔 Food, ⚽ Activities, 🚗 Places, and 💡 Symbols.
  - Dedicated **Backspace (`⌫`)** and **`ABC Keyboard`** navigation buttons directly on the Emoji Panel header.
  - UTF-16 surrogate pair detection for 1-tap emoji deletion.
- **In-Place Settings Panel & Gboard Modes**:
  - In-place full-surface `SettingsPanel` view (zero popups or clipping).
  - **Gboard Tablet Split Mode**: Dual thumb clusters + central ergonomic gap + dual spacebars.
  - **One-Handed Mode**: Anchors keyboard to 65% width on the left or right side via LayerShell.
  - **Top 123 Number Row**: Toggleable 5th row (`1 2 3 4 5 6 7 8 9 0`).
  - **International Layout Switcher**: QWERTY, QWERTZ, AZERTY, DVORAK.
- **Real-Time Dynamic Gboard Theme Palettes**:
  - 🖤 **Dark Slate**: Slate background, dark grey keys, KDE Plasma `#3daee9` Blue accent.
  - 🖤 **Pitch Black**: True `#000000` OLED black, `#1a1a1a` keys, `#00d2ff` Cyan accent.
  - 💙 **Midnight Navy**: Deep `#0f172a` Navy background, slate keys, `#38bdf8` Sky Blue accent.
  - 💜 **Material Purple**: Deep `#1e102a` Purple background, violet keys, `#c084fc` Neon Purple accent.
- **Audio & Visual Polish**:
  - Audio keyclick sound feedback (`canberra-gtk-play`).
  - Long-press accent & number popups (`E` $\rightarrow$ `é`, `3`; `A` $\rightarrow$ `ä`, `@`).
  - Clipboard history manager with bookmark snippet pinning.

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