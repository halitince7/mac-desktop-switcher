# Mac Utilities: Mac Desktop Switcher & ScrollFix

A collection of lightweight, silent background utilities that enhance macOS usability, especially for users coming from other operating systems. Both tools run as launch agents, starting automatically at login and running silently in the background with no Dock or menu bar icons.

---

## 1. Desktop Switcher

A utility that enables desktop switching on macOS using **Ctrl + Scroll Wheel**. Perfect for users with traditional non-Mac mice who want familiar desktop navigation.

### 🚀 Features

- **Intuitive Controls**: Hold `Ctrl` and scroll to switch between desktops.
- **Universal Compatibility**: Works with any mouse (traditional PC mice, gaming mice, etc.).
- **Silent Background Operation**: Runs as a system service.
- **Efficient**: Consumes minimal system resources.

---

## 2. ScrollFix: Per-Device Scroll Direction

A utility that sets independent scroll directions for your mouse and trackpad. It keeps the trackpad's "Natural Scrolling" while reversing the mouse to a traditional "unnatural" scroll direction.

### 🤔 The Problem it Solves

By default, macOS applies the "Natural Scrolling" setting globally. This means your trackpad feels intuitive, but your mouse wheel might feel backward compared to what you're used to on Windows or Linux. This utility fixes that by intelligently inverting *only* the mouse's scroll direction.

### 🚀 Features

- **Independent Control**: Use natural scrolling on the trackpad and traditional scrolling on the mouse.
- **Smart Detection**: Automatically distinguishes between mouse and trackpad scroll events.
- **Seamless Integration**: Works in the background with any application.
- **System Setting**: Requires "Natural Scrolling" to be **ON** in System Settings → Mouse/Trackpad.

---

## 📋 Requirements

- macOS (tested on modern versions)
- Swift Compiler (included with Xcode or Command Line Tools)
- Administrator privileges for installation.

## 🛠️ Installation

Follow the steps for the utility you want to install. You can install one or both.

### Desktop Switcher Installation

1.  **Clone the Repository (if you haven't already)**:
    ```bash
    git clone https://github.com/halitince7/mac-desktop-switcher.git
    cd mac-desktop-switcher
    ```

2.  **Compile the Binary**:
    This command compiles the Swift script into a native executable file named `desktop-switcher`.
    ```bash
    swiftc -o desktop-switcher desktop-switcher.swift
    ```

3.  **Install the Binary**:
    Move the compiled executable to `/usr/local/bin`, a standard location for user-installed command-line tools.
    ```bash
    sudo mv desktop-switcher /usr/local/bin/
    ```

4.  **Create and Install the Launch Agent**:
    The service file (`com.user.desktopswitcher.plist`) tells macOS to run the utility automatically when you log in.
    ```bash
    cat > ~/Library/LaunchAgents/com.user.desktopswitcher.plist << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.desktopswitcher</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/desktop-switcher</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOL
    ```

5.  **Load and Start the Service**:
    This command tells macOS to load your new service and start it immediately.
    ```bash
    launchctl load ~/Library/LaunchAgents/com.user.desktopswitcher.plist
    ```

6.  **Grant Accessibility Permissions**:
    The service needs permissions to monitor your mouse and keyboard.
    - Go to **System Settings** → **Privacy & Security** → **Accessibility**.
    - Find `desktop-switcher` in the list and enable the toggle.

---

### ScrollFix Installation

1.  **Compile the Binary**:
    ```bash
    swiftc -o scrollfix scrollfix.swift
    ```

2.  **Install the Binary**:
    ```bash
    sudo mv scrollfix /usr/local/bin/
    ```

3.  **Create and Install the Launch Agent**:
    ```bash
    cat > ~/Library/LaunchAgents/com.user.scrollfix.plist << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.scrollfix</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/scrollfix</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOL
    ```

4.  **Load and Start the Service**:
    ```bash
    launchctl load ~/Library/LaunchAgents/com.user.scrollfix.plist
    ```

5.  **Grant System Permissions**:
    This utility requires permissions to monitor input events. You will likely need to grant permissions in two places:
    - Go to **System Settings** → **Privacy & Security** → **Accessibility**.
    - Go to **System Settings** → **Privacy & Security** → **Input Monitoring**.
    - In both sections, find `scrollfix` in the list and enable the toggle. If it's not listed, the system should prompt you to add it the first time it tries to run.

---

## ⚙️ Service Management

To stop, start, or uninstall a service, replace `[service-name]` and `[binary-name]` in the commands below.
- For Desktop Switcher: `[service-name]` is `com.user.desktopswitcher`, `[binary-name]` is `desktop-switcher`.
- For ScrollFix: `[service-name]` is `com.user.scrollfix`, `[binary-name]` is `scrollfix`.

#### Stop the Service
Stops the process for the current session. It will restart on the next login.
```bash
launchctl unload ~/Library/LaunchAgents/[service-name].plist
```

#### Start the Service
If the service is stopped, you can start it again manually.
```bash
launchctl load ~/Library/LaunchAgents/[service-name].plist
```

#### Uninstall the Service
This will permanently remove the utility and its startup service.
```bash
# 1. Stop the service
launchctl unload ~/Library/LaunchAgents/[service-name].plist

# 2. Remove the service file
rm ~/Library/LaunchAgents/[service-name].plist

# 3. Remove the executable
sudo rm /usr/local/bin/[binary-name]

echo "[binary-name] has been uninstalled."
```

## 📄 License
This project is open source. Feel free to use, modify, and distribute as needed.
