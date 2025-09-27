import SwiftUI
import Foundation
import ServiceManagement

struct ServiceManagerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
    }
}

struct ContentView: View {
    @StateObject private var serviceManager = ServiceManagerViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("Mac Utilities Manager")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Manage Desktop Switcher and ScrollFix services")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            
            Divider()
            
            // Services
            VStack(spacing: 16) {
                ServiceCard(
                    title: "Desktop Switcher",
                    description: "Switch desktops with Ctrl + Scroll Wheel",
                    icon: "desktopcomputer",
                    service: serviceManager.desktopSwitcher,
                    onInstall: { serviceManager.installDesktopSwitcher() },
                    onStart: { serviceManager.startDesktopSwitcher() },
                    onStop: { serviceManager.stopDesktopSwitcher() },
                    onUninstall: { serviceManager.uninstallDesktopSwitcher() }
                )
                
                ServiceCard(
                    title: "ScrollFix",
                    description: "Independent scroll directions for mouse and trackpad",
                    icon: "scroll",
                    service: serviceManager.scrollFix,
                    onInstall: { serviceManager.installScrollFix() },
                    onStart: { serviceManager.startScrollFix() },
                    onStop: { serviceManager.stopScrollFix() },
                    onUninstall: { serviceManager.uninstallScrollFix() }
                )
            }
            
            Divider()
            
            // Permissions Status
            PermissionsView(serviceManager: serviceManager)
            
            // Bulk Actions
            HStack(spacing: 12) {
                Button("Install All") {
                    serviceManager.installAll()
                }
                .buttonStyle(BorderedButtonStyle())
                .accentColor(.blue)
                .disabled(serviceManager.desktopSwitcher.isInstalled && serviceManager.scrollFix.isInstalled)
                
                Button("Start All") {
                    serviceManager.startAll()
                }
                .buttonStyle(BorderedButtonStyle())
                .disabled(!serviceManager.desktopSwitcher.isInstalled || !serviceManager.scrollFix.isInstalled)
                
                Button("Stop All") {
                    serviceManager.stopAll()
                }
                .buttonStyle(BorderedButtonStyle())
                .disabled(!serviceManager.desktopSwitcher.isRunning && !serviceManager.scrollFix.isRunning)
                
                Button("Uninstall All") {
                    serviceManager.uninstallAll()
                }
                .buttonStyle(BorderedButtonStyle())
                .foregroundColor(.red)
                .disabled(!serviceManager.desktopSwitcher.isInstalled && !serviceManager.scrollFix.isInstalled)
            }
            .padding(.bottom, 20)
        }
        .frame(width: 500, height: 600)
        .background(Color(.windowBackgroundColor))
        .onAppear {
            serviceManager.refreshStatus()
        }
    }
}

struct ServiceCard: View {
    let title: String
    let description: String
    let icon: String
    let service: ServiceStatus
    let onInstall: () -> Void
    let onStart: () -> Void
    let onStop: () -> Void
    let onUninstall: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: service)
            }
            
            HStack(spacing: 8) {
                if !service.isInstalled {
                    Button("Install") {
                        onInstall()
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .accentColor(.blue)
                } else {
                    if service.isRunning {
                        Button("Stop") {
                            onStop()
                        }
                        .buttonStyle(BorderedButtonStyle())
                    } else {
                        Button("Start") {
                            onStart()
                        }
                        .buttonStyle(BorderedButtonStyle())
                        .accentColor(.blue)
                    }
                    
                    Button("Uninstall") {
                        onUninstall()
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .foregroundColor(.red)
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct StatusBadge: View {
    let status: ServiceStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(statusText)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var statusColor: Color {
        if !status.isInstalled {
            return .gray
        } else if status.isRunning {
            return .green
        } else {
            return .orange
        }
    }
    
    private var statusText: String {
        if !status.isInstalled {
            return "Not Installed"
        } else if status.isRunning {
            return "Running"
        } else {
            return "Stopped"
        }
    }
}

struct PermissionsView: View {
    @ObservedObject var serviceManager: ServiceManagerViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Permissions Status")
                .font(.headline)
            
            HStack {
                Image(systemName: serviceManager.hasAccessibilityPermission ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(serviceManager.hasAccessibilityPermission ? .green : .red)
                
                Text("Accessibility")
                
                Spacer()
                
                if !serviceManager.hasAccessibilityPermission {
                    Button("Open Settings") {
                        serviceManager.openAccessibilitySettings()
                    }
                    .buttonStyle(BorderedButtonStyle())
                }
            }
            
            HStack {
                Image(systemName: serviceManager.hasInputMonitoringPermission ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(serviceManager.hasInputMonitoringPermission ? .green : .red)
                
                Text("Input Monitoring")
                
                Spacer()
                
                if !serviceManager.hasInputMonitoringPermission {
                    Button("Open Settings") {
                        serviceManager.openInputMonitoringSettings()
                    }
                    .buttonStyle(BorderedButtonStyle())
                }
            }
        }
        .padding(16)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
    }
}

// MARK: - Data Models

struct ServiceStatus {
    var isInstalled: Bool = false
    var isRunning: Bool = false
    var hasPermissions: Bool = false
}

// MARK: - View Model

class ServiceManagerViewModel: ObservableObject {
    @Published var desktopSwitcher = ServiceStatus()
    @Published var scrollFix = ServiceStatus()
    @Published var hasAccessibilityPermission = false
    @Published var hasInputMonitoringPermission = false
    
    private let desktopSwitcherService = "com.user.desktopswitcher"
    private let scrollFixService = "com.user.scrollfix"
    private let installDir = "/usr/local/bin"
    private let launchAgentsDir = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/LaunchAgents")
    
    init() {
        refreshStatus()
        startPeriodicRefresh()
    }
    
    func refreshStatus() {
        DispatchQueue.main.async {
            self.checkServiceStatus()
            self.checkPermissions()
        }
    }
    
    private func startPeriodicRefresh() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            self.refreshStatus()
        }
    }
    
    private func checkServiceStatus() {
        // Check Desktop Switcher
        let dsInstalled = FileManager.default.fileExists(atPath: "\(installDir)/desktop-switcher") &&
                         FileManager.default.fileExists(atPath: launchAgentsDir.appendingPathComponent("\(desktopSwitcherService).plist").path)
        
        let dsRunning = isServiceRunning(desktopSwitcherService)
        
        desktopSwitcher = ServiceStatus(isInstalled: dsInstalled, isRunning: dsRunning)
        
        // Check ScrollFix
        let sfInstalled = FileManager.default.fileExists(atPath: "\(installDir)/scrollfix") &&
                         FileManager.default.fileExists(atPath: launchAgentsDir.appendingPathComponent("\(scrollFixService).plist").path)
        
        let sfRunning = isServiceRunning(scrollFixService)
        
        scrollFix = ServiceStatus(isInstalled: sfInstalled, isRunning: sfRunning)
    }
    
    private func checkPermissions() {
        hasAccessibilityPermission = AXIsProcessTrusted()
        // Input monitoring permission is harder to check directly
        hasInputMonitoringPermission = true // Assume true for now
    }
    
    private func isServiceRunning(_ serviceName: String) -> Bool {
        let task = Process()
        task.launchPath = "/bin/launchctl"
        task.arguments = ["list", serviceName]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch {
            return false
        }
    }
    
    // MARK: - Service Management
    
    func installDesktopSwitcher() {
        runManagementScript(["create", "desktop-switcher"])
    }
    
    func startDesktopSwitcher() {
        runManagementScript(["start", "desktop-switcher"])
    }
    
    func stopDesktopSwitcher() {
        runManagementScript(["stop", "desktop-switcher"])
    }
    
    func uninstallDesktopSwitcher() {
        runManagementScript(["delete", "desktop-switcher"])
    }
    
    func installScrollFix() {
        runManagementScript(["create", "scrollfix"])
    }
    
    func startScrollFix() {
        runManagementScript(["start", "scrollfix"])
    }
    
    func stopScrollFix() {
        runManagementScript(["stop", "scrollfix"])
    }
    
    func uninstallScrollFix() {
        runManagementScript(["delete", "scrollfix"])
    }
    
    func installAll() {
        runManagementScript(["create", "both"])
    }
    
    func startAll() {
        runManagementScript(["start", "both"])
    }
    
    func stopAll() {
        runManagementScript(["stop", "both"])
    }
    
    func uninstallAll() {
        runManagementScript(["delete", "both"])
    }
    
    private func runManagementScript(_ arguments: [String]) {
        DispatchQueue.global(qos: .userInitiated).async {
            let task = Process()
            task.launchPath = "/bin/bash"
            task.arguments = [Bundle.main.resourcePath! + "/manage-services.sh"] + arguments
            
            do {
                try task.run()
                task.waitUntilExit()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.refreshStatus()
                }
            } catch {
                print("Error running management script: \(error)")
            }
        }
    }
    
    // MARK: - Permission Management
    
    func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
    
    func openInputMonitoringSettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")!
        NSWorkspace.shared.open(url)
    }
}

// Main entry point
ServiceManagerApp.main()
