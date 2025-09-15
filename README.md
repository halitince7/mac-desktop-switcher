# Mac Desktop Switcher

A lightweight, silent background utility that enables desktop switching on macOS using **Ctrl + Scroll Wheel**. Perfect for users with traditional non-Mac mice who want familiar desktop navigation.

This tool runs as a launch agent, meaning it starts automatically at login and runs silently in the background with no Dock or menu bar icon.

## 🚀 Features

- **Intuitive Controls**: Hold `Ctrl` and scroll to switch between desktops.
- **Universal Compatibility**: Works with any mouse (traditional PC mice, gaming mice, etc.).
- **Silent Background Operation**: Runs as a system service that starts automatically on login.
- **Efficient**: Consumes minimal system resources.
- **No GUI**: Completely invisible to the user after installation.

## 📋 Requirements

- macOS (tested on modern versions)
- Swift Compiler (included with Xcode or Command Line Tools)
- Administrator privileges for installation.

## 🛠️ Installation

Follow these steps to compile the utility and install it as a background service that runs on login.

1.  **Clone the Repository**:
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
    Move the compiled executable to `/usr/local/bin`, a standard location for user-installed command-line tools. You will be prompted for your password.
    ```bash
    sudo mv desktop-switcher /usr/local/bin/
    ```

4.  **Create and Install the Launch Agent**:
    The service file (`com.user.desktopswitcher.plist`) tells macOS to run the utility automatically when you log in.

    First, create the file:
    ```bash
    cat > com.user.desktopswitcher.plist << EOL
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
    
    Next, move it to the `LaunchAgents` directory:
    ```bash
    mv com.user.desktopswitcher.plist ~/Library/LaunchAgents/
    ```

5.  **Load and Start the Service**:
    This command tells macOS to load your new service and start it immediately.
    ```bash
    launchctl load ~/Library/LaunchAgents/com.user.desktopswitcher.plist
    ```

6.  **Grant Accessibility Permissions**:
    The first time the service runs, it will need accessibility permissions to monitor your mouse and keyboard.
    - Go to **System Settings** → **Privacy & Security** → **Accessibility**.
    - You should see `desktop-switcher` in the list. Enable the toggle for it.
    - If it's not in the list, you may need to add it manually or restart the service (`launchctl unload ...` then `launchctl load ...`).

Installation is now complete! The utility will run silently in the background and start automatically every time you log in.

## 🖱️ Usage

Once installed and running:
- **Hold `Ctrl`** and **scroll your mouse wheel** to switch between your desktops.

There is no interface, and nothing to quit. It just works.

## ⚙️ Service Management

If you need to stop, start, or completely remove the utility, use these commands in the terminal.

#### Stop the Service
This will stop the process for your current session. It will start again on the next login.
```bash
launchctl unload ~/Library/LaunchAgents/com.user.desktopswitcher.plist
```

#### Start the Service
If the service is stopped, you can start it again manually.
```bash
launchctl load ~/Library/LaunchAgents/com.user.desktopswitcher.plist
```

#### Uninstall the Service
This will permanently remove the utility and its startup service from your system.
```bash
# 1. Stop the service if it's running
launchctl unload ~/Library/LaunchAgents/com.user.desktopswitcher.plist

# 2. Remove the service file
rm ~/Library/LaunchAgents/com.user.desktopswitcher.plist

# 3. Remove the executable (requires password)
sudo rm /usr/local/bin/desktop-switcher

echo "Desktop Switcher has been uninstalled."
```

## 📄 License
This project is open source. Feel free to use, modify, and distribute as needed.
