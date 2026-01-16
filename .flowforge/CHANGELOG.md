# FlowForge Changelog

All notable changes to FlowForge will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.4] - 2025-01-13

### 🎨 NEW FEATURE - Enhanced Installation Wizard UI (Issue #319)

### Added
- **Professional Installation Experience**: Enhanced terminal UI with ASCII branding
  - Dynamic ASCII logo generation with figlet integration
  - Gradient color effects with graceful degradation
  - Terminal-responsive design (40-200+ column support)
  - Cross-platform compatibility (Linux, macOS, Windows)
  - Performance optimization (<200ms logo generation target)
  
- **LogoGenerator API**: Complete ASCII art generation system
  - Figlet-based logo creation with multiple font options
  - Gradient color application using gradient-string
  - Responsive design based on terminal width detection
  - Error resilience with fallback text generation
  - Performance monitoring with budget enforcement
  
- **TerminalCapabilities API**: Comprehensive terminal feature detection
  - Width and height detection with environment fallbacks
  - Color support detection (true color, 256-color, basic, monochrome)
  - Unicode/UTF-8 support detection
  - TTY vs pipe detection for CI/CD compatibility
  - UI recommendation system for adaptive interfaces

### Enhanced
- **Installation Wizard**: Professional appearance with branded experience
- **NPX Integration**: Enhanced first impression for `npx @justcode-cruzalex/flowforge init`
- **Developer Onboarding**: Reduced friction with visual appeal
- **Terminal Adaptation**: Intelligent layout adjustments for all screen sizes

### Technical Details
- **Performance**: Logo generation 50-150ms (target: <200ms) ✅
- **Memory Usage**: ~2MB peak (target: <5MB) ✅  
- **Test Coverage**: 85% comprehensive test coverage
- **Error Handling**: Graceful fallbacks for all failure scenarios
- **Logger Integration**: Rule #8 compliant (no console.* usage)

### Files Added
- `src/ui-enhanced/LogoGenerator.ts` - ASCII art generation engine
- `src/ui-enhanced/TerminalCapabilities.ts` - Terminal feature detection
- `src/ui-enhanced/index.ts` - Module exports and type definitions
- `tests/ui-enhanced/` - Comprehensive test suite
- `documentation/2.0/demo/installation-wizard-ui.md` - Demo guide
- `documentation/2.0/api/ui-enhanced.md` - API documentation
- `documentation/2.0/guides/ui-integration.md` - Integration guide

### Dependencies Added
- `figlet@^1.9.1` - ASCII art text generation
- `gradient-string@^3.0.0` - Terminal color gradients
- `@types/figlet@^1.7.0` - TypeScript definitions

### Developer Impact
- **Professional First Impression**: Enhanced developer onboarding experience
- **Brand Consistency**: Unified visual identity across all FlowForge tools
- **Terminal Intelligence**: Automatic adaptation to developer environments
- **Performance Focus**: Sub-200ms generation maintains productivity flow

## [2.0.3] - 2025-01-09

### 🚨 CRITICAL FIX - Session Corruption Prevention

### Fixed
- **CRITICAL**: Fixed session corruption where PR numbers contaminated issue numbers
  - This was the 3rd occurrence and was blocking developer payment tracking
  - Root cause: Markdown file found at JSON location causing state corruption
  - PR #406 number was overwriting Issue #315, system thought it was Issue #407
  
### Added
- Multiple layers of protection against session corruption:
  - JSON format validation before reading session files
  - Task ID validation to reject PR numbers (>= 300)
  - Ghost task detection in provider bridge
  - Automatic corruption recovery script (`scripts/recover-session.sh`)
  - Pre-session guard hooks
  - Git protection via .gitignore for session files
  
### Changed
- Session files now excluded from Git to prevent merge corruption
- Enhanced session:start command with JSON validation
- Provider bridge now filters non-existent tasks
  
### Security
- Command injection prevention via task ID validation
- Protected state management for payment data integrity

### Testing
- 23 comprehensive tests covering all corruption scenarios
- 100% coverage of payment protection paths
- All attack vectors validated and blocked

### Developer Notes
- This fix ensures developer payment tracking cannot be corrupted
- Recovery runbook available at `/documentation/2.0/runbooks/session-corruption-recovery.md`
- Incident report at `/documentation/2.0/incidents/session-corruption-fix.md`
- **TIME = MONEY**: This fix protects the core mission of FlowForge

## [1.4.2] - 2025-08-03

### Added
- `/tasks` command for comprehensive task reporting (from PR #42)
  - Generate markdown reports of tasks by various filters
  - Support for today, tomorrow, week, next-week, milestone, and all filters
  - Option to filter by assignee (--mine or --all)
  - Automatic progress bars for milestones
  - Summary statistics by priority and size

### Developer Notes
- Manually merged /tasks command from feature/41-tasks-command branch
- This completes all planned features for v1.4.x series

## [1.4.1] - 2025-08-03

### Fixed
- Critical install and update script failures
  - Added comprehensive error handling and logging
  - Scripts now log to `/tmp/flowforge-install-logs/` and `/tmp/flowforge-update-logs/`
  - Proper FF-on-FF detection prevents path confusion
  - Clear error messages with recovery hints
  - Dry-run mode for testing without changes
  - Fixed hanging scripts with proper error recovery
  - Automatic cleanup of old logs (keeps last 10)

### Added
- Logging system for install/update scripts
- Dry-run mode (--dry-run) for both scripts
- Better progress indicators and validation
- Backup system for update script
- Help documentation (--help) for both scripts

### Developer Notes
- This was an untracked fix (no GitHub issue) - lost billable time!
- Always follow FlowForge rules, even when fixing FlowForge itself
- Both scripts now handle FF-on-FF mode correctly
- No more silent failures - users get clear feedback

## [1.4.0] - 2025-08-03

### Added
- FlowForge Context Awareness System (flowforge-context.sh)
  - Automatic detection of source vs installed mode
  - Dynamic path resolution for all scripts
  - Single source of truth for FlowForge location
- FF-on-FF Detection (detect-ff-on-ff.sh)
  - Detects when FlowForge is developing itself
  - Different rule enforcement for internal development
  - Rule #33 (AI references) skipped in FF-on-FF mode
- Comprehensive Rule Enforcement (all 34 rules)
  - All rules now enforced in Claude Code hooks
  - Context-aware enforcement based on project type
- Time Format Improvements
  - All time displays now use HH:MM format
  - Fixed decimal hour confusion (1.24h → 01:14)
- Enhanced Commands
  - /tasks - Comprehensive task reporting
  - /icebox - View future ideas without milestones
  - /endday - Fixed execution and automation
- Session Management Improvements
  - Fixed duplicate session creation
  - Proper time formatting in all outputs
  - Better session state management

### Fixed
- Time tracking automation issues (#39)
  - TASKS.md now properly moves completed items
  - SCHEDULE.md calculates hours correctly
  - Session tracker formats time properly
- Path resolution issues in mixed environments
- Rule enforcement false positives for FlowForge development
- /endday command execution (was showing docs instead of running)
- setup-labels.js console.log blocking commits

### Changed
- Rule enforcement now context-aware (source vs installed)
- Install/update scripts detect FF-on-FF mode
- All scripts use unified context system
- Version strategy updated with hybrid automation plan

### Developer Notes
- FlowForge can now manage its own development!
- The context system eliminates path confusion
- FF-on-FF mode enables self-referential development
- Ready for stable release and self-management

## [1.3.71] - 2025-07-30

### Fixed
- Documentation enforcement false positives for ML/AI projects
- Test files no longer require test documentation
- ML model files (e.g., llama3_model.py) no longer trigger database documentation requirements

### Added
- Project type auto-detection (ML, API, Web, Mobile, General)
- Support for multiple language API frameworks (Ruby, Python, JavaScript)
- Smarter pattern matching based on project type
- Scripts directory exemption for ML projects

### Improved
- More specific patterns for database models vs ML models
- Better detection of actual database files (entity, schema, orm, db keywords)
- Added support for more package managers (pyproject.toml, Pipfile)
- Docker file changes now trigger README updates

## [1.3.7] - 2025-07-29

### Fixed
- Documentation validation script now properly handles warnings without failing
- Fixed `check_documentation_currency` function returning warning count as exit code
- Warnings no longer cause commit failures (only errors block commits)
- Script now redirects warning messages to stderr and returns count via stdout

### Improved
- Better separation between errors and warnings in documentation checks
- Clearer logic flow for warning count accumulation

## [1.3.6] - 2025-07-29

### Improved
- Enhanced error messages for NEXT_SESSION.md validation
- Now shows exact sections needed with examples
- Added clear instructions on how to fix missing required files
- Better guidance for FlowForge automation requirements

## [1.3.5] - 2025-07-29

### Changed
- Made documentation checks more flexible for existing projects
- README structure validation now accepts common variations (Architecture, Structure, etc.)
- Existing projects (100+ line README or simple integration mode) get warnings instead of errors
- Better detection of established projects to avoid forcing structure changes

### Added
- Detection of existing projects based on README size and integration mode
- Informative messages about relaxed validation for existing projects

## [1.3.4] - 2025-07-29

### Fixed
- Fixed pre-commit hook template to show detailed error messages
- Template now matches setup-enforcement-hooks.sh behavior

## [1.3.3] - 2025-07-29

### Changed
- Improved pre-commit hook error reporting to show detailed documentation check failures
- Enhanced error messages visibility for better user feedback

## [1.3.2] - 2025-07-29

### Added
- Rule #34: Document learned knowledge in wisdom directory
- Wisdom knowledge base system for institutional knowledge
- `/update-wisdom-docs` command for refreshing wisdom documentation
- `/read_from_wisdom` command for accessing wisdom documents
- Wisdom sync in update.sh script
- Documentation for Anthropic custom agents
- Documentation for Claude Code hooks system

### Changed
- Updated Claude Code hooks configuration to new array format
- Fixed UserPromptSubmit hook to use correct configuration format
- Enhanced update.sh to sync wisdom documentation

### Fixed
- Claude Code hooks not executing due to outdated configuration format
- Hook configuration in settings.json template

## [1.3.0] - 2025-07-25

### Added
- Enforcement levels system (Gradual vs Immediate)
- `/enforcement` command to manage enforcement levels
- Enforcement-aware git hooks that respect gradual mode
- 30-day transition period for gradual enforcement
- Comprehensive test framework with 100+ tests
- Fresh installation test suite
- Enforcement feature test suite
- Migration guide installation option

### Changed
- Installation flow now has separate installation type and enforcement level choices
- Pre-commit hooks now check enforcement level before blocking commits
- Config structure includes enforcement settings
- Simple mode renamed to Standard mode for clarity
- Complete mode renamed to "With Migration Guide" for clarity

### Fixed
- Bash arithmetic operations with `set -e` causing test failures
- Missing `argument-hint` in setup-flowforge.md
- Installation test issues with symlinks
- Config enforcement structure pattern matching

## [Unreleased]

### Added
- `/postUpdateWizard` command for interactive feature discovery after updates
- Automatic post-update wizard prompt in `/update` command
- Learning task creation in GitHub for new features
- Adaptive Integration Architecture documentation for future multi-tool support

### Changed
- Enhanced update mechanism to detect major version changes
- Update script now saves previous version for comparison

## [1.2.0] - 2025-01-24

### Added
- Comprehensive installation guide (`HOWTOINSTALL.md`)
- Host project version tracking system (opt-in)
- `/flowforgeVersion` command to show version and changelog
- `/enableVersioning` command for project version tracking
- `/disableVersioning` command to disable version tracking
- Version tracking option in `/setupproject` wizard
- Complete documentation structure in README
- All documentation files properly linked

### Changed
- Updated README with complete documentation links
- Version badge now shows 1.2.0
- Enhanced `/setupproject` with version tracking option
- All references to "CruzAlex" replaced with "developer" where appropriate (kept attribution)
- Improved documentation organization and consistency

### Fixed
- Missing documentation links in README
- Inconsistent naming conventions
- Documentation structure alignment

## [1.1.0] - 2025-07-21

### Added
- Version system with VERSION file and CHANGELOG
- `/update` command to check and install updates
- `/setupproject` wizard for one-time project setup
- `/plan` command for AI-powered sprint/milestone planning
- `/StartWorkOnNextProgrammedTask` for smart session starts
- Proper path resolution in installation script
- Validation checks before installation
- Better error messages during installation

### Changed
- Renamed `/endwork` to `/pause` for clarity
- Renamed `/callthenight-enhanced` to `/endday`
- Fixed all path references from `.standards/` to `.flowforge/`
- Installation script now copies RULES.md (was missing!)
- Improved command descriptions with better messaging

### Fixed
- Installation script path resolution issues
- Missing RULES.md copy during installation
- Silent failures now show proper warnings
- All slash command path references
- Duplicate startsession.md removed

## [1.0.0] - 2025-07-01

### Added
- Initial FlowForge release
- 33 development rules
- Time tracking system
- Git hooks for enforcement
- Claude Code integration
- Documentation templates
- Project structure automation