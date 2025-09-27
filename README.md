# Mac Utilities: Desktop Switcher & ScrollFix

Two lightweight macOS utilities that enhance desktop navigation and scrolling behavior. Both run silently in the background as system services.

## Desktop Switcher
Switch between desktops using **Ctrl + Scroll Wheel** - perfect for users with traditional PC mice.

## ScrollFix  
Independent scroll directions for mouse and trackpad. Keeps trackpad natural while making mouse scroll traditionally (requires "Natural Scrolling" ON in System Settings).

---

## Quick Setup

### Option 1: One-Click Installer (Recommended)

1. **Clone and install**:
   ```bash
   git clone https://github.com/halitince7/mac-desktop-switcher.git
   cd mac-desktop-switcher
   ./install.sh
   ```

2. **Double-click `Mac Utilities Manager.app`** to open the GUI application

3. **Click "Install All"** to install both services

4. **Grant permissions when prompted**:
   - **System Settings** → **Privacy & Security** → **Accessibility** → Enable both services
   - **System Settings** → **Privacy & Security** → **Input Monitoring** → Enable `scrollfix`

### Option 2: Manual GUI Build

1. **Clone the repository**:
   ```bash
   git clone https://github.com/halitince7/mac-desktop-switcher.git
   cd mac-desktop-switcher
   ```

2. **Build the GUI application**:
   ```bash
   cd gui
   ./build-gui.sh
   cd ..
   ```

3. **Follow steps 2-4 from Option 1**

### Option 3: Command Line Only

1. **Clone and navigate to the repository**:
   ```bash
   git clone https://github.com/halitince7/mac-desktop-switcher.git
   cd mac-desktop-switcher
   ```

2. **Install both services**:
   ```bash
   ./scripts/manage-services.sh create both
   ```

3. **Grant permissions** (same as above)

That's it! Both services will start automatically and run in the background.

---

## Management Commands

The `scripts/manage-services.sh` script handles everything:

```bash
# Create and start services
./scripts/manage-services.sh create both              # Install both services
./scripts/manage-services.sh create desktop-switcher  # Install only desktop switcher
./scripts/manage-services.sh create scrollfix         # Install only scrollfix

# Control services
./scripts/manage-services.sh start both     # Start services
./scripts/manage-services.sh stop both      # Stop services  
./scripts/manage-services.sh status         # Check status
./scripts/manage-services.sh delete both    # Completely remove

# Short aliases work too
./scripts/manage-services.sh create ds      # Desktop switcher
./scripts/manage-services.sh start sf       # ScrollFix
```

## Requirements

- macOS (modern versions)
- Swift compiler (install with: `xcode-select --install`)
- Administrator privileges for installation

## License
This project is open source. Feel free to use, modify, and distribute as needed.
