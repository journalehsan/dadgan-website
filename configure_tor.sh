#!/bin/bash

# Tor Configuration Script for Arch Linux
# This script configures torrc with obfs4 bridges for Iran

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if Tor is installed
if ! command -v tor &> /dev/null; then
    print_error "Tor is not installed. Please install it first:"
    echo "sudo pacman -S tor"
    exit 1
fi

# Check if obfs4proxy is installed
if ! command -v obfs4proxy &> /dev/null; then
    print_error "obfs4proxy is not installed. Please install it first:"
    echo "sudo pacman -S obfs4proxy"
    exit 1
fi

# Backup existing torrc
TORRC_PATH="/etc/tor/torrc"
if [[ -f "$TORRC_PATH" ]]; then
    print_status "Backing up existing torrc to /etc/tor/torrc.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$TORRC_PATH" "/etc/tor/torrc.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Create Tor data directory
TOR_DATA_DIR="/tmp/tor"
print_status "Creating Tor data directory at $TOR_DATA_DIR..."
mkdir -p "$TOR_DATA_DIR"
chown tor:tor "$TOR_DATA_DIR"
chmod 700 "$TOR_DATA_DIR"

# Create new torrc configuration
print_status "Creating new torrc configuration with obfs4 bridges..."

cat > "$TORRC_PATH" << EOF
# This is the torrc file for using obfs4 bridges in Iran.
# Enter the bridges you received from bridges@torproject.org below.

# Data directory
DataDirectory $TOR_DATA_DIR

UseBridges 1
ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy

# Bridge lines from the email
Bridge obfs4 85.119.83.165:9707 B988FDDEB8818FD9B13D198F84FD1FD3FE54296B cert=N3Oewp54WXf17Zd0+/DbU63dEThTd0qpKSJoBDLBm+GFsyC3kdLfHgG0SGZVNpyQOvRcQA iat-mode=0
Bridge obfs4 51.75.25.151:9003 B669C827EB059C3CBCCC50710F5EE97E5E4B23CA cert=hgyMuXRakoQ/rKJ3kUH8seAE3ovad26fpo4IKIPuB+38KOy03u6MeDxq2Ij/wVNDnda8fg iat-mode=0

# Avoid known bad bridges and potential network surveillance
ExcludeNodes {ir}
StrictNodes 1

# Performance optimizations
# Enable caching for better performance
CacheDirectory $TOR_DATA_DIR/cache
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
Log notice file $TOR_DATA_DIR/tor.log
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

# Set proper permissions
chmod 644 "$TORRC_PATH"
chown root:root "$TORRC_PATH"

print_status "Tor configuration updated successfully!"

# Restart Tor service
print_status "Restarting Tor service..."

if systemctl is-active --quiet tor; then
    print_status "Stopping Tor service..."
    systemctl stop tor
fi

print_status "Starting Tor service..."
systemctl start tor

# Wait a moment for the service to start
sleep 2

# Check if Tor is running
if systemctl is-active --quiet tor; then
    print_status "Tor service is running successfully!"
    
    # Show Tor status
    print_status "Tor service status:"
    systemctl status tor --no-pager -l
    
    # Show Tor logs for verification
    print_status "Recent Tor logs:"
    journalctl -u tor --no-pager -n 10
    
else
    print_error "Failed to start Tor service!"
    print_error "Check the logs with: journalctl -u tor -f"
    exit 1
fi

print_status "Configuration complete! Your Tor client is now configured with obfs4 bridges."
print_warning "Note: It may take a few minutes for Tor to establish connections through the bridges."
print_status "You can monitor Tor's progress with: journalctl -u tor -f"
