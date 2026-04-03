# EnvBox

A lightweight macOS menu bar app for managing your API keys and environment variables.

No more digging through `.zshrc` to find that one API key. EnvBox reads your shell config, displays all your environment variables in a clean interface, and lets you add, edit, or delete them with a click.

## Features

- **Instant overview** — Click the menu bar icon to see all your environment variables at a glance
- **Smart masking** — API keys are masked by default (`sk-••••••••de58`), hover to reveal. URLs and paths are shown in full
- **Quick add** — Add new API keys with name + value + optional Base URL, automatically writes to `~/.zshrc`
- **Edit & delete** — Modify or remove any variable, changes take effect immediately
- **Search** — Filter variables by name
- **Copy to clipboard** — One-click copy for any value
- **Keyboard shortcut** — `Ctrl+Shift+E` to toggle from anywhere

## Screenshot

<img width="420" alt="EnvBox" src="https://img.shields.io/badge/macOS-menu_bar_app-blue?style=flat-square">

## Install

### Build from source

Requires Xcode / Swift 6.0+, macOS 13+.

```bash
git clone https://github.com/JOZUJIOJIO/EnvBox.git
cd EnvBox
make install
```

This builds a release binary and copies `EnvBox.app` to `/Applications/`.

### Run directly

```bash
swift build
.build/debug/EnvBox
```

## How it works

EnvBox parses `export KEY="VALUE"` lines from `~/.zshrc`. When you add or edit a variable, it writes the change back to `~/.zshrc` and sources the file so changes take effect immediately.

- Skips commented-out lines (`# export ...`)
- Skips PATH and other system variables
- Supports double-quoted, single-quoted, and unquoted values
- Adding an API key with a Base URL automatically creates the matching `_BASE_URL` variable (e.g., `OPENAI_API_KEY` + Base URL → also adds `OPENAI_BASE_URL`)

## Tech

- Swift + SwiftUI + AppKit
- Zero dependencies
- ~500KB app bundle
- No Dock icon (menu bar only)

## License

MIT
