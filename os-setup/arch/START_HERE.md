# Arch Linux Setup - START HERE

## TL;DR

```bash
cd ~/.dotfiles
./os-setup/arch/setup.sh
```

Wait 30-45 minutes. Done.

---

## What This Does

Installs your complete Arch Linux system with:
- **Desktop**: Hyprland + Kitty + all components
- **Audio**: Pipewire (fully configured)
- **Development**: Git, Neovim, Zsh, Tmux, Docker, etc.
- **Languages**: Go, Python (pyenv), Node (nvm)
- **Tools**: yazi, fzf, fd, ripgrep, etc.
- **Optional**: lazygit, Obsidian, fonts, opencode

---

## Before You Start

1. You need **Arch Linux** (fresh installation is fine)
2. You need **internet** (script checks this)
3. You need **sudo** access
4. You need **20GB+ disk space**

---

## How to Use

### Step 1: Navigate to dotfiles
```bash
cd ~/.dotfiles
```

### Step 2: Run the setup
```bash
./os-setup/arch/setup.sh
```

Or with bash explicitly:
```bash
bash os-setup/arch/setup.sh
```

### Step 3: Wait
The script handles everything. Don't interrupt it.

You'll see colored output:
- `[STEP]` - Major steps (blue)
- `[INFO]` - Progress updates (green)  
- `[WARN]` - Non-critical issues (yellow)
- `[ERROR]` - Actual errors (red)

### Step 4: Reboot
```bash
sudo reboot
```

Hyprland will start automatically.

---

## What Happens Next

The script:
1. ✓ Checks you're on Arch Linux
2. ✓ Updates all system packages
3. ✓ Installs 150+ packages (takes 10-20 mins)
4. ✓ Configures Pipewire audio
5. ✓ Installs yay AUR helper
6. ✓ Installs optional extras (5-10 mins)
7. ✓ Sets up language managers
8. ✓ Sets Zsh as default
9. ✓ Verifies everything works

---

## If Something Goes Wrong

The script is **safe to run multiple times**.

### Most Common Issues

**"Permission denied"**
```bash
chmod +x os-setup/arch/setup.sh
bash os-setup/arch/setup.sh
```

**"pacman is locked"**
Wait a moment, then try again. Or reboot.

**"No internet"**
Check your connection, then rerun the script.

**"Package X failed to install"**
Script continues anyway. You can install manually later with:
```bash
sudo pacman -S package-name
```

**"yay didn't install"**
Non-critical. Desktop still works. Install later if needed:
```bash
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
```

---

## Documentation

- **README.md** - Complete guide with all options
- **SETUP_GUIDE.md** - Detailed walkthrough + advanced tips
- **QUICK_START.md** - Quick reference
- **NVIDIA_README.md** - GPU setup (if needed)

---

## After Setup

### Deploy Your Dotfiles
```bash
cd ~/.dotfiles
stow -v -t ~ .config
```

### Set Up Git
```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

### Generate SSH Key
```bash
ssh-keygen -t ed25519 -C "your@email.com"
cat ~/.ssh/id_ed25519.pub  # Copy to GitHub
```

### Install Language Versions
```bash
# Python
pyenv install 3.12
pyenv global 3.12

# Node
nvm install 20
nvm use 20
```

---

## That's It!

You now have a complete Arch Linux system with:
- ✓ Modern Wayland desktop
- ✓ Working audio
- ✓ All development tools
- ✓ Everything preconfigured

Enjoy your new system!

---

**Questions?** See the full guides in this directory.

**Want to customize?** Edit `setup.sh` to add/remove packages.

**Something broken?** Read SETUP_GUIDE.md troubleshooting section.
