# Mac Utilities: Desktop Switcher & ScrollFix

Two lightweight macOS utilities that enhance desktop navigation and scrolling behavior. Both run silently in the background as system services.

## Desktop Switcher
Switch between desktops using **Ctrl + Scroll Wheel** - perfect for users with traditional PC mice.

## ScrollFix  
Independent scroll directions for mouse and trackpad. Keeps trackpad natural while making mouse scroll traditionally (requires "Natural Scrolling" ON in System Settings).

---

## Quick Setup

1. **Clone and navigate to the repository**:
   ```bash
   git clone https://github.com/halitince7/mac-desktop-switcher.git
   cd mac-desktop-switcher
   ```

2. **Install both services**:
   ```bash
   ./manage-services.sh create both
   ```

3. **Grant permissions when prompted**:
   - **System Settings** → **Privacy & Security** → **Accessibility** → Enable both services
   - **System Settings** → **Privacy & Security** → **Input Monitoring** → Enable `scrollfix`

That's it! Both services will start automatically and run in the background.

---

## Management Commands

The `manage-services.sh` script handles everything:

```bash
# Create and start services
./manage-services.sh create both              # Install both services
./manage-services.sh create desktop-switcher  # Install only desktop switcher
./manage-services.sh create scrollfix         # Install only scrollfix

# Control services
./manage-services.sh start both     # Start services
./manage-services.sh stop both      # Stop services  
./manage-services.sh status         # Check status
./manage-services.sh delete both    # Completely remove

# Short aliases work too
./manage-services.sh create ds      # Desktop switcher
./manage-services.sh start sf       # ScrollFix
```

## Requirements

- macOS (modern versions)
- Swift compiler (install with: `xcode-select --install`)
- Administrator privileges for installation

## License
This project is open source. Feel free to use, modify, and distribute as needed.
