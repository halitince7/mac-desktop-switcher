# Mac Desktop Switcher

A Swift utility that enables desktop switching on macOS using **Ctrl + Scroll Wheel** - perfect for users with traditional non-Mac mice who want familiar desktop navigation.

## 🚀 Features

- **Intuitive Controls**: Hold `Ctrl` and scroll to switch between desktops
- **Universal Compatibility**: Works with any mouse (traditional PC mice, gaming mice, etc.)
- **Dual Monitoring**: Uses both local and global event monitoring for maximum compatibility
- **Lightweight**: Runs as a background accessory app (no dock icon)
- **Smart Cooldown**: Prevents accidental rapid switching with built-in scroll cooldown
- **Multiple Methods**: Uses both CGEvent and AppleScript for reliable desktop switching

## 📋 Requirements

- macOS (tested on modern versions)
- Swift runtime (included with Xcode or Command Line Tools)
- Accessibility permissions (for global event monitoring)

## 🛠️ Installation & Usage

### Quick Start

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/mac-desktop-switcher.git
   cd mac-desktop-switcher
   ```

2. **Run the application** (choose one method):

   **Method 1: Direct execution**
   ```bash
   swift desktop-switcher.swift
   ```

   **Method 2: Compile to binary**
   ```bash
   # Compile to binary
   swiftc -o desktop-switcher-binary desktop-switcher.swift
   
   # Run the binary
   ./desktop-switcher-binary
   ```

3. **Grant permissions** (if prompted):
   - Go to **System Preferences** → **Security & Privacy** → **Privacy** → **Accessibility**
   - Add **Terminal** (or **swift**) to the allowed applications
   - This enables global event monitoring for system-wide functionality

### Usage

Once running:
- **Hold `Ctrl`** and **scroll up** to move to the left desktop
- **Hold `Ctrl`** and **scroll down** to move to the right desktop
- **Press `Ctrl+C`** to quit the application

## 🔧 How It Works

The application monitors for scroll wheel events while the Control key is held down:

1. **Event Monitoring**: Captures both local and global scroll/keyboard events
2. **Key State Tracking**: Monitors Control key press/release states
3. **Desktop Switching**: Sends system events to trigger macOS desktop transitions
4. **Fallback Methods**: Uses multiple approaches (CGEvent + AppleScript) for reliability

## 🔒 Permissions

The app requests **Accessibility permissions** to enable global event monitoring. This allows it to:
- Detect scroll events system-wide (not just when the app is focused)
- Monitor Control key state globally
- Send desktop switching commands to the system

**Note**: The app will still work with local monitoring only, but global monitoring provides the best user experience.

## 🎯 Why This Tool?

Mac's default desktop switching requires:
- **Magic Mouse**: Two-finger swipe (not available on traditional mice)
- **Trackpad**: Three/four-finger swipe gestures
- **Keyboard**: `Ctrl + ←/→` (requires both hands)

This tool brings **Windows/Linux-style desktop switching** to macOS, making it accessible for users with traditional mice.

## 🐛 Troubleshooting

### App Not Responding to Scroll
- Ensure Accessibility permissions are granted
- Try running from Terminal vs. other applications
- Check that you're holding `Ctrl` while scrolling

### Desktop Not Switching
- Verify you have multiple desktops/spaces configured in Mission Control
- Check System Preferences → Mission Control → "Automatically rearrange Spaces" settings
- Try the keyboard shortcut `Ctrl + ←/→` to verify desktop switching works manually

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs or issues
- Suggest new features
- Submit pull requests
- Improve documentation

## 📄 License

This project is open source. Feel free to use, modify, and distribute as needed.

---

**Enjoy seamless desktop switching with your favorite mouse! 🖱️✨**
