# GitHub Actions Workflows

## Update Configuration Files Workflow

### Overview

The `update-config-files.yml` workflow automatically synchronizes configuration files from the [actions/reusable-workflows](https://github.com/actions/reusable-workflows) repository to this repository.

### Features

#### 1. **Enhanced Validation**
- Validates target directories before processing
- Creates missing directories automatically with warnings
- Validates source directories exist before syncing
- Clear error messages for all validation failures

#### 2. **Robust File Pattern Handling**
- Parses comma-separated file patterns correctly
- Handles whitespace in pattern lists
- Skips empty patterns gracefully
- Logs all patterns for debugging
- Shows which patterns match files and which don't

#### 3. **Comprehensive Logging**
- Groups related log output for readability
- Shows configuration at workflow start
- Logs each processing step
- Provides operation summaries
- Shows which files were changed

#### 4. **Fallback Mechanisms**
- Creates target directories if missing
- Continues processing after failed patterns
- Provides warnings instead of hard failures for non-critical issues
- Reports detailed summaries of successes and failures

#### 5. **Manual Triggers**
- Supports `workflow_dispatch` for manual execution
- Configurable inputs for flexibility
- Maintains backward compatibility with defaults

### Usage

#### Automatic Execution
The workflow runs automatically every Sunday at 3 AM UTC via the schedule trigger:
```yaml
schedule:
  - cron: '0 3 * * 0'
```

#### Manual Execution
You can manually trigger the workflow from the GitHub Actions UI with custom parameters:

**Parameters:**
- **target-folder**: Target folder for config files (default: `./`)
- **reference-files**: File patterns to sync, comma-separated (default: `*`)
- **base-pr-branch**: Base branch for PR (default: `main`)
- **head-pr-branch**: Head branch for PR (default: `tool-config-auto-update`)

### Workflow Steps

1. **Checkout Repositories**
   - Checks out the target repository (this repo)
   - Checks out the source repository (actions/reusable-workflows)

2. **Validate Directories**
   - Validates target directory exists (creates if missing)
   - Validates source directory exists

3. **Process File Patterns**
   - Parses file patterns from input
   - Validates each pattern matches files
   - Syncs matching files using rsync
   - Provides detailed logging

4. **Commit and Push Changes** (if changes detected)
   - Creates or switches to update branch
   - Commits changes with descriptive message
   - Pushes to remote

5. **Create Pull Request** (if changes and no PR exists)
   - Creates a new PR with the changes
   - Links to the workflow run for traceability

### Example Logs

The workflow provides structured, grouped output:

```
::group::Configuration
Target folder: ./
File patterns: *.yml,*.yaml
Head branch: tool-config-auto-update
Source folder: /home/runner/work/stale/stale/source/reusable-configurations
::endgroup::

::group::Validating target directory
✓ Target directory validated: ./
::endgroup::

::group::Parsing file patterns
File patterns array (2 patterns):
  [0]: '*.yml'
  [1]: '*.yaml'
::endgroup::

::group::Processing file patterns
Processing pattern: '*.yml'
Found 5 file(s) matching pattern '*.yml'
✓ Successfully synced files matching '*.yml'

Summary:
  Patterns processed: 2
  Successfully updated: 2
  Failed patterns: 0
::endgroup::
```

### Improvements Over Previous Implementation

**Before**: Used external reusable workflow
- Limited control over error handling
- No visibility into processing steps
- No customization options
- Fixed directory validation logic

**After**: Self-contained workflow
- ✅ Full control over all steps
- ✅ Detailed logging with groups
- ✅ Configurable via workflow inputs
- ✅ Improved directory validation
- ✅ Better file pattern handling
- ✅ Fallback mechanisms
- ✅ Clear error messages
- ✅ Operation summaries

### Troubleshooting

#### No changes detected
If the workflow completes but shows "No configuration file changes detected":
- The configuration files are already up to date
- No action is needed

#### Failed pattern warnings
If you see warnings about failed patterns:
- Check that the file patterns are correct
- Verify files exist in the source repository
- Review the workflow logs for specific pattern names

#### Directory creation warnings
If the workflow creates directories:
- Review whether these directories should exist
- Consider adding them to your repository structure
- Update the `target-folder` input if needed

### Related Files

- Workflow file: `.github/workflows/update-config-files.yml`
- This documentation: `.github/workflows/README.md`
