# Stack Monitor

[🇫🇷 FR](README.md) · [🇬🇧 EN](README_en.md)

Surveillance RAM/CPU du stack terminal — ghostty, omp, opencode, luvus, herdr — pour [Luvus](https://luvus.dev).

## ✅ Fonctionnalités

- **Widget barre** : RAM + CPU par process, total Σ, badge CPU ; version compacte automatique quand la place manque
- **Dock latéral** : une ligne par process, alignée en colonnes, pastilles d'état (vert < 512 Mo, orange < 2 Go, rouge au-delà) ; ligne TOTAL cliquable
- **TUI** : volet complet en overlay (open via right-click sur un pane ou clic sur la ligne TOTAL du dock)
- **Affichage** au choix : `bottom-right` · `top-right` · `dock` — appliqué à chaud, sans réactiver le module

## 🧠 Utilisation

Le widget se rafraîchit toutes les 10 s. Le réglage **Affichage** se navigue aux flèches dans Settings → Modules.

| Ligne du dock | RAM | CPU |
|---|---|---|
| `Ghostty` | < 512 Mo 🟢 · < 2 Go 🟠 · ≥ 2 Go 🔴 | idem |

## ⚙️ Réglages

| Clé | Type | Défaut | Rôle |
|---|---|---|---|
| `display` | enum | `bottom-right` | `bottom-right` / `top-right` / `dock` |

## 🧪 Installation

```sh
luvus module install mondary/luvus-stackmon/stackmon-module
```

Prérequis : macOS ou Linux, `ps` (intégré). Testé contre Luvus 0.13.4.

📋 Voir le [CHANGELOG](CHANGELOG.md) pour l'historique complet.

## 🔗 Liens

- [Luvus](https://luvus.dev) · [Documentation modules](https://luvus.dev/docs)
