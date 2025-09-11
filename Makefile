# Persian Law Firm Website - Makefile
# Convenient commands for development and deployment

.PHONY: help dev sandbox build test check clean deploy stop status logs install-deps

# Default target
help:
	@echo "Persian Law Firm Website - Available Commands:"
	@echo ""
	@echo "Development:"
	@echo "  make dev          Start development server (port 8081)"
	@echo "  make sandbox      Start sandbox server (port 8082)"
	@echo "  make watch        Watch for changes and auto-rebuild"
	@echo "  make build        Build the application"
	@echo "  make test         Run tests"
	@echo "  make check        Check code without building"
	@echo "  make clean        Clean build artifacts"
	@echo ""
	@echo "Deployment:"
	@echo "  make deploy       Deploy as systemd service (requires sudo)"
	@echo "  make stop         Stop all running instances"
	@echo "  make status       Show running instances"
	@echo "  make logs         Show application logs"
	@echo ""
	@echo "Dependencies:"
	@echo "  make install-deps Install development dependencies"
	@echo ""

# Development commands
dev:
	@./dev.sh dev

sandbox:
	@./dev.sh sandbox

watch:
	@./dev.sh watch

build:
	@./dev.sh build

test:
	@./dev.sh test

check:
	@./dev.sh check

clean:
	@./dev.sh clean

# Deployment commands
deploy:
	@echo "Deploying Persian Law Firm Website..."
	@sudo ./deploy.sh

stop:
	@./dev.sh stop

status:
	@./dev.sh status

logs:
	@./dev.sh logs

# Install development dependencies
install-deps:
	@echo "Installing development dependencies..."
	@cargo install cargo-watch
	@echo "Dependencies installed successfully!"

# Quick start for new developers
setup: install-deps
	@echo "Setting up development environment..."
	@cargo check
	@echo "Setup complete! Run 'make dev' to start development server."
