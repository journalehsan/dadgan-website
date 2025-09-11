#!/bin/bash

# Persian Law Firm Website Deployment Script
# This script builds and deploys the website as a systemd service

set -e

# Configuration
SERVICE_NAME="dadgan-website"
SERVICE_USER="www-data"
SERVICE_GROUP="www-data"
APP_DIR="/opt/dadgan-website"
BINARY_NAME="dadgan-website"
PORT="8080"
ENVIRONMENT="production"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root (use sudo)"
fi

# Check if Rust is installed
if ! command -v cargo &> /dev/null; then
    error "Rust/Cargo is not installed. Please install Rust first."
fi

log "Starting deployment of Dadgan Law Firm Website..."

# Create application directory
log "Creating application directory: $APP_DIR"
mkdir -p $APP_DIR
mkdir -p $APP_DIR/static
mkdir -p $APP_DIR/templates/partials

# Create service user if it doesn't exist
if ! id "$SERVICE_USER" &>/dev/null; then
    log "Creating service user: $SERVICE_USER"
    useradd --system --no-create-home --shell /bin/false $SERVICE_USER
fi

# Build the application
log "Building the application..."
cargo build --release

# Copy application files
log "Copying application files..."
cp target/release/$BINARY_NAME $APP_DIR/
cp -r templates/ $APP_DIR/
cp -r static/ $APP_DIR/
cp Cargo.toml $APP_DIR/
cp askama.toml $APP_DIR/

# Set proper permissions
log "Setting permissions..."
chown -R $SERVICE_USER:$SERVICE_GROUP $APP_DIR
chmod +x $APP_DIR/$BINARY_NAME
chmod -R 755 $APP_DIR

# Create systemd service file
log "Creating systemd service file..."
cat > /etc/systemd/system/$SERVICE_NAME.service << EOF
[Unit]
Description=Dadgan Law Firm Website
After=network.target
Wants=network.target

[Service]
Type=simple
User=$SERVICE_USER
Group=$SERVICE_GROUP
WorkingDirectory=$APP_DIR
ExecStart=$APP_DIR/$BINARY_NAME
Restart=always
RestartSec=5
Environment=RUST_LOG=info
Environment=PORT=$PORT
Environment=ENVIRONMENT=$ENVIRONMENT

# Security settings
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=$APP_DIR

# Resource limits
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable service
log "Reloading systemd and enabling service..."
systemctl daemon-reload
systemctl enable $SERVICE_NAME

# Stop existing service if running
if systemctl is-active --quiet $SERVICE_NAME; then
    log "Stopping existing service..."
    systemctl stop $SERVICE_NAME
fi

# Start the service
log "Starting $SERVICE_NAME service..."
systemctl start $SERVICE_NAME

# Wait a moment for service to start
sleep 3

# Check service status
if systemctl is-active --quiet $SERVICE_NAME; then
    log "Service started successfully!"
    info "Service status:"
    systemctl status $SERVICE_NAME --no-pager -l
    info "Website should be available at: http://localhost:$PORT"
    info "To view logs: journalctl -u $SERVICE_NAME -f"
    info "To restart: systemctl restart $SERVICE_NAME"
    info "To stop: systemctl stop $SERVICE_NAME"
else
    error "Failed to start service. Check logs with: journalctl -u $SERVICE_NAME -f"
fi

log "Deployment completed successfully!"
