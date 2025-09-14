#!/usr/bin/swift

import Cocoa
import Carbon
import Foundation

// Create a minimal NSApplication to handle events
class DesktopSwitcherApp: NSApplication {
    var switcher: DesktopSwitcher?
    
    override func run() {
        switcher = DesktopSwitcher()
        switcher?.start()
        super.run()
    }
}

class DesktopSwitcher: NSObject {
    private var localScrollMonitor: Any?
    private var localKeyMonitor: Any?
    private var globalScrollMonitor: Any?
    private var globalKeyMonitor: Any?
    private var ctrlPressed = false
    private var lastScrollTime: TimeInterval = 0
    private let scrollCooldown: TimeInterval = 0.2
    
    func start() {
        print("🖱️  Desktop Switcher Started!")
        print("📋 Hold Ctrl + Scroll to switch desktops")
        print("⏹️  Press Ctrl+C to quit")
        print("🔍 Testing both local and global event monitoring")
        print("----------------------------------------")
        
        // Request accessibility permissions
        requestAccessibilityPermissions()
        
        // Try both local and global monitoring
        startLocalEventMonitoring()
        startGlobalEventMonitoring()
        
        // Setup signal handler
        setupSignalHandler()
        
        print("✅ Desktop switcher is active!")
        print("💡 Hold Ctrl and scroll to switch desktops")
        print("🔍 Watching for events...")
        
        // Create a simple window to capture local events
        createInvisibleWindow()
    }
    
    private func createInvisibleWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1, height: 1),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        window.isOpaque = false
        window.backgroundColor = NSColor.clear
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.makeKeyAndOrderFront(nil)
        
        print("🔍 Created invisible window for local events")
    }
    
    private func requestAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true]
        let accessibilityEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if accessibilityEnabled {
            print("✅ Accessibility permissions granted")
        } else {
            print("⚠️  Accessibility permission required for global monitoring!")
            print("📱 Go to: System Preferences > Security & Privacy > Privacy > Accessibility")
            print("➕ Add 'Terminal' or 'swift' to allowed apps")
            print("🔄 Local monitoring will still work...")
        }
    }
    
    private func startLocalEventMonitoring() {
        // Local scroll monitoring (works without special permissions)
        localScrollMonitor = NSEvent.addLocalMonitorForEvents(matching: [.scrollWheel]) { [weak self] event in
            print("🔍 LOCAL Scroll: deltaY=\(event.scrollingDeltaY)")
            self?.handleScrollEvent(event)
            return event
        }
        
        // Local key monitoring
        localKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged]) { [weak self] event in
            print("🔍 LOCAL Key flags: Ctrl=\(event.modifierFlags.contains(.control))")
            self?.handleKeyEvent(event)
            return event
        }
        
        if localScrollMonitor != nil {
            print("✅ Local event monitoring started")
        }
    }
    
    private func startGlobalEventMonitoring() {
        // Global scroll monitoring (requires accessibility permissions)
        globalScrollMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.scrollWheel]) { [weak self] event in
            print("🔍 GLOBAL Scroll: deltaY=\(event.scrollingDeltaY)")
            self?.handleScrollEvent(event)
        }
        
        // Global key monitoring
        globalKeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.flagsChanged]) { [weak self] event in
            print("🔍 GLOBAL Key flags: Ctrl=\(event.modifierFlags.contains(.control))")
            self?.handleKeyEvent(event)
        }
        
        if globalScrollMonitor != nil {
            print("✅ Global event monitoring started")
        } else {
            print("❌ Global event monitoring failed - accessibility permissions needed")
        }
    }
    
    private func handleScrollEvent(_ event: NSEvent) {
        print("🔍 handleScrollEvent - Ctrl: \(ctrlPressed), deltaY: \(event.scrollingDeltaY)")
        
        guard ctrlPressed else {
            print("🔍 Ctrl not pressed, ignoring")
            return
        }
        
        let currentTime = CACurrentMediaTime()
        guard currentTime - lastScrollTime > scrollCooldown else {
            print("🔍 Cooldown active, ignoring")
            return
        }
        
        let scrollDelta = event.scrollingDeltaY
        
        if abs(scrollDelta) > 0.1 {  // Lower threshold
            print("🔍 Switching desktop...")
            if scrollDelta > 0 {
                switchDesktop(direction: .left)
            } else {
                switchDesktop(direction: .right)
            }
            lastScrollTime = currentTime
        }
    }
    
    private func handleKeyEvent(_ event: NSEvent) {
        let wasPressed = ctrlPressed
        ctrlPressed = event.modifierFlags.contains(.control)
        
        if ctrlPressed != wasPressed {
            print("🔧 Ctrl \(ctrlPressed ? "PRESSED" : "RELEASED")")
        }
    }
    
    private enum Direction {
        case left, right
    }
    
    private func switchDesktop(direction: Direction) {
        print("🔍 switchDesktop: \(direction)")
        
        // Try multiple approaches to switch desktops
        
        // Method 1: CGEvent (most reliable)
        let keyCode: CGKeyCode = direction == .left ? 123 : 124
        
        if let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true),
           let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false) {
            
            keyDown.flags = .maskControl
            keyUp.flags = .maskControl
            
            keyDown.post(tap: .cghidEventTap)
            keyUp.post(tap: .cghidEventTap)
            
            print("✅ Posted CGEvent for desktop switch")
        }
        
        // Method 2: AppleScript as backup
        DispatchQueue.global().async {
            let script = direction == .left ? 
                "tell application \"System Events\" to key code 123 using control down" :
                "tell application \"System Events\" to key code 124 using control down"
            
            let process = Process()
            process.launchPath = "/usr/bin/osascript"
            process.arguments = ["-e", script]
            
            do {
                try process.run()
                process.waitUntilExit()
                print("✅ AppleScript backup executed")
            } catch {
                print("❌ AppleScript failed: \(error)")
            }
        }
        
        let arrow = direction == .left ? "←" : "→"
        print("\(arrow) Desktop switch attempted")
    }
    
    private func setupSignalHandler() {
        signal(SIGINT) { _ in
            print("\n🛑 Shutting down...")
            NSApp.terminate(nil)
        }
    }
}

// MARK: - Main Entry Point
print("🚀 Starting Desktop Switcher with enhanced monitoring...")

let app = DesktopSwitcherApp.shared
app.setActivationPolicy(.accessory)  // Hide from dock
app.run()