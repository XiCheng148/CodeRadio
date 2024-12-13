# CodeRadio

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/XiCheng148/CodeRadio)](https://github.com/XiCheng148/CodeRadio/releases)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-macOS%2013.5+-blue.svg)](https://www.apple.com/macos/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Build Status](https://github.com/XiCheng148/CodeRadio/actions/workflows/buildAndRelease.yaml/badge.svg)](https://github.com/XiCheng148/CodeRadio/actions)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/XiCheng148/CodeRadio/pulls)

🎵 24/7 music designed for coding, now in your mac!

A menu bar music radio client for https://coderadio.freecodecamp.org ([about](https://www.freecodecamp.org/news/code-radio-24-7/)), written in Swift.

![screenshot](./.github/images/screenshot.png)

## Install

- Download prebuilt binary from [GitHub release page](https://github.com/XiCheng148/CodeRadio/releases).
- enjoy~

## Development

### Requirements

- Xcode 15.0+
- Swift 5.9+
- macOS 13.5+
- [Tuist](https://github.com/tuist/tuist)

### Build Steps

1. Install [Tuist](https://github.com/tuist/tuist#install-▶️)

2. Clone repository
```bash
git clone https://github.com/XiCheng148/CodeRadio.git
cd CodeRadio
```

3. Generate Xcode project
```bash
tuist install
tuist generate
```

4. Open and build
```bash
open CodeRadio.xcworkspace
```

### Automated Build and Release

This project uses GitHub Actions for automated building and releasing:

1. Push a new version tag to trigger automatic build:
```bash
git tag v1.0.0
git push origin v1.0.0
```

2. GitHub Actions will automatically:
   - install
   - Build the application
   - Create DMG package
   - Release new version

3. Build artifacts can be downloaded from [Releases](https://github.com/XiCheng148/CodeRadio/releases)

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

## Acknowledgments 🙏

This project was inspired by and received help from:
- [Awesome-Merge-Picture](https://github.com/XiCheng148/Awesome-Merge-Picture) - A tool to quickly create a preview image of a dark 和 light mode project.
-
