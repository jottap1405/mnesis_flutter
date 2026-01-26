# Mnesis Documentation Index

**Project**: Mnesis - AI Medical Assistant (MVP)
**Architecture**: Hybrid Preservation (Option Charlie)
**Last Updated**: 2026-01-23
**MVP Timeline**: 2 weeks (45-60 hours)

---

## 📚 Documentation Structure

This directory contains all architecture and design documentation for the Mnesis medical assistant MVP application.

---

## 🏗️ MVP Architecture Documents (CURRENT)

### 1. **ARCHITECTURE.md** ⭐ PRIMARY
**Status**: ✅ Active (MVP v3.0)
**Purpose**: MVP architecture overview and implementation guide

**Contents**:
- MVP scope (5+1 screens)
- Hybrid Preservation approach (Option Charlie)
- Navigation flow (Login → Home → PageView)
- State management strategy (Riverpod)
- Mock data strategy (patients, chat, attachments)
- Preserved infrastructure (design system, DI, tests)
- Removed features (Chat Secretaria, Agenda)
- Future roadmap (v1 backend integration)

**Read this first**: This is the authoritative MVP architecture document.

---

### 2. **MVP_DECISIONS.md** ⭐ DECISION RECORD
**Status**: ✅ Active
**Purpose**: Architecture decision rationale and analysis

**Contents**:
- MVP scope definition (what's in/out)
- Three-option analysis (Alpha, Bravo, Charlie)
- Option Charlie selection rationale (Hybrid Preservation)
- Auth design pending status
- Mock data strategy
- Backend deferral rationale
- Implementation timeline (2 weeks)
- Risk assessment

**Read this for**: Understanding WHY decisions were made.

---

### 3. **IMPLEMENTATION_PLAN.md** ⭐ EXECUTION PLAN
**Status**: ✅ Active
**Purpose**: Week-by-week implementation breakdown

**Contents**:
- Week 1: Infrastructure + Auth + Navigation (20-25h)
- Week 2: Screens + Integration (25-35h)
- Testing requirements (80%+ coverage)
- Quality gates
- Daily task breakdown
- Success criteria

**Read this for**: Step-by-step implementation guide.

---

## 🎨 Design Documents

### 4. **MNESIS_DESIGN_SYSTEM.md**
**Status**: ✅ Active (Grade A - 94/100)
**Purpose**: Complete design system specification

**Contents**:
- Design philosophy (dark-first, orange primary)
- Color palette (WCAG AA/AAA compliant)
- Typography (Inter font, type scale)
- Spacing system (4px base unit)
- Component library (buttons, inputs, chat bubbles)
- Material 3 theme configuration
- Accessibility standards (138 tests)
- Visual testing guide

**Read this for**: All design/UI implementation details.

---

## 📅 Legacy Documents (Pre-MVP - Reference Only)

### 5. **MNESIS_ARCHITECTURE_REVISED.md**
**Status**: ⚠️ Superseded by ARCHITECTURE.md
**Purpose**: Original backend-heavy architecture (6-week scope)

**Note**: This was the pre-MVP architecture assuming full backend integration. Replaced by MVP approach (Option Charlie) due to 2-week timeline constraint.

**Keep for reference**: Backend API contract definitions useful for v1 integration.

---

### 6. **MNESIS_ROADMAP_REVISED.md**
**Status**: ⚠️ Superseded by IMPLEMENTATION_PLAN.md
**Purpose**: Original 6-week development roadmap

**Note**: This roadmap assumed backend-first approach with extensive features. Replaced by MVP 2-week plan focusing on 5+1 screens with mock data.

**Keep for reference**: Epic breakdown useful for v1 planning.

---

### 7. **ARCHITECTURE_REVISION_SUMMARY.md**
**Status**: ⚠️ Legacy (Pre-MVP)
**Purpose**: Quick reference for original architecture changes

**Note**: This document explained the shift from offline-first to backend-heavy architecture. Now superseded by MVP_DECISIONS.md which explains the MVP scope reduction and Option Charlie approach.

**Keep for reference**: Historical context of architectural evolution.

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

## 🎯 Quick Start Guide (MVP)

### For Architects
1. Read `MVP_DECISIONS.md` (10 min) - Understand WHY Option Charlie was chosen
2. Read `ARCHITECTURE.md` (15 min) - MVP architecture overview
3. Review Navigation Flow and State Management sections
4. Check preserved infrastructure (design system, DI, tests)

### For Frontend Developers (START HERE!)
1. **Read `MVP_DECISIONS.md`** (10 min) - Context on scope and decisions
2. **Read `IMPLEMENTATION_PLAN.md`** (15 min) - Week-by-week tasks
3. **Read `ARCHITECTURE.md`** → MVP Scope section (10 min)
4. **Read `MNESIS_DESIGN_SYSTEM.md`** (10 min) - Use existing components
5. **Start coding**: Week 1 Day 1 tasks (refactoring)

### For Designers
1. Read `MNESIS_DESIGN_SYSTEM.md` (10 min)
2. **Note**: Login screen design pending - provide ASAP
3. Review 5+1 MVP screens (HomeScreen.png, ChatAssistentScreen.png, etc.)
4. Validate existing components (MnesisButton, MnesisInput) work for MVP

### For Project Managers
1. **Read `MVP_DECISIONS.md`** (10 min) - Full context
2. **Read `IMPLEMENTATION_PLAN.md`** (10 min) - Timeline and milestones
3. Track progress against 2-week sprint:
   - Week 1: Infrastructure complete?
   - Week 2: All 6 screens implemented?
4. Monitor quality gates (80% test coverage, flutter analyze clean)

---

## 📋 Key Concepts (MVP Quick Reference)

### MVP Architecture Principles
1. **Hybrid Preservation**: Keep Grade A design system (94/100), 1,165 tests, DI infrastructure
2. **Mock Data First**: Frontend unblocked with hardcoded patients, chat, attachments
3. **Simplified Navigation**: Login → Home → PageView (Chat ↔ Resumo ↔ Anexos)
4. **Backend Deferred**: Real API integration moved to v1 (post-MVP)
5. **2-Week Sprint**: 45-60 hours total effort

### MVP Technology Stack
- **Frontend**: Flutter 3.35.5 + Riverpod + Clean Architecture
- **Backend (MVP)**: Mock data providers (no real API yet)
- **Backend (v1+)**: Supabase + LLM integration (deferred)
- **Navigation**: go_router (simplified routes)
- **Local Storage**: SQLite (conversations + messages tables only)
- **Authentication**: Supabase Auth (placeholder UI)
- **Testing**: 80%+ coverage maintained (1,165+ tests)

### MVP Scope (5+1 Screens)
1. **Login** - Placeholder UI (design pending), Supabase auth
2. **Home** - Patient list + search + stats (mock data)
3. **Chat Assistente** - AI chat per patient (mock streaming)
4. **Resumo Paciente** - Patient summary (mock data)
5. **Anexos** - Attachment list (mock data)
6. **Visualização Anexo** - PDF/image viewer (asset files)

### Removed from MVP (Post-MVP v1)
- ❌ Chat Secretaria (doctor ↔ secretary chat)
- ❌ Agenda (calendar view)
- ❌ Horizontal scroll navigation
- ❌ appointments_cache table
- ❌ Real backend integration
- ❌ Voice input (button placeholder only)

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

## 🚀 MVP Implementation Priorities (2-Week Sprint)

### Week 1: Infrastructure + Auth + Navigation (20-25h)
- [ ] **Day 1-2**: Refactoring (8h)
  - Remove Chat Secretaria code
  - Remove Agenda widgets
  - Remove appointments_cache table
  - Simplify navigation structure
- [ ] **Day 3**: Authentication (6h)
  - Placeholder login screen
  - Supabase auth integration
  - Session management
- [ ] **Day 4**: Mock Data Setup (4h)
  - Mock patients (10-15 profiles)
  - Mock chat responses (context-aware)
  - Mock attachments (PDFs, images)
- [ ] **Day 5**: Navigation (4h)
  - go_router configuration
  - PageView implementation (Chat ↔ Resumo ↔ Anexos)

### Week 2: Screens + Integration (25-35h)
- [ ] **Day 6**: Home Screen (6h)
  - Patient list with search
  - Stats cards
  - Navigation to Chat
- [ ] **Day 7-8**: Chat Assistente (8h)
  - Message list with auto-scroll
  - Input area (text + voice placeholder)
  - Mock streaming integration
- [ ] **Day 9**: Resumo + Anexos (8h)
  - Patient summary screen
  - Attachment list screen
- [ ] **Day 10**: Attachment Viewer (4h)
  - PDF viewer (flutter_pdfview)
  - Image viewer (pinch to zoom)
- [ ] **Day 11**: Integration + Polish (4h)
  - End-to-end testing
  - Bug fixes
  - Documentation updates

---

## 📊 MVP Success Metrics

### Functional Requirements (Must Have)
- ✅ User can log in (placeholder UI, functional auth)
- ✅ User can search/view patient list (mock data)
- ✅ User can navigate to Chat per patient
- ✅ User can send messages, see mock AI responses
- ✅ User can swipe between Chat/Resumo/Anexos
- ✅ User can view patient summary
- ✅ User can see attachment list
- ✅ User can view PDF/image attachments

### Technical Quality (Must Have)
- ✅ 80%+ test coverage maintained (1,165+ tests)
- ✅ Clean Architecture compliance (3-tier separation)
- ✅ Zero critical bugs
- ✅ `flutter analyze` clean (zero issues)
- ✅ All functions documented with Dart docs
- ✅ No AI references in code/commits (FlowForge Rule #33)

### User Experience (Must Have)
- ✅ Smooth navigation (60 FPS)
- ✅ Mock chat streaming feels real-time
- ✅ PageView swipe gestures responsive
- ✅ WCAG AA accessibility compliance (preserved)

### Documentation (Must Have)
- ✅ MVP_DECISIONS.md complete
- ✅ IMPLEMENTATION_PLAN.md complete
- ✅ ARCHITECTURE.md updated
- ✅ README.md updated
- ✅ INDEX.md updated (this doc)

---

## ❓ MVP FAQ

### Q: Why Option Charlie (Hybrid Preservation)?
**A**: Balances quality preservation (Grade A design system, 1,165 tests) with MVP speed (2 weeks). Removes unused features but keeps proven infrastructure. Best ROI.

### Q: Why mock data instead of real backend?
**A**:
1. Backend API contracts not finalized yet
2. Frontend can progress independently
3. Functional demo for stakeholders
4. Easy to swap providers later (4-6h per feature)

### Q: What happens to Chat Secretaria and Agenda?
**A**: Moved to v1 (post-MVP). Code removed to reduce complexity. Can be restored in ~39 hours if needed. Not essential for MVP validation.

### Q: Why is Login design pending?
**A**: Design team hasn't provided final mockup yet. Placeholder implementation uses existing Mnesis components (MnesisInput, MnesisButton). Replacement takes ~2-3 hours once design arrives.

### Q: How do we transition to real backend (v1)?
**A**: Replace mock providers with real API clients. Environment flag toggles between mock and real:
```dart
final chatDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  if (EnvConfig.useMockData) {
    return MockChatDataSource();
  }
  return ChatRemoteDataSourceImpl(/* real API */);
});
```
**Effort**: ~30 hours total for v1 integration.

### Q: Will tests break during refactoring?
**A**: Some tests for removed features will need deletion/updating (~2-3h). Core design system tests (138 accessibility tests) remain intact. Overall coverage stays 80%+.

### Q: What's preserved vs. removed?
**Preserved** (Grade A quality):
- Design system (MnesisColors, TextStyles, Spacings, Theme)
- 1,165 passing tests (80%+ coverage)
- DI infrastructure (get_it + injectable)
- SQLite foundation (drift)
- Environment configuration

**Removed** (MVP scope reduction):
- Chat Secretaria feature
- Agenda widgets
- appointments_cache table
- Horizontal scroll navigation
- Complex backend integrations

---

## 🔄 Document Maintenance

### Update Schedule
- **MVP docs**: Update daily during 2-week sprint
- **Architecture**: Update when scope or decisions change
- **Design system**: Stable (no MVP changes planned)
- **Implementation plan**: Update weekly progress

### Version History
- **v3.0.0** (2026-01-23): MVP revision (Option Charlie, 2-week sprint)
- **v2.0.0** (2026-01-16): Architecture revision (backend-heavy approach)
- **v1.0.0** (Initial): Original architecture (deprecated)

### Feedback & Questions
Contact FlowForge agents:
- **MVP Decisions**: fft-documentation agent
- **Implementation**: fft-mobile or fft-frontend agent
- **Design**: fft-documentation agent
- **Architecture**: fft-architecture agent

---

## 📝 MVP Notes

### Critical Reminders (FlowForge Rules)
1. **Rule #21**: NO SHORTCUTS - Solve problems completely and correctly
2. **Rule #13**: Living Documentation - Update IMMEDIATELY after changes
3. **Rule #3**: TDD - Write tests BEFORE code (80%+ coverage)
4. **Rule #24**: File Size Limit - Non-test files < 700 lines
5. **Rule #33**: NO AI REFERENCES - Career-ending violation!

### MVP-Specific Reminders
1. **Mock Data First**: Don't build real API integration yet (v1)
2. **Preserve Quality**: Keep Grade A design system (94/100)
3. **Simplified Navigation**: Login → Home → PageView (no complex routing)
4. **Placeholder Login**: Design pending, use existing components
5. **2-Week Sprint**: 45-60 hours total, strict timeline

### Common Pitfalls to Avoid
- ❌ Building real backend integration (deferred to v1)
- ❌ Modifying design system (already Grade A, preserve)
- ❌ Complex authentication UI (placeholder until design arrives)
- ❌ Adding features beyond 5+1 screens (scope creep)
- ❌ Skipping refactoring (Week 1 Day 1-2 critical)
- ❌ Breaking existing tests (maintain 80%+ coverage)

---

**Document Status**: ✅ Active (MVP Development)
**Maintainer**: fft-documentation agent
**Last Update**: 2026-01-23
**Next Review**: End of Week 1 (check progress against plan)

---

> 💡 **MVP Philosophy**: Hybrid Preservation (Option Charlie) - Keep what works (design system, tests, DI), remove what's not needed (Chat Secretaria, Agenda), add MVP screens with mock data. Quality + Speed = 2-week success.
