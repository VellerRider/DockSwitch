# DockSwitch

[English](#english) | [中文](#中文)

<div align="center">
  <img src="https://img.shields.io/badge/macOS-13.0+-blue.svg" alt="macOS 13.0+">
  <img src="https://img.shields.io/badge/Swift-5.0+-orange.svg" alt="Swift 5.0+">
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License: MIT">
</div>

---

## English

### 📖 Overview

**DockSwitch** is a lightweight macOS menu bar application that automatically adjusts your Dock position based on your display configuration. Perfect for users who work with multiple monitor setups and want different Dock positions for different environments.

### ✨ Key Features

- 🖥️ **Automatic Detection**: Intelligently detects your screen configuration using unique fingerprints
- 🔄 **Auto-Switching**: Automatically changes Dock position when you switch between monitor setups
- 💾 **Multiple Profiles**: Save unlimited configurations for different display setups
- 🌐 **Bilingual**: Full support for English and Chinese (based on system language)
- 🎯 **Simple UI**: Clean menu bar interface with minimal footprint
- 🔒 **Safe**: Uses AppleScript (no dangerous shell commands)
- ⚡ **Lightweight**: Minimal resource usage, runs quietly in the background

### 🎬 Use Cases

- **Office vs Home**: Dock at bottom for dual monitors at office, left side for laptop at home
- **Presentations**: Quickly switch Dock position when connecting to a projector
- **Desk Setups**: Different Dock positions for different desk configurations
- **Mobile Work**: Automatically adapt as you move between locations

### 📋 Requirements

- macOS 13.0 (Ventura) or later
- Automation permission for System Events

### 🚀 Installation

#### Option 1: Download Release (Recommended)

Download the latest version from the [Releases](https://github.com/VellerRider/DockSwitch/releases) page.

**Installation steps:**
1. Download `DockSwitch.zip`
2. Extract the file
3. Right-click `DockSwitch.app` and select "Open"
4. Click "Open" in the security warning dialog
5. Grant automation permission when prompted

⚠️ **Important**: You must right-click > Open the first time. Double-clicking won't work due to macOS security.

#### Option 2: Build from Source

1. Clone this repository:
   ```bash
   git clone https://github.com/VellerRider/DockSwitch.git
   cd DockSwitch
   ```

2. Open `DockSwitch.xcodeproj` in Xcode

3. Build and run (⌘R)

4. Grant automation permission when prompted

#### Option 3: Homebrew (Coming Soon)

```bash
brew install --cask dockswitch
```

### 🎯 How to Use

#### First Launch

1. **Launch DockSwitch** - The app will appear in your menu bar
2. **Grant Permission** - Allow DockSwitch to control System Events when prompted
   - Go to: System Settings > Privacy & Security > Automation
   - Enable DockSwitch

#### Creating a Configuration

1. Click the DockSwitch icon in the menu bar
2. Ensure you're in the environment you want to configure
3. Enter a name for this configuration (e.g., "Office Dual Monitor")
4. Select your preferred Dock position (Bottom/Left/Right)
5. Click "Save Config"

#### Automatic Switching

Once you've saved configurations for different environments:
- **Connect/disconnect monitors** - DockSwitch automatically detects the change
- **Wait ~1 second** - The app uses debouncing to avoid multiple triggers
- **Dock moves automatically** - Your Dock will switch to the saved position

#### Updating a Configuration

1. Switch to the environment you want to update
2. Modify the name or Dock position
3. Click "Update Config"

#### Deleting a Configuration

- Click the trash icon (🗑️) next to any saved configuration

### 🔧 Technical Details

#### Screen Fingerprinting

DockSwitch creates unique fingerprints for each display configuration by combining:
- Display names
- Screen resolutions
- Number of displays

Example fingerprint: `Built-in Retina Display_3024x1964|LG Ultra HD_3840x2160`

#### Dock Position Control

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

#### Storage

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

### 🌐 Localization

DockSwitch automatically detects your system language and displays the appropriate interface:

- 🇺🇸 English
- 🇨🇳 简体中文

To add more languages, contribute translations in the `.lproj` folders.

### 🛠️ Development

#### Project Structure

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

#### Key Components

- **LayoutConfig**: Data model for saved configurations
- **DockPosition**: Enum representing Dock positions (bottom/left/right)
- **DockManager**: Core logic controller (ObservableObject)
  - Screen fingerprint generation
  - Configuration management
  - Dock position control
- **MenuBarView**: SwiftUI interface
- **DockSwitchApp**: App entry point using MenuBarExtra

#### Building

```bash
# Open project
open DockSwitch.xcodeproj

# Or build from command line
xcodebuild -project DockSwitch.xcodeproj -scheme DockSwitch -configuration Release
```

### 🐛 Troubleshooting

#### Dock not switching automatically

1. **Check permissions**: System Settings > Privacy & Security > Automation
2. **Verify configuration**: Ensure you've saved a config for the current environment
3. **Check logs**: Look for fingerprint changes in Console.app

#### "Permission required" error

- Open System Settings > Privacy & Security > Automation
- Enable DockSwitch to control System Events
- Restart the app

#### Fingerprint not updating

- The app uses a 1-second debounce to avoid rapid changes
- Wait a moment after connecting/disconnecting displays
- Check Console logs for "Screen fingerprint changed" messages

### 📦 Distribution

#### Can I publish to the App Store?

**Yes, but with conditions:**
- AppleScript usage is allowed but strictly reviewed by Apple
- Requires proper entitlements and user authorization
- May need detailed explanation during review process

### Recommended Distribution Methods

1. **GitHub Releases** (Free, easiest for open source)
2. **Apple Notarized DMG** (Best user experience, requires $99/year)
3. **Homebrew Cask** (Great for technical users)

### 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

#### Areas for Contribution

- 🌍 Additional language translations
- 🎨 UI/UX improvements  
- 🐛 Bug fixes
- 📝 Documentation improvements
- ✨ New features

### 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### 🙏 Acknowledgments

- Built with Swift and SwiftUI
- Uses macOS AppleScript for Dock control
- Inspired by the need for better multi-monitor workspace management

### 📮 Contact

- **Issues**: [GitHub Issues](https://github.com/VellerRider/DockSwitch/issues)
- **Discussions**: [GitHub Discussions](https://github.com/VellerRider/DockSwitch/discussions)

---

## 中文

### 📖 简介

**DockSwitch** 是一款轻量级的 macOS 菜单栏应用程序，可以根据您的显示器配置自动调整程序坞位置。非常适合使用多显示器设置并希望在不同环境下使用不同程序坞位置的用户。

### ✨ 主要特性

- 🖥️ **自动检测**：使用独特的指纹智能识别您的屏幕配置
- 🔄 **自动切换**：在不同显示器设置之间切换时自动更改程序坞位置
- 💾 **多配置文件**：为不同的显示器设置保存无限数量的配置
- 🌐 **双语支持**：完整支持英文和简体中文（基于系统语言）
- 🎯 **简洁界面**：清爽的菜单栏界面，占用空间最小
- 🔒 **安全可靠**：使用 AppleScript（无危险的 shell 命令）
- ⚡ **轻量级**：资源占用最小，在后台静默运行

### 🎬 使用场景

- **办公室 vs 家中**：办公室双显示器时程序坞在底部，家中笔记本时在左侧
- **演示展示**：连接投影仪时快速切换程序坞位置
- **办公桌布局**：不同办公桌配置使用不同的程序坞位置
- **移动办公**：在不同地点间移动时自动适应

### 📋 系统要求

- macOS 13.0 (Ventura) 或更高版本
- 系统事件的自动化权限

### 🚀 安装方法

#### 方式 1：下载发行版（推荐）

从 [Releases](https://github.com/VellerRider/DockSwitch/releases) 页面下载最新版本。

**安装步骤：**
1. 下载 `DockSwitch.zip`
2. 解压文件
3. 右键点击 `DockSwitch.app` 并选择"打开"
4. 在安全警告对话框中点击"打开"
5. 在提示时授予自动化权限

⚠️ **重要提示**：首次运行必须右键点击 > 打开。由于 macOS 安全机制，双击打开将无法运行。

#### 方式 2：从源码构建

1. 克隆此仓库：
   ```bash
   git clone https://github.com/VellerRider/DockSwitch.git
   cd DockSwitch
   ```

2. 在 Xcode 中打开 `DockSwitch.xcodeproj`

3. 构建并运行 (⌘R)

4. 在提示时授予自动化权限

#### 方式 3：Homebrew（即将推出）

```bash
brew install --cask dockswitch
```

### 🎯 使用方法

#### 首次启动

1. **启动 DockSwitch** - 应用程序将出现在菜单栏中
2. **授予权限** - 在提示时允许 DockSwitch 控制系统事件
   - 前往：系统设置 > 隐私与安全性 > 自动化
   - 启用 DockSwitch

#### 创建配置

1. 点击菜单栏中的 DockSwitch 图标
2. 确保您处于要配置的环境中
3. 为此配置输入名称（例如："办公室双显示器"）
4. 选择您首选的程序坞位置（底部/左侧/右侧）
5. 点击"保存配置"

#### 自动切换

一旦您为不同环境保存了配置：
- **连接/断开显示器** - DockSwitch 自动检测变化
- **等待约 1 秒** - 应用使用防抖动来避免多次触发
- **程序坞自动移动** - 您的程序坞将切换到保存的位置

#### 更新配置

1. 切换到您要更新的环境
2. 修改名称或程序坞位置
3. 点击"更新配置"

#### 删除配置

- 点击任何已保存配置旁边的垃圾桶图标（🗑️）

### 🔧 技术细节

#### 屏幕指纹识别

DockSwitch 通过组合以下信息为每个显示器配置创建唯一指纹：
- 显示器名称
- 屏幕分辨率
- 显示器数量

指纹示例：`Built-in Retina Display_3024x1964|LG Ultra HD_3840x2160`

#### 程序坞位置控制

应用程序使用 AppleScript 与系统事件通信：
```applescript
tell application "System Events"
    tell dock preferences
        set screen edge to bottom
    end tell
end tell
```

此方法的优点：
- ✅ 安全且经过 Apple 批准
- ✅ 平滑（无需重启程序坞）
- ✅ 在各个 macOS 版本中可靠运行

#### 存储方式

配置以 JSON 格式存储在 UserDefaults 中：
```json
[
  {
    "id": "Built-in Retina Display_3024x1964",
    "name": "仅笔记本",
    "dockPosition": "left"
  }
]
```

### 🌐 本地化

DockSwitch 自动检测您的系统语言并显示相应的界面：

- 🇺🇸 英文
- 🇨🇳 简体中文

要添加更多语言，请在 `.lproj` 文件夹中贡献翻译。

### 🛠️ 开发

#### 项目结构

```
DockSwitch/
├── DockSwitch/
│   ├── DockSwitchApp.swift       # 主应用程序代码
│   ├── Assets.xcassets/          # 应用图标和资源
│   ├── en.lproj/                 # 英文本地化
│   │   └── Localizable.strings
│   └── zh-Hans.lproj/            # 中文本地化
│       └── Localizable.strings
├── DockSwitch.xcodeproj/         # Xcode 项目
└── README.md
```

#### 核心组件

- **LayoutConfig**：保存配置的数据模型
- **DockPosition**：表示程序坞位置的枚举（底部/左侧/右侧）
- **DockManager**：核心逻辑控制器（ObservableObject）
  - 屏幕指纹生成
  - 配置管理
  - 程序坞位置控制
- **MenuBarView**：SwiftUI 界面
- **DockSwitchApp**：使用 MenuBarExtra 的应用程序入口点

#### 构建

```bash
# 打开项目
open DockSwitch.xcodeproj

# 或从命令行构建
xcodebuild -project DockSwitch.xcodeproj -scheme DockSwitch -configuration Release
```

### 🐛 故障排除

#### 程序坞未自动切换

1. **检查权限**：系统设置 > 隐私与安全性 > 自动化
2. **验证配置**：确保您已为当前环境保存配置
3. **查看日志**：在控制台应用中查找指纹变化

#### "需要权限"错误

- 打开系统设置 > 隐私与安全性 > 自动化
- 启用 DockSwitch 控制系统事件
- 重启应用程序

#### 指纹未更新

- 应用程序使用 1 秒防抖动以避免快速变化
- 连接/断开显示器后稍等片刻
- 在控制台日志中检查"屏幕指纹已更改"消息

### 📦 分发

#### 可以发布到 App Store 吗？

**可以，但有条件：**
- AppleScript 使用是允许的，但会受到 Apple 的严格审查
- 需要适当的权限和用户授权
- 审查过程中可能需要详细说明

#### 推荐的分发方式

1. **GitHub Releases**（免费，最适合开源项目）
2. **Apple 公证的 DMG**（最佳用户体验，需要 $99/年）
3. **Homebrew Cask**（适合技术用户）

### 🤝 贡献

欢迎贡献！请随时提交问题或拉取请求。

#### 贡献方向

- 🌍 添加更多语言翻译
- 🎨 UI/UX 改进
- 🐛 Bug 修复
- 📝 文档改进
- ✨ 新功能

### 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

### 🙏 致谢

- 使用 Swift 和 SwiftUI 构建
- 使用 macOS AppleScript 进行程序坞控制
- 灵感来自于更好的多显示器工作空间管理需求

### 📮 联系方式

- **问题反馈**：[GitHub Issues](https://github.com/VellerRider/DockSwitch/issues)
- **讨论交流**：[GitHub Discussions](https://github.com/VellerRider/DockSwitch/discussions)

---

<div align="center">
  Made with ❤️ for macOS users who love multiple monitors<br>
  为热爱多显示器的 macOS 用户用心打造
</div>
