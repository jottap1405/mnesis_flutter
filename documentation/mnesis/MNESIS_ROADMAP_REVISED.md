# 🗺️ Mnesis Development Roadmap - REVISED

> **CRITICAL ARCHITECTURE REVISION**: Backend-heavy approach with minimal SQLite usage
>
> **Last Updated**: January 16, 2026
> **Version**: 2.0 (Revised)
> **Total Duration**: 6 weeks (148 hours)

---

## 📋 Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Roadmap Summary](#roadmap-summary)
3. [Sprint 0: Foundation (Week 1)](#sprint-0-foundation-week-1)
4. [Epic 1: Design System & Core UI (Week 1-2)](#epic-1-design-system--core-ui-week-1-2)
5. [Epic 2: Chat Interface & Streaming (Week 2-3)](#epic-2-chat-interface--streaming-week-2-3)
6. [Epic 3: Backend API Integration (Week 3-4)](#epic-3-backend-api-integration-week-3-4)
7. [Epic 4: Patient Management UI (Week 4-5)](#epic-4-patient-management-ui-week-4-5)
8. [Epic 5: Appointment Management UI (Week 5-6)](#epic-5-appointment-management-ui-week-5-6)
9. [Epic 6: Polish & Production (Week 6)](#epic-6-polish--production-week-6)
10. [Dependencies & Critical Path](#dependencies--critical-path)

---

## 🏗️ Architecture Overview

### REVISED Architecture Principles

**Backend-Heavy (NOT Offline-First)**:
- All business logic resides in backend/LLM
- Flutter app is primarily a chat UI with API integration
- SQLite used ONLY for chat message caching (minimal scope)
- No complex local CRUD operations
- Real-time streaming from backend API

### Technology Stack

**Frontend (Flutter)**:
- State Management: Riverpod
- HTTP Client: Dio + Retrofit
- Real-time: SSE (Server-Sent Events) for streaming
- Local Cache: SQLite (chat messages ONLY)
- UI Framework: shadcn_flutter (optional)

**Backend (Assumed)**:
- LLM API integration (OpenAI/Anthropic)
- RESTful API endpoints
- Streaming endpoints for chat responses
- Patient/Appointment CRUD APIs
- Authentication/Authorization

### Data Flow

```
User Input → Flutter UI → HTTP Request → Backend API → LLM Processing → Streaming Response → Flutter UI Update
                                ↓
                         SQLite Cache (chat only)
```

---

## 📊 Roadmap Summary

### Time Allocation (Total: 148 hours)

| Epic | Description | Duration | Hours |
|------|-------------|----------|-------|
| Sprint 0 | Foundation & Design System | Week 1 | 30h |
| Epic 1 | Design System Implementation | Week 1-2 | 18h |
| Epic 2 | Chat Interface & Streaming | Week 2-3 | 26h |
| Epic 3 | Backend API Integration | Week 3-4 | 24h |
| Epic 4 | Patient Management UI | Week 4-5 | 16h |
| Epic 5 | Appointment Management UI | Week 5-6 | 16h |
| Epic 6 | Polish & Production Readiness | Week 6 | 18h |

### Key Changes from Original Roadmap

**REDUCED**:
- SQLite work: 8h → 2h (only chat cache)
- Local CRUD logic: Removed completely (0h)
- Offline sync: Removed completely (0h)

**INCREASED**:
- API integration: 14h → 24h (+10h)
- Streaming chat: 4h → 8h (+4h)
- Backend contract definition: NEW +4h

**ADDED**:
- Epic 3: Dedicated backend integration epic (24h)
- API contract validation (4h)
- Error handling for network failures (4h)

---

## 🚀 Sprint 0: Foundation (Week 1)

**Duration**: 5 days (30 hours)
**Goal**: Project setup, dependencies, and design system foundation

### Tasks Overview

| # | Task | Type | Hours | Priority |
|---|------|------|-------|----------|
| 0.1 | Project initialization & dependencies | Setup | 4h | Critical |
| 0.2 | Design system constants (colors, typography, spacing) | Design | 6h | Critical |
| 0.3 | Core theme configuration | Design | 4h | Critical |
| 0.4 | Navigation structure (go_router setup) | Architecture | 4h | High |
| 0.5 | SQLite setup (chat cache ONLY) | Database | 2h | High |
| 0.6 | Dio HTTP client configuration | API | 4h | Critical |
| 0.7 | Retrofit API client setup | API | 3h | High |
| 0.8 | Environment configuration (.env) | Setup | 2h | High |
| 0.9 | CI/CD pipeline setup | DevOps | 1h | Medium |

### Deliverables

- Working Flutter project with all dependencies
- MnesisColors, MnesisTextStyles, MnesisSpacings constants
- Dark theme configured and applied
- Basic navigation structure
- SQLite initialized (chat cache schema only)
- HTTP client ready for API calls
- Environment variables for API endpoints

---

## 🎨 Epic 1: Design System & Core UI (Week 1-2)

**Duration**: 3 days (18 hours)
**Goal**: Implement all design system components from MNESIS_DESIGN_SYSTEM.md

### Tasks (Detailed Breakdown)

#### Task 1.1: Button Components (3h)
**Description**: Implement all button variants with Mnesis styling

**Acceptance Criteria**:
- [ ] Primary button (orange, 48px height)
- [ ] Secondary button (outlined, white border)
- [ ] Text button (transparent, orange text)
- [ ] All states: normal, hover, pressed, disabled, loading
- [ ] Ripple effects with orange_20
- [ ] Widget tests for all variants

**Technical Details**:
```dart
// lib/shared/components/mnesis_button.dart
class MnesisButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  // ...
}
```

**Dependencies**: Sprint 0 (colors, text styles)

---

#### Task 1.2: Input Field Component (3h)
**Description**: Implement dark-themed input field with pill shape

**Acceptance Criteria**:
- [ ] Background: surfaceDark (#3D4349)
- [ ] Border radius: 24px (pill shape)
- [ ] Height: 56px
- [ ] Focus state: orange border (2px)
- [ ] Error state: red border
- [ ] Prefix/suffix icon support
- [ ] Widget tests

**Technical Details**:
```dart
// lib/shared/components/mnesis_input.dart
class MnesisInput extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final Widget? prefixIcon;
  // ...
}
```

**Dependencies**: Sprint 0 (colors, spacings)

---

#### Task 1.3: Chat Bubble Component (4h)
**Description**: Implement AI and user chat bubbles with Mnesis styling

**Acceptance Criteria**:
- [ ] AI bubble: dark gray background, left-aligned
- [ ] User bubble: transparent, right-aligned
- [ ] Max width: 80% of screen
- [ ] Padding: 16px horizontal, 12px vertical
- [ ] Border radius: 16px (symmetric)
- [ ] Timestamp display (label style)
- [ ] Spacing: 12px (different sender), 4px (same sender)
- [ ] Widget tests for both variants

**Technical Details**:
```dart
// lib/features/chat/presentation/widgets/mnesis_chat_bubble.dart
class MnesisChatBubble extends StatelessWidget {
  final String message;
  final bool isAI;
  final DateTime timestamp;
  // ...
}
```

**Dependencies**: Sprint 0 (colors, text styles, spacings)

---

#### Task 1.4: Voice Button Component (2h)
**Description**: Implement circular orange voice input button

**Acceptance Criteria**:
- [ ] Size: 56px × 56px (circular)
- [ ] Background: orange (#FF7043)
- [ ] Icon: mic (24px, white)
- [ ] Elevation: 4dp shadow
- [ ] States: normal, pressed, recording, disabled
- [ ] Recording state: pulsing animation (scale 1.0 → 1.1 → 1.0)
- [ ] Widget tests

**Technical Details**:
```dart
// lib/shared/components/mnesis_voice_button.dart
class MnesisVoiceButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isRecording;
  // ...
}
```

**Dependencies**: Sprint 0 (colors)

---

#### Task 1.5: Message Action Buttons (2h)
**Description**: Implement 5 action icons for AI messages

**Acceptance Criteria**:
- [ ] 5 icons: copy, like, dislike, share, more
- [ ] Icon size: 20px
- [ ] Color: textSecondary (#A0A0A0)
- [ ] Tap target: 40px × 40px
- [ ] Spacing: 8px between icons
- [ ] Hover state: color change to textPrimary
- [ ] Widget tests

**Technical Details**:
```dart
// lib/features/chat/presentation/widgets/message_actions.dart
class MessageActions extends StatelessWidget {
  final VoidCallback onCopy;
  final VoidCallback onLike;
  // ...
}
```

**Dependencies**: Task 1.3 (chat bubble)

---

#### Task 1.6: Suggestion Chips (2h)
**Description**: Implement pill-shaped suggestion chips

**Acceptance Criteria**:
- [ ] Background: surfaceDark
- [ ] Border radius: 18px (pill)
- [ ] Height: 36px
- [ ] Padding: 16px horizontal, 8px vertical
- [ ] Spacing: 8px between chips
- [ ] States: normal, hover, pressed (orange)
- [ ] Horizontal scrollable list
- [ ] Widget tests

**Technical Details**:
```dart
// lib/shared/components/mnesis_chip.dart
class MnesisChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  // ...
}
```

**Dependencies**: Sprint 0 (colors, text styles)

---

#### Task 1.7: Disclaimer Component (1h)
**Description**: Implement info icon + text disclaimer

**Acceptance Criteria**:
- [ ] Icon: info_outline (14px, textSecondary)
- [ ] Text: label style, textSecondary color
- [ ] Spacing: 4px between icon and text
- [ ] Default text: "Mnesis can make mistakes. Check important info."
- [ ] Widget tests

**Technical Details**:
```dart
// lib/shared/components/mnesis_disclaimer.dart
class MnesisDisclaimer extends StatelessWidget {
  final String? text;
  // ...
}
```

**Dependencies**: Sprint 0 (colors, text styles)

---

#### Task 1.8: Loading Indicators (1h)
**Description**: Implement loading states for various components

**Acceptance Criteria**:
- [ ] Circular progress (orange)
- [ ] Skeleton loaders for chat bubbles
- [ ] Shimmer effect for lists
- [ ] Typing indicator (3 dots animation)
- [ ] Widget tests

**Technical Details**:
```dart
// lib/shared/components/mnesis_loading.dart
class MnesisLoading extends StatelessWidget {
  final LoadingType type;
  // ...
}
```

**Dependencies**: Sprint 0 (colors)

---

#### Task 1.9: Screen Templates (2h)
**Description**: Create reusable screen templates with consistent padding

**Acceptance Criteria**:
- [ ] SafeArea wrapper
- [ ] Screen padding: 24px horizontal, 16px vertical
- [ ] AppBar template (dark theme)
- [ ] Bottom navigation placeholder
- [ ] Widget tests

**Technical Details**:
```dart
// lib/shared/templates/mnesis_screen.dart
class MnesisScreen extends StatelessWidget {
  final Widget child;
  final String? title;
  // ...
}
```

**Dependencies**: Sprint 0 (spacings)

---

#### Task 1.10: Component Documentation (2h)
**Description**: Document all components with examples

**Acceptance Criteria**:
- [ ] Dart doc comments for all components
- [ ] Usage examples in documentation
- [ ] Screenshots of all components
- [ ] Storybook setup (optional)
- [ ] README for design system

**Technical Details**:
- Update MNESIS_DESIGN_SYSTEM.md with implementation notes
- Create examples/ directory with demo screens

**Dependencies**: All previous tasks (1.1-1.9)

---

### Epic 1 Summary

**Total Hours**: 18h
**Components Created**: 10
**Test Coverage**: 80%+ required
**Deliverables**: Complete design system implementation matching screenshots

---

## 💬 Epic 2: Chat Interface & Streaming (Week 2-3)

**Duration**: 4 days (26 hours)
**Goal**: Implement chat UI with streaming responses from backend

### Tasks Overview

| # | Task | Type | Hours | Priority |
|---|------|------|-------|----------|
| 2.1 | Chat screen layout | UI | 3h | Critical |
| 2.2 | Message list with auto-scroll | UI | 3h | Critical |
| 2.3 | Input area with send/voice | UI | 2h | Critical |
| 2.4 | SSE streaming client | API | 4h | Critical |
| 2.5 | Real-time message updates | State | 4h | Critical |
| 2.6 | Voice input integration | Feature | 4h | High |
| 2.7 | Message persistence (SQLite) | Database | 2h | High |
| 2.8 | Error handling for streaming | Error | 2h | High |
| 2.9 | Typing indicator | UI | 1h | Medium |
| 2.10 | Message actions (copy, like, etc.) | Feature | 1h | Medium |

### Key Technical Decisions

**Streaming Protocol**: Server-Sent Events (SSE)
- Simpler than WebSockets for one-way streaming
- Works over HTTP, no special server config
- Automatic reconnection built-in

**State Management**: Riverpod with StreamProvider
```dart
final chatStreamProvider = StreamProvider.autoDispose<ChatMessage>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return apiClient.streamChatResponse(message);
});
```

**SQLite Schema (Chat Cache ONLY)**:
```sql
CREATE TABLE messages (
  id TEXT PRIMARY KEY,
  content TEXT NOT NULL,
  is_ai BOOLEAN NOT NULL,
  timestamp INTEGER NOT NULL,
  session_id TEXT NOT NULL
);
```

### Deliverables

- Fully functional chat interface
- Real-time streaming responses
- Voice input working
- Message persistence
- 80%+ test coverage

---

## 🔌 Epic 3: Backend API Integration (Week 3-4)

**Duration**: 4 days (24 hours)
**Goal**: Complete API integration for all backend services

### Tasks Overview

| # | Task | Type | Hours | Priority |
|---|------|------|-------|----------|
| 3.1 | API contract definition | Architecture | 4h | Critical |
| 3.2 | Retrofit interfaces | API | 4h | Critical |
| 3.3 | Authentication flow | Auth | 4h | Critical |
| 3.4 | Patient API integration | API | 3h | High |
| 3.5 | Appointment API integration | API | 3h | High |
| 3.6 | Error handling & retry logic | Error | 3h | High |
| 3.7 | API response caching strategy | Cache | 2h | Medium |
| 3.8 | Network status monitoring | Feature | 1h | Medium |

### API Contract Definition (Task 3.1)

**Backend Endpoints (Expected)**:

```yaml
# Chat Streaming
POST /api/chat/stream
Content-Type: text/event-stream
Body: { "message": "string", "sessionId": "string" }
Response: SSE stream of { "delta": "string", "done": boolean }

# Patient Management
GET /api/patients
POST /api/patients
GET /api/patients/{id}
PUT /api/patients/{id}
DELETE /api/patients/{id}

# Appointment Management
GET /api/appointments
POST /api/appointments
GET /api/appointments/{id}
PUT /api/appointments/{id}
DELETE /api/appointments/{id}

# Authentication
POST /api/auth/login
POST /api/auth/logout
GET /api/auth/me
```

### Retrofit Implementation (Task 3.2)

```dart
// lib/core/api/mnesis_api.dart
@RestApi(baseUrl: "https://api.mnesis.com")
abstract class MnesisApi {
  factory MnesisApi(Dio dio, {String baseUrl}) = _MnesisApi;

  @POST("/api/chat/stream")
  Stream<ChatDelta> streamChat(@Body() ChatRequest request);

  @GET("/api/patients")
  Future<List<Patient>> getPatients();

  @POST("/api/patients")
  Future<Patient> createPatient(@Body() Patient patient);

  // ... more endpoints
}
```

### Error Handling Strategy (Task 3.6)

**Network Errors**:
- Connection timeout: Show retry dialog
- 500 errors: Retry with exponential backoff
- 401 errors: Redirect to login
- Rate limiting: Queue requests

**User Feedback**:
- Toast messages for transient errors
- Error states in UI
- Offline mode indicator

### Deliverables

- Complete API client implementation
- All CRUD operations working
- Error handling tested
- API documentation

---

## 👥 Epic 4: Patient Management UI (Week 4-5)

**Duration**: 3 days (16 hours)
**Goal**: Thin UI layer for patient management calling backend APIs

### Tasks Overview

| # | Task | Type | Hours | Priority |
|---|------|------|-------|----------|
| 4.1 | Patient list screen (thin UI) | UI | 3h | High |
| 4.2 | Patient detail screen | UI | 3h | High |
| 4.3 | Create/Edit patient form | UI | 4h | High |
| 4.4 | Search & filter UI | UI | 2h | Medium |
| 4.5 | Patient card component | UI | 2h | Medium |
| 4.6 | Loading & error states | UI | 2h | High |

### Architecture Pattern (Thin UI Layer)

**NO Local CRUD Logic**:
- All data from backend APIs
- No complex validation (backend handles)
- UI only handles display and user input
- State management via Riverpod providers

**Example State Provider**:
```dart
final patientsProvider = FutureProvider<List<Patient>>((ref) async {
  final api = ref.watch(apiClientProvider);
  return api.getPatients(); // Direct API call, no local processing
});
```

### Deliverables

- Patient list with search
- Patient detail view
- Create/edit forms
- All connected to backend APIs
- 80%+ test coverage

---

## 📅 Epic 5: Appointment Management UI (Week 5-6)

**Duration**: 3 days (16 hours)
**Goal**: Thin UI layer for appointment scheduling calling backend APIs

### Tasks Overview

| # | Task | Type | Hours | Priority |
|---|------|------|-------|----------|
| 5.1 | Appointment list screen | UI | 3h | High |
| 5.2 | Calendar view component | UI | 4h | High |
| 5.3 | Create/Edit appointment form | UI | 4h | High |
| 5.4 | Appointment detail screen | UI | 2h | Medium |
| 5.5 | Reminder notifications | Feature | 2h | Medium |
| 5.6 | Loading & error states | UI | 1h | High |

### Architecture Pattern (Same as Epic 4)

**Thin UI Layer**:
- All scheduling logic in backend
- UI only displays available slots from API
- No local conflict detection
- Backend validates all appointments

**Example**:
```dart
final availableSlotsProvider = FutureProvider.family<List<TimeSlot>, DateTime>(
  (ref, date) async {
    final api = ref.watch(apiClientProvider);
    return api.getAvailableSlots(date); // Backend returns available slots
  },
);
```

### Deliverables

- Appointment list/calendar
- Create/edit appointment
- All connected to backend APIs
- Push notifications configured

---

## 🎯 Epic 6: Polish & Production (Week 6)

**Duration**: 3 days (18 hours)
**Goal**: Production readiness and quality assurance

### Tasks Overview

| # | Task | Type | Hours | Priority |
|---|------|------|-------|----------|
| 6.1 | End-to-end testing | Testing | 4h | Critical |
| 6.2 | Performance optimization | Performance | 3h | High |
| 6.3 | Accessibility audit | A11y | 3h | High |
| 6.4 | Error logging & monitoring | DevOps | 2h | High |
| 6.5 | User onboarding flow | UI | 3h | Medium |
| 6.6 | Production deployment | DevOps | 2h | Critical |
| 6.7 | Documentation finalization | Docs | 1h | Medium |

### Quality Gates

**Before Production**:
- [ ] 80%+ test coverage achieved
- [ ] All WCAG AA contrast standards met
- [ ] API error handling tested
- [ ] Streaming chat works on slow networks
- [ ] Voice input works on all devices
- [ ] No hardcoded API endpoints
- [ ] All environment variables configured
- [ ] Error monitoring configured (Sentry/Firebase)

### Deliverables

- Production-ready application
- Deployment documentation
- User documentation
- Monitoring dashboards configured

---

## 🔗 Dependencies & Critical Path

### Critical Path (Must Complete First)

```
Sprint 0 (Setup)
    ↓
Epic 1 (Design System)
    ↓
Epic 3 (API Integration) ← Parallel with Epic 2
    ↓
Epic 2 (Chat Interface)
    ↓
Epic 4 (Patient UI) ← Can run parallel with Epic 5
    ↓
Epic 5 (Appointment UI)
    ↓
Epic 6 (Production)
```

### Inter-Epic Dependencies

**Epic 2 depends on**:
- Epic 1: Chat bubble, input components
- Epic 3: API client, streaming setup

**Epic 3 depends on**:
- Sprint 0: Dio/Retrofit setup
- Backend API contracts (external dependency)

**Epic 4 & 5 depend on**:
- Epic 3: API client ready
- Epic 1: UI components

**Epic 6 depends on**:
- All previous epics complete

### External Dependencies

**Backend API** (CRITICAL):
- Chat streaming endpoint ready
- Patient/Appointment CRUD endpoints
- Authentication endpoints
- API documentation provided

**Design Assets**:
- Mnesis logo files
- Icon assets
- Screenshots for onboarding

**Third-Party Services**:
- Voice recognition API (Google/Apple)
- Push notification service (Firebase)
- Error monitoring (Sentry)

---

## 📏 Hour Breakdown by Category

### By Epic
| Epic | Hours | % of Total |
|------|-------|------------|
| Sprint 0 | 30h | 20.3% |
| Epic 1 | 18h | 12.2% |
| Epic 2 | 26h | 17.6% |
| Epic 3 | 24h | 16.2% |
| Epic 4 | 16h | 10.8% |
| Epic 5 | 16h | 10.8% |
| Epic 6 | 18h | 12.2% |
| **TOTAL** | **148h** | **100%** |

### By Task Type
| Type | Hours | % of Total |
|------|-------|------------|
| UI/Components | 54h | 36.5% |
| API Integration | 36h | 24.3% |
| Setup/DevOps | 18h | 12.2% |
| Testing | 16h | 10.8% |
| Database (SQLite) | 2h | 1.4% |
| Documentation | 6h | 4.1% |
| Other | 16h | 10.8% |

### Architecture Comparison (Revised vs Original)

| Category | Original | Revised | Change |
|----------|----------|---------|--------|
| SQLite/Local Storage | 8h | 2h | -6h (75% reduction) |
| API Integration | 14h | 36h | +22h (157% increase) |
| Streaming/Real-time | 4h | 8h | +4h (100% increase) |
| Local CRUD Logic | 12h | 0h | -12h (removed) |
| Offline Sync | 6h | 0h | -6h (removed) |

**Net Change**: Reallocated 24 hours from local storage/CRUD to API integration and streaming.

---

## 🎯 Success Metrics

### Technical Metrics
- **Test Coverage**: 80%+ across all features
- **API Response Time**: < 200ms for CRUD operations
- **Streaming Latency**: < 500ms first token
- **App Size**: < 25MB download
- **Crash Rate**: < 1% of sessions

### User Experience Metrics
- **Chat Response Time**: Perceived as real-time
- **Voice Input Accuracy**: > 90% (backend dependent)
- **UI Smoothness**: 60 FPS on mid-range devices
- **Accessibility**: WCAG AA compliant

### Development Metrics
- **Sprint Velocity**: ~25h per sprint (1 week)
- **Bug Density**: < 0.5 bugs per feature
- **Code Review Time**: < 24h turnaround
- **Deployment Time**: < 30 minutes

---

## 🚨 Risks & Mitigation

### Risk 1: Backend API Not Ready
**Impact**: High (blocks all development)
**Probability**: Medium
**Mitigation**:
- Request API contracts early (Sprint 0)
- Mock API server for development (json-server)
- Parallel track: UI development with mock data

### Risk 2: Streaming Performance Issues
**Impact**: High (core feature)
**Probability**: Medium
**Mitigation**:
- Test on slow networks early (Epic 2)
- Implement chunked buffering
- Fallback to polling if SSE fails

### Risk 3: Voice Input Platform Inconsistencies
**Impact**: Medium
**Probability**: High
**Mitigation**:
- Use platform-agnostic library (speech_to_text)
- Extensive device testing
- Graceful degradation to text input

### Risk 4: SQLite Migration Overhead
**Impact**: Low (minimal usage)
**Probability**: Low
**Mitigation**:
- Simple schema (1 table for chat)
- Use drift for type-safe migrations
- Versioned schema from day 1

---

## 📝 Change Log from Original Roadmap

### Major Changes

1. **Architecture Shift**: Backend-heavy instead of offline-first
   - Removed local business logic
   - Increased API integration focus
   - Minimal SQLite usage (chat cache only)

2. **Time Reallocation**:
   - -6h SQLite/local storage
   - -12h local CRUD logic
   - -6h offline sync
   - +22h API integration
   - +4h streaming implementation

3. **New Epic Added**: Epic 3 (Backend API Integration)
   - Dedicated 24 hours for API work
   - API contract definition
   - Error handling and retry logic

4. **Simplified Epics 4 & 5**:
   - Reduced from complex CRUD to thin UI layers
   - All logic delegated to backend
   - Faster implementation (16h each instead of 24h)

### Unchanged Elements

- Sprint 0 setup (30h)
- Design system implementation (18h)
- Total duration (6 weeks)
- Quality standards (80% test coverage)
- Epic 1 detailed breakdown (10 tasks)

---

## 🎓 Lessons Applied

### From Volan Flutter Project

**Good Practices to Adopt**:
- Riverpod for state management (proven in Volan)
- go_router for navigation (working well)
- Clean architecture patterns
- Comprehensive testing strategy

**Improvements from Volan**:
- Simpler architecture (backend-heavy, not offline-first)
- Less complexity in local data management
- Focus on UI/UX rather than sync logic

### From MNESIS_DESIGN_SYSTEM.md

**Design System Insights**:
- Dark-first design requires 18h implementation
- 10 core components needed
- Accessibility must be built in, not added later
- Component documentation critical for team velocity

---

## 📚 References

### Internal Documentation
- `/documentation/technical/MNESIS_DESIGN_SYSTEM.md` - Complete design specs
- `/documentation/technical/architecture/HTTP_Backend_Architecture_TECH.md` - Backend patterns
- `/documentation/technical/flows/ChatImplementation_DIDACTIC.md` - Chat flow reference

### External Dependencies
- **Riverpod**: [pub.dev/packages/riverpod](https://pub.dev/packages/riverpod)
- **Dio**: [pub.dev/packages/dio](https://pub.dev/packages/dio)
- **Retrofit**: [pub.dev/packages/retrofit](https://pub.dev/packages/retrofit)
- **SSE Client**: [pub.dev/packages/sse_client](https://pub.dev/packages/sse_client)
- **Speech to Text**: [pub.dev/packages/speech_to_text](https://pub.dev/packages/speech_to_text)

### Technical Resources
- **Server-Sent Events**: [MDN SSE Guide](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events)
- **Flutter Streaming**: [Flutter Streams Docs](https://dart.dev/tutorials/language/streams)
- **Riverpod Streaming**: [Riverpod StreamProvider](https://riverpod.dev/docs/providers/stream_provider)

---

## ✅ Next Steps

### Immediate Actions (This Week)

1. **Validate Backend API Contract** (4h)
   - Schedule meeting with backend team
   - Review API endpoints and data models
   - Document any gaps or changes needed

2. **Start Sprint 0** (30h)
   - Initialize Flutter project
   - Set up dependencies (Riverpod, Dio, Retrofit)
   - Create design system constants

3. **Set Up Development Environment** (2h)
   - Configure API base URLs (.env)
   - Set up mock server for development
   - Create Git repository and CI/CD pipeline

### First Sprint Goal (Week 1)

Complete Sprint 0 + Start Epic 1:
- All design system constants defined
- HTTP client configured
- First 3 components built (buttons, inputs, chat bubbles)

### First Milestone Target (Week 2)

- Epic 1 complete (all design system components)
- Epic 2 started (basic chat interface working)
- API integration begun (Epic 3)

---

**Created by**: fft-project-manager (FlowForge Agent)
**Date**: January 16, 2026
**Version**: 2.0 (Revised for Backend-Heavy Architecture)
**Status**: Ready for Review and Approval
**Total Effort**: 148 hours across 6 weeks

---

> **Note**: This roadmap assumes backend APIs are available or can be mocked. Coordinate with backend team BEFORE Sprint 0 to validate API contracts and availability timelines.
