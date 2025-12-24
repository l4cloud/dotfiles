# Arch Setup Files Index

## Quick Start

**START HERE:** `START_HERE.md` (3 min read)

**RUN THIS:** `setup.sh` (30-45 min execution)

---

## File Guide

### 🎯 MAIN (Use These)

| File | Purpose | Size |
|------|---------|------|
| **setup.sh** | Complete automated setup script | 5.1K |
| **START_HERE.md** | Quick start guide - READ FIRST | 3.3K |
| **README.md** | Full documentation + options | 3.6K |
| **SETUP_GUIDE.md** | Detailed walkthrough + advanced | 6.5K |

### 📚 REFERENCE (Optional)

| File | Purpose | Size |
|------|---------|------|
| **QUICK_START.md** | Quick reference (overview) | 2.5K |
| **NVIDIA_README.md** | GPU setup if needed | 2.1K |
| **MINIMAL_SETUP.md** | Old minimal setup guide | 5.9K |

### 🔧 ADDITIONAL SCRIPTS

| File | Purpose | Note |
|------|---------|------|
| `install_arch_desktop.sh` | Desktop environment only | Advanced NVIDIA detection |
| `install_arch_services.sh` | Development tools only | CLI tools without desktop |
| `install_yay.sh` | Standalone yay installer | Only if you need just yay |

---

## How to Use

### Option A: Quickest Path
1. Read: `START_HERE.md` (5 min)
2. Run: `./setup.sh` (30-45 min)
3. Done!

### Option B: Comprehensive Path
1. Read: `START_HERE.md` (5 min)
2. Read: `README.md` (10 min)
3. Read: `SETUP_GUIDE.md` (15 min)
4. Run: `./setup.sh` (30-45 min)
5. If issues, see SETUP_GUIDE.md troubleshooting

### Option C: Reference Only
- Need quick info? → `QUICK_START.md`
- GPU issues? → `NVIDIA_README.md`
- Specific problem? → `SETUP_GUIDE.md` (troubleshooting)

---

## File Descriptions

### setup.sh
**THE MAIN SCRIPT** - Everything happens here.

- 159 lines of straightforward bash
- Pure shell script, no dependencies
- Installs 150+ packages
- Configures Pipewire
- Sets up language managers
- Works from minimal Arch install

**Usage:**
```bash
bash os-setup/arch/setup.sh
```

### START_HERE.md
Quick start guide for impatient people.

- TL;DR at the top
- Step-by-step instructions
- Common error solutions
- 3-5 minute read

**Best for:** First-time users who want to start now

### README.md
Complete guide with all details.

- What gets installed (full list)
- Requirements and system needs
- Installation options
- Troubleshooting section
- Post-setup steps

**Best for:** Understanding everything before starting

### SETUP_GUIDE.md
Detailed walkthrough + advanced info.

- Step-by-step explanation
- What happens at each stage
- Detailed troubleshooting
- Customization examples
- Language manager setup

**Best for:** Deep dive / fixing specific issues

### QUICK_START.md
Quick reference (not a tutorial).

- Overview of changes
- What gets installed
- High-level workflow
- Old vs new approach

**Best for:** Quick facts without reading full guides

### NVIDIA_README.md
GPU-specific configuration.

- NVIDIA driver selection
- Hyprland + NVIDIA setup
- Troubleshooting GPU issues
- Performance tips

**Best for:** NVIDIA GPU users

### MINIMAL_SETUP.md
Old minimal setup documentation.

- Older guide format
- Less relevant now
- Kept for reference

**Best for:** Legacy reference only

---

## Choosing Your Starting Point

**If you're new to Arch:**
→ Read `START_HERE.md` then run `setup.sh`

**If you have an NVIDIA GPU:**
→ Run `setup.sh` then read `NVIDIA_README.md`

**If you want to understand everything:**
→ Read `README.md` and `SETUP_GUIDE.md` first

**If you want to customize packages:**
→ Read `setup.sh`, edit it, then run

**If something breaks:**
→ Read `SETUP_GUIDE.md` troubleshooting section

**If you only need yay:**
→ Run `install_yay.sh` standalone

---

## One-Minute Summary

- `setup.sh` = Single script that installs everything
- Works from minimal Arch Linux
- Takes 30-45 minutes
- Safe to run multiple times
- Includes all your software
- Fully configures Pipewire
- Ready to use immediately after

**Just run:**
```bash
bash setup.sh
```

---

## Next Steps

1. Choose a file from the guide above
2. Read or run it
3. Follow the instructions
4. Done!

Questions? See the file that matches your need above.
