# System management commands

# Update the system
update:
    @echo "Updating system..."
    bootc upgrade

# Rollback to previous deployment
rollback:
    @echo "Rolling back to previous deployment..."
    bootc rollback

# Show system info
info:
    @echo "=== System Info ==="
    @echo "Image: $(cat /usr/lib/os-release | grep ^IMAGE_ID= | cut -d= -f2)"
    @echo "Version: $(cat /usr/lib/os-release | grep ^VERSION= | cut -d= -f2)"
    @echo "Kernel: $(uname -r)"
    @bootc status

# Cleanup old deployments
cleanup:
    @echo "Cleaning up old deployments..."
    sudo bootc cleanup

# Show disk usage
disk-usage:
    @echo "=== Disk Usage ==="
    @df -h / /var

# Install Homebrew packages declared in the image Brewfile without upgrading unrelated packages
brew-bundle-install:
    @echo "Installing Homebrew packages from /usr/share/ublue-os/brew/Brewfile..."
    brew bundle install --file /usr/share/ublue-os/brew/Brewfile --no-upgrade

# Rebase to a different image (e.g., just rebase ghcr.io/user/image:tag)
rebase IMAGE:
    @echo "Rebasing to {{ IMAGE }}..."
    bootc switch {{ IMAGE }}
