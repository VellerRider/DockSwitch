# DockSwitch

<div align="center">
  <img src="https://img.shields.io/badge/macOS-13.0+-blue.svg" alt="macOS 13.0+">
  <img src="https://img.shields.io/badge/Swift-5.0+-orange.svg" alt="Swift 5.0+">
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License: MIT">
</div>

## 📖 Overview

**DockSwitch** is a lightweight macOS menu bar application that automatically adjusts your Dock position based on your display configuration. Perfect for users who work with multiple monitor setups and want different Dock positions for different environments.

### ✨ Key Features

- 🖥️ **Automatic Detection**: Intelligently detects your screen configuration using unique fingerprints
- 🔄 **Auto-Switching**: Automatically changes Dock position when you switch between monitor setups
- 💾 **Multiple Profiles**: Save unlimited configurations for different display setups
- 🌐 **Bilingual**: Full support for English and Chinese (based on system language)
- 🎯 **Simple UI**: Clean menu bar interface with minimal footprint
- 🔒 **Safe**: Uses AppleScript (no dangerous shell commands)
- ⚡ **Lightweight**: Minimal resource usage, runs quietly in the background

## 🎬 Use Cases

- **Office vs Home**: Dock at bottom for dual monitors at office, left side for laptop at home
- **Presentations**: Quickly switch Dock position when connecting to a projector
- **Desk Setups**: Different Dock positions for different desk configurations
- **Mobile Work**: Automatically adapt as you move between locations

## 📋 Requirements

- macOS 13.0 (Ventura) or later
- Automation permission for System Events

## 🚀 Installation

### Option 1: Download Release (Recommended)

Download the latest version from the [Releases](https://github.com/yourusername/DockSwitch/releases) page.

**Installation steps:**
1. Download `DockSwitch.zip`
2. Extract the file
3. Right-click `DockSwitch.app` and select "Open"
4. Click "Open" in the security warning dialog
5. Grant automation permission when prompted

⚠️ **Important**: You must right-click > Open the first time. Double-clicking won't work due to macOS security.

### Option 2: Build from Source

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/DockSwitch.git
   cd DockSwitch
   ```

2. Open `DockSwitch.xcodeproj` in Xcode

3. Build and run (⌘R)

4. Grant automation permission when prompted

### Option 3: Homebrew (Coming Soon)

```bash
brew install --cask dockswitch
```

## 🎯 How to Use

### First Launch

1. **Launch DockSwitch** - The app will appear in your menu bar
2. **Grant Permission** - Allow DockSwitch to control System Events when prompted
   - Go to: System Settings > Privacy & Security > Automation
   - Enable DockSwitch

### Creating a Configuration

1. Click the DockSwitch icon in the menu bar
2. Ensure you're in the environment you want to configure
3. Enter a name for this configuration (e.g., "Office Dual Monitor")
4. Select your preferred Dock position (Bottom/Left/Right)
5. Click "Save Config"

### Automatic Switching

Once you've saved configurations for different environments:
- **Connect/disconnect monitors** - DockSwitch automatically detects the change
- **Wait ~1 second** - The app uses debouncing to avoid multiple triggers
- **Dock moves automatically** - Your Dock will switch to the saved position

### Updating a Configuration

1. Switch to the environment you want to update
2. Modify the name or Dock position
3. Click "Update Config"

### Deleting a Configuration

- Click the trash icon (🗑️) next to any saved configuration

## 🔧 Technical Details

### Screen Fingerprinting

DockSwitch creates unique fingerprints for each display configuration by combining:
- Display names
- Screen resolutions
- Number of displays

Example fingerprint: `Built-in Retina Display_3024x1964|LG Ultra HD_3840x2160`

### Dock Position Control

The app uses AppleScript to communicate with System Events:
```applescript
tell application "System Events"
    tell dock preferences
        set screen edge to bottom
    end tell
end tell
```

This method is:
- ✅ Safe and approved by Apple
- ✅ Smooth (no Dock restart needed)
- ✅ Reliable across macOS versions

### Storage

Configurations are stored in UserDefaults as JSON:
```json
[
  {
    "id": "Built-in Retina Display_3024x1964",
    "name": "Laptop Only",
    "dockPosition": "left"
  }
]
```

## 🌐 Localization

DockSwitch automatically detects your system language and displays the appropriate interface:

- 🇺🇸 English
- 🇨🇳 简体中文

To add more languages, contribute translations in the `.lproj` folders.

## 🛠️ Development

### Project Structure

```
DockSwitch/
├── DockSwitch/
│   ├── DockSwitchApp.swift       # Main application code
│   ├── Assets.xcassets/          # App icons and assets
│   ├── en.lproj/                 # English localization
│   │   └── Localizable.strings
│   └── zh-Hans.lproj/            # Chinese localization
│       └── Localizable.strings
├── DockSwitch.xcodeproj/         # Xcode project
└── README.md
```

### Key Components

- **LayoutConfig**: Data model for saved configurations
- **DockPosition**: Enum representing Dock positions (bottom/left/right)
- **DockManager**: Core logic controller (ObservableObject)
  - Screen fingerprint generation
  - Configuration management
  - Dock position control
- **MenuBarView**: SwiftUI interface
- **DockSwitchApp**: App entry point using MenuBarExtra

### Building

```bash
# Open project
open DockSwitch.xcodeproj

# Or build from command line
xcodebuild -project DockSwitch.xcodeproj -scheme DockSwitch -configuration Release
```

## 🐛 Troubleshooting

### Dock not switching automatically

1. **Check permissions**: System Settings > Privacy & Security > Automation
2. **Verify configuration**: Ensure you've saved a config for the current environment
3. **Check logs**: Look for fingerprint changes in Console.app

### "Permission required" error

- Open System Settings > Privacy & Security > Automation
- Enable DockSwitch to control System Events
- Restart the app

### Fingerprint not updating

- The app uses a 1-second debounce to avoid rapid changes
- Wait a moment after connecting/disconnecting displays
- Check Console logs for "Screen fingerprint changed" messages

## 📦 Distribution

### Can I publish to the App Store?

**Yes, but with conditions:**
- AppleScript usage is allowed but strictly reviewed by Apple
- Requires proper entitlements and user authorization
- May need detailed explanation during review process

See [DISTRIBUTION.md](DISTRIBUTION.md) for detailed publishing guide.

### Recommended Distribution Methods

1. **GitHub Releases** (Free, easiest for open source)
2. **Apple Notarized DMG** (Best user experience, requires $99/year)
3. **Homebrew Cask** (Great for technical users)

## 🎨 Customizing Icon

Want to change the app icon? See [ICON_GUIDE.md](ICON_GUIDE.md) for:
- Using different SF Symbols
- Creating custom app icons
- Design recommendations
- Icon generation tools

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

### Areas for Contribution

- 🌍 Additional language translations
- 🎨 UI/UX improvements  
- 🐛 Bug fixes
- 📝 Documentation improvements
- ✨ New features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with Swift and SwiftUI
- Uses macOS AppleScript for Dock control
- Inspired by the need for better multi-monitor workspace management

## 📮 Contact

- **Issues**: [GitHub Issues](https://github.com/yourusername/DockSwitch/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/DockSwitch/discussions)

---

<div align="center">
  Made with ❤️ for macOS users who love multiple monitors
</div>
