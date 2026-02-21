# chip-8-watchOS

watchOS frontend for the CHIP-8 emulator.

## Build

```bash
xcodebuild clean build -workspace "./CHIP8WatchOS.xcodeproj/project.xcworkspace" \
  -scheme "CHIP8WatchOS WatchKit App" \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```

## Architecture

Xcode WatchKit project consuming `Chip8EmulatorPackage` via SPM. The dependency version is pinned in `CHIP8WatchOS.xcodeproj/project.pbxproj`.

Source is in `CHIP8WatchOS WatchKit Extension/`:

- **InterfaceController** — main WKInterfaceController, implements `Chip8EngineDelegate`
- **ExtensionDelegate** — WatchKit extension lifecycle
- **WatchInputCode / WatchInputMappingService** — maps watch input to `Chip8InputCode`
- **PlatformSupportedRomService** — platform ROM selection

## Dependency Updates

When `Chip8EmulatorPackage` is tagged with a new version:
1. Update the version in `CHIP8WatchOS.xcodeproj/project.pbxproj`
2. Delete `CHIP8WatchOS.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`
3. Build to verify

## Workflow

- Branch protection on `main`: PR required, `build` CI check required, enforce admins
- CI: `.github/workflows/build.yml` — xcodebuild on macOS

### PR flow

1. Commit to a feature branch
2. Push and create PR
3. Set PR to auto-merge (`gh pr merge --auto --squash`)
4. CI must pass before merge completes
