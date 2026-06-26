#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Fedora Dev Environment Install Script
# =============================================================================

# --- Colors ------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# --- Tracking ----------------------------------------------------------------
INSTALLED=()
SKIPPED=()
FAILED=()

# --- Helpers -----------------------------------------------------------------
info()    { echo -e "${CYAN}${BOLD}[....] $*${RESET}"; }
skip()    { echo -e "${YELLOW}[SKIP] $*${RESET}"; SKIPPED+=("$1"); }
success() { echo -e "${GREEN}[DONE] $*${RESET}"; INSTALLED+=("$1"); }
fail()    { echo -e "${RED}[FAIL] $*${RESET}"; FAILED+=("$1"); }

has() { command -v "$1" &>/dev/null; }

gh_latest() {
  # Returns the latest release tag for a GitHub repo (owner/repo)
  curl -fsSL "https://api.github.com/repos/$1/releases/latest" \
    | grep '"tag_name"' \
    | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/'
}

install_binary() {
  # install_binary <name> <url> <binary-in-archive> [strip-components]
  local name="$1" url="$2" binary="$3" strip="${4:-1}"
  local tmp; tmp=$(mktemp -d)
  info "Downloading $name..."
  if [[ "$url" == *.zip ]]; then
    curl -fsSL "$url" -o "$tmp/$name.zip"
    unzip -q "$tmp/$name.zip" -d "$tmp/extract"
  else
    curl -fsSL "$url" | tar -xz -C "$tmp" --strip-components="$strip"
  fi
  local found
  found=$(find "$tmp" -name "$binary" -type f | head -1)
  if [[ -z "$found" ]]; then
    fail "$name (binary not found in archive)"
    rm -rf "$tmp"
    return 1
  fi
  chmod +x "$found"
  mv "$found" "$HOME/.local/bin/$binary"
  rm -rf "$tmp"
}

# --- Preflight ---------------------------------------------------------------
echo ""
echo -e "${BOLD}================================================${RESET}"
echo -e "${BOLD}  Fedora Dev Environment Setup${RESET}"
echo -e "${BOLD}================================================${RESET}"
echo ""

if ! has dnf; then
  echo -e "${RED}ERROR: This script requires a Fedora/DNF-based system.${RESET}"
  exit 1
fi

mkdir -p "$HOME/.local/bin"

# =============================================================================
# 1. DNF packages (batched)
# =============================================================================
echo ""
echo -e "${BOLD}--- DNF packages ---${RESET}"

DNF_PACKAGES=()
dnf_queue() {
  # Only queue if not already installed
  if ! has "$1"; then
    DNF_PACKAGES+=("${2:-$1}")
    echo -e "${YELLOW}[QUEUE] $1${RESET}"
  else
    skip "$1"
  fi
}

dnf_queue git       git
dnf_queue zsh       zsh
dnf_queue stow      stow
dnf_queue tmux      tmux
dnf_queue zellij    zellij
dnf_queue nvim      neovim
dnf_queue btop      btop
dnf_queue lsd       lsd
dnf_queue fd        fd-find
dnf_queue rg        ripgrep
dnf_queue gh        gh
dnf_queue kubectl   kubectl

if [[ ${#DNF_PACKAGES[@]} -gt 0 ]]; then
  info "Installing DNF packages: ${DNF_PACKAGES[*]}"

  # kubectl requires the Kubernetes repo
  if [[ " ${DNF_PACKAGES[*]} " =~ " kubectl " ]]; then
    if [[ ! -f /etc/yum.repos.d/kubernetes.repo ]]; then
      info "Adding Kubernetes DNF repo..."
      sudo tee /etc/yum.repos.d/kubernetes.repo > /dev/null <<'EOF'
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
EOF
    fi
  fi

  sudo dnf install -y "${DNF_PACKAGES[@]}" && {
    for pkg in "${DNF_PACKAGES[@]}"; do
      success "$pkg"
    done
  } || {
    for pkg in "${DNF_PACKAGES[@]}"; do
      fail "$pkg"
    done
  }
fi

# =============================================================================
# 2. lazygit (COPR)
# =============================================================================
echo ""
echo -e "${BOLD}--- lazygit ---${RESET}"

if ! has lazygit; then
  info "Enabling COPR atim/lazygit and installing..."
  sudo dnf copr enable -y atim/lazygit
  sudo dnf install -y lazygit && success "lazygit" || fail "lazygit"
else
  skip "lazygit"
fi

# =============================================================================
# 3. Docker
# =============================================================================
echo ""
echo -e "${BOLD}--- Docker ---${RESET}"

if ! has docker; then
  info "Adding Docker CE DNF repo..."
  sudo dnf config-manager addrepo \
    --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
  info "Installing Docker CE..."
  sudo dnf install -y \
    docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin && {
    sudo systemctl enable --now docker
    sudo usermod -aG docker "$USER"
    success "docker"
    echo -e "${YELLOW}  NOTE: Log out and back in for docker group to take effect.${RESET}"
    echo -e "${YELLOW}  NOTE: If docker fails to start, run:${RESET}"
    echo -e "${YELLOW}        sudo alternatives --set iptables /usr/bin/iptables-nft${RESET}"
    echo -e "${YELLOW}        sudo systemctl restart docker${RESET}"
  } || fail "docker"
else
  skip "docker"
fi

# =============================================================================
# 4. Yazi
# =============================================================================
echo ""
echo -e "${BOLD}--- Yazi ---${RESET}"

if ! has yazi; then
  info "Installing Yazi (latest release)..."
  YAZI_TAG=$(gh_latest "sxyazi/yazi")
  YAZI_URL="https://github.com/sxyazi/yazi/releases/download/${YAZI_TAG}/yazi-x86_64-unknown-linux-gnu.zip"
  tmp=$(mktemp -d)
  curl -fsSL "$YAZI_URL" -o "$tmp/yazi.zip"
  unzip -q "$tmp/yazi.zip" -d "$tmp/extract"
  find "$tmp/extract" -name "yazi" -type f | head -1 | xargs -I{} cp {} "$HOME/.local/bin/yazi"
  find "$tmp/extract" -name "ya" -type f | head -1 | xargs -I{} cp {} "$HOME/.local/bin/ya"
  chmod +x "$HOME/.local/bin/yazi" "$HOME/.local/bin/ya"
  rm -rf "$tmp"
  success "yazi"
else
  skip "yazi"
fi

# =============================================================================
# 5. Mononoki Nerd Font
# =============================================================================
echo ""
echo -e "${BOLD}--- Mononoki Nerd Font ---${RESET}"

FONT_DIR="$HOME/.local/share/fonts/NerdFonts/Mononoki"

if command -v fc-list &>/dev/null && fc-list | grep -qi "Mononoki Nerd Font" || [[ -d "$FONT_DIR" ]]; then
  skip "Mononoki Nerd Font"
else
  info "Installing Mononoki Nerd Font..."
  FONT_TAG=$(gh_latest "ryanoasis/nerd-fonts")
  FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${FONT_TAG}/Mononoki.zip"
  tmp=$(mktemp -d)
  curl -fsSL "$FONT_URL" -o "$tmp/Mononoki.zip"
  mkdir -p "$FONT_DIR"
  unzip -q "$tmp/Mononoki.zip" -d "$FONT_DIR"
  rm -rf "$tmp"
  fc-cache -fv &>/dev/null
  success "Mononoki Nerd Font"
fi

# =============================================================================
# 6. NVM
# =============================================================================
echo ""
echo -e "${BOLD}--- NVM ---${RESET}"

if [[ ! -d "$HOME/.nvm" ]]; then
  info "Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | bash && success "nvm" || fail "nvm"
else
  skip "nvm"
fi

# =============================================================================
# 7. pyenv
# =============================================================================
echo ""
echo -e "${BOLD}--- pyenv ---${RESET}"

if [[ ! -d "$HOME/.pyenv" ]]; then
  info "Installing pyenv dependencies..."
  sudo dnf install -y \
    make gcc zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel \
    openssl-devel tk-devel libffi-devel xz-devel libuuid-devel &>/dev/null
  info "Installing pyenv..."
  curl https://pyenv.run | bash && success "pyenv" || fail "pyenv"

  # Add to .zshrc if not already present
  if ! grep -q 'pyenv init' "$HOME/.zshrc"; then
    cat >> "$HOME/.zshrc" <<'EOF'

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF
    info "Added pyenv init to ~/.zshrc"
  fi
else
  skip "pyenv"
fi

# =============================================================================
# 8. opencode
# =============================================================================
echo ""
echo -e "${BOLD}--- opencode ---${RESET}"

if ! has opencode; then
  info "Installing opencode..."
  curl -fsSL https://opencode.ai/install | sh && success "opencode" || fail "opencode"
else
  skip "opencode"
fi

# =============================================================================
# 9. Go
# =============================================================================
echo ""
echo -e "${BOLD}--- Go ---${RESET}"

if [[ ! -d /usr/local/go ]]; then
  info "Fetching latest Go version..."
  GO_VERSION=$(curl -fsSL https://go.dev/VERSION?m=text | head -1)
  GO_URL="https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz"
  info "Installing ${GO_VERSION}..."
  curl -fsSL "$GO_URL" | sudo tar -xz -C /usr/local && success "go (${GO_VERSION})" || fail "go"
else
  INSTALLED_GO=$(/usr/local/go/bin/go version 2>/dev/null | awk '{print $3}' || echo "unknown")
  skip "go (${INSTALLED_GO} already installed)"
fi

# =============================================================================
# 10. rustup
# =============================================================================
echo ""
echo -e "${BOLD}--- rustup ---${RESET}"

if [[ ! -d "$HOME/.rustup" ]]; then
  info "Installing rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && success "rustup" || fail "rustup"
else
  skip "rustup"
fi

# =============================================================================
# 11. Terraform
# =============================================================================
echo ""
echo -e "${BOLD}--- Terraform ---${RESET}"

if ! has terraform; then
  info "Adding HashiCorp DNF repo..."
  sudo dnf install -y dnf-plugins-core &>/dev/null
  sudo dnf config-manager addrepo \
    --from-repofile=https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
  info "Installing Terraform..."
  sudo dnf install -y terraform && success "terraform" || fail "terraform"
else
  skip "terraform"
fi

# =============================================================================
# 12. AWS CLI
# =============================================================================
echo ""
echo -e "${BOLD}--- AWS CLI ---${RESET}"

if ! has aws; then
  info "Installing AWS CLI v2..."
  tmp=$(mktemp -d)
  curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$tmp/awscliv2.zip"
  unzip -q "$tmp/awscliv2.zip" -d "$tmp"
  sudo "$tmp/aws/install"
  rm -rf "$tmp"
  has aws && success "aws-cli" || fail "aws-cli"
else
  skip "aws-cli"
fi

# =============================================================================
# 13. Azure CLI
# =============================================================================
echo ""
echo -e "${BOLD}--- Azure CLI ---${RESET}"

if ! has az; then
  info "Adding Microsoft DNF repo and installing Azure CLI..."
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
  sudo dnf install -y \
    "https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm" &>/dev/null || true
  sudo dnf install -y azure-cli && success "azure-cli" || fail "azure-cli"
else
  skip "azure-cli"
fi

# =============================================================================
# 14. GCP CLI
# =============================================================================
echo ""
echo -e "${BOLD}--- GCP CLI (gcloud) ---${RESET}"

if ! has gcloud; then
  info "Adding Google Cloud DNF repo..."
  sudo tee /etc/yum.repos.d/google-cloud-sdk.repo > /dev/null <<'EOF'
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-x86_64
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
  info "Installing gcloud..."
  sudo dnf install -y google-cloud-cli && success "gcloud" || fail "gcloud"
else
  skip "gcloud"
fi

# =============================================================================
# 15. k9s
# =============================================================================
echo ""
echo -e "${BOLD}--- k9s ---${RESET}"

if ! has k9s; then
  info "Installing k9s (latest release)..."
  K9S_TAG=$(gh_latest "derailed/k9s")
  K9S_URL="https://github.com/derailed/k9s/releases/download/${K9S_TAG}/k9s_Linux_amd64.tar.gz"
  tmp=$(mktemp -d)
  curl -fsSL "$K9S_URL" | tar -xz -C "$tmp"
  cp "$tmp/k9s" "$HOME/.local/bin/k9s"
  chmod +x "$HOME/.local/bin/k9s"
  rm -rf "$tmp"
  success "k9s"
else
  skip "k9s"
fi

# =============================================================================
# 16. saml2aws
# =============================================================================
echo ""
echo -e "${BOLD}--- saml2aws ---${RESET}"

if ! has saml2aws; then
  info "Installing saml2aws (latest release)..."
  SAML_TAG=$(gh_latest "Versent/saml2aws")
  SAML_VER="${SAML_TAG#v}"
  SAML_URL="https://github.com/Versent/saml2aws/releases/download/${SAML_TAG}/saml2aws_${SAML_VER}_linux_amd64.tar.gz"
  tmp=$(mktemp -d)
  curl -fsSL "$SAML_URL" | tar -xz -C "$tmp"
  find "$tmp" -name "saml2aws" -type f | head -1 | xargs -I{} cp {} "$HOME/.local/bin/saml2aws"
  chmod +x "$HOME/.local/bin/saml2aws"
  rm -rf "$tmp"
  success "saml2aws"
else
  skip "saml2aws"
fi

# =============================================================================
# 17. Starship prompt
# =============================================================================
echo ""
echo -e "${BOLD}--- Starship ---${RESET}"

if ! has starship; then
  info "Installing Starship..."
  curl -fsSL https://starship.rs/install.sh | sh -s -- --yes && success "starship" || fail "starship"
else
  skip "starship"
fi

# Add Starship init to ~/.zshrc if not already present
if has starship && ! grep -q 'starship init zsh' "$HOME/.zshrc" 2>/dev/null; then
  echo '' >> "$HOME/.zshrc"
  echo '# Starship prompt' >> "$HOME/.zshrc"
  echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
  info "Added starship init to ~/.zshrc"
fi

# =============================================================================
# 18. Set zsh as default shell
# =============================================================================
echo ""
echo -e "${BOLD}--- Default shell ---${RESET}"

ZSH_PATH=$(command -v zsh 2>/dev/null || true)
if [[ -z "$ZSH_PATH" ]]; then
  fail "zsh not found; cannot set as default shell"
else
  CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)
  if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
    # Ensure zsh is listed in /etc/shells
    if ! grep -qx "$ZSH_PATH" /etc/shells; then
      echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
    fi
    info "Changing default shell to zsh for $USER..."
    sudo chsh -s "$ZSH_PATH" "$USER" && success "default shell → zsh" || fail "chsh"
  else
    skip "default shell (already zsh)"
  fi
fi

# =============================================================================
# 19. Stow dotfiles
# =============================================================================
echo ""
echo -e "${BOLD}--- Stow dotfiles ---${RESET}"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if has stow; then
  info "Stowing dotfiles from $DOTFILES_DIR to $HOME..."
  # --adopt moves any pre-existing real files into the dotfiles dir so stow can
  # replace them with symlinks; git restore then reinstates our tracked versions.
  stow --dir="$DOTFILES_DIR" --target="$HOME" --adopt --restow . && {
    git -C "$DOTFILES_DIR" restore . 2>/dev/null || true
    success "dotfiles stowed"
  } || fail "stow dotfiles"
else
  fail "stow not found; cannot symlink dotfiles"
fi

# =============================================================================
# Summary
# =============================================================================
echo ""
echo -e "${BOLD}================================================${RESET}"
echo -e "${BOLD}  Summary${RESET}"
echo -e "${BOLD}================================================${RESET}"

if [[ ${#INSTALLED[@]} -gt 0 ]]; then
  echo -e "${GREEN}Installed (${#INSTALLED[@]}):${RESET}"
  for item in "${INSTALLED[@]}"; do
    echo -e "  ${GREEN}+${RESET} $item"
  done
fi

if [[ ${#SKIPPED[@]} -gt 0 ]]; then
  echo -e "${YELLOW}Skipped / already present (${#SKIPPED[@]}):${RESET}"
  for item in "${SKIPPED[@]}"; do
    echo -e "  ${YELLOW}-${RESET} $item"
  done
fi

if [[ ${#FAILED[@]} -gt 0 ]]; then
  echo -e "${RED}Failed (${#FAILED[@]}):${RESET}"
  for item in "${FAILED[@]}"; do
    echo -e "  ${RED}x${RESET} $item"
  done
  echo ""
  echo -e "${RED}Some tools failed to install. Check output above for details.${RESET}"
  exit 1
fi

echo ""
echo -e "${GREEN}${BOLD}All done!${RESET}"
echo ""
echo -e "${CYAN}Next steps:${RESET}"
echo "  - Log out and back in for docker group membership to take effect"
echo "  - Restart your shell or run: source ~/.zshrc"
echo "  - Install tmux plugins: open tmux, then press prefix + I (Ctrl-b I)"
echo "  - Install a Node version: nvm install --lts"
echo "  - Install a Python version: pyenv install <version>"
echo ""
