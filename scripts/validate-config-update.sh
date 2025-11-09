#!/usr/bin/env bash
# Validation script for update-config-files workflow
# This script validates directory existence and file patterns with proper safeguards

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TARGET_FOLDER="${TARGET_FOLDER:-./}"
SOURCE_BASE="${SOURCE_BASE:-./source/reusable-configurations}"
FILE_PATTERNS="${FILE_PATTERNS:-*}"
VERBOSE="${VERBOSE:-false}"

# Function to print colored messages
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to validate directory existence
validate_directory() {
    local dir_path="$1"
    local dir_name="$2"
    
    if [ ! -d "$dir_path" ]; then
        log_error "Directory '$dir_name' does not exist at path: $dir_path"
        log_info "Expected directory structure:"
        log_info "  - Target folder should exist in the repository"
        log_info "  - Path checked: $dir_path"
        return 1
    fi
    
    log_success "Directory '$dir_name' exists: $dir_path"
    return 0
}

# Function to validate file patterns
validate_file_patterns() {
    local source_path="$1"
    local patterns="$2"
    local found_any=false
    
    log_info "Validating file patterns in: $source_path"
    
    # Split patterns by comma
    IFS=',' read -ra pattern_array <<< "$patterns"
    
    for pattern in "${pattern_array[@]}"; do
        # Trim whitespace
        pattern=$(echo "$pattern" | xargs)
        
        if [ "$VERBOSE" = "true" ]; then
            log_info "Checking pattern: $pattern"
        fi
        
        # Find files matching the pattern
        local matches
        matches=$(find "$source_path" -name "$pattern" 2>/dev/null || true)
        
        if [ -n "$matches" ]; then
            local count=$(echo "$matches" | wc -l)
            log_success "Pattern '$pattern' matched $count file(s)"
            if [ "$VERBOSE" = "true" ]; then
                echo "$matches" | while read -r file; do
                    log_info "  - $(basename "$file")"
                done
            fi
            found_any=true
        else
            log_warning "Pattern '$pattern' did not match any files in $source_path"
        fi
    done
    
    if [ "$found_any" = "false" ]; then
        log_error "No files matched any of the specified patterns: $patterns"
        log_info "Available files in $source_path:"
        if [ -d "$source_path" ]; then
            find "$source_path" -type f 2>/dev/null | head -10 | while read -r file; do
                log_info "  - $(basename "$file")"
            done
        else
            log_warning "Source directory does not exist: $source_path"
        fi
        return 1
    fi
    
    return 0
}

# Function to check if directory is accessible and writable
check_directory_permissions() {
    local dir_path="$1"
    
    if [ ! -r "$dir_path" ]; then
        log_error "Directory is not readable: $dir_path"
        return 1
    fi
    
    if [ ! -w "$dir_path" ]; then
        log_error "Directory is not writable: $dir_path"
        return 1
    fi
    
    log_success "Directory has proper permissions: $dir_path"
    return 0
}

# Main validation logic
main() {
    log_info "Starting validation for update-config-files workflow"
    log_info "Target folder: $TARGET_FOLDER"
    log_info "Source base: $SOURCE_BASE"
    log_info "File patterns: $FILE_PATTERNS"
    echo ""
    
    local validation_failed=false
    
    # Validate target directory
    if ! validate_directory "$TARGET_FOLDER" "target folder"; then
        validation_failed=true
    fi
    echo ""
    
    # Check target directory permissions
    if [ -d "$TARGET_FOLDER" ]; then
        if ! check_directory_permissions "$TARGET_FOLDER"; then
            validation_failed=true
        fi
        echo ""
    fi
    
    # Validate source directory exists
    if ! validate_directory "$SOURCE_BASE" "source configurations"; then
        validation_failed=true
    fi
    echo ""
    
    # Validate file patterns
    if [ -d "$SOURCE_BASE" ]; then
        if ! validate_file_patterns "$SOURCE_BASE" "$FILE_PATTERNS"; then
            validation_failed=true
        fi
        echo ""
    fi
    
    # Final result
    if [ "$validation_failed" = "true" ]; then
        log_error "Validation failed! Please check the errors above."
        exit 1
    else
        log_success "All validations passed successfully!"
        exit 0
    fi
}

# Run main function
main "$@"
