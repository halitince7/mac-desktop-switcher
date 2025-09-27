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
    private var eventTap: CFMachPort?
    private var ctrlPressed = false
    private var lastScrollTime: TimeInterval = 0
    private let scrollCooldown: TimeInterval = 0.2
    
    func start() {
        // Request accessibility permissions
        requestAccessibilityPermissions()
        
        // Start the event tap
        startEventTap()
        
        // Setup signal handler
        setupSignalHandler()
    }
    
    private func requestAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true]
        let accessibilityEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if !accessibilityEnabled {
            // This will only be visible if run from a terminal, but is critical for debugging.
            fputs("Accessibility permission required! Please grant it in System Settings and restart the service.\n", stderr)
            NSApp.terminate(nil)
        }
    }
    
    private func startEventTap() {
        let eventMask = (1 << CGEventType.scrollWheel.rawValue) | (1 << CGEventType.flagsChanged.rawValue)
        
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else {
                    return Unmanaged.passUnretained(event)
                }
                let mySelf = Unmanaged<DesktopSwitcher>.fromOpaque(refcon).takeUnretainedValue()
                return mySelf.handleEvent(proxy: proxy, type: type, event: event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            fputs("Failed to create event tap. This might be due to missing accessibility permissions.\n", stderr)
            NSApp.terminate(nil)
            return
        }
        
        self.eventTap = tap
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }
    
    private func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        switch type {
        case .flagsChanged:
            handleFlagsChangedEvent(event)
        case .scrollWheel:
            if ctrlPressed {
                handleScrollEvent(event)
                // Consume the event to prevent it from reaching other applications
                return nil
            }
        default:
            break
        }
        // Pass the event through if we're not handling it
        return Unmanaged.passUnretained(event)
    }

    private func handleScrollEvent(_ event: CGEvent) {
        let scrollDelta = event.getIntegerValueField(.scrollWheelEventDeltaAxis1)
        
        let currentTime = CACurrentMediaTime()
        guard currentTime - lastScrollTime > scrollCooldown else {
            return
        }
        
        if scrollDelta != 0 {
            if scrollDelta > 0 {
                switchDesktop(direction: .left)
            } else {
                switchDesktop(direction: .right)
            }
            lastScrollTime = currentTime
        }
    }
    
    private func handleFlagsChangedEvent(_ event: CGEvent) {
        let flags = event.flags
        ctrlPressed = flags.contains(.maskControl)
    }
    
    private enum Direction {
        case left, right
    }
    
    private func switchDesktop(direction: Direction) {
        let keyCode: CGKeyCode = direction == .left ? 123 : 124 // 123 = Left Arrow, 124 = Right Arrow
        
        guard let source = CGEventSource(stateID: .hidSystemState) else {
            fputs("Failed to create event source for mimicking hardware event.\n", stderr)
            return
        }

        if let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true),
           let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false) {
            
            keyDown.flags.formUnion(.maskControl)
            keyUp.flags.formUnion(.maskControl)
            
            keyDown.post(tap: .cghidEventTap)
            usleep(1000) // 1ms delay to ensure keydown is processed before keyup
            keyUp.post(tap: .cghidEventTap)
            
        } else {
            fputs("Failed to create key down/up events.\n", stderr)
        }
    }
    
    private func setupSignalHandler() {
        // Handle signals gracefully for launchd
        signal(SIGINT) { _ in NSApp.terminate(nil) }
        signal(SIGTERM) { _ in NSApp.terminate(nil) }
    }
}

// MARK: - Main Entry Point
let app = DesktopSwitcherApp.shared
app.setActivationPolicy(.accessory)  // Hide from dock
app.run()