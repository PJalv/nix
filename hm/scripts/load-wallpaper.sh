#!/usr/bin/env bash
# Robust wallpaper loader for swww
# Handles race conditions and provides retry logic

set -euo pipefail

# Configuration
WALLPAPER_DIR="${HOME}/.config/wallpaper"
MAX_RETRIES=10
RETRY_DELAY=1

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Wait for swww-daemon to be ready
wait_for_swww() {
    local attempt=0

    log_info "Waiting for swww-daemon to start..."

    while [ $attempt -lt $MAX_RETRIES ]; do
        if swww query >/dev/null 2>&1; then
            log_info "swww-daemon is ready!"
            return 0
        fi

        attempt=$((attempt + 1))
        log_warn "Attempt $attempt/$MAX_RETRIES: swww-daemon not ready yet, waiting ${RETRY_DELAY}s..."
        sleep $RETRY_DELAY
    done

    log_error "swww-daemon failed to start after $MAX_RETRIES attempts"
    return 1
}

# Find and load a random wallpaper
load_wallpaper() {
    if [ ! -d "$WALLPAPER_DIR" ]; then
        log_error "Wallpaper directory not found: $WALLPAPER_DIR"
        return 1
    fi

    # Find a random wallpaper
    local wallpaper
    wallpaper=$(find -L "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \) 2>/dev/null | shuf -n 1)

    if [ -z "$wallpaper" ]; then
        log_error "No wallpaper files found in $WALLPAPER_DIR"
        return 1
    fi

    log_info "Loading wallpaper: $(basename "$wallpaper")"

    if swww img "$wallpaper"; then
        log_info "Wallpaper loaded successfully!"
        return 0
    else
        log_error "Failed to load wallpaper: $wallpaper"
        return 1
    fi
}

# Main execution
main() {
    log_info "Starting wallpaper loader..."

    # Ensure swww-daemon is running
    if ! pgrep -x swww-daemon >/dev/null; then
        log_info "Starting swww-daemon..."
        swww-daemon &
    fi

    # Wait for daemon to be ready
    if ! wait_for_swww; then
        log_error "Failed to initialize swww-daemon"
        exit 1
    fi

    # Load wallpaper with retry logic
    local attempt=0
    while [ $attempt -lt $MAX_RETRIES ]; do
        if load_wallpaper; then
            exit 0
        fi

        attempt=$((attempt + 1))
        if [ $attempt -lt $MAX_RETRIES ]; then
            log_warn "Retrying ($attempt/$MAX_RETRIES)..."
            sleep $RETRY_DELAY
        fi
    done

    log_error "Failed to load wallpaper after $MAX_RETRIES attempts"
    exit 1
}

main "$@"
