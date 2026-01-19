#!/bin/bash
#
# Fosi Audio K7 DAC/Amp - PipeWire Configuration Installer
#
# This script installs PipeWire/WirePlumber configuration for the Fosi Audio K7
# DAC/Amp to support both UAC 1.0 (microphone + 48kHz) and UAC 2.0 (high-res up to 384kHz) modes.
#
# Requirements:
#   - PipeWire (audio server)
#   - WirePlumber (session manager)
#   - Linux kernel with USB audio support
#
# Usage:
#   ./install.sh          # Install configuration
#   ./install.sh --remove # Remove configuration
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Configuration paths
PIPEWIRE_CONF_DIR="$HOME/.config/pipewire/pipewire.conf.d"
WIREPLUMBER_LUA_DIR="$HOME/.config/wireplumber/main.lua.d"
WIREPLUMBER_CONF_DIR="$HOME/.config/wireplumber/wireplumber.conf.d"
# Files to install
PIPEWIRE_CONF="10-fosi-audio-k7.conf"
WIREPLUMBER_LUA_1="51-fosi-audio-k7.lua"
WIREPLUMBER_LUA_2="52-fosi-audio-k7-profile.lua"
WIREPLUMBER_CONF="51-fosi-audio-k7.conf"

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Fosi Audio K7 DAC/Amp - PipeWire Configuration Installer${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Check for --remove flag
if [[ "${1:-}" == "--remove" ]]; then
    echo -e "${YELLOW}Removing Fosi Audio K7 configuration...${NC}"
    echo ""
    
    rm -f "$PIPEWIRE_CONF_DIR/$PIPEWIRE_CONF" && echo "  Removed: $PIPEWIRE_CONF_DIR/$PIPEWIRE_CONF"
    rm -f "$WIREPLUMBER_LUA_DIR/$WIREPLUMBER_LUA_1" && echo "  Removed: $WIREPLUMBER_LUA_DIR/$WIREPLUMBER_LUA_1"
    rm -f "$WIREPLUMBER_LUA_DIR/$WIREPLUMBER_LUA_2" && echo "  Removed: $WIREPLUMBER_LUA_DIR/$WIREPLUMBER_LUA_2"
    rm -f "$WIREPLUMBER_CONF_DIR/$WIREPLUMBER_CONF" && echo "  Removed: $WIREPLUMBER_CONF_DIR/$WIREPLUMBER_CONF"
    
    echo ""
    echo -e "${GREEN}Configuration removed successfully!${NC}"
    echo ""
    echo "Restart WirePlumber to apply changes:"
    echo "  systemctl --user restart wireplumber"
    exit 0
fi

# ============================================================================
# Compatibility Checks
# ============================================================================

echo -e "${BLUE}Checking system compatibility...${NC}"
echo ""

ERRORS=0

# Check for PipeWire
if command -v pipewire &> /dev/null; then
    PIPEWIRE_VERSION=$(pipewire --version 2>/dev/null | head -1 || echo "unknown")
    echo -e "  ${GREEN}✓${NC} PipeWire installed: $PIPEWIRE_VERSION"
else
    echo -e "  ${RED}✗${NC} PipeWire not found!"
    echo "    Install PipeWire first. On Ubuntu/Debian:"
    echo "      sudo apt install pipewire pipewire-audio-client-libraries"
    ERRORS=$((ERRORS + 1))
fi

# Check for WirePlumber
if command -v wireplumber &> /dev/null; then
    WIREPLUMBER_VERSION=$(wireplumber --version 2>/dev/null | head -1 || echo "unknown")
    echo -e "  ${GREEN}✓${NC} WirePlumber installed: $WIREPLUMBER_VERSION"
else
    echo -e "  ${RED}✗${NC} WirePlumber not found!"
    echo "    Install WirePlumber. On Ubuntu/Debian:"
    echo "      sudo apt install wireplumber"
    ERRORS=$((ERRORS + 1))
fi

# Check if PipeWire is running
if pgrep -x pipewire > /dev/null; then
    echo -e "  ${GREEN}✓${NC} PipeWire is running"
else
    echo -e "  ${YELLOW}!${NC} PipeWire is not running"
    echo "    Start PipeWire with: systemctl --user start pipewire"
fi

# Check if WirePlumber is running
if pgrep -x wireplumber > /dev/null; then
    echo -e "  ${GREEN}✓${NC} WirePlumber is running"
else
    echo -e "  ${YELLOW}!${NC} WirePlumber is not running"
    echo "    Start WirePlumber with: systemctl --user start wireplumber"
fi

# Check for pw-cli (used by mode-check script)
if command -v pw-cli &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} pw-cli available"
else
    echo -e "  ${YELLOW}!${NC} pw-cli not found (optional, for diagnostics)"
fi

# Check for Fosi Audio K7 device
if grep -qi "K7\|Fosi" /proc/asound/cards 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Fosi Audio K7 detected"
else
    echo -e "  ${YELLOW}!${NC} Fosi Audio K7 not detected (connect it later)"
fi

echo ""

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}Cannot proceed: $ERRORS critical error(s) found.${NC}"
    echo "Please install the missing dependencies and try again."
    exit 1
fi

# ============================================================================
# Installation
# ============================================================================

echo -e "${BLUE}Installing configuration files...${NC}"
echo ""

# Create directories
mkdir -p "$PIPEWIRE_CONF_DIR"
mkdir -p "$WIREPLUMBER_LUA_DIR"
mkdir -p "$WIREPLUMBER_CONF_DIR"

# Install PipeWire configuration
cp "$SCRIPT_DIR/pipewire.conf.d/$PIPEWIRE_CONF" "$PIPEWIRE_CONF_DIR/"
echo -e "  ${GREEN}✓${NC} Installed: $PIPEWIRE_CONF_DIR/$PIPEWIRE_CONF"

# Install WirePlumber Lua configurations
cp "$SCRIPT_DIR/wireplumber/main.lua.d/$WIREPLUMBER_LUA_1" "$WIREPLUMBER_LUA_DIR/"
echo -e "  ${GREEN}✓${NC} Installed: $WIREPLUMBER_LUA_DIR/$WIREPLUMBER_LUA_1"

cp "$SCRIPT_DIR/wireplumber/main.lua.d/$WIREPLUMBER_LUA_2" "$WIREPLUMBER_LUA_DIR/"
echo -e "  ${GREEN}✓${NC} Installed: $WIREPLUMBER_LUA_DIR/$WIREPLUMBER_LUA_2"

# Install WirePlumber .conf configuration
cp "$SCRIPT_DIR/wireplumber/wireplumber.conf.d/$WIREPLUMBER_CONF" "$WIREPLUMBER_CONF_DIR/"
echo -e "  ${GREEN}✓${NC} Installed: $WIREPLUMBER_CONF_DIR/$WIREPLUMBER_CONF"

echo ""

# ============================================================================
# Restart Services
# ============================================================================

echo -e "${BLUE}Restarting audio services...${NC}"
echo ""

if systemctl --user restart wireplumber 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} WirePlumber restarted"
else
    echo -e "  ${YELLOW}!${NC} Could not restart WirePlumber automatically"
    echo "    Run manually: systemctl --user restart wireplumber"
fi

sleep 2

# ============================================================================
# Verification
# ============================================================================

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}Installed files:${NC}"
echo "  • $PIPEWIRE_CONF_DIR/$PIPEWIRE_CONF"
echo "  • $WIREPLUMBER_LUA_DIR/$WIREPLUMBER_LUA_1"
echo "  • $WIREPLUMBER_LUA_DIR/$WIREPLUMBER_LUA_2"
echo "  • $WIREPLUMBER_CONF_DIR/$WIREPLUMBER_CONF"
echo ""
echo -e "${BLUE}Usage:${NC}"
echo "  • Switch UAC mode: Press the UAC button on the device"
echo ""
echo -e "${BLUE}UAC Modes:${NC}"
echo "  • UAC 1.0: 48kHz/16-bit + Microphone input"
echo "  • UAC 2.0: Up to 384kHz/32-bit (no microphone)"
echo ""
echo -e "${BLUE}To remove this configuration:${NC}"
echo "  $SCRIPT_DIR/install.sh --remove"
echo ""

# Check if device is connected
if grep -qi "K7\|Fosi" /proc/asound/cards 2>/dev/null; then
    echo -e "${GREEN}Fosi Audio K7 detected and ready!${NC}"
fi
