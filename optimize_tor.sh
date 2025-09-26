#!/bin/bash

# Tor Optimization Script
# This script applies performance optimizations to a running Tor instance

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root (use sudo)"
   exit 1
fi

# Check if Tor is running
if ! systemctl is-active --quiet tor; then
    print_error "Tor service is not running. Please start it first."
    exit 1
fi

TORRC_PATH="/etc/tor/torrc"
TOR_DATA_DIR="/tmp/tor"

print_status "Applying Tor performance optimizations..."

# Create cache directory
mkdir -p "$TOR_DATA_DIR/cache"
chown tor:tor "$TOR_DATA_DIR/cache"
chmod 700 "$TOR_DATA_DIR/cache"

# Backup current torrc
if [[ -f "$TORRC_PATH" ]]; then
    print_status "Backing up current torrc..."
    cp "$TORRC_PATH" "/etc/tor/torrc.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Read current torrc and add optimizations
print_status "Adding performance optimizations to torrc..."

# Check if optimizations are already present
if grep -q "CacheDirectory" "$TORRC_PATH"; then
    print_warning "Performance optimizations already present in torrc"
    print_status "Restarting Tor to apply any changes..."
    systemctl restart tor
    print_status "Tor restarted successfully!"
    exit 0
fi

# Add optimizations to existing torrc
cat >> "$TORRC_PATH" << 'EOF'

# Performance optimizations
# Enable caching for better performance
CacheDirectory /tmp/tor/cache
CacheDirectoryGroupReadable 1

# Connection optimizations
ConnectionPadding 1
ReducedConnectionPadding 0
CircuitPadding 1
ReducedCircuitPadding 0

# Bandwidth optimizations
BandwidthBurst 1048576  # 1MB burst
BandwidthRate 1048576   # 1MB/s sustained

# DNS optimizations
DNSPort 9053
AutomapHostsOnResolve 1
AutomapHostsSuffixes .exit,.onion

# Logging optimizations (reduce log spam)
Log notice file /tmp/tor/tor.log
Log notice stdout
Log info stdout
Log debug stdout
Log warn stdout
Log err stdout

# Connection timeouts
NewCircuitPeriod 30
MaxCircuitDirtiness 600

# Memory optimizations
MaxMemInQueues 32MB
EOF

print_status "Optimizations added to torrc!"

# Restart Tor to apply optimizations
print_status "Restarting Tor service to apply optimizations..."
systemctl restart tor

# Wait for Tor to start
sleep 3

# Check if Tor is running
if systemctl is-active --quiet tor; then
    print_status "Tor service restarted successfully with optimizations!"
    
    # Show current status
    print_status "Current Tor status:"
    systemctl status tor --no-pager -l
    
    print_status "Performance optimizations applied:"
    echo "  ✅ Caching enabled"
    echo "  ✅ Connection padding optimized"
    echo "  ✅ Bandwidth limits set (1MB/s)"
    echo "  ✅ DNS optimizations enabled"
    echo "  ✅ Memory usage optimized"
    echo "  ✅ Connection timeouts optimized"
    
else
    print_error "Failed to restart Tor service!"
    print_error "Check logs with: journalctl -u tor -f"
    exit 1
fi

print_status "Tor optimization complete!"
print_warning "Note: It may take a few minutes for optimizations to take full effect."
