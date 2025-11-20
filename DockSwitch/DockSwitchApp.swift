import SwiftUI
import Combine
import AppKit

// MARK: - Global Menu Bar Manager

class MenuBarController: NSObject {
    static let shared = MenuBarController()
    
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    
    func setup() {
        // Create status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "dock.rectangle", accessibilityDescription: "DockSwitch")
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        // Create popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 300, height: 500)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: MenuBarView())
    }
    
    @objc func togglePopover() {
        guard let button = statusItem?.button else { return }
        
        if let popover = popover {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    func hideIcon() {
        statusItem?.isVisible = false
        popover?.performClose(nil)
    }
    
    func showIcon() {
        statusItem?.isVisible = true
    }
}

// MARK: - App Delegate for handling app reopen events

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Setup menu bar
        MenuBarController.shared.setup()
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // Show menu bar icon when app is clicked again
        MenuBarController.shared.showIcon()
        return true
    }
}

// MARK: - Data Models

struct LayoutConfig: Codable, Identifiable, Equatable {
    var id: String // Screen fingerprint
    var name: String // User-defined name for this configuration (e.g., "Office Dual Monitor")
    var dockPosition: DockPosition
}

enum DockPosition: String, Codable, CaseIterable, Identifiable {
    case bottom = "bottom"
    case left = "left"
    case right = "right"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .bottom: 
            return NSLocalizedString("dock_position_bottom", comment: "")
        case .left: 
            return NSLocalizedString("dock_position_left", comment: "")
        case .right: 
            return NSLocalizedString("dock_position_right", comment: "")
        }
    }
}

// MARK: - Core Logic Controller

class DockManager: ObservableObject {
    @Published var currentFingerprint: String = ""
    @Published var savedConfigs: [LayoutConfig] = []
    @Published var lastActionMessage: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    private var hasShownPermissionAlert = false // Prevent repeated alerts
    
    // Computed property for current environment's config (cached for performance)
    var currentConfig: LayoutConfig? {
        savedConfigs.first(where: { $0.id == currentFingerprint })
    }
    
    init() {
        // Load saved configurations
        loadConfigs()
        
        // Initialize current fingerprint (without triggering a switch)
        currentFingerprint = updateFingerprint()
        
        // Initialize status message
        lastActionMessage = NSLocalizedString("status_ready", comment: "")
        
        // Listen for screen change notifications
        NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)
            .debounce(for: .seconds(1.0), scheduler: RunLoop.main) // Debounce to avoid multiple triggers during connect/disconnect
            .sink { [weak self] _ in
                self?.handleScreenChange()
            }
            .store(in: &cancellables)
    }
    
    // Generate screen fingerprint (using resolution + name combination, unique enough)
    func updateFingerprint() -> String {
        let screens = NSScreen.screens
        let fingerprint = screens.map { screen -> String in
            let width = Int(screen.frame.width)
            let height = Int(screen.frame.height)
            let name = screen.localizedName
            return "\(name)_\(width)x\(height)"
        }.sorted().joined(separator: "|")
        
        return fingerprint
    }
    
    // Handle screen change logic
    func handleScreenChange() {
        let newFingerprint = updateFingerprint()
        
        // Skip if fingerprint hasn't changed (avoid redundant triggers)
        guard newFingerprint != currentFingerprint else {
            print("Screen change but fingerprint unchanged, skipping")
            return
        }
        
        print("Screen fingerprint changed from: \(currentFingerprint)")
        print("                              to: \(newFingerprint)")
        
        currentFingerprint = newFingerprint
        
        // Check if there's a saved configuration for this fingerprint
        if let config = currentConfig {
            print("Found matching config: \(config.name) - \(config.dockPosition.rawValue)")
            applyDockPosition(config.dockPosition)
            let message = String(format: NSLocalizedString("status_auto_switched_format", comment: ""), config.dockPosition.displayName)
            lastActionMessage = message
        } else {
            print("No matching config found for this fingerprint")
            lastActionMessage = NSLocalizedString("status_new_environment", comment: "")
        }
    }
    
    // Apply Dock position change
    func applyDockPosition(_ position: DockPosition) {
        print("Attempting to set dock position to: \(position.rawValue)")
        
        // Use AppleScript (smoother, doesn't require Dock restart)
        let scriptSource = """
        tell application "System Events"
            tell dock preferences
                set screen edge to \(position.rawValue)
            end tell
        end tell
        """
        
        var error: NSDictionary?
        // Note: macOS doesn't have a direct API to "request" AppleScript permission.
        // The system automatically prompts on first execution.
        // We execute directly and rely on the system mechanism.
        
        if let scriptObject = NSAppleScript(source: scriptSource) {
            scriptObject.executeAndReturnError(&error)
            if error == nil {
                print("Successfully set Dock position via AppleScript")
                DispatchQueue.main.async {
                    let message = String(format: NSLocalizedString("status_switched_applescript_format", comment: ""), position.displayName)
                    self.lastActionMessage = message
                }
                return
            }
        }
        
        if let error = error {
            print("AppleScript failed: \(error)")
            
            // Get error details
            let errorNumber = error["NSAppleScriptErrorNumber"] as? Int ?? 0
            let errorMessage = error["NSAppleScriptErrorMessage"] as? String ?? "Unknown error"
            
            print("Error code: \(errorNumber)")
            print("Error message: \(errorMessage)")
            
            // -1743: Not authorized
            // -10004: Privilege violation
            if errorNumber == -1743 || errorNumber == -10004 {
                DispatchQueue.main.async {
                    self.lastActionMessage = NSLocalizedString("status_need_permission", comment: "")
                    
                    // Only show alert once per session to avoid annoying loops
                    if !self.hasShownPermissionAlert {
                        self.hasShownPermissionAlert = true
                        self.showPermissionAlert()
                    } else {
                        print("Permission alert already shown, not showing again")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.lastActionMessage = NSLocalizedString("status_switch_failed", comment: "")
                }
            }
        }
    }

    func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("permission_alert_title", comment: "")
        alert.informativeText = NSLocalizedString("permission_alert_message", comment: "")
        alert.alertStyle = .warning
        alert.addButton(withTitle: NSLocalizedString("permission_button_open_settings", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("permission_button_cancel", comment: ""))
        
        // Ensure execution on main thread
        if Thread.isMainThread {
            if alert.runModal() == .alertFirstButtonReturn {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation") {
                    NSWorkspace.shared.open(url)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.showPermissionAlert()
            }
        }
    }
    
    // Save or update configuration
    func saveOrUpdateConfig(name: String, position: DockPosition) {
        let defaultName = NSLocalizedString("unnamed_config", comment: "")
        let newConfig = LayoutConfig(id: currentFingerprint, name: name.isEmpty ? defaultName : name, dockPosition: position)
        
        // Update if exists, add if new
        if let index = savedConfigs.firstIndex(where: { $0.id == currentFingerprint }) {
            savedConfigs[index] = newConfig
            lastActionMessage = NSLocalizedString("status_config_updated", comment: "")
        } else {
            savedConfigs.append(newConfig)
            lastActionMessage = NSLocalizedString("status_config_saved", comment: "")
        }
        
        saveToDisk()
        applyDockPosition(position) // Apply immediately after saving
    }
    
    // Delete configuration
    func deleteConfig(at offsets: IndexSet) {
        savedConfigs.remove(atOffsets: offsets)
        saveToDisk()
    }
    
    // Persist to disk
    private func saveToDisk() {
        if let encoded = try? JSONEncoder().encode(savedConfigs) {
            UserDefaults.standard.set(encoded, forKey: "DockSwitchConfigs")
        }
    }
    
    private func loadConfigs() {
        if let data = UserDefaults.standard.data(forKey: "DockSwitchConfigs"),
           let decoded = try? JSONDecoder().decode([LayoutConfig].self, from: data) {
            savedConfigs = decoded
        }
    }
}

// MARK: - UI (Menu Bar Style)

struct MenuBarView: View {
    @StateObject var manager = DockManager()
    @State private var newConfigName: String = ""
    @State private var selectedPosition: DockPosition = .bottom
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Title bar
            HStack {
                Text(NSLocalizedString("app_title", comment: ""))
                    .font(.headline)
                Spacer()
                Text(manager.lastActionMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 4)
            
            Divider()
            
            // Current environment configuration section
            VStack(alignment: .leading) {
                // Configuration form for current environment (always visible, supports updates)
                VStack(alignment: .leading, spacing: 8) {
                    if let existingConfig = manager.currentConfig {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text(String(format: NSLocalizedString("current_environment_format", comment: ""), existingConfig.name))
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        .padding(.bottom, 4)
                    }
                    
                    Text(manager.currentConfig != nil ? NSLocalizedString("update_environment_config", comment: "") : NSLocalizedString("fingerprint_set_position", comment: ""))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    TextField(NSLocalizedString("name_placeholder", comment: ""), text: $newConfigName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(NSLocalizedString("dock_position_label", comment: ""))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Picker("", selection: $selectedPosition) {
                            ForEach(DockPosition.allCases) { pos in
                                Text(pos.displayName).tag(pos)
                            }
                        }
                        .pickerStyle(RadioGroupPickerStyle())
                        .labelsHidden()
                    }
                    
                    Button(action: {
                        manager.saveOrUpdateConfig(name: newConfigName, position: selectedPosition)
                        newConfigName = "" // Reset input field
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: manager.currentConfig != nil ? "arrow.triangle.2.circlepath" : "plus.circle.fill")
                            Text(manager.currentConfig != nil ? NSLocalizedString("button_update_config", comment: "") : NSLocalizedString("button_save_config", comment: ""))
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(8)
                .background(Color.accentColor.opacity(0.08))
                .cornerRadius(8)
                .onAppear {
                    // Pre-fill form with existing config if available
                    if let existing = manager.currentConfig {
                        newConfigName = existing.name
                        selectedPosition = existing.dockPosition
                    }
                }
                .onChange(of: manager.currentFingerprint) { _ in
                    // Update form when fingerprint changes
                    if let existing = manager.currentConfig {
                        newConfigName = existing.name
                        selectedPosition = existing.dockPosition
                    } else {
                        newConfigName = ""
                        selectedPosition = .bottom
                    }
                }
            }
            
            Divider()
            
            // Saved configurations list
            Text(NSLocalizedString("saved_configs_title", comment: ""))
                .font(.subheadline)
                .bold()
            
            if manager.savedConfigs.isEmpty {
                Text(NSLocalizedString("no_saved_configs", comment: ""))
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(manager.savedConfigs) { config in
                            HStack(spacing: 8) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(config.name)
                                        .font(.body)
                                    Text(config.dockPosition.displayName)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if config.id == manager.currentFingerprint {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                                Button(action: {
                                    if let index = manager.savedConfigs.firstIndex(where: { $0.id == config.id }) {
                                        manager.deleteConfig(at: IndexSet(integer: index))
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.plain)
                                .help(NSLocalizedString("delete_config_tooltip", comment: ""))
                            }
                            .padding(8)
                            .background(config.id == manager.currentFingerprint ? Color.green.opacity(0.1) : Color.clear)
                            .cornerRadius(6)
                        }
                    }
                }
                .frame(height: 150)
            }
            
            Divider()
            
            HStack {
                Button(action: {
                    MenuBarController.shared.hideIcon()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "eye.slash")
                        Text(NSLocalizedString("button_hide_icon", comment: ""))
                    }
                }
                .buttonStyle(.plain)
                .font(.caption)
                
                Spacer()
                
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "power")
                        Text(NSLocalizedString("button_quit_app", comment: ""))
                    }
                }
                .buttonStyle(.plain)
                .font(.caption)
                .foregroundColor(.red)
            }
        }
        .padding()
        .frame(width: 300)
    }
}

// MARK: - App Entry Point

@main
struct DockSwitchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // Empty scene - menu bar is managed by MenuBarController
        Settings {
            EmptyView()
        }
    }
}
