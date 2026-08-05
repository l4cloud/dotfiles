# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Install

```bash
git clone https://github.com/<your-username>/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow --override='.*' -t ~ .
```

> If stow reports a conflict on a plain file (not a symlink), delete that file and re-run.

---

## Shell

**zsh** with [zinit](https://github.com/zdharma-continuum/zinit) for plugin management.

| File | Purpose |
|------|---------|
| `.zshrc` | Main shell config — plugins, history, keybindings, prompt |
| `.zshenv` | Environment variables — `$EDITOR`, `$PATH`, `$GOPATH` |
| `.aliases` | Aliases |
| `.func.zsh` | Shell functions |
| `.ssh_fzf.zsh` | fzf-powered SSH host picker |

**Plugins**
- `zsh-completions` — extended completions
- `zsh-autosuggestions` — fish-style inline suggestions
- `zsh-syntax-highlighting` — command syntax highlighting

**Prompt:** [Starship](https://starship.rs)

---

## Text Editor — Neovim

Config lives at `.config/nvim/`. Built on [lazy.nvim](https://github.com/folke/lazy.nvim).

**Plugins**

| Plugin | Purpose |
|--------|---------|
| LSP + Mason | Language servers, diagnostics, completions |
| nvim-cmp | Autocompletion engine |
| Telescope | Fuzzy finder |
| Treesitter | Syntax highlighting & code parsing |
| Conform | Formatting |
| Gitsigns | Git decorations in the gutter |
| Lazygit | Git TUI inside Neovim |
| Yazi | File manager integration |
| mini.nvim | Collection of small utilities |
| Alpha | Start screen |
| Copilot | GitHub Copilot completions |
| Rose Pine | Colorscheme |
| Todo Comments | Highlight and search TODO/FIXME comments |
| Neogen | Docstring generator |

---

## Multiplexer — Zellij

Config lives at `.config/zellij/`. Uses a fully custom keybind layout with defaults cleared.

**Key bindings** (modal, prefix-free)

| Mode | Trigger |
|------|---------|
| Pane | `Ctrl p` |
| Tab | `Ctrl t` |
| Resize | `Ctrl n` |
| Move | `Ctrl h` |
| Scroll | `Ctrl s` |
| Session | `Ctrl o` |
| Tmux compat | `Ctrl b` |
| Locked | `Ctrl g` |

All modes use **hjkl** for directional navigation. `Esc` or `Enter` returns to normal mode.

**Shell functions** (in `.func.zsh`)

| Function | Description |
|----------|-------------|
| `zi` | Attach to or create a zellij session named after the current directory |
| `zf [dir]` | fzf over git repos and open selected in a new zellij session |
| `z [args]` | Attach to an existing session via fzf, or fall back to `zf` |

**Themes** at `.config/zellij/themes/` — rose-pine and noctalia variants.

---

## Opencode Agents

Agents live at `.opencode/agents/`. These are custom AI agent definitions used with [opencode](https://opencode.ai).

### `flow` (default)

A structured multi-phase workflow agent for coding tasks.

```
Phase 1 — Understand   → explore codebase, build context
Phase 2 — Clarify      → ask scoped questions, wait for answers
Phase 3 — Scope Check  → break large tasks into sub-tasks if needed
Phase 4 — Plan         → present full plan with READY pause point
Phase 5 — Implement    → execute only after explicit user approval
```

The agent never proceeds to implementation without explicit confirmation. Plans are always shown in full before any code is written.

### `helper`

A conversational planning partner. Does **not** write code — instead explores the codebase, discusses the approach in short back-and-forth exchanges, and drops numbered `// TODO:` comments at the exact locations where changes should happen. Designed to be used before handing off to `flow` or implementing manually.

```
Explore → Discuss → Align → Place TODOs → Hand off
```
