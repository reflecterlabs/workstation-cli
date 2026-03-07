# Changelog

All notable changes to this project will be documented in this file.

## [2.1.0] - 2026-03-07

### Added
- **ORQ (Orchestration Queue) Protocol** - Multi-agent coordination system
  - `workstation orq claim` - Claim files for editing with TTL
  - `workstation orq release` - Release claims when done
  - `workstation orq check` - Check file availability before editing
  - `workstation orq status` - View all active claims across seats
  - `workstation orq sync` - Sync claims from other seats
  - `workstation orq clean` - Remove expired claims
- File-based locking with automatic TTL expiration
- Conflict detection for concurrent editing
- Cross-seat claim visibility

### Changed
- Updated help documentation to include ORQ commands

## [2.0.0] - 2026-03-06

### Added
- Initial release of Workstation CLI v2.0
- Multi-organization support
- Seat management (create, activate, sync)
- Knowledge Base management
- Two-level memory system (MEMORY.md + daily logs)
- Automatic backup with snapshots and archives
- Bootstrap ritual for new agents
- Template system for seats
- Git-native state management
- Integration with OpenClaw

### Features
- `workstation init` - Initialize new organization
- `workstation seat create` - Create new agent seat
- `workstation seat activate` - Switch between seats
- `workstation seat sync` - Backup and sync state
- `workstation kb add` - Add Knowledge Base from git
- `workstation kb update` - Update all KBs
- `workstation backup` - Full backup of all seats
- `workstation doctor` - Installation check
- `workstation status` - Show current status

### Architecture
- SSOT (Single Source of Truth) per organization
- Symlink-based workspace switching
- Git-based version control for all state
- JSON configuration with jq processing
- Bash-based implementation

## [1.0.0] - Deprecated

- Initial prototype
- Basic file organization
- Limited seat management

---

[2.0.0]: https://github.com/agentzfactory/workstation/releases/tag/v2.0.0
