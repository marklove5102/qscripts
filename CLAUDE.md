# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# QScripts - IDA Pro Productivity Plugin

QScripts is an IDA Pro plugin that enables automatic script execution upon file changes, supporting hot-reload development workflows with Python, IDC, and compiled plugins.

## Build Commands

### Prerequisites
- **IDASDK**: Environment variable must be set to IDA SDK path
- **ida-cmake**: Must be installed at `$IDASDK/ida-cmake/`
- **idacpp**: Optional - will be automatically fetched if not found at `$IDASDK/include/idacpp/`

### Build with ida-cmake agent
Always use the ida-cmake agent for building:
```
Task with subagent_type="ida-cmake"
```

### Manual build (Windows)
```bash
# Configure CMake
prep-cmake.bat

# Build
prep-cmake.bat build

# Clean build
prep-cmake.bat clean
```

## Architecture

### Core Components

**Main Plugin (`qscripts.cpp`)**
- Implements `qscripts_chooser_t`: Non-modal chooser UI for script management
- File monitoring system with configurable intervals (default 500ms)
- Dependency tracking and automatic reloading
- Integration with IDA's recent scripts system (shares same list)

**Script Management (`script.hpp`)**
- `fileinfo_t`: File metadata and modification tracking
- `script_info_t`: Script state management (active/inactive/dependency)
- `active_script_info_t`: Extends script_info with dependency handling
- Dependency resolution with recursive parsing and cycle detection

### Key Features Implementation

**Dependency System**
- Dependencies defined in `.deps.qscripts` files
- Supports `/reload` directive for Python module reloading
- `/triggerfile` directive for custom trigger conditions
- `/notebook` mode for cell-based execution
- Variable expansion: `$basename$`, `$env:VAR$`, `$pkgbase$`, `$ext$`

**File Monitoring**
- Uses qtimer-based polling (not OS-specific watchers yet)
- Monitors active script and all dependencies
- Trigger file support for compiled plugin development

## IDA SDK and API Resources

When answering SDK/API questions, search and read from:
- **SDK Headers**: `$IDASDK/include` - All headers have docstrings
- **SDK Examples**: `$IDASDK/plugins`, `$IDASDK/loaders`, `$IDASDK/module`

## Testing

Test scripts are located in `test_scripts/`:
- `dependency-test/` - Simple dependency examples
- `pkg-dependency/` - Package dependency examples
- `notebooks/` - Notebook mode examples
- `trigger-native/` - Compiled plugin hot-reload examples

## Plugin States

Scripts can be in three states:
1. **Normal**: Shown in regular font
2. **Active** (bold): Currently monitored for changes
3. **Inactive** (italics): Previously active but monitoring disabled

## Important Implementation Notes

- Plugin uses idacpp wrapper library for enhanced C++ API
- Shares script list with IDA's built-in "Recent Scripts" (Alt-F9)
- Maximum 512 scripts in list (IDA_MAX_RECENT_SCRIPTS)
- Special unload function: `__quick_unload_script` called before reload
- Supports undo via IDA's undo system when enabled in options

## CI/CD and Releases

### Automated Builds
- GitHub Actions builds for Linux (.so), macOS (.dylib), and Windows (.dll)
- Runs on every push and pull request
- CMake automatically fetches idacpp if not available in IDASDK

### Creating Releases
To create a new release with pre-built binaries:
```bash
git tag v1.0.0              # Create version tag
git push origin v1.0.0      # Push tag to trigger release
```
This will automatically:
1. Build qscripts for all 3 platforms
2. Create a GitHub Release page
3. Upload all platform binaries (.dll, .so, .dylib)
4. Generate release notes from commits