# dankWarpToggle

A minimal DankMaterialShell plugin that toggles Cloudflare WARP via `warp-cli` with real-time status updates.

## Features

- **Real-time status** — Uses `warp-cli -l status` live stream for instant state updates
- **Minimal & polished** — Card-based UI with badge-style bar pill, spinner animation, and a clean popout panel following DMS Material 3 design
- **No DBus, no native bindings** — Interacts with WARP exclusively via subprocess calls
- **Settings** — Toggle the listener, adjust restart interval, manual refresh

## Requirements

- `warp-cli` installed and available in `$PATH`
- DankMaterialShell >= 1.4.0

## Permissions

- `process` — spawn `warp-cli` subprocesses
- `settings_read` / `settings_write` — persist plugin preferences

## Usage

- Click the bar pill to toggle WARP on/off
- Expand the widget to see detailed status and a toggle button
- Open plugin settings to configure the listener behavior

## Files

| File | Description |
|------|-------------|
| `plugin.json` | Plugin manifest |
| `DankWarpToggle.qml` | Main UI component (bar pill + popout) |
| `DankWarpToggleService.qml` | Singleton service (listener process + toggle logic) |
| `DankWarpToggleSettings.qml` | Settings panel |
| `components/WarpToggleButton.qml` | Reusable toggle button |
| `qmldir` | QML singleton registration |

## License

MIT
