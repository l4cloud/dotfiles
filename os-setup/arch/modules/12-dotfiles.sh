#!/bin/bash

##############################################################################
# Module: Dotfiles Installation
# Installs dotfiles using GNU Stow
##############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

DOTFILES_DIR="$HOME/.dotfiles"

backup_existing_files() {
    log_step "Backing up existing dotfiles..."
    
    local stamp=$(date +%Y%m%d%H%M%S)
    local tmpbackdir=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-backup-$stamp-XXXX")
    local moved_any=0
    
    local items=(
        .config
        wallpapers
        nvim
        starship.toml
        .aliases.zsh
        .func.zsh
        .ssh_fzf.zsh
        .tmux.conf
        .zshrc
    )
    
    for item in "${items[@]}"; do
        local target="$HOME/$item"
        
        if [ -L "$target" ]; then
            # Remove symlink
            rm -f "$target"
            log_info "  Removed existing symlink: $item"
        elif [ -e "$target" ]; then
            # Backup file/directory
            mkdir -p "$(dirname "$tmpbackdir/$item")" 2>/dev/null || true
            mv "$target" "$tmpbackdir/$item"
            log_info "  Backed up: $item"
            moved_any=1
        fi
    done
    
    # Create archive if anything was backed up
    if [ "$moved_any" -eq 1 ]; then
        local archive="${TMPDIR:-/tmp}/dotfiles-backup-$stamp.tar.gz"
        
        if command -v tar >/dev/null 2>&1; then
            if tar -C "$tmpbackdir" -czf "$archive" . 2>/dev/null; then
                log_info "Backups archived to: $archive"
                rm -rf "$tmpbackdir"
                return 0
            else
                log_warn "Archive creation failed; backups remain in: $tmpbackdir"
                return 1
            fi
        else
            log_warn "tar not available; backups are in: $tmpbackdir"
            return 1
        fi
    else
        rmdir "$tmpbackdir" 2>/dev/null || true
        log_info "No existing files to backup"
        return 0
    fi
}

install_dotfiles() {
    log_step "Installing dotfiles with stow..."
    
    if [ ! -d "$DOTFILES_DIR" ]; then
        log_error "Dotfiles directory not found: $DOTFILES_DIR"
        return 1
    fi
    
    cd "$HOME" || return 1
    
    if stow -d "$DOTFILES_DIR" -t "$HOME" -R . 2>&1; then
        log_success "Dotfiles installed successfully"
        return 0
    else
        log_error "Stow installation failed"
        return 1
    fi
}

main() {
    log_section "Dotfiles Installation"
    
    if ! command -v stow >/dev/null 2>&1; then
        log_error "GNU Stow not installed"
        log_info "Install it with: sudo pacman -S stow"
        return 1
    fi
    
    if ! backup_existing_files; then
        log_warn "Backup had issues, but continuing..."
    fi
    
    if install_dotfiles; then
        log_success "Dotfiles setup complete"
        return 0
    else
        return 1
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_arch || exit 1
    main
    exit $?
fi
