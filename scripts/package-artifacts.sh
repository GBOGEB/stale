#!/usr/bin/env bash
# Script to package target artifacts as .tar.gz for handover
# This creates a compressed archive of specified directories and files

set -e

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
OUTPUT_DIR="${OUTPUT_DIR:-./artifacts}"
ARCHIVE_NAME="${ARCHIVE_NAME:-stale-config-$(date +%Y%m%d-%H%M%S).tar.gz}"
INCLUDE_PATTERNS="${INCLUDE_PATTERNS:-.glob.yaml scripts/ Makefile}"

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

main() {
    log_info "Packaging artifacts for handover"
    
    # Create output directory if it doesn't exist
    mkdir -p "$OUTPUT_DIR"
    
    # Build the tar command with include patterns
    local tar_files=""
    for pattern in $INCLUDE_PATTERNS; do
        if [ -e "$pattern" ]; then
            tar_files="$tar_files $pattern"
        else
            log_info "Skipping non-existent: $pattern"
        fi
    done
    
    if [ -z "$tar_files" ]; then
        echo "Error: No files to package"
        exit 1
    fi
    
    log_info "Creating archive: $OUTPUT_DIR/$ARCHIVE_NAME"
    log_info "Including: $tar_files"
    
    # Create the tar.gz archive
    tar -czf "$OUTPUT_DIR/$ARCHIVE_NAME" $tar_files
    
    # Show archive info
    log_success "Archive created successfully!"
    log_info "Archive location: $OUTPUT_DIR/$ARCHIVE_NAME"
    log_info "Archive size: $(du -h "$OUTPUT_DIR/$ARCHIVE_NAME" | cut -f1)"
    
    # List contents
    log_info "Archive contents:"
    tar -tzf "$OUTPUT_DIR/$ARCHIVE_NAME" | head -20
    
    echo ""
    log_success "Packaging complete!"
}

main "$@"
