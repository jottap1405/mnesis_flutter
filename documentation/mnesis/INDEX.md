# Mnesis Documentation Index

**Project**: Mnesis - AI Medical Assistant
**Architecture**: Backend-Heavy, Chat-First, LLM-Powered
**Last Updated**: 2026-01-16

---

## 📚 Documentation Structure

This directory contains all architecture and design documentation for the Mnesis medical assistant application.

---

## 🏗️ Architecture Documents

### 1. **MNESIS_ARCHITECTURE_REVISED.md** ⭐ PRIMARY
**Status**: ✅ Active (Current Version)
**Purpose**: Complete technical architecture specification

**Contents**:
- Backend-heavy architecture philosophy
- Minimal SQLite schema (messages cache only)
- 3-tier Clean Architecture structure
- Feature breakdown (chat vs thin features)
- Backend API contract (REST + SSE)
- State management (Riverpod)
- Streaming chat implementation (SSE)
- Error handling patterns
- Testing strategy
- Migration from Volan Flutter

**Read this first**: This is the authoritative architecture document.

---

### 2. **ARCHITECTURE_REVISION_SUMMARY.md**
**Status**: ✅ Active
**Purpose**: Quick reference for architecture changes

**Contents**:
- What changed from original architecture
- Why the change was necessary
- Before/After comparison
- Implementation impact
- Migration strategy
- Validation checklist

**Read this for**: Quick understanding of the architectural shift.

---

## 🎨 Design Documents

### 3. **MNESIS_DESIGN_SYSTEM.md**
**Status**: ✅ Active
**Purpose**: Complete design system specification

**Contents**:
- Design philosophy (dark-first, orange primary)
- Color palette (extracted from screenshots)
- Typography (Inter font, type scale)
- Spacing system (4px base unit)
- Border radius scale
- Component library (buttons, inputs, chat bubbles)
- Volan vs Mnesis comparison
- shadcn_flutter customization guide
- Implementation checklist

**Read this for**: All design/UI implementation details.

---

## 📅 Planning Documents

### 4. **MNESIS_ROADMAP_REVISED.md**
**Status**: ✅ Active
**Purpose**: Development roadmap and timeline

**Contents**:
- Phase-by-phase implementation plan
- Feature priorities
- Timeline estimates
- Resource allocation
- Risk management
- Success metrics

**Read this for**: Project planning and timeline.

---

## 🗂️ Document Relationship Map

```
┌─────────────────────────────────────────────────────────┐
│             MNESIS DOCUMENTATION                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  START HERE                                             │
│  ├─→ ARCHITECTURE_REVISION_SUMMARY.md (5 min read)    │
│  │   ↓                                                  │
│  ├─→ MNESIS_ARCHITECTURE_REVISED.md (20 min read) ⭐  │
│  │   ↓                                                  │
│  ├─→ MNESIS_DESIGN_SYSTEM.md (15 min read)            │
│  │   ↓                                                  │
│  └─→ MNESIS_ROADMAP_REVISED.md (10 min read)          │
│                                                          │
│  IMPLEMENTATION REFERENCE                               │
│  ├─→ Volan Flutter Codebase (reference implementation) │
│  ├─→ HTTP_Backend_Architecture_TECH.md (in /technical)│
│  └─→ DESIGN_SYSTEM.md (Volan design - for comparison) │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## 🎯 Quick Start Guide

### For Architects
1. Read `ARCHITECTURE_REVISION_SUMMARY.md` (5 min)
2. Read `MNESIS_ARCHITECTURE_REVISED.md` (20 min)
3. Review Backend API Contract section
4. Validate with backend team

### For Frontend Developers
1. Read `ARCHITECTURE_REVISION_SUMMARY.md` (5 min)
2. Read `MNESIS_ARCHITECTURE_REVISED.md` → Feature Structure section (10 min)
3. Read `MNESIS_DESIGN_SYSTEM.md` (15 min)
4. Review Volan Flutter codebase for reference implementation
5. Start with chat feature implementation

### For Designers
1. Read `MNESIS_DESIGN_SYSTEM.md` (15 min)
2. Review component library section
3. Check Volan vs Mnesis comparison
4. Validate design tokens match Figma

### For Project Managers
1. Read `ARCHITECTURE_REVISION_SUMMARY.md` (5 min)
2. Read `MNESIS_ROADMAP_REVISED.md` (10 min)
3. Review timeline and resource allocation
4. Track progress against roadmap

---

## 📋 Key Concepts (Quick Reference)

### Architecture Principles
1. **Backend-Heavy**: 90% logic in backend LLM, 10% in Flutter UI
2. **Chat-First**: Conversation is the primary interface
3. **Minimal Local Storage**: Only cache chat messages (2 SQLite tables)
4. **Streaming-First**: SSE for real-time AI responses
5. **Thin Features**: Patients/appointments/cases are simple API wrappers

### Technology Stack
- **Frontend**: Flutter + Riverpod + Clean Architecture
- **Backend**: LLM (GPT-4/Claude) + REST API + SSE Streaming
- **Local Storage**: SQLite (messages cache only)
- **Authentication**: Same as Volan (HTTP + Secure Storage)
- **Testing**: Mocktail + Flutter Test (80%+ coverage)

### Feature Types

#### Rich Feature (Chat)
- Full 3-tier implementation
- Complex UI/UX (streaming, voice input, message actions)
- SQLite cache integration
- Riverpod state management

#### Thin Features (Patients, Appointments, Cases)
- Minimal 3-tier structure
- Simple list/detail screens
- API wrapper only (no local logic)
- Backend handles all business rules

---

## 🔗 Related Documents (Outside /mnesis)

### In `/documentation/technical/`
- `HTTP_Backend_Architecture_TECH.md` - Volan's HTTP implementation (reference)
- `DESIGN_SYSTEM.md` - Volan design system (for comparison)
- `architecture/` - Volan architecture docs

### In `/documentation/`
- `PROJECT_OVERVIEW_DIDACTIC.md` - General project overview
- `QUICK_START_DIDACTIC.md` - Volan quick start guide

### In Codebase
- `/lib/features/auth/` - Reference implementation (3-tier structure)
- `/lib/core/` - Shared infrastructure (DI, errors, utils)
- `/test/` - Testing patterns and helpers

---

## 🚀 Implementation Priorities

### Phase 1: Foundation (Week 1-2)
- [ ] Review all documentation
- [ ] Confirm backend API contract
- [ ] Setup SQLite schema
- [ ] Configure Mnesis theme/colors

### Phase 2: Chat Feature (Week 3-5)
- [ ] Implement chat data layer (HTTP + SSE + SQLite)
- [ ] Implement chat domain layer (use cases)
- [ ] Implement chat presentation layer (UI + Riverpod)
- [ ] Add voice input integration
- [ ] Write tests (80%+ coverage)

### Phase 3: Thin Features (Week 6-7)
- [ ] Implement patients feature (API wrapper)
- [ ] Implement appointments feature (API wrapper)
- [ ] Implement cases feature (API wrapper)
- [ ] Write tests

### Phase 4: Integration & Testing (Week 8)
- [ ] Integration testing
- [ ] E2E testing
- [ ] Performance optimization
- [ ] Documentation updates

---

## 📊 Success Metrics

### Technical
- ✅ 80%+ test coverage
- ✅ Clean Architecture compliance (3-tier separation)
- ✅ SSE streaming working reliably
- ✅ Zero main branch commits (feature branches only)
- ✅ All functions documented with Dart docs

### User Experience
- ✅ Chat response latency < 500ms (first token)
- ✅ Smooth streaming (no stuttering)
- ✅ Offline chat history accessible
- ✅ WCAG AA accessibility compliance

### Code Quality
- ✅ Zero compilation errors
- ✅ `flutter analyze` clean
- ✅ No AI references in code/commits
- ✅ Consistent code style

---

## ❓ FAQ

### Q: How is Mnesis different from Volan?
**A**: Volan is form-based with traditional navigation. Mnesis is chat-first with LLM-powered interactions. Both use Clean Architecture, but Mnesis has even less local storage (messages only vs session only).

### Q: Why minimal SQLite?
**A**: Backend LLM handles all business logic. Local storage only needed for offline chat history. Medical data requires server validation for security.

### Q: What's the backend team's responsibility?
**A**: Backend provides:
- REST API endpoints (patients, appointments, cases)
- SSE streaming for chat responses
- LLM integration (GPT-4/Claude)
- Business logic (scheduling rules, validation, etc.)

### Q: What's the Flutter team's responsibility?
**A**: Flutter provides:
- Rich chat UI/UX (streaming, voice, message actions)
- Thin API wrappers (patients, appointments, cases)
- Minimal SQLite cache (messages)
- Authentication (same as Volan)

### Q: How does offline mode work?
**A**: Users can read cached chat history. Sending new messages requires internet (like WhatsApp). No offline CRUD for patients/appointments.

### Q: What about data sync?
**A**: No sync needed. Messages are append-only from API. Patients/appointments fetched on-demand from backend.

---

## 🔄 Document Maintenance

### Update Schedule
- **Architecture docs**: Update when API contract changes
- **Design system**: Update when UI components added/changed
- **Roadmap**: Update weekly during development

### Version History
- **v2.0.0** (2026-01-16): Architecture revision (backend-heavy approach)
- **v1.0.0** (Initial): Original architecture (deprecated)

### Feedback
Questions or suggestions? Contact:
- **Architecture**: fft-architecture agent
- **Design**: fft-documentation agent
- **Project Management**: fft-project-manager agent

---

## 📝 Notes

### Critical Reminders
1. **Backend-heavy**: Don't build complex local logic. LLM handles it.
2. **Chat-first**: Chat is the primary interface, not forms.
3. **Minimal SQLite**: Only 2 tables (conversations + messages).
4. **Streaming**: SSE is critical for good UX.
5. **Test-driven**: Write tests before code (80%+ coverage).

### Common Pitfalls to Avoid
- ❌ Building offline-first sync (not needed)
- ❌ Complex local patient/appointment CRUD (backend handles it)
- ❌ Traditional form-based UI (use chat instead)
- ❌ Storing sensitive medical data locally (security risk)
- ❌ Hardcoding API responses (use streaming)

---

**Document Status**: ✅ Active
**Maintainer**: fft-architecture + fft-documentation
**Last Review**: 2026-01-16
**Next Review**: 2026-02-16

---

> 💡 **Remember**: Mnesis is NOT a traditional CRUD app. It's a conversational AI interface where users talk to an intelligent medical assistant. Keep the Flutter app simple and let the backend LLM do the heavy lifting.
