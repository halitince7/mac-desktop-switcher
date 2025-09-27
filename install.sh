#!/bin/bash

# Mac Utilities Manager - One-Click Installer
# This script builds and prepares the GUI application for use

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Welcome message
print_header "Mac Utilities Manager Installer"
echo
echo "This installer will:"
echo "1. Check system requirements"
echo "2. Build the GUI application"
echo "3. Make it ready to use"
echo

# Check if Swift compiler is available
check_swift() {
    if ! command -v swiftc &> /dev/null; then
        print_error "Swift compiler not found!"
        print_info "Please install Xcode Command Line Tools:"
        print_info "Run: xcode-select --install"
        echo
        print_info "After installation, run this script again."
        exit 1
    fi
    print_success "Swift compiler found"
}

# Check if we're in the right directory
check_directory() {
    if [[ ! -d "gui" || ! -f "gui/build-gui.sh" ]]; then
        print_error "Installation files not found!"
        print_info "Please make sure you're running this script from the mac-desktop-switcher directory."
        exit 1
    fi
    print_success "Installation files found"
}

# Build the GUI application
build_gui() {
    print_info "Building Mac Utilities Manager..."
    cd gui
    ./build-gui.sh > /dev/null 2>&1
    cd ..
    
    if [[ -d "Mac Utilities Manager.app" ]]; then
        print_success "Mac Utilities Manager built successfully"
    else
        print_error "Failed to build the application"
        exit 1
    fi
}

# Check if app already exists and ask user
check_existing_app() {
    if [[ -d "Mac Utilities Manager.app" ]]; then
        print_warning "Mac Utilities Manager.app already exists"
        echo -n "Do you want to rebuild it? (y/N): "
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            print_info "Removing existing application..."
            rm -rf "Mac Utilities Manager.app"
            return 0
        else
            print_info "Using existing application"
            return 1
        fi
    fi
    return 0
}

# Show completion message
show_completion() {
    echo
    print_header "Installation Complete!"
    echo
    print_success "Mac Utilities Manager is ready to use!"
    echo
    echo "Next steps:"
    echo "1. Double-click 'Mac Utilities Manager.app' to open it"
    echo "2. Click 'Install All' to install both services"
    echo "3. Grant permissions when prompted:"
    echo "   • System Settings → Privacy & Security → Accessibility"
    echo "   • System Settings → Privacy & Security → Input Monitoring"
    echo
    print_info "The app is located in this directory: $(pwd)"
    echo
    echo -n "Would you like to open the app now? (y/N): "
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        print_info "Opening Mac Utilities Manager..."
        open "Mac Utilities Manager.app"
    fi
}

# Main installation process
main() {
    print_info "Checking system requirements..."
    check_swift
    check_directory
    echo
    
    if check_existing_app; then
        print_info "Building application..."
        build_gui
    fi
    
    show_completion
}

# Run main function
main
