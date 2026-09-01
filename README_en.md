# Stack Monitor

[🇫🇷 FR](README.md) · [🇬🇧 EN](README_en.md)

RAM/CPU monitoring for your terminal stack — ghostty, omp, opencode, luvus, herdr — for [Luvus](https://luvus.dev).

## ✅ Features

- **Bar widget**: per-process RAM + CPU, Σ total, CPU badge; automatic compact version when space is tight
- **Sidebar dock**: one aligned row per process, status dots (green < 512 MB, orange < 2 GB, red above); clickable TOTAL row
- **TUI**: full pane in overlay (open via right-click on a pane or click the dock's TOTAL row)
- **Display** choice: `bottom-right` · `top-right` · `dock` — applied live, no module re-enable needed

## 🧠 Usage

The widget refreshes every 10 s. The **Display** setting is browsed with arrow keys in Settings → Modules.

| Dock row | RAM | CPU |
|---|---|---|
| `Ghostty` | < 512 MB 🟢 · < 2 GB 🟠 · ≥ 2 GB 🔴 | same |

## ⚙️ Settings

| Key | Type | Default | Purpose |
|---|---|---|---|
| `display` | enum | `bottom-right` | `bottom-right` / `top-right` / `dock` |

## 🧪 Install

```sh
luvus module install mondary/luvus-stackmon/stackmon-module
```

Requirements: macOS or Linux, stock `ps`. Tested against Luvus 0.13.4.

📋 See the [CHANGELOG](CHANGELOG.md) for full history.

## 🔗 Links

- [Luvus](https://luvus.dev) · [Module docs](https://luvus.dev/docs)
