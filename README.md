# NoSleep

A tiny macOS menu bar app that keeps your Mac awake.

| State | Icon | Meaning |
|-------|------|---------|
| On  | strained, wide-open eye | Display and system sleep are blocked |
| Off | closed eye              | Your Mac sleeps as usual |

NoSleep holds standard IOKit power assertions (the same mechanism as `caffeinate`), so quitting or crashing the app always releases them. It has no Dock icon, no network access and no background daemons.

## Features

- Starts active as soon as it launches
- Pick a duration from the menu: indefinitely, 15 min, 30 min, 1 h, 2 h, 4 h or 8 h
- Shows the time remaining for timed sessions
- Icons are template images, so they follow light and dark menu bars

## Install

**Download:** grab `NoSleep.zip` from the [latest release](../../releases/latest), unzip it and drag `NoSleep.app` into `/Applications`.

The app is ad-hoc signed, not notarized, so the first time you open it macOS will block it. Right-click the app, choose **Open**, then confirm. Alternatively, run `xattr -dr com.apple.quarantine /Applications/NoSleep.app`.

**Build from source** (needs the Xcode command line tools):

```sh
./build.sh
cp -R NoSleep.app /Applications/
```

To start it at login, add it under System Settings → General → Login Items.

## Notes

- Closing the lid of a MacBook still puts it to sleep, as with every tool of this kind.
- On Macs with a notch, macOS can hide a new menu bar icon under the notch. NoSleep starts its icon near the clock to avoid this. If it ever disappears, hold ⌘ and drag it to the right.
- On macOS 26, make sure NoSleep is enabled under System Settings → Menu Bar → Allow in the Menu Bar.

## Project layout

| File | Purpose |
|------|---------|
| `main.swift` | App, menu and power assertions |
| `icons.swift` | Menu bar eye icons, drawn in code |
| `make_icon.swift` | Generates `AppIcon.icns` from the same artwork |
| `build.sh` | Builds and ad-hoc signs `NoSleep.app` |

## License

[MIT](LICENSE)
