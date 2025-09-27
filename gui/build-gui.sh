#!/bin/bash

# Build script for Service Manager GUI

set -e

APP_NAME="Mac Utilities Manager"
BUNDLE_ID="com.user.servicemanager"
BUILD_DIR="build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Clean previous build
print_info "Cleaning previous build..."
rm -rf "$BUILD_DIR"

# Create app bundle structure
print_info "Creating app bundle structure..."
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Compile the SwiftUI app
print_info "Compiling SwiftUI application..."
swiftc -o "$MACOS_DIR/Mac Utilities Manager" ServiceManagerMain.swift \
    -framework SwiftUI \
    -framework Foundation \
    -framework ServiceManagement \
    -framework AppKit \
    -target x86_64-apple-macos11.0

# Copy management script to resources
print_info "Copying management script..."
cp ../scripts/manage-services.sh "$RESOURCES_DIR/"
chmod +x "$RESOURCES_DIR/manage-services.sh"

# Copy Swift source files to resources (needed for compilation)
cp ../src/desktop-switcher.swift "$RESOURCES_DIR/"
cp ../src/scrollfix.swift "$RESOURCES_DIR/"

# Create Info.plist
print_info "Creating Info.plist..."
cat > "$CONTENTS_DIR/Info.plist" << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Mac Utilities Manager</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>LSMinimumSystemVersion</key>
    <string>11.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
    <key>LSUIElement</key>
    <false/>
</dict>
</plist>
EOL

# Create PkgInfo
echo "APPL????" > "$CONTENTS_DIR/PkgInfo"

print_success "Build completed successfully!"
print_info "Application created at: $APP_DIR"

# Copy to main directory for easy access
print_info "Copying to main directory..."
cp -r "$APP_DIR" ../
print_success "Application available at: ../Mac Utilities Manager.app"
print_info "To run: Double-click 'Mac Utilities Manager.app' or run 'open \"Mac Utilities Manager.app\"'"

# Optionally open the app
if [[ "$1" == "--run" ]]; then
    print_info "Opening application..."
    open "../Mac Utilities Manager.app"
fi
