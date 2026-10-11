# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Install

```bash
git clone https://github.com/<your-username>/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow --override='.*' -t ~ .
```

> If stow reports a conflict on a plain file (not a symlink), delete that file and re-run.

### Packages

Fedora packages are split into two lists and installed by `install.sh`, which prompts
for a profile:

```bash
./install.sh
```

| Profile | Lists | Use case |
|---------|-------|----------|
| `minimal` | `packages.base` | WSL / headless — CLI tools only |
| `full` | `packages.base` + `packages.desktop` | Desktop — adds GUI/Wayland/Hyprland packages |

`packages.base` holds tools needed everywhere — shell/core CLI (nvim, zellij, zsh, fzf,
nerd font), languages/toolchains, C/C++ build tools, and cloud/container CLIs.
`packages.desktop` holds GUI-only packages (browser, Discord, LibreOffice, Hyprland meta,
`wl-clipboard`, GTK theme). Both lists support `#` comments and blank lines.

**Languages & tooling** (all in `packages.base`, from Fedora repos unless noted)

| Area | Packages |
|------|----------|
| Go | `golang` (`gopls`/`delve` come from Mason in nvim) |
| Python | `python3`, `uv`, `ruff` |
| Node/TS | `pnpm` (Node itself via nvm / `nodejs22`) |
| Java | `java-25-openjdk-devel` |
| Rust | `rust`, `cargo` |
| C/C++ | `clang`, `clang-tools-extra`, `cmake`, `ninja-build`, `gcc`, `gcc-c++`, `make` |
| Cloud/containers | `kubernetes1.35-client`, `helm`, `awscli2`, `k9s` |
| Terraform | `terraform` (HashiCorp repo), `tflint` (`go install`) |
| Docker | `docker-ce`, `docker-buildx-plugin`, `docker-compose-plugin` |

**Third-party repos** added by `install.sh`: `docker-ce-stable` (Docker) and `hashicorp`
(Terraform). The Hyprland COPR is only enabled for the `full` profile. `tflint` is not
packaged anywhere, so it is installed with `go install` into `~/.local/bin`.

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
| lspsaga | Floating LSP UI — hover, code actions, rename, diagnostics, outline |
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

**LSP keymaps** (leader is `Space`)

Core server actions live in `lua/plugins/lsp.lua` (`gd`, `gr`, `K`, `<leader>rn`, `<leader>ca`, …). The lspsaga UI in `lua/plugins/lsp-ui.lua` adds a `<leader>g` group:

| Key | Action |
|-----|--------|
| `<leader>gd` | Peek definition |
| `<leader>gD` | Peek type definition |
| `<leader>gr` | References & implementations (finder) |
| `<leader>gh` | Hover documentation |
| `<leader>go` | Symbol outline |
| `<leader>gc` | Code action (with live preview) |
| `<leader>gn` | Rename (with project search) |
| `<leader>gl` | Line diagnostics |
| `<leader>gb` | Buffer diagnostics |
| `<leader>gj` / `<leader>gk` | Next / previous diagnostic |
| `<leader>gci` / `<leader>gco` | Incoming / outgoing call hierarchy |
| `<leader>gt` | Toggle floating terminal |

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
