#!/bin/bash
set -e

# =============================================================================
# Linux Lab - User Data Script
# This script runs on first boot to configure the lab instance
# =============================================================================

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "=========================================="
echo "Starting Linux Lab Setup - $(date)"
echo "=========================================="

# Wait for cloud-init to complete
cloud-init status --wait

# =============================================================================
# System Update
# =============================================================================
echo "[1/6] Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y

# =============================================================================
# Install Essential Packages
# =============================================================================
echo "[2/6] Installing essential packages..."

PACKAGES=(
    # System utilities
    htop
    iotop
    sysstat
    dstat

    # Editors and tools
    vim
    nano
    tmux
    screen

    # Network tools
    net-tools
    tcpdump
    nmap
    traceroute
    dnsutils
    curl
    wget
    telnet
    netcat
    iperf3

    # Development tools
    git
    jq
    tree
    unzip
    zip
    build-essential

    # Monitoring
    atop
    glances

    # Security
    fail2ban
    ufw

    # AWS CLI
    awscli
)

apt-get install -y "${PACKAGES[@]}"

# =============================================================================
# Install Docker
# =============================================================================
echo "[3/6] Installing Docker..."

# Install Docker
curl -fsSL https://get.docker.com | sh

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Install Docker Compose
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.tag_name')
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# =============================================================================
# Install SSM Agent
# =============================================================================
echo "[4/6] Configuring SSM Agent..."

# SSM Agent is usually pre-installed on Ubuntu AMIs, but ensure it's running
snap install amazon-ssm-agent --classic || true
systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service

# =============================================================================
# Configure System
# =============================================================================
echo "[5/6] Configuring system settings..."

# Set timezone
timedatectl set-timezone UTC

# Configure vim as default editor
update-alternatives --set editor /usr/bin/vim.basic

# Create useful aliases for ubuntu user
cat >> /home/ubuntu/.bashrc << 'ALIASES'

# Linux Lab Aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ports='netstat -tulanp'
alias meminfo='free -m -l -t'
alias cpuinfo='lscpu'
alias dockerps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias k='kubectl'

# History settings
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
ALIASES

# Create welcome banner
cat > /etc/motd << 'BANNER'
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                             ║
║                         🐧 LINUX LAB INSTANCE 🐧                            ║
║                                                                             ║
║  This is a lab environment for practicing Linux administration.             ║
║                                                                             ║
║  Installed Tools:                                                           ║
║  • System: htop, iotop, sysstat, tmux, vim                                 ║
║  • Network: tcpdump, nmap, netcat, curl, wget                              ║
║  • Docker: docker, docker-compose                                           ║
║  • Dev: git, jq, aws-cli                                                    ║
║                                                                             ║
║  Quick Commands:                                                            ║
║  • htop          - Interactive process viewer                               ║
║  • docker ps     - List running containers                                  ║
║  • ports         - Show listening ports                                     ║
║                                                                             ║
║  Logs: /var/log/user-data.log                                              ║
║                                                                             ║
╚═══════════════════════════════════════════════════════════════════════════╝
BANNER

# =============================================================================
# Create Lab Directory Structure
# =============================================================================
echo "[6/6] Creating lab directory structure..."

mkdir -p /home/ubuntu/lab/{scripts,docker,projects}

cat > /home/ubuntu/lab/README.md << 'README'
# Linux Lab Environment

## Directory Structure
- `scripts/` - Shell scripts for practice
- `docker/` - Docker configurations
- `projects/` - Your projects

## Quick Start

### Check system resources
```bash
htop
free -h
df -h
```

### Docker basics
```bash
docker run hello-world
docker ps -a
docker images
```

### Network diagnostics
```bash
ip addr
ports
curl ifconfig.me
```

## Learning Resources
- Linux Journey: https://linuxjourney.com/
- Docker Docs: https://docs.docker.com/
README

chown -R ubuntu:ubuntu /home/ubuntu/lab

# =============================================================================
# Completion
# =============================================================================

echo "=========================================="
echo "Linux Lab Setup Completed - $(date)"
echo "=========================================="
echo "Instance is ready for use!"

# Signal completion
touch /var/log/user-data-complete
