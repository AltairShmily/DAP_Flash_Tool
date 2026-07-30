# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### 2026-07-30 - Project Initialization

#### Decisions

1. **Architecture: Flutter + Python gRPC**
   - **Decision:** Flutter desktop frontend communicates with Python backend via gRPC on localhost
   - **Reason:** gRPC provides type-safe interfaces, bidirectional streaming for progress updates, and clear separation of concerns. Python backend handles hardware interaction while Flutter focuses on UI.
   - **Alternatives considered:**
     - REST API + SSE: Simpler but no type safety, progress streaming less natural
     - Dart FFI direct call: Best performance but requires rewriting PyOCD in C/Rust, not feasible

2. **Dual Driver Support: PyOCD + OpenOCD**
   - **Decision:** Support both PyOCD (Python native) and OpenOCD (subprocess) drivers behind a unified abstraction layer
   - **Reason:** Users have different preferences and hardware requirements. PyOCD is easier to integrate; OpenOCD has broader hardware support.
   - **Trade-off:** Doubles the driver implementation effort, but the abstraction layer keeps the interface clean.

3. **UI Framework: Material 3 with Collapsible Cards**
   - **Decision:** Use Material 3 design language with collapsible card layout
   - **Reason:** Material 3 provides modern, accessible components. Collapsible cards allow users to focus on relevant sections while keeping the interface compact.
   - **Alternatives considered:**
     - macOS-style: Too platform-specific
     - Industrial/Keil-style: Less modern, harder to maintain

4. **Theme System: Switchable Dark/Light**
   - **Decision:** Support both dark and light themes with user toggle
   - **Reason:** Embedded developers often work in both bright offices and dark labs. Dark theme reduces eye strain during long sessions.
   - **Implementation:** Riverpod ThemeMode provider with SharedPreferences persistence

5. **History Storage: JSON File**
   - **Decision:** Store flash history in JSON file instead of SQLite
   - **Reason:** Simpler implementation, no additional dependencies, sufficient for 100-record limit
   - **Trade-off:** Less efficient for large datasets, but acceptable for this use case

6. **Pack Management: Local + Network**
   - **Decision:** Support both local pack directory scanning and network pack download
   - **Reason:** Users may have existing pack files locally, or need to download new ones from vendor sites
   - **Implementation:** PackManager class with scan_directory() and download capabilities

7. **Backend Process Management: Auto-start with Health Check**
   - **Decision:** Flutter automatically starts Python backend on launch, with periodic health checks
   - **Reason:** Provides seamless user experience; users shouldn't need to manually start the backend
   - **Implementation:** BackendManager class with start/stop/checkHealth methods

#### Documentation

- Created project design specification: `docs/compose/specs/2026-07-30-dap-flash-tool-design.md`
- Created implementation plan: `docs/compose/plans/2026-07-30-dap-flash-tool.md`
- Created this CHANGELOG.md

#### Project Structure

```
dap_download/
├── CHANGELOG.md                    # This file
├── docs/
│   └── compose/
│       ├── specs/                  # Design specifications
│       └── plans/                  # Implementation plans
├── flutter_app/                    # Flutter desktop application (planned)
├── backend/                        # Python gRPC backend (planned)
├── proto/                          # Shared protobuf definitions (planned)
└── scripts/                        # Build and setup scripts (planned)
```

---

## Template for Future Entries

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- New features

### Changed
- Changes to existing features

### Deprecated
- Features that will be removed in future versions

### Removed
- Features removed in this version

### Fixed
- Bug fixes

### Security
- Security-related changes

### Decisions
- Key architectural or design decisions made, with rationale
```
