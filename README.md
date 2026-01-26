# Mnesis 🧠

> AI-powered medical assistant helping doctors manage patient care through conversational AI and intelligent insights.

## Overview

Mnesis is a mobile medical assistant designed to help healthcare professionals:
- 💬 Chat with AI assistant per patient (contextual medical insights)
- 📋 Manage patient information and medical history
- 📎 Access and view patient attachments (PDFs, images)
- 🔍 Search and organize patient lists efficiently
- 📊 Review patient summaries and key metrics

## MVP Scope (v1.0)

**Current Status**: MVP Development (2-week sprint)
**Approach**: Option Charlie (Hybrid Preservation)

### 5+1 Screens
1. **Login** - Authentication (placeholder design, Supabase auth)
2. **Home** - Patient list with search and stats
3. **Chat Assistente** - AI chat interface per patient
4. **Resumo Paciente** - Patient summary and medical history
5. **Anexos** - Attachment list (PDFs, images)
6. **Visualização Anexo** - PDF/image viewer

### MVP Features
- ✅ Supabase authentication
- ✅ Patient search and filtering
- ✅ Mock AI chat responses (simulated streaming)
- ✅ PageView navigation (Chat ↔ Resumo ↔ Anexos)
- ✅ PDF/image attachment viewing
- ✅ Dark-first Material 3 design system

### Post-MVP (v1+)
- ⏳ Real backend integration (LLM + API)
- ⏳ Chat Secretaria (doctor ↔ secretary P2P chat)
- ⏳ Agenda (calendar view for appointments)
- ⏳ Voice input for chat
- ⏳ Real-time notifications

## Architecture

- **Frontend**: Flutter 3.35.5 (Clean Architecture + Riverpod)
- **State Management**: Riverpod (type-safe, testable)
- **Navigation**: go_router (Login → Home → PageView)
- **Design**: Dark-first Material 3 with orange accent (#FF7043)
- **Backend (MVP)**: Mock data providers (patients, chat, attachments)
- **Backend (v1+)**: Supabase + LLM integration (deferred)
- **Testing**: 80%+ coverage (1,165+ tests)

## Documentation

See `/documentation/mnesis/` folder for comprehensive docs:

### Architecture & Planning
- **[ARCHITECTURE.md](documentation/mnesis/ARCHITECTURE.md)** - MVP architecture overview
- **[MVP_DECISIONS.md](documentation/mnesis/MVP_DECISIONS.md)** - Decision rationale (Option Charlie)
- **[IMPLEMENTATION_PLAN.md](documentation/mnesis/IMPLEMENTATION_PLAN.md)** - Week-by-week breakdown
- **[MNESIS_DESIGN_SYSTEM.md](documentation/mnesis/MNESIS_DESIGN_SYSTEM.md)** - Design system (Grade A)

### Legacy Docs (Pre-MVP)
- MNESIS_ARCHITECTURE_REVISED.md - Original backend-heavy architecture
- MNESIS_ROADMAP_REVISED.md - Original 6-week roadmap
- INDEX.md - Documentation index

## Quick Start

### Prerequisites
- Flutter 3.35.5+ installed
- Supabase account (for auth in v1+)
- Android/iOS development environment

### Installation

```bash
# Clone repository
git clone https://github.com/your-org/mnesis_flutter.git
cd mnesis_flutter

# Install dependencies
flutter pub get

# Run code generation (for freezed, injectable, drift)
flutter pub run build_runner build --delete-conflicting-outputs

# Run app (development mode with mock data)
flutter run
```

### Environment Setup

Create `.env` file in project root:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
USE_MOCK_DATA=true
```

## Development

### Project Structure

```
lib/
├── core/
│   ├── design_system/      # MnesisColors, TextStyles, Spacings, Theme
│   ├── di/                 # Dependency injection (get_it + injectable)
│   ├── config/             # Environment configuration
│   └── router/             # Navigation (go_router)
├── features/
│   ├── auth/               # Login screen (placeholder)
│   ├── home/               # Patient list screen
│   ├── chat/               # Chat Assistente screen
│   ├── patients/           # Resumo Paciente screen
│   └── attachments/        # Anexos + Viewer screens
└── shared/
    ├── data/               # Mock data providers
    └── widgets/            # Reusable components
```

### Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Code Generation

```bash
# Freezed (immutable models)
# injectable (DI)
# drift (SQLite)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-rebuild on changes)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Code Quality

```bash
# Analyze code
flutter analyze

# Format code
dart format lib/ test/

# Check for outdated dependencies
flutter pub outdated
```

## FlowForge Workflow

This project follows FlowForge methodology. See `CLAUDE.md` for:
- Complete FlowForge rules (38 rules)
- Git workflow (feature branches, no main commits)
- Testing requirements (80%+ coverage, TDD)
- Documentation standards
- Time tracking guidelines

### Quick Commands

```bash
# Start work session (MANDATORY FIRST COMMAND)
./run_ff_command.sh flowforge:session:start MNESIS-XXX

# End work session
./run_ff_command.sh flowforge:session:end "Completed task description"

# Check rules compliance
./run_ff_command.sh flowforge:dev:checkrules
```

## Related Projects

- [Volan Flutter](https://github.com/jottap/volan_flutter) - Medical billing platform
- Mnesis Server - Backend API (coming soon)
