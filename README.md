# SilentPwn 🕵️‍♂️🔓

## Overview
SilentPwn is an advanced iOS Mod Menu framework designed for runtime manipulation and system-level interactions. Perfect for iOS application research, game modifications, and security testing.

[Video Menu Preview](https://i.imgur.com/lorajGZ.mp4)

## 🚀 Features

### Memory Hooking
- Runtime method interception
- Hook by memory address or symbol name
- Preserve original method functionality

### Configuration Management
- Centralized global configuration
- Debug mode support
- Customizable runtime settings

### Dynamic Menu System
- Interactive UI elements
- Slider and toggle controls
- Categorized modifications

### Advanced Capabilities
- IL2CPP class utilities
- Memory patching
- Runtime obfuscation

## 🛠 Prerequisites

- [iPhone15.5 SDK](https://github.com/Batchhh/SilentPwn/releases/latest)
- IOS Development Tools
- [Theos](https://theos.dev/)
- Objective-C++ knowledge

## 🔧 Installation Package

Install the [package](https://github.com/Batchhh/SilentPwn/releases/latest)

## 🔧 Build

1. Clone the repository
```bash
git clone https://github.com/Batchhh/SilentPwn.git
cd SilentPwn
```

2. Build for theos
```bash
$THEOS/bin/nicify.pl . && mv Batchh_SilentPwn\ 2.nic.tar $THEOS/templates/ios
```

## 🎉 Upload.sh

Run the script to upload the package to your device
```bash
./Upload.sh
```
This script will automatically remove the old com.* files on the device and upload the new package, also install the package and respring the device if you want.

## 📖 Documentation

Detailed documentation available in [wiki.md](wiki.md)

## 🚧 Usage Warning

**Disclaimer**: This framework is for research and educational purposes. Ensure compliance with legal and ethical guidelines.

## 📜 License

Distributed under the GNU General Public License v3.0.
See `LICENSE` for more information.

## 🏆 Credits

- [Batchh on GitHub](https://github.com/Batchhh)
- [Batchh on iOSGods](https://iosgods.com/profile/10738750-batchh/)
- [MJx0 - KittyMemory](https://github.com/MJx0/KittyMemory)
- LeFF Obfuscate.h

**⚠️ Ethical Use Only ⚠️**
