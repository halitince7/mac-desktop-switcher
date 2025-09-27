import Foundation
import AppKit
import ApplicationServices

// ---- Basit durum tutulumu ----
final class TapState {
    enum Source { case mouse, trackpad }
    var lastSource: Source = .mouse
    var lastTouchTimeNs: UInt64 = 0
    var touchingMax: Int = 0
}

func nowNs() -> UInt64 {
    var info = mach_timebase_info_data_t()
    mach_timebase_info(&info)
    let t = mach_absolute_time()
    return t &* UInt64(info.numer) / UInt64(info.denom)
}

func momentumPhase(for event: CGEvent) -> NSEvent.Phase {
    let ne = NSEvent(cgEvent: event)!
    return ne.momentumPhase
}

// Natural Scrolling sistemde AÇIK varsayımı:
// Trackpad doğal kalsın (invert=false), Mouse ters olsun (invert=true)
func shouldInvert(for source: TapState.Source) -> Bool {
    return (source == .mouse)
}

// ---- Event tap callback ----
private func eventTapCallback(proxy: CGEventTapProxy,
                              type: CGEventType,
                              event: CGEvent,
                              refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    guard let refcon = refcon else { return Unmanaged.passUnretained(event) }
    let state = Unmanaged<TapState>.fromOpaque(refcon).takeUnretainedValue()
    let tNow = nowNs()

    if type.rawValue == 29 { // kCGEventGesture
        // Yalnızca 2+ parmak temaslarını dikkate al (trackpad ipucu)
        if let ne = NSEvent(cgEvent: event) {
            let touching = ne.touches(matching: .touching, in: nil).count
            if touching >= 2 {
                state.lastTouchTimeNs = tNow
                state.touchingMax = max(state.touchingMax, touching)
            }
        }
        return Unmanaged.passUnretained(event)
    }

    guard type.rawValue == 22 else { // kCGEventScrollWheel
        return Unmanaged.passUnretained(event)
    }

    // Kaynak (mouse vs trackpad) belirleme
    let continuous = event.getIntegerValueField(.scrollWheelEventIsContinuous) != 0
    let phase = momentumPhase(for: event)
    let touchElapsedNs = tNow &- state.lastTouchTimeNs

    let source: TapState.Source = {
        if !continuous { return .mouse } // klasik tekerlek
        if state.touchingMax >= 2 && touchElapsedNs < 222_000_000 { // 222 ms
            return .trackpad
        }
        if phase == [] && touchElapsedNs > 333_000_000 { // normal faz + 333 ms
            return .mouse
        }
        return state.lastSource
    }()

    state.lastSource = source
    state.touchingMax = 0

    // Invert kararı
    let invert = shouldInvert(for: source)
    if !invert {
        return Unmanaged.passUnretained(event) // trackpad: dokunma
    }

    // ---- Ters çevirme ----
    // Not: Pürüzsüz kaydırmayı korumak için önce Delta, sonra Point/FixedPt set edeceğiz.
    // Dikey
    let dY = event.getIntegerValueField(.scrollWheelEventDeltaAxis1)
    event.setIntegerValueField(.scrollWheelEventDeltaAxis1, value: -dY)

    // Yatay
    let dX = event.getIntegerValueField(.scrollWheelEventDeltaAxis2)
    event.setIntegerValueField(.scrollWheelEventDeltaAxis2, value: -dX)

    // Continuous ise Point/FixedPt’yi de çevir (smooth scroll için)
    if continuous {
        let pY = event.getIntegerValueField(.scrollWheelEventPointDeltaAxis1)
        let pX = event.getIntegerValueField(.scrollWheelEventPointDeltaAxis2)
        let fY = event.getDoubleValueField(.scrollWheelEventFixedPtDeltaAxis1)
        let fX = event.getDoubleValueField(.scrollWheelEventFixedPtDeltaAxis2)

        event.setIntegerValueField(.scrollWheelEventPointDeltaAxis1, value: -pY)
        event.setIntegerValueField(.scrollWheelEventPointDeltaAxis2, value: -pX)
        event.setDoubleValueField(.scrollWheelEventFixedPtDeltaAxis1, value: -fY)
        event.setDoubleValueField(.scrollWheelEventFixedPtDeltaAxis2, value: -fX)
    }

    return Unmanaged.passUnretained(event)
}

// ---- Tap kurulumu ----
let state = TapState()

// Pasif: sadece gesture'ları izler (izin istemez)
let passiveTap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                   place: .tailAppendEventTap,
                                   options: .listenOnly,
                                   eventsOfInterest: NSEvent.EventTypeMask.gesture.rawValue,
                                   callback: eventTapCallback,
                                   userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(state).toOpaque()))
// Aktif: scroll'u değiştirir (Accessibility / Input Monitoring izni gerekir)
let activeTap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                  place: .tailAppendEventTap,
                                  options: .defaultTap,
                                  eventsOfInterest: NSEvent.EventTypeMask.scrollWheel.rawValue,
                                  callback: eventTapCallback,
                                  userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(state).toOpaque()))

guard let passiveTap = passiveTap, let activeTap = activeTap else {
    fputs("Failed to create event taps. Grant Accessibility permission and retry.\n", stderr)
    exit(1)
}

let passiveSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, passiveTap, 0)
let activeSource  = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, activeTap, 0)

CFRunLoopAddSource(CFRunLoopGetMain(), passiveSource, .commonModes)
CFRunLoopAddSource(CFRunLoopGetMain(), activeSource,  .commonModes)

CGEvent.tapEnable(tap: passiveTap, enable: true)
CGEvent.tapEnable(tap: activeTap, enable: true)

print("Scroll per device shim running. System Prefs → Natural Scrolling = ON olmalı. Mouse ters çevrilecek.")
CFRunLoopRun()