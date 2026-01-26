# Mnesis MVP Planning Report
**Option Charlie: Hybrid Preservation Strategy**
**Generated:** 2026-01-23
**Milestone:** v1.0.0 - MVP Release

---

## Executive Summary

### Project Status
- **Current State:** Design System Complete (Grade A - 94/100)
- **Test Coverage:** 86.8% (1,165 passing tests)
- **Preserved Assets:** Core design system, DI infrastructure, environment config, SQLite foundation
- **Decision:** Option Charlie (Hybrid Preservation) - Build MVP on solid foundation

### MVP Scope
**5 Screens + Authentication:**
1. Login/Auth (Supabase - placeholder design)
2. Home (Patient lists, stats, search)
3. Chat Assistente (MOCKED AI responses)
4. Resumo Paciente (Patient summary/demographics)
5. Anexos (Attachment list)
6. Visualização Anexo (PDF/image viewer)

### Timeline
- **Total Duration:** 2 weeks (10 working days)
- **Total Effort:** 100 hours
- **Week 1 Focus:** Auth, caching, navigation foundation (43 hours)
- **Week 2 Focus:** UI screens, mock data, testing, polish (57 hours)

---

## Task Breakdown Summary

### Total Tasks Created: 25
- **Completed:** 1 (MNESIS-057 - Test coverage achievement)
- **Backlog:** 24 new MVP tasks

### Tasks by Epic
| Epic | Count | Hours | Priority |
|------|-------|-------|----------|
| mvp-auth | 3 | 16 | Critical |
| mvp-cache | 3 | 14 | High |
| mvp-navigation | 2 | 11 | Critical |
| mvp-state | 1 | 3 | High |
| mvp-screens | 5 | 24 | Critical/High |
| mvp-mock-data | 3 | 8 | High/Medium |
| mvp-testing | 3 | 12 | High |
| mvp-polish | 4 | 12 | High/Medium |

### Tasks by Size
- **XS:** 0 tasks
- **S:** 7 tasks (21 hours)
- **M:** 13 tasks (52 hours)
- **L:** 4 tasks (24 hours)
- **XL:** 0 tasks
- **XXL:** 0 tasks (✅ No tasks need breakdown)

### Tasks by Priority
- **Critical:** 9 tasks (49 hours)
- **High:** 11 tasks (39 hours)
- **Medium:** 4 tasks (12 hours)

---

## Week 1: Foundation (43 hours)

### Epic 1: Authentication (16 hours)
**MNESIS-058** (L - 6h) - Supabase authentication setup
- Dependencies: None
- Blocks: MNESIS-059, MNESIS-061
- Critical path task

**MNESIS-059** (M - 4h) - Login screen UI
- Dependencies: MNESIS-058
- Blocks: MNESIS-060
- Uses Mnesis design system

**MNESIS-060** (L - 6h) - Auth flow & session management
- Dependencies: MNESIS-058, MNESIS-059
- Blocks: MNESIS-064, MNESIS-075
- Critical path task

### Epic 2: Cache Layer (14 hours)
**MNESIS-061** (M - 4h) - SQLite cache layer foundation
- Dependencies: MNESIS-058
- Blocks: MNESIS-062, MNESIS-063
- Core infrastructure

**MNESIS-062** (M - 5h) - Patients cache table & repository
- Dependencies: MNESIS-061
- Blocks: MNESIS-066, MNESIS-067, MNESIS-072
- Critical for all patient features

**MNESIS-063** (M - 5h) - Attachments cache table & repository
- Dependencies: MNESIS-061
- Blocks: MNESIS-070, MNESIS-073
- Critical for attachments feature

### Epic 3: Navigation (11 hours)
**MNESIS-064** (L - 6h) - Navigation refactor (Login → Home → Chat)
- Dependencies: MNESIS-060
- Blocks: MNESIS-065, MNESIS-067, MNESIS-076
- Major architectural change

**MNESIS-065** (M - 5h) - PageView for Chat ↔ Resumo ↔ Anexos
- Dependencies: MNESIS-064
- Blocks: MNESIS-068, MNESIS-069, MNESIS-070
- Core navigation pattern

### Epic 4: State Management (3 hours)
**MNESIS-066** (S - 3h) - Patient context provider (Riverpod)
- Dependencies: MNESIS-062
- Blocks: MNESIS-068, MNESIS-069, MNESIS-070
- Shared state across screens

**Week 1 Total:** 43 hours (6 tasks)

---

## Week 2: Screens, Data & Polish (57 hours)

### Epic 5: Screen Development (24 hours)
**MNESIS-067** (M - 5h) - Home screen - Patient list UI
- Dependencies: MNESIS-062, MNESIS-064
- Blocks: MNESIS-077
- First user-facing screen

**MNESIS-068** (L - 6h) - Chat Assistente screen UI
- Dependencies: MNESIS-065, MNESIS-066
- Blocks: MNESIS-074, MNESIS-077
- Core feature screen

**MNESIS-069** (M - 4h) - Resumo Paciente screen
- Dependencies: MNESIS-065, MNESIS-066
- No blocking tasks

**MNESIS-070** (M - 4h) - Anexos screen (attachment list)
- Dependencies: MNESIS-063, MNESIS-065, MNESIS-066
- Blocks: MNESIS-071

**MNESIS-071** (M - 5h) - Visualização de Anexo (PDF viewer)
- Dependencies: MNESIS-070
- No blocking tasks

### Epic 6: Mock Data (8 hours)
**MNESIS-072** (S - 3h) - Mock data service for patients
- Dependencies: MNESIS-062
- Blocks: MNESIS-073
- Realistic test data

**MNESIS-073** (S - 3h) - Mock data service for attachments
- Dependencies: MNESIS-063, MNESIS-072
- No blocking tasks

**MNESIS-074** (S - 2h) - Mock chat response service
- Dependencies: MNESIS-068
- No blocking tasks

### Epic 7: Integration Testing (12 hours)
**MNESIS-075** (M - 4h) - Integration test - Auth flow
- Dependencies: MNESIS-060
- No blocking tasks

**MNESIS-076** (M - 4h) - Integration test - Navigation flow
- Dependencies: MNESIS-064, MNESIS-065
- No blocking tasks

**MNESIS-077** (M - 4h) - Integration test - Patient & chat
- Dependencies: MNESIS-067, MNESIS-068
- Blocks: MNESIS-078

### Epic 8: Polish & Delivery (12 hours)
**MNESIS-078** (M - 4h) - Code review & refactoring
- Dependencies: MNESIS-077
- Blocks: MNESIS-079, MNESIS-080
- Quality assurance

**MNESIS-079** (M - 3h) - Performance optimization
- Dependencies: MNESIS-078
- No blocking tasks

**MNESIS-080** (S - 3h) - Documentation finalization
- Dependencies: MNESIS-078
- Blocks: MNESIS-081

**MNESIS-081** (S - 2h) - MVP demo preparation
- Dependencies: MNESIS-080
- Final deliverable

**Week 2 Total:** 57 hours (18 tasks)

---

## Critical Path Analysis

### Must-Complete Sequence (Critical Path)
```
MNESIS-058 (Supabase auth) →
MNESIS-059 (Login UI) →
MNESIS-060 (Auth flow) →
MNESIS-064 (Navigation refactor) →
MNESIS-065 (PageView) →
MNESIS-068 (Chat screen) →
MNESIS-077 (Integration test) →
MNESIS-078 (Code review) →
MNESIS-080 (Docs) →
MNESIS-081 (Demo prep)
```

**Critical Path Duration:** ~49 hours (5 days if single-threaded)

### Parallel Work Opportunities
**Week 1 Parallel Tracks:**
- Track A: Auth (058 → 059 → 060)
- Track B: Cache (061 → 062 → 063) - Can start with 058
- Track C: State (066) - Can start after 062

**Week 2 Parallel Tracks:**
- Track A: Screens (067, 069, 070, 071) - Can work in parallel after 064-066
- Track B: Mock Data (072, 073, 074) - Can start early
- Track C: Testing (075, 076, 077) - Can start as features complete

---

## Dependency Map

### Foundation Layer (Week 1)
```
MNESIS-058 (Supabase Auth) ──┬──> MNESIS-059 (Login UI) ──> MNESIS-060 (Auth Flow)
                              │
                              └──> MNESIS-061 (SQLite Foundation)
                                        │
                                        ├──> MNESIS-062 (Patients Cache) ──> MNESIS-066 (Patient Context)
                                        │
                                        └──> MNESIS-063 (Attachments Cache)
```

### Navigation Layer (Week 1)
```
MNESIS-060 (Auth Flow) ──> MNESIS-064 (Navigation Refactor) ──> MNESIS-065 (PageView)
```

### Screen Layer (Week 2)
```
                            ┌──> MNESIS-067 (Home Screen)
MNESIS-062 + MNESIS-064 ───┤
                            │   ┌──> MNESIS-068 (Chat Screen)
MNESIS-065 + MNESIS-066 ───┼───┼──> MNESIS-069 (Resumo Screen)
                            │   └──> MNESIS-070 (Anexos Screen) ──> MNESIS-071 (PDF Viewer)
                            │
MNESIS-063 ─────────────────┘
```

### Testing & Polish Layer (Week 2)
```
MNESIS-060 ──> MNESIS-075 (Auth Tests)
MNESIS-064 + MNESIS-065 ──> MNESIS-076 (Navigation Tests)
MNESIS-067 + MNESIS-068 ──> MNESIS-077 (Chat Tests) ──> MNESIS-078 (Code Review)
                                                              │
                                                              ├──> MNESIS-079 (Performance)
                                                              │
                                                              └──> MNESIS-080 (Docs) ──> MNESIS-081 (Demo)
```

---

## Recommended Starting Points

### Option 1: Sequential Start (Single Developer)
**Start with:** MNESIS-058 (Supabase authentication setup)
- Most critical foundation piece
- Blocks most other work
- 6-hour task to establish authentication

**Command:**
```bash
./run_ff_command.sh flowforge:session:start 58
```

### Option 2: Parallel Start (Multiple Developers)
**Developer 1:** MNESIS-058 (Auth) → MNESIS-059 → MNESIS-060
**Developer 2:** MNESIS-061 (SQLite) → MNESIS-062 → MNESIS-063
**Developer 3:** Design review & mock data preparation

### Option 3: Risk-First Start
**Start with:** MNESIS-058 + MNESIS-064 (Auth + Navigation)
- Highest risk/complexity items
- Validate architectural decisions early
- Better risk mitigation

---

## Risk Assessment

### High-Risk Items
| Task | Risk Level | Mitigation |
|------|-----------|------------|
| MNESIS-064 (Navigation Refactor) | HIGH | Keep old code commented, can rollback |
| MNESIS-060 (Auth Flow) | MEDIUM | Use proven Supabase patterns |
| MNESIS-071 (PDF Viewer) | MEDIUM | Multiple library options available |
| MNESIS-065 (PageView) | LOW | Standard Flutter widget |

### Technical Debt Decisions
1. **Bottom Navigation:** Code preserved but disabled (easy to re-enable)
2. **AI Chat:** Mocked responses (backend decision deferred)
3. **Auth Design:** Placeholder (designer input pending)
4. **Real Backend:** All APIs mocked (migration path clear)

---

## Label Distribution

### FlowForge Standard Labels Applied
All tasks include 4 required labels:
- **Status:** All start as `status:backlog`
- **Priority:** 9 critical, 11 high, 4 medium
- **Type:** feature, ui, database, testing, documentation, chore
- **Size:** S (7), M (13), L (4)

### Milestone
All tasks assigned to: **v1.0.0 - MVP Release**

---

## Testing Strategy

### Unit Testing (Continuous)
- Every task includes unit test acceptance criteria
- Target: 80%+ coverage (FlowForge Rule #3)
- Current coverage: 86.8% (design system)

### Integration Testing (Week 2)
- MNESIS-075: Auth flow end-to-end
- MNESIS-076: Navigation flow end-to-end
- MNESIS-077: Patient & chat flow end-to-end

### Manual Testing (Week 2)
- MNESIS-081: Demo preparation includes thorough manual testing
- Test on both iOS and Android

---

## What's Preserved (Grade A Foundation)

### ✅ Keeping (Zero Changes Needed)
```
lib/core/design_system/       # All design tokens, themes, components
lib/core/di/                  # Dependency injection setup
lib/core/config/              # Environment configuration
lib/core/database/            # SQLite foundation (to be extended)
test/core/                    # All 1,165 passing tests
```

### 🔄 Refactoring (Preserved but Modified)
```
lib/core/router/              # Remove ShellRoute, simplify for MVP
lib/features/shell/           # Comment out, preserve for future
```

### ➕ Building New
```
lib/features/auth/            # Supabase authentication
lib/features/home/            # New home screen
lib/features/patients/        # Patient management + cache
lib/features/chat/            # Chat with mock responses
lib/features/attachments/     # Attachment management + cache
lib/core/mocks/               # Mock data services
```

---

## Success Metrics

### Functional Completeness
- [ ] Login/logout works with Supabase
- [ ] Home screen shows 20+ mock patients
- [ ] Chat responds with mock AI answers
- [ ] PageView navigation works smoothly
- [ ] PDF viewer displays documents
- [ ] All 5 screens functional

### Quality Metrics
- [ ] 80%+ test coverage maintained
- [ ] Zero flutter analyze issues
- [ ] 60 FPS on mid-range devices
- [ ] App size < 30 MB
- [ ] All files < 700 lines

### Delivery Metrics
- [ ] 25 tasks completed in 2 weeks
- [ ] 100 hours of tracked work
- [ ] Demo-ready on iOS and Android
- [ ] Documentation complete

---

## Next Steps

### Immediate Actions
1. **Review this plan** with stakeholders
2. **Confirm Supabase account** is ready
3. **Decide on starting strategy** (sequential vs parallel)
4. **Start session** with first task

### Recommended First Session
```bash
# Start with authentication foundation
./run_ff_command.sh flowforge:session:start 58
```

### Daily Cadence (Recommended)
**Week 1 Daily Goals:**
- Day 1: MNESIS-058 (Supabase setup)
- Day 2: MNESIS-059 + MNESIS-061 (Login UI + SQLite foundation)
- Day 3: MNESIS-060 (Auth flow)
- Day 4: MNESIS-062 + MNESIS-063 (Cache tables)
- Day 5: MNESIS-064 (Navigation refactor)

**Week 2 Daily Goals:**
- Day 6: MNESIS-065 + MNESIS-066 (PageView + Patient context)
- Day 7: MNESIS-067 + MNESIS-072 (Home screen + mock patients)
- Day 8: MNESIS-068 + MNESIS-074 (Chat screen + mock responses)
- Day 9: MNESIS-069 + MNESIS-070 + MNESIS-071 (All remaining screens)
- Day 10: MNESIS-075-081 (Testing + Polish + Demo prep)

---

## FlowForge Compliance Checklist

- [x] **Rule #5:** All tasks have GitHub issue numbers
- [x] **Rule #3:** 80%+ test coverage required in acceptance criteria
- [x] **Rule #21:** No shortcuts - proper solutions planned
- [x] **Rule #24:** All files will be < 700 lines
- [x] **Rule #26:** Function documentation required
- [x] **Rule #33:** NO AI references in any output
- [x] **Rule #38:** Task mirroring will happen (JSON + GitHub)
- [x] **Labels:** All tasks have 4 required labels (status, priority, type, size)

---

## Communication Plan

### Stakeholder Updates
- **Daily:** Session end summaries via `flowforge:session:end`
- **Weekly:** Progress report (end of Week 1)
- **Final:** Demo presentation (end of Week 2)

### Documentation Updates
- **Continuous:** Code documentation (Dart docs)
- **End of Week 1:** Architecture docs update
- **End of Week 2:** Complete documentation package

### Code Review
- **Task 78:** Comprehensive code review using `fft-code-reviewer`
- **Continuous:** Self-review during development

---

**Report Generated by:** fft-project-manager
**FlowForge Version:** 2.0.0
**Methodology:** Option Charlie (Hybrid Preservation)
**Confidence Level:** HIGH (building on Grade A foundation)

✅ Ready for execution. Awaiting session start command.
