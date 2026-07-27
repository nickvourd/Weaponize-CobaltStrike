# Weaponize-CobaltStrike

Your Cobalt Strike Weaponization Toolkit

<p align="center">\
  <img width="500" height="400" src="/Pictures/logo.svg"><br /><br />
  <!--<img alt="GitHub License" src="https://img.shields.io/github/license/nickvourd/Weaponize-CobaltStrike?style=social&logo=GitHub&logoColor=purple">
  <img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/nickvourd/Weaponize-CobaltStrike?logoColor=yellow"><br />
  <img alt="GitHub forks" src="https://img.shields.io/github/forks/nickvourd/Weaponize-CobaltStrike?logoColor=red">
  <img alt="GitHub watchers" src="https://img.shields.io/github/watchers/nickvourd/Weaponize-CobaltStrike?logoColor=blue">
  <img alt="GitHub contributors" src="https://img.shields.io/github/contributors/nickvourd/Weaponize-CobaltStrike?style=social&logo=GitHub&logoColor=green">-->
</p>

## Description

Weaponize-CobaltStrike is an automated toolkit for setting up and configuring Cobalt Strike with a comprehensive collection of Beacon Object Files (BOFs) and offensive security tools. This project streamlines the installation of dependencies and compilation of multiple open-source BOFs and utilities, making it easy to extend your Cobalt Strike arsenal with community-driven capabilities.

![Static Badge](https://img.shields.io/badge/Bash-darkgreen?style=flat&logoSize=auto)
![Static Badge](https://img.shields.io/badge/BOF-red?style=flat&logoSize=auto)
![Static Badge](https://img.shields.io/badge/Mingw--w64-blue?style=flat&logoSize=auto)
![Static Badge](https://img.shields.io/badge/LLVM-cyan?style=flat&logoSize=auto)

## Features

Weaponize-CobaltStrike automates the deployment of the following tools and BOFs:

- **CS-Aggressor-Kit** - Aggressor script framework for Cobalt Strike
- **CS-Remote-OPs-BOF** - Remote operations Beacon Object Files
- **CS-Situational-Awareness-BOF** - Situational awareness and reconnaissance BOFs
- **GetWebDAVStatus** - WebDAV status enumeration
- **C2-Tool-Collection** - Comprehensive C2 tool collection
- **sekken-enum** - Enumeration BOF
- **WebcamBOF** - Webcam access BOF
- **COM-Hunter** - COM object enumeration
- **PrivKit** - Privilege escalation toolkit
- **RegPersist** - Registry-based persistence BOF
- **HelpColor** - Color formatting utilities
- **PersisTask-BOF** - Persistence through scheduled tasks

> If you find any bugs or have suggestions, don't hesitate to [report them](https://github.com/nickvourd/Weaponize-CobaltStrike/issues). Your feedback is valuable in improving the quality of this project!

Created with <3 by [@nickvourd](https://x.com/nickvourd/)

## Disclaimer

The authors and contributors of this project are not liable for any illegal use of the tool. It is intended for authorized security testing and educational purposes only. Users are responsible for ensuring lawful usage and obtaining proper authorization before conducting any offensive security activities.

## Table of Contents
- [Weaponize-CobaltStrike](#weaponize-cobaltstrike)
  - [Description](#description)
  - [Features](#features)
  - [Disclaimer](#disclaimer)
  - [Table of Contents](#table-of-contents)
  - [Acknowledgement](#acknowledgement)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Usage](#usage)
  - [References](#references)

## Acknowledgement

This project created with :heart: by [@nickvourd](https://x.com/nickvourd).

Special thanks to all the contributors and maintainers of the individual BOF projects integrated into this toolkit.

## Prerequisites

Weaponize-CobaltStrike requires the following tools to be installed on your system:

- **git** - Version control system
- **make** - Build automation tool
- **mingw-w64** - Cross-compilation toolchain for Windows executables
- **LLVM/Clang** - C compiler and related tools

### Supported Operating Systems

- **macOS** (Intel and Apple Silicon via Homebrew)
- **Linux** (Debian/Ubuntu, Fedora/RHEL, Arch)

## Installation

### For macOS

Do NOT run the full script with sudo on macOS. Homebrew should run as a normal user.

```bash
./WeaponizeCobaltStrike.sh install
```

The script will automatically install Homebrew and all required dependencies.

### For Linux

On Linux, you may need sudo privileges for package manager operations.

```bash
sudo ./WeaponizeCobaltStrike.sh install
```

Or if running as root:

```bash
./WeaponizeCobaltStrike.sh install
```

## Usage

### Install Mode

Clones all repositories and compiles all BOFs and tools:

```bash
./WeaponizeCobaltStrike.sh install
```

This command will:
1. Install missing dependencies
2. Clone all BOF repositories to `/opt`
3. Compile all available tools
4. Organize compiled files for Cobalt Strike integration

### Clean Mode

Remove all installed tools and compiled files:

```bash
./WeaponizeCobaltStrike.sh clean
```

⚠️ This will delete everything under `/opt` except `/opt/homebrew`

### CNA Discovery Mode

Find all compiled Cobalt Strike Aggressor scripts (.cna files):

```bash
./WeaponizeCobaltStrike.sh cna
```

If no .cna files are found, this will automatically run the install process.

## References

- [Cobalt Strike Official Site](https://www.cobaltstrike.com/)
- [Beacon Object Files (BOF) Documentation](https://www.cobaltstrike.com/help-beacon-object-files)
- [TrustedSec Security Research](https://www.trustedsec.com/)
- [Outflank Research](https://outflank.nl/)
