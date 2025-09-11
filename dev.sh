#!/bin/bash

# Persian Law Firm Website Development Script
# This script provides easy commands for development and testing

set -e

# Configuration
APP_NAME="Dadgan Law Firm Website"
DEV_PORT="8081"
SANDBOX_PORT="8082"
ENVIRONMENT="development"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
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

success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

# Help function
show_help() {
    echo -e "${CYAN}$APP_NAME - Development Script${NC}"
    echo ""
    echo "Usage: ./dev.sh [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  dev, start     Start development server on port $DEV_PORT"
    echo "  sandbox        Start sandbox server on port $SANDBOX_PORT"
    echo "  build          Build the application"
    echo "  test           Run tests"
    echo "  check          Check code without building"
    echo "  clean          Clean build artifacts"
    echo "  watch          Watch for changes and auto-rebuild"
    echo "  logs           Show application logs"
    echo "  stop           Stop all running instances"
    echo "  status         Show running instances"
    echo "  help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./dev.sh dev          # Start development server"
    echo "  ./dev.sh sandbox      # Start sandbox server"
    echo "  ./dev.sh watch        # Auto-rebuild on changes"
    echo ""
}

# Check if Rust is installed
check_rust() {
    if ! command -v cargo &> /dev/null; then
        error "Rust/Cargo is not installed. Please install Rust first."
    fi
}

# Kill process on specific port
kill_port() {
    local port=$1
    local pid=$(lsof -ti:$port 2>/dev/null || true)
    if [ ! -z "$pid" ]; then
        info "Killing process on port $port (PID: $pid)"
        kill -9 $pid 2>/dev/null || true
        sleep 1
    fi
}

# Start development server
start_dev() {
    log "Starting development server..."
    check_rust
    
    # Kill any existing process on dev port
    kill_port $DEV_PORT
    
    # Set environment variables
    export RUST_LOG=debug
    export PORT=$DEV_PORT
    export ENVIRONMENT=$ENVIRONMENT
    
    info "Building and starting development server on port $DEV_PORT"
    info "Website will be available at: http://localhost:$DEV_PORT"
    info "Press Ctrl+C to stop"
    echo ""
    
    # Start the server
    cargo run
}

# Start sandbox server
start_sandbox() {
    log "Starting sandbox server..."
    check_rust
    
    # Kill any existing process on sandbox port
    kill_port $SANDBOX_PORT
    
    # Set environment variables for sandbox
    export RUST_LOG=info
    export PORT=$SANDBOX_PORT
    export ENVIRONMENT=sandbox
    
    info "Building and starting sandbox server on port $SANDBOX_PORT"
    info "Sandbox will be available at: http://localhost:$SANDBOX_PORT"
    info "Press Ctrl+C to stop"
    echo ""
    
    # Start the server
    cargo run
}

# Build the application
build_app() {
    log "Building application..."
    check_rust
    cargo build --release
    success "Build completed successfully!"
}

# Run tests
run_tests() {
    log "Running tests..."
    check_rust
    cargo test
    success "Tests completed!"
}

# Check code
check_code() {
    log "Checking code..."
    check_rust
    cargo check
    success "Code check completed!"
}

# Clean build artifacts
clean_build() {
    log "Cleaning build artifacts..."
    check_rust
    cargo clean
    success "Clean completed!"
}

# Watch for changes
watch_changes() {
    log "Starting file watcher..."
    check_rust
    
    if ! command -v cargo-watch &> /dev/null; then
        warning "cargo-watch not installed. Installing..."
        cargo install cargo-watch
    fi
    
    info "Watching for changes and auto-rebuilding..."
    info "Development server will restart automatically on file changes"
    info "Press Ctrl+C to stop"
    echo ""
    
    cargo watch -x "run"
}

# Show logs
show_logs() {
    info "Recent application logs:"
    echo ""
    journalctl -u dadgan-website -f --no-pager -n 50 2>/dev/null || {
        warning "No systemd service logs found. Showing recent cargo output..."
        echo "Use 'cargo run' to see live logs"
    }
}

# Stop all instances
stop_all() {
    log "Stopping all instances..."
    kill_port $DEV_PORT
    kill_port $SANDBOX_PORT
    
    # Try to stop systemd service if it exists
    if systemctl is-active --quiet dadgan-website 2>/dev/null; then
        info "Stopping systemd service..."
        sudo systemctl stop dadgan-website
    fi
    
    success "All instances stopped!"
}

# Show status
show_status() {
    info "Checking running instances..."
    echo ""
    
    # Check dev port
    if lsof -ti:$DEV_PORT &>/dev/null; then
        success "Development server running on port $DEV_PORT"
    else
        info "No development server on port $DEV_PORT"
    fi
    
    # Check sandbox port
    if lsof -ti:$SANDBOX_PORT &>/dev/null; then
        success "Sandbox server running on port $SANDBOX_PORT"
    else
        info "No sandbox server on port $SANDBOX_PORT"
    fi
    
    # Check systemd service
    if systemctl is-active --quiet dadgan-website 2>/dev/null; then
        success "Systemd service is running"
    else
        info "No systemd service running"
    fi
}

# Main script logic
case "${1:-help}" in
    "dev"|"start")
        start_dev
        ;;
    "sandbox")
        start_sandbox
        ;;
    "build")
        build_app
        ;;
    "test")
        run_tests
        ;;
    "check")
        check_code
        ;;
    "clean")
        clean_build
        ;;
    "watch")
        watch_changes
        ;;
    "logs")
        show_logs
        ;;
    "stop")
        stop_all
        ;;
    "status")
        show_status
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        error "Unknown command: $1"
        show_help
        ;;
esac
