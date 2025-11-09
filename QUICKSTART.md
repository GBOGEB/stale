# Quick Start Guide

## Overview

This repository now includes comprehensive validation tooling for the GitHub Actions `update-config-files` workflow. All deliverables have been packaged and are ready for use.

## What Was Delivered

### Investigation
- Analyzed workflow run #19202702064
- Found the workflow actually succeeded (no real failure)
- Created tooling to improve validation and debugging

### Deliverables

1. **Validation Script** (`scripts/validate-config-update.sh`)
   - Validates directory existence and permissions
   - Checks file patterns with detailed logging
   - Provides actionable error messages

2. **Manifest File** (`.glob.yaml`)
   - Documents workflow configuration
   - Defines file patterns and validation rules
   - Describes source/target repository settings

3. **Packaging Script** (`scripts/package-artifacts.sh`)
   - Creates `.tar.gz` archives for handover
   - Includes all tooling and documentation
   - Timestamped and versioned

4. **Makefile**
   - Automated setup, build, and test targets
   - Validation and packaging commands
   - Integration testing support

5. **Documentation**
   - `docs/WORKFLOW_VALIDATION.md` - Complete tooling guide
   - `INVESTIGATION_SUMMARY.md` - Full investigation report
   - `QUICKSTART.md` - This guide

## Quick Start

### 1. View Available Commands

```bash
make help
```

### 2. Run Validation Test

```bash
# Create a mock environment and test validation
make validate-mock
```

Expected output:
```
[SUCCESS] Directory 'target folder' exists: ./
[SUCCESS] Directory has proper permissions: ./
[SUCCESS] Pattern '*' matched 2 file(s)
[SUCCESS] All validations passed successfully!
```

### 3. Create Artifact Package

```bash
# Package all deliverables
make package
```

This creates: `artifacts/stale-config-YYYYMMDD-HHMMSS.tar.gz`

### 4. Extract and Use Package

```bash
# Extract the archive
cd /tmp
tar -xzf /path/to/artifacts/stale-config-*.tar.gz

# View contents
ls -la
```

### 5. Run Integration Tests

```bash
# Run full validation and packaging test
make integration-test
```

## Usage Examples

### Local Validation

```bash
# Validate with custom settings
TARGET_FOLDER=./ \
SOURCE_BASE=./source/reusable-configurations \
FILE_PATTERNS="*.yml,*.yaml" \
VERBOSE=true \
./scripts/validate-config-update.sh
```

### Development Workflow

```bash
# Install dependencies
make setup

# Build the project
make build

# Run tests
make test

# Run linter
make lint

# Full CI pipeline
make ci
```

### Custom Packaging

```bash
# Package specific files
OUTPUT_DIR=./my-artifacts \
INCLUDE_PATTERNS=".glob.yaml scripts/" \
./scripts/package-artifacts.sh
```

## File Locations

```
stale/
├── .glob.yaml                      # Manifest file
├── Makefile                        # Build automation
├── INVESTIGATION_SUMMARY.md        # Full investigation report
├── QUICKSTART.md                   # This guide
├── scripts/
│   ├── validate-config-update.sh   # Validation script
│   └── package-artifacts.sh        # Packaging script
├── docs/
│   └── WORKFLOW_VALIDATION.md      # Comprehensive guide
└── artifacts/                      # Generated packages (gitignored)
    └── stale-config-*.tar.gz       # Packaged deliverables
```

## Common Tasks

### Check Validation Status

```bash
make validate-mock
# Returns 0 on success, 1 on failure
```

### View Package Contents

```bash
tar -tzf artifacts/stale-config-*.tar.gz
```

### Clean Up

```bash
# Remove all build artifacts
make clean

# Remove only packages
make clean-artifacts
```

## Environment Variables

### Validation Script

- `TARGET_FOLDER` - Target directory (default: `./`)
- `SOURCE_BASE` - Source configuration path (default: `./source/reusable-configurations`)
- `FILE_PATTERNS` - Comma-separated patterns (default: `*`)
- `VERBOSE` - Enable detailed logging (default: `false`)

### Packaging Script

- `OUTPUT_DIR` - Output directory (default: `./artifacts`)
- `ARCHIVE_NAME` - Archive filename (default: `stale-config-<timestamp>.tar.gz`)
- `INCLUDE_PATTERNS` - Files to include (default: `.glob.yaml scripts/ Makefile`)

## Integration with GitHub Actions

Add to your workflow:

```yaml
- name: Validate configuration
  run: |
    chmod +x scripts/validate-config-update.sh
    TARGET_FOLDER=./ \
    SOURCE_BASE=./source/reusable-configurations \
    FILE_PATTERNS="${{ inputs.reference-files }}" \
    VERBOSE=true \
    ./scripts/validate-config-update.sh
```

## Troubleshooting

### Validation Fails

1. Check that directories exist
2. Verify file patterns are correct
3. Run with `VERBOSE=true` for details
4. See `docs/WORKFLOW_VALIDATION.md` for more help

### Package Creation Fails

1. Ensure files exist before packaging
2. Check `INCLUDE_PATTERNS` paths
3. Verify write permissions on output directory

### Build or Test Failures

1. Run `make setup` to install dependencies
2. Check Node.js version (requires v20)
3. Run `npm install` manually if needed

## Next Steps

1. **Review Documentation**
   ```bash
   cat docs/WORKFLOW_VALIDATION.md
   cat INVESTIGATION_SUMMARY.md
   ```

2. **Test the Tooling**
   ```bash
   make integration-test
   ```

3. **Integrate into Workflow**
   - Add validation step to `.github/workflows/update-config-files.yml`
   - Use the manifest file (`.glob.yaml`) as reference

4. **Share the Package**
   ```bash
   # Package is ready for handover
   ls -lh artifacts/stale-config-*.tar.gz
   ```

## Summary

All requirements from the problem statement have been implemented:

✅ Investigation of workflow failure (found it actually succeeded)
✅ Logic and safeguards for directory validation
✅ File pattern validation with safeguards and logging
✅ Manifest file (`.glob.yaml`) created
✅ Packaging as `.tar.gz` implemented
✅ Makefile for local setup and testing
✅ All components tested and confirmed working

## Support

For detailed information:
- **Tooling Guide**: `docs/WORKFLOW_VALIDATION.md`
- **Investigation**: `INVESTIGATION_SUMMARY.md`
- **Help**: Run `make help` for available commands

---

**Ready for Production**: All changes have been tested and are ready for use.
