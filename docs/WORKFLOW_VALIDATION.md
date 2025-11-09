# Workflow Validation and Tooling

This directory contains validation scripts and tooling for the GitHub Actions workflow configuration update process.

## Overview

The `update-config-files` workflow synchronizes configuration files from the `actions/reusable-workflows` repository. This tooling provides:

1. **Validation scripts** - Validate directory existence and file patterns
2. **Manifest file** - Describe reusable patterns and directories (`.glob.yaml`)
3. **Makefile** - Local setup and integration testing
4. **Packaging script** - Package artifacts as `.tar.gz` for handover

## Files

### `.glob.yaml`
Manifest file describing:
- Source and target repository configuration
- File patterns to synchronize
- Validation rules
- Required directories

### `scripts/validate-config-update.sh`
Validation script that checks:
- Target directory existence
- Directory permissions (read/write)
- Source directory existence
- File pattern matching with detailed logging

### `scripts/package-artifacts.sh`
Packaging script that:
- Creates timestamped `.tar.gz` archives
- Includes configuration and tooling files
- Outputs archive metadata and contents

### `Makefile`
Provides targets for:
- **Setup**: `make setup` - Install dependencies
- **Development**: `make build`, `make test`, `make lint`
- **Validation**: `make validate`, `make validate-mock`
- **Packaging**: `make package`
- **Integration**: `make integration-test`
- **CI/CD**: `make ci` - Full pipeline

## Usage

### Local Setup

```bash
# Initial setup - install dependencies
make setup

# Or just install dependencies
make install
```

### Validation

```bash
# Validate workflow configuration with mock data
make validate-mock

# Run validation manually
TARGET_FOLDER=./ \
SOURCE_BASE=./source/reusable-configurations \
FILE_PATTERNS="*" \
VERBOSE=true \
./scripts/validate-config-update.sh
```

### Packaging

```bash
# Package artifacts for handover
make package

# The archive will be created in artifacts/ directory
# Example: artifacts/stale-config-20251109-124039.tar.gz
```

### Integration Testing

```bash
# Run full integration test (validation + packaging)
make integration-test
```

### Development Workflow

```bash
# Format code
make format

# Run linter
make lint

# Build project
make build

# Run tests
make test

# Run full CI pipeline
make ci
```

## Workflow Validation Details

The validation script (`validate-config-update.sh`) performs the following checks:

1. **Target Directory Validation**
   - Checks if the target folder exists
   - Validates directory permissions (readable and writable)

2. **Source Directory Validation**
   - Verifies the source configuration directory exists
   - Confirms it's accessible

3. **File Pattern Validation**
   - Checks each file pattern against source directory
   - Reports matched file counts
   - Lists matched files in verbose mode
   - Warns on missing patterns
   - Fails if no files match any pattern

## Safeguards

### Directory Checks
- Validates `./` directory exists in target repository context
- Checks for read/write permissions
- Provides detailed error messages with expected structure

### File Pattern Checks
- Validates patterns from `arrOfFilePatterns` array
- Logs warnings for patterns that don't match
- Fails gracefully with informative error messages
- Lists available files when validation fails

### Logging
- Color-coded output (INFO, SUCCESS, WARNING, ERROR)
- Verbose mode for detailed debugging
- Clear error messages with actionable information

## Troubleshooting

### Directory Not Found
If you see "Directory does not exist" errors:
1. Check the TARGET_FOLDER path is correct
2. Ensure you're running from the repository root
3. Verify the directory structure matches expectations

### No Files Matched Pattern
If validation fails with "No files matched":
1. Check the SOURCE_BASE path is correct
2. Verify the source repository was checked out
3. Review the file patterns in FILE_PATTERNS
4. Run with VERBOSE=true to see detailed pattern matching

### Permission Errors
If you see permission errors:
1. Check directory ownership
2. Verify read/write permissions
3. Ensure the workflow has proper access rights

## Integration with GitHub Actions

The workflow uses these patterns:
- **target-folder**: `./` (root directory)
- **reference-files**: `*` (all files)
- **source**: `actions/reusable-workflows/reusable-configurations`

The validation script can be integrated into the workflow to provide better error reporting:

```yaml
- name: Validate configuration
  run: |
    chmod +x scripts/validate-config-update.sh
    TARGET_FOLDER=./ \
    SOURCE_BASE=./source/reusable-configurations \
    FILE_PATTERNS="*" \
    VERBOSE=true \
    ./scripts/validate-config-update.sh
```

## Artifact Contents

The packaged `.tar.gz` archive includes:
- `.glob.yaml` - Manifest file
- `scripts/` - Validation and packaging scripts
- `Makefile` - Build and test automation
- `README.md` - Project documentation

Extract with:
```bash
tar -xzf artifacts/stale-config-*.tar.gz
```

## Environment Variables

### validate-config-update.sh
- `TARGET_FOLDER` - Target directory path (default: `./`)
- `SOURCE_BASE` - Source configuration base path (default: `./source/reusable-configurations`)
- `FILE_PATTERNS` - Comma-separated file patterns (default: `*`)
- `VERBOSE` - Enable verbose logging (default: `false`)

### package-artifacts.sh
- `OUTPUT_DIR` - Output directory for archives (default: `./artifacts`)
- `ARCHIVE_NAME` - Archive filename (default: `stale-config-<timestamp>.tar.gz`)
- `INCLUDE_PATTERNS` - Files/directories to include (default: `.glob.yaml scripts/ Makefile`)

## Contributing

When modifying the validation or packaging scripts:
1. Test locally with `make validate-mock`
2. Run integration tests with `make integration-test`
3. Verify package contents with `tar -tzf artifacts/*.tar.gz`
4. Update this documentation if behavior changes
