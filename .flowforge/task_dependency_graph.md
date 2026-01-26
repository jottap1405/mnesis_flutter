# Mnesis MVP Task Dependency Graph
**Visual representation of task dependencies and execution flow**

---

## Critical Path (Sequential - Must Follow Order)

```
START
  │
  ├─> [058] Supabase Auth Setup (6h) ─────────────────────┐
  │                                                         │
  │                                                         v
  ├─> [059] Login UI (4h) ─────────────────────────────> [060] Auth Flow (6h)
  │                                                         │
  │                                                         v
  │                                              [064] Navigation Refactor (6h)
  │                                                         │
  │                                                         v
  │                                              [065] PageView Setup (5h)
  │                                                         │
  │                                                         v
  │                                              [068] Chat Screen (6h)
  │                                                         │
  │                                                         v
  │                                              [077] Integration Tests (4h)
  │                                                         │
  │                                                         v
  │                                              [078] Code Review (4h)
  │                                                         │
  │                                                         v
  │                                              [080] Documentation (3h)
  │                                                         │
  │                                                         v
  └───────────────────────────────────────────> [081] Demo Prep (2h)
                                                            │
                                                            v
                                                          END
```

**Critical Path Total: ~49 hours**

---

## Complete Dependency Tree

### Week 1: Foundation Layer

```
┌────────────────────────────────────────────────────────────────┐
│                         WEEK 1 START                           │
└────────────────────────────────────────────────────────────────┘

                    [058] Supabase Auth Setup (6h)
                              │
                              ├─────────────┬──────────────┐
                              │             │              │
                              v             v              v
                    [059] Login UI    [061] SQLite   (to Week 2)
                         (4h)         Foundation
                              │            (4h)
                              │             │
                              v             ├──────────────┬────────────────┐
                    [060] Auth Flow         │              │                │
                         (6h)               v              v                v
                              │      [062] Patients   [063] Attachments  (parallel)
                              │        Cache (5h)      Cache (5h)
                              │             │              │
                              v             v              v
                    [064] Navigation   [066] Patient   (to Week 2)
                       Refactor (6h)   Context (3h)
                              │             │
                              └─────┬───────┘
                                    v
                          [065] PageView Setup (5h)
                                    │
                                    v
┌────────────────────────────────────────────────────────────────┐
│                          WEEK 1 END                            │
│          Deliverable: Auth + Cache + Navigation Ready          │
└────────────────────────────────────────────────────────────────┘
```

### Week 2: Screens & Polish Layer

```
┌────────────────────────────────────────────────────────────────┐
│                         WEEK 2 START                           │
└────────────────────────────────────────────────────────────────┘

         [062] + [064]            [065] + [066]         [063] + [065] + [066]
              │                         │                        │
              v                         │                        │
    [067] Home Screen (5h)              │                        │
              │                         │                        │
              v                         v                        v
    [072] Mock Patients (3h)  [068] Chat Screen (6h)  [070] Anexos Screen (4h)
              │                         │                        │
              v                         v                        v
    [073] Mock Attachments  [074] Mock Chat (2h)     [071] PDF Viewer (5h)
              (3h)                      │                        │
                                        v                        │
                              [069] Resumo Screen (4h)           │
                                        │                        │
                                        └────────┬───────────────┘
                                                 │
                    ┌────────────────────────────┼────────────────────────────┐
                    │                            │                            │
                    v                            v                            v
        [075] Auth Tests (4h)     [076] Navigation Tests (4h)   [077] Chat Tests (4h)
                    │                            │                            │
                    └────────────────────────────┼────────────────────────────┘
                                                 │
                                                 v
                                      [078] Code Review (4h)
                                                 │
                                    ┌────────────┴────────────┐
                                    │                         │
                                    v                         v
                    [079] Performance (3h)      [080] Documentation (3h)
                                                              │
                                                              v
                                                  [081] Demo Prep (2h)
                                                              │
                                                              v
┌────────────────────────────────────────────────────────────────┐
│                          WEEK 2 END                            │
│                    Deliverable: MVP Complete                   │
└────────────────────────────────────────────────────────────────┘
```

---

## Parallel Execution Opportunities

### Week 1 Parallel Tracks (Up to 3 simultaneous)

**Track A: Authentication (Critical Path)**
```
[058] → [059] → [060] → [064]
 6h      4h      6h      6h
Total: 22 hours
```

**Track B: Cache Layer (Can run parallel with Track A after 058)**
```
[061] → [062] → [066]
 4h      5h      3h
         └────> [063]
                 5h
Total: 17 hours
```

**Track C: Preparation (Can run anytime)**
- Design review
- Mock data planning
- Test strategy
- Documentation structure

### Week 2 Parallel Tracks (Up to 5 simultaneous)

**Track A: Home Screen**
```
[067] → [072]
 5h      3h
Total: 8 hours
```

**Track B: Chat Screen**
```
[068] → [074]
 6h      2h
Total: 8 hours
```

**Track C: Patient Details**
```
[069]
 4h
Total: 4 hours
```

**Track D: Attachments**
```
[070] → [071]
 4h      5h
Total: 9 hours
```

**Track E: Testing (After screens complete)**
```
[075] ┐
 4h   ├─> [078] → [079] ┐
[076] │    4h      3h   ├─> [081]
 4h   ├───────────────> │     2h
[077] │           [080] │
 4h   └────────────> 3h ┘
Total: 24 hours
```

---

## Blocking Relationships

### Tasks That Block Multiple Others (High Impact)

**MNESIS-058** (Supabase Auth) blocks:
- MNESIS-059 (Login UI)
- MNESIS-061 (SQLite Foundation)

**MNESIS-060** (Auth Flow) blocks:
- MNESIS-064 (Navigation Refactor)
- MNESIS-075 (Auth Tests)

**MNESIS-061** (SQLite Foundation) blocks:
- MNESIS-062 (Patients Cache)
- MNESIS-063 (Attachments Cache)

**MNESIS-064** (Navigation Refactor) blocks:
- MNESIS-065 (PageView)
- MNESIS-067 (Home Screen)
- MNESIS-076 (Navigation Tests)

**MNESIS-065** (PageView) blocks:
- MNESIS-068 (Chat Screen)
- MNESIS-069 (Resumo Screen)
- MNESIS-070 (Anexos Screen)

**MNESIS-066** (Patient Context) blocks:
- MNESIS-068 (Chat Screen)
- MNESIS-069 (Resumo Screen)
- MNESIS-070 (Anexos Screen)

### Tasks Blocked By Multiple Dependencies

**MNESIS-068** (Chat Screen) requires:
- MNESIS-065 (PageView)
- MNESIS-066 (Patient Context)

**MNESIS-069** (Resumo Screen) requires:
- MNESIS-065 (PageView)
- MNESIS-066 (Patient Context)

**MNESIS-070** (Anexos Screen) requires:
- MNESIS-063 (Attachments Cache)
- MNESIS-065 (PageView)
- MNESIS-066 (Patient Context)

**MNESIS-077** (Chat Tests) requires:
- MNESIS-067 (Home Screen)
- MNESIS-068 (Chat Screen)

---

## Resource Allocation Strategy

### Single Developer (10 days)
**Daily Plan:**
- **Day 1:** 058 (6h) - Setup day
- **Day 2:** 059 (4h) + 061 (4h) - Auth UI + DB foundation
- **Day 3:** 060 (6h) - Auth flow completion
- **Day 4:** 062 (5h) + 063 (5h) - Cache layer (split across day)
- **Day 5:** 064 (6h) - Navigation refactor
- **Day 6:** 065 (5h) + 066 (3h) - PageView + state
- **Day 7:** 067 (5h) + 072 (3h) - Home + mock data
- **Day 8:** 068 (6h) + 074 (2h) - Chat + mock responses
- **Day 9:** 069 (4h) + 070 (4h) - Remaining screens
- **Day 10:** 071 (5h) + 075-081 (phased) - Polish & testing

### Two Developers (5 days each)
**Dev 1: Critical Path**
- Days 1-2: 058 → 059 → 060 (16h)
- Days 3-4: 064 → 065 (11h)
- Day 5: 068 → 077 → 078 (14h)

**Dev 2: Support Path**
- Days 1-2: 061 → 062 → 063 (14h)
- Day 3: 066 → 072 → 073 (9h)
- Days 4-5: 067 → 069 → 070 → 071 → 074 (22h)

**Testing/Polish: Both collaborate**
- Days 5-6: 075 → 076 → 079 → 080 → 081

### Three Developers (3-4 days each)
**Dev 1: Auth & Navigation**
- 058 → 059 → 060 → 064 → 065 (27h)

**Dev 2: Data Layer**
- 061 → 062 → 063 → 066 → 072 → 073 (23h)

**Dev 3: UI Screens**
- 067 → 068 → 069 → 070 → 071 → 074 (28h)

**Testing Phase: All collaborate**
- 075 → 076 → 077 → 078 → 079 → 080 → 081 (26h)

---

## Risk Mitigation by Dependency

### Early Risk Resolution
Complete high-risk tasks early in their dependency chain:

**Week 1 Risks:**
- MNESIS-058: Supabase setup issues (Day 1)
- MNESIS-064: Navigation refactor complexity (Day 5)
- MNESIS-061: SQLite initialization (Day 2)

**Week 2 Risks:**
- MNESIS-068: Chat UI complexity (Day 8)
- MNESIS-071: PDF viewer library choice (Day 9)
- MNESIS-078: Code review findings (Day 10)

### Rollback Points
If critical tasks fail, these are safe rollback points:

1. **After 058:** Can revert to local auth if Supabase fails
2. **After 064:** Preserved old navigation code (commented)
3. **After 065:** Can fall back to separate screens (no PageView)

---

## Completion Milestones

### Milestone 1: Authentication Working (End of Day 3)
- MNESIS-058, 059, 060 complete
- User can login/logout
- Session persists

### Milestone 2: Foundation Complete (End of Week 1)
- All Week 1 tasks complete (058-066)
- Navigation structure in place
- Cache layer functional
- Ready to build screens

### Milestone 3: Screens Complete (End of Day 9)
- All 5 screens functional (067-071)
- Mock data showing
- Basic functionality works

### Milestone 4: MVP Ready (End of Week 2)
- All tasks complete (058-081)
- Tests passing
- Documentation done
- Demo ready

---

## Quick Reference: Task Order Options

### Option 1: Pure Sequential (Safest)
```
058 → 059 → 060 → 061 → 062 → 063 → 064 → 065 → 066 →
067 → 068 → 069 → 070 → 071 → 072 → 073 → 074 →
075 → 076 → 077 → 078 → 079 → 080 → 081
```

### Option 2: Optimized Parallel (Fastest)
```
Day 1:  058
Day 2:  059 || 061
Day 3:  060
Day 4:  062 || 063
Day 5:  064
Day 6:  065 || 066
Day 7:  067 || 072
Day 8:  068 || 074
Day 9:  069 || 070 || 071 || 073
Day 10: 075 || 076 || 077 → 078 → 079 || 080 → 081
```

### Option 3: Risk-First (Most Validation)
```
058 → 064 → 060 → 061 → 065 → 062 → 063 → 066 →
068 → 067 → 074 → 072 → 073 → 069 → 070 → 071 →
075 → 076 → 077 → 078 → 079 → 080 → 081
```

---

**Legend:**
- `[XXX]` = Task number (MNESIS-XXX)
- `(Xh)` = Estimated hours
- `→` = Blocking dependency
- `||` = Parallel execution possible
- `┐├└┘│` = Visual tree structure

---

**Generated by:** fft-project-manager
**Date:** 2026-01-23
**Purpose:** Visual execution planning for Mnesis MVP
