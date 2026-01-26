# Mnesis MVP Architecture Decisions

**Status**: ✅ Active
**Version**: 1.0.0
**Last Updated**: 2026-01-23
**Decision Framework**: Three-Option Analysis (Charlie Selected)

---

## 📋 Table of Contents

1. [Executive Summary](#executive-summary)
2. [MVP Scope Definition](#mvp-scope-definition)
3. [Decision: Option Charlie (Hybrid Preservation)](#decision-option-charlie-hybrid-preservation)
4. [Auth Design Pending Status](#auth-design-pending-status)
5. [Mock Data Strategy](#mock-data-strategy)
6. [Backend Deferral Rationale](#backend-deferral-rationale)
7. [Implementation Timeline](#implementation-timeline)
8. [Risk Assessment](#risk-assessment)

---

## Executive Summary

**Decision Date**: 2026-01-23
**Selected Option**: Charlie (Hybrid Preservation)
**Timeline**: 2 weeks (45-60 hours)
**Scope**: 5+1 MVP screens with mock data

### Key Decisions

1. **Scope Reduction**: Removed Chat Secretaria, Agenda, and horizontal navigation from MVP
2. **Architecture**: Hybrid approach preserving Grade A design system (94/100) while implementing MVP features
3. **Auth Strategy**: Placeholder implementation while awaiting final design
4. **Data Strategy**: Mock data for patients, attachments, and chat responses
5. **Backend**: Deferred integration until post-MVP (v1)

---

## MVP Scope Definition

### ✅ IN SCOPE (MVP - 5+1 Screens)

#### 1. Login Screen (PENDING DESIGN)
- **Status**: Design not finalized
- **Approach**: Placeholder implementation with Supabase auth
- **Functionality**: Email/password authentication
- **Design System**: Use existing Mnesis components (buttons, inputs)

#### 2. Home Screen (HomeScreen.png)
- **Features**:
  - Patient list (mock data)
  - Search functionality
  - Stats/metrics cards
  - Navigation to Chat per patient
- **Data Source**: Mock patients (hardcoded JSON)
- **State**: Riverpod providers

#### 3. Chat Assistente (ChatAssistentScreen.png)
- **Features**:
  - AI chat interface per patient
  - Message history (mock)
  - Voice input button (placeholder)
  - Suggestion chips
- **Data Source**: Mock chat responses (simulated streaming)
- **Navigation**: PageView integration with Resumo/Anexos

#### 4. Resumo Paciente (PatientSummaryScreen.png)
- **Features**:
  - Patient demographic info
  - Medical history summary
  - Quick stats
  - Tab navigation integration
- **Data Source**: Mock patient details
- **Layout**: PageView screen #2

#### 5. Anexos (AttachsScreen.png)
- **Features**:
  - Attachment list (PDFs, images)
  - File metadata (name, size, date)
  - Tap to open viewer
- **Data Source**: Mock attachment list
- **Layout**: PageView screen #3

#### 6. Visualização Anexo (AttachVisualizationScreen.png)
- **Features**:
  - PDF viewer
  - Image viewer
  - Zoom/pan controls
  - Download button (placeholder)
- **Data Source**: Asset PDFs/images
- **Navigation**: Modal/push from Anexos

### ❌ OUT OF SCOPE (Post-MVP v1)

#### Removed Features
1. **Chat Secretaria**: Doctor ↔ Secretary P2P chat
2. **Agenda**: Calendar view for appointments
3. **Horizontal Scroll Navigation**: Complex home navigation pattern
4. **appointments_cache Table**: SQLite caching removed

#### Rationale
- **Time Constraint**: 2-week MVP timeline
- **Design Complexity**: Features require additional UX design
- **Backend Dependencies**: Require real-time backend services
- **Core Value**: Not essential for MVP validation

---

## Decision: Option Charlie (Hybrid Preservation)

### Three Options Considered

#### Option Alpha: Full Restart
**Description**: Delete all code, start fresh with MVP-only scope

**Pros**:
- Clean slate, no legacy baggage
- Faster initial development
- Simpler codebase

**Cons**:
- Lose 1,165 passing tests ❌
- Lose Grade A design system (94/100) ❌
- Lose DI infrastructure (get_it + injectable) ❌
- Lose SQLite foundation ❌
- Risk: ~40h wasted previous work

**Verdict**: ❌ Rejected - Too much quality work discarded

---

#### Option Bravo: Keep Everything, Add MVP
**Description**: Keep all existing code, add MVP screens alongside

**Pros**:
- Zero waste of previous work
- Design system intact
- Tests preserved
- Infrastructure ready

**Cons**:
- Technical debt from unused features
- Confusing codebase (auth + MVP mixed)
- Larger bundle size
- Future refactoring needed

**Verdict**: ⚠️ Risky - Creates maintenance burden

---

#### Option Charlie: Hybrid Preservation ✅ SELECTED
**Description**: Keep core infrastructure, remove unused features, add MVP

**What to KEEP**:
- ✅ Design system (MnesisColors, MnesisTextStyles, MnesisSpacings) - Grade A
- ✅ Theme configuration (MnesisTheme) - 22+ component themes
- ✅ DI setup (get_it + injectable) - proven architecture
- ✅ Environment config (.env, EnvConfig) - production-ready
- ✅ SQLite foundation (drift setup) - reusable infrastructure
- ✅ Test infrastructure (138 accessibility tests) - quality assurance
- ✅ Core utilities (logger, extensions, validators)

**What to REMOVE**:
- ❌ Unused auth screens (beyond basic login)
- ❌ Complex navigation (horizontal scroll)
- ❌ Chat Secretaria feature code
- ❌ Agenda/calendar widgets
- ❌ appointments_cache database table

**What to ADD**:
- ✅ Login screen (placeholder while design pending)
- ✅ Home screen (patient list)
- ✅ Chat Assistente (mock AI responses)
- ✅ Resumo Paciente (patient details)
- ✅ Anexos (attachment list)
- ✅ Visualização Anexo (PDF/image viewer)
- ✅ Mock data providers (patients, attachments, chat)
- ✅ Simplified navigation (Login → Home → PageView)

**Pros**:
- ✅ Preserve 94/100 design system quality
- ✅ Keep 1,165 passing tests (80%+ coverage)
- ✅ Reuse proven DI/config infrastructure
- ✅ Clean codebase (remove unused features)
- ✅ Focus on MVP functionality
- ✅ Fast implementation (45-60h)

**Cons**:
- ⚠️ Requires careful refactoring (10-12h)
- ⚠️ Need to update tests for removed features

**Verdict**: ✅ SELECTED - Best balance of quality preservation and MVP focus

---

### Charlie Implementation Strategy

#### Week 1: Infrastructure + Auth + Cache + Navigation (20-25h)
1. **Refactoring** (8h)
   - Remove Chat Secretaria code
   - Remove Agenda widgets
   - Remove appointments_cache table
   - Clean up navigation structure
   - Update tests

2. **Auth Placeholder** (6h)
   - Basic login screen (Supabase)
   - Use existing MnesisInput + MnesisButton
   - Simple validation
   - Session management

3. **Mock Data Setup** (4h)
   - Patient list JSON (10-15 patients)
   - Attachment list JSON
   - Chat response generator
   - Riverpod providers

4. **Navigation** (4h)
   - go_router setup (Login → Home → PageView)
   - PageView configuration (Chat ↔ Resumo ↔ Anexos)
   - AppBar integration

#### Week 2: Screens + Integration + Testing (25-35h)
1. **Home Screen** (6h)
   - Patient list with search
   - Stats cards
   - Navigation to Chat

2. **Chat Assistente** (8h)
   - Message list
   - Input area
   - Mock streaming responses
   - Voice button (placeholder)

3. **Resumo Paciente** (4h)
   - Patient info display
   - Medical history
   - Tab integration

4. **Anexos** (4h)
   - Attachment list
   - File metadata cards

5. **Visualização Anexo** (4h)
   - PDF viewer (flutter_pdfview)
   - Image viewer
   - Zoom controls

6. **Integration + Testing** (4h)
   - End-to-end flow testing
   - Widget tests for new screens
   - Update documentation

---

## Auth Design Pending Status

### Current Situation

**Challenge**: Final login screen design not provided
**Blocker**: Cannot implement final UI without design specs
**Impact**: Medium (auth is entry point)

### Placeholder Approach (Option Charlie)

#### Temporary Login Implementation
```dart
// Placeholder login using existing design system
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MnesisColors.backgroundDark,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(MnesisSpacings.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo placeholder
              Icon(
                Icons.medical_services,
                size: 80,
                color: MnesisColors.primaryOrange,
              ),
              SizedBox(height: MnesisSpacings.xl2),

              // Email input
              MnesisInput(
                hintText: 'Email',
                controller: emailController,
              ),
              SizedBox(height: MnesisSpacings.lg),

              // Password input
              MnesisInput(
                hintText: 'Password',
                controller: passwordController,
                obscureText: true,
              ),
              SizedBox(height: MnesisSpacings.xl),

              // Login button
              MnesisButton.primary(
                label: 'Login',
                onPressed: _handleLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### Authentication Logic
- **Backend**: Supabase Auth
- **State**: Riverpod AuthNotifier
- **Storage**: flutter_secure_storage (session token)
- **Flow**: Login → Home (on success)

#### Design Replacement Plan
1. Design team provides final mockup
2. Replace placeholder UI (keep logic)
3. Update colors/spacing if needed
4. Test authentication flow remains intact

**Estimated Replacement Time**: 2-3 hours (UI only)

---

## Mock Data Strategy

### Why Mock Data?

**Rationale**:
1. **Backend Not Ready**: API contracts not finalized
2. **Parallel Development**: Frontend can progress independently
3. **Demo Capability**: Functional app for stakeholder reviews
4. **Testing**: Deterministic data for widget tests

### Mock Data Providers

#### 1. Patients (Mock)
**Location**: `lib/shared/data/mock_patients.dart`

```dart
class MockPatients {
  static final List<Patient> patients = [
    Patient(
      id: '1',
      name: 'João Silva',
      age: 45,
      gender: 'M',
      diagnosis: 'Hipertensão',
      lastVisit: DateTime(2026, 1, 15),
    ),
    // ... 10-15 mock patients
  ];
}
```

#### 2. Chat Responses (Simulated Streaming)
**Location**: `lib/features/chat/data/mock_chat_datasource.dart`

```dart
class MockChatDataSource implements ChatRemoteDataSource {
  @override
  Future<Stream<String>> streamChatResponse({
    required String message,
    String? conversationId,
  }) async {
    // Simulate streaming with delay
    return Stream.periodic(
      Duration(milliseconds: 50),
      (index) => _mockResponse[index],
    ).take(_mockResponse.length);
  }

  String get _mockResponse {
    // Generate contextual response based on user message
    if (message.contains('exame')) {
      return 'Os exames do paciente indicam...';
    }
    return 'Entendi. Posso ajudar com mais informações.';
  }
}
```

#### 3. Attachments (Mock)
**Location**: `lib/shared/data/mock_attachments.dart`

```dart
class MockAttachments {
  static final List<Attachment> attachments = [
    Attachment(
      id: '1',
      name: 'Exame de Sangue.pdf',
      type: AttachmentType.pdf,
      size: 1024 * 250, // 250KB
      date: DateTime(2026, 1, 10),
      assetPath: 'assets/sample_exam.pdf',
    ),
    // ... 5-10 mock attachments
  ];
}
```

### Mock Data Integration

#### Riverpod Providers
```dart
// Mock patient provider
final patientsProvider = Provider<List<Patient>>((ref) {
  return MockPatients.patients;
});

// Mock chat data source provider
final chatDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  return MockChatDataSource(); // Replace with real API later
});
```

### Transition to Real Backend

**Phase 1 (MVP)**: Mock providers
**Phase 2 (v1)**: Feature flag toggle
**Phase 3 (Production)**: Replace with real API

```dart
// Environment-based switching
final chatDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  if (EnvConfig.useMockData) {
    return MockChatDataSource();
  }
  return ChatRemoteDataSourceImpl(
    httpClient: ref.watch(httpClientProvider),
  );
});
```

**Effort to Replace**: ~4-6 hours per feature (swap providers)

---

## Backend Deferral Rationale

### Why Defer Backend Integration?

#### 1. API Contracts Not Finalized
**Issue**: Backend API contracts in flux
**Risk**: Building against unstable API = rework
**Solution**: Use mocks until contracts stabilize

#### 2. Frontend Can Validate UX
**Goal**: Validate screen designs and user flows
**Approach**: Fully functional UI with mock data
**Benefit**: Early stakeholder feedback

#### 3. Parallel Development
**Backend Team**: Working on LLM integration, database schema
**Frontend Team**: Can proceed with UI implementation
**Sync Point**: v1 integration phase (post-MVP)

#### 4. Reduced MVP Complexity
**Without Backend**: 45-60 hours
**With Backend Integration**: 70-90 hours (+25-30h)
**Savings**: 30-40% time reduction

### Backend Integration Plan (Post-MVP)

#### v1 Integration Tasks
1. **API Contract Validation** (4h)
   - Review finalized API docs
   - Update data models to match
   - Define error handling strategies

2. **Replace Mock Providers** (12h)
   - Implement real ChatRemoteDataSource (SSE streaming)
   - Implement PatientsRemoteDataSource (REST)
   - Implement AttachmentsRemoteDataSource (REST + file upload)

3. **Authentication** (6h)
   - Integrate with backend auth service
   - Update token management
   - Handle refresh tokens

4. **Testing** (8h)
   - Integration tests with mock server
   - Error scenario testing
   - Performance testing (network conditions)

**Total v1 Integration Effort**: 30 hours

---

## Implementation Timeline

### Week 1: Foundation (20-25 hours)

#### Monday-Tuesday: Refactoring (8h)
- [ ] Remove Chat Secretaria feature code
- [ ] Remove Agenda components
- [ ] Remove appointments_cache table
- [ ] Update navigation structure
- [ ] Update/remove related tests

#### Wednesday: Auth + Cache (6h)
- [ ] Implement placeholder login screen
- [ ] Supabase auth integration
- [ ] Session management (flutter_secure_storage)
- [ ] Login flow testing

#### Thursday: Mock Data (4h)
- [ ] Create mock patient data (10-15 patients)
- [ ] Create mock attachment data
- [ ] Create mock chat response generator
- [ ] Setup Riverpod providers

#### Friday: Navigation (4h)
- [ ] Configure go_router (Login → Home → PageView)
- [ ] Setup PageView (Chat ↔ Resumo ↔ Anexos)
- [ ] AppBar with patient name/tabs
- [ ] Navigation testing

---

### Week 2: Screens (25-35 hours)

#### Monday: Home Screen (6h)
- [ ] Patient list with search
- [ ] Stats cards (total patients, pending, etc.)
- [ ] Navigation to Chat per patient
- [ ] Widget tests

#### Tuesday-Wednesday: Chat Assistente (8h)
- [ ] Message list with auto-scroll
- [ ] Input area (text + voice button placeholder)
- [ ] Mock streaming responses
- [ ] Suggestion chips
- [ ] Widget tests

#### Thursday Morning: Resumo Paciente (4h)
- [ ] Patient demographic display
- [ ] Medical history section
- [ ] Tab integration (PageView screen #2)
- [ ] Widget tests

#### Thursday Afternoon: Anexos (4h)
- [ ] Attachment list
- [ ] File metadata cards
- [ ] Navigation to viewer
- [ ] Widget tests

#### Friday Morning: Visualização Anexo (4h)
- [ ] PDF viewer (flutter_pdfview)
- [ ] Image viewer
- [ ] Zoom/pan controls
- [ ] Widget tests

#### Friday Afternoon: Integration + Polish (4h)
- [ ] End-to-end flow testing
- [ ] Fix integration bugs
- [ ] Update documentation
- [ ] Code review preparation

---

### Timeline Contingency

**Best Case**: 45 hours (9 days at 5h/day)
**Expected**: 50-55 hours (10-11 days)
**Worst Case**: 60 hours (12 days)

**Buffer**: 2-3 days for unexpected issues

---

## Risk Assessment

### High-Priority Risks

#### Risk 1: Auth Design Delay
**Impact**: High (blocks user testing)
**Probability**: Medium
**Mitigation**:
- Placeholder implementation (Option Charlie)
- Functional auth with basic UI
- Quick replacement when design arrives (2-3h)

#### Risk 2: Mock Data Insufficient
**Impact**: Medium (demo quality)
**Probability**: Low
**Mitigation**:
- Create diverse patient profiles (10-15)
- Realistic chat responses (context-aware)
- Multiple attachment types (PDF, images)

#### Risk 3: PageView Navigation Complexity
**Impact**: Medium (UX quality)
**Probability**: Medium
**Mitigation**:
- Reference existing Flutter PageView examples
- Use TabBar for visual indicators
- Test swipe gestures on devices

### Medium-Priority Risks

#### Risk 4: PDF Viewer Issues
**Impact**: Medium (attachment viewing)
**Probability**: Medium
**Mitigation**:
- Use established package (flutter_pdfview)
- Fallback to external viewer if needed
- Test on both iOS and Android

#### Risk 5: Refactoring Scope Creep
**Impact**: Medium (timeline slip)
**Probability**: Medium
**Mitigation**:
- Strict 8-hour limit for refactoring
- Focus only on removing MVP-excluded features
- Defer optimization to v1

### Low-Priority Risks

#### Risk 6: Design System Breaking Changes
**Impact**: Low (tests catch issues)
**Probability**: Very Low
**Mitigation**:
- Design system already Grade A (94/100)
- 138 accessibility tests
- No changes planned for MVP

---

## Success Criteria

### MVP Completion Checklist

#### Functionality (Must Have)
- [ ] User can log in (placeholder UI)
- [ ] User can see patient list on Home
- [ ] User can search patients
- [ ] User can navigate to Chat per patient
- [ ] User can send messages and see mock responses
- [ ] User can swipe between Chat ↔ Resumo ↔ Anexos
- [ ] User can view patient summary
- [ ] User can see attachment list
- [ ] User can open PDF/image viewer

#### Quality (Must Have)
- [ ] 80%+ test coverage maintained
- [ ] Zero critical bugs
- [ ] Smooth navigation (no lag)
- [ ] Responsive UI (all screen sizes)
- [ ] Accessibility: WCAG AA compliance

#### Documentation (Must Have)
- [ ] MVP_DECISIONS.md (this document)
- [ ] IMPLEMENTATION_PLAN.md (detailed tasks)
- [ ] Updated ARCHITECTURE.md
- [ ] Updated README.md

#### Code Quality (Must Have)
- [ ] `flutter analyze` clean
- [ ] No hardcoded strings (use l10n or constants)
- [ ] All functions documented (Dart docs)
- [ ] No AI references in code/commits
- [ ] Consistent code style

---

## Lessons Learned (For Future Reference)

### What Worked Well
1. **Three-Option Analysis**: Clear decision framework
2. **Hybrid Preservation**: Balanced quality vs speed
3. **Mock Data Strategy**: Unblocked frontend development
4. **Design System Reuse**: Saved 15-20 hours

### What to Improve
1. **Earlier Scope Freeze**: MVP scope should be locked before design system
2. **Design Dependencies**: Request all designs upfront (including auth)
3. **Backend Contracts**: Parallel track API contract definition

### Recommendations for v1
1. **Backend Integration First**: Don't defer if contracts are stable
2. **Feature Flags**: Build toggle system from start
3. **Incremental Rollout**: Replace mocks feature-by-feature
4. **Performance Budget**: Define metrics before implementation

---

## References

### Internal Documents
- `MNESIS_ARCHITECTURE_REVISED.md` - Architecture overview
- `MNESIS_ROADMAP_REVISED.md` - Original roadmap
- `MNESIS_DESIGN_SYSTEM.md` - Design system documentation

### External Resources
- [Flutter PageView](https://api.flutter.dev/flutter/widgets/PageView-class.html)
- [go_router](https://pub.dev/packages/go_router)
- [flutter_pdfview](https://pub.dev/packages/flutter_pdfview)
- [Supabase Auth](https://supabase.com/docs/guides/auth)

---

**Document Version**: 1.0.0
**Author**: fft-documentation (FlowForge Agent)
**Last Updated**: 2026-01-23
**Status**: ✅ Active - Approved Decision Record
**Decision Impact**: High (defines MVP scope and approach)

---

> 💡 **Key Takeaway**: Option Charlie (Hybrid Preservation) maximizes ROI on existing work (Grade A design system, 1,165 tests) while delivering focused MVP in 2 weeks. Mock data strategy unblocks frontend development while backend stabilizes.
