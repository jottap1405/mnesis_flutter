# Mnesis Architecture Revision Summary

**Date**: 2026-01-16
**Reason**: Critical correction to architecture approach

---

## 🚨 Critical Change

**Original Approach**: Complex local SQLite database with full CRUD operations for patients, appointments, studies, etc.

**Revised Approach**: Minimal SQLite cache (messages only) + Backend-heavy LLM architecture

---

## Why the Change?

**User's Critical Insight**:
> "Mnesis não necessita de um cache tão grande e bem estruturado porque quase toda a lógica para pacientes, consultas, agendamentos, estudos e outros estará concentrado na LLM, no backend!"

**Translation**: Mnesis doesn't need such large/structured cache because almost all logic for patients, appointments, scheduling, studies will be concentrated in the LLM/backend.

---

## What Changed?

### Before (Original Architecture)

```
Flutter App (Volan-like)
├── SQLite Database (Large)
│   ├── patients table
│   ├── appointments table
│   ├── studies table
│   ├── medical_records table
│   └── messages table
├── Complex Local CRUD Logic
├── Offline-First Sync
└── Traditional Forms/Navigation
```

### After (Revised Architecture)

```
Flutter App (Chat-First)
├── SQLite Database (Minimal)
│   ├── conversations table
│   └── messages table (cache only)
├── Thin API Wrappers
├── Chat as Primary Interface
└── Streaming SSE Integration

Backend (LLM-Powered)
├── LLM Engine (GPT-4/Claude)
├── Business Logic Services
│   ├── PatientService
│   ├── AppointmentService
│   └── StudyService
└── PostgreSQL Database
```

---

## Key Architectural Changes

### 1. SQLite Schema (Massively Simplified)

**Before**: 5+ tables with full CRUD
**After**: 2 tables (conversations + messages) - cache only

```sql
-- OLD (Complex)
CREATE TABLE patients (...);
CREATE TABLE appointments (...);
CREATE TABLE studies (...);
CREATE TABLE medical_records (...);
CREATE TABLE messages (...);

-- NEW (Minimal)
CREATE TABLE conversations (id, title, created_at, updated_at);
CREATE TABLE messages (id, conversation_id, text, is_user, timestamp);
```

### 2. Feature Structure (Thin vs Rich)

**Before**: All features equally complex with local state management
**After**:
- ✅ `features/chat/` - **RICH** (full implementation)
- ✅ `features/patients/` - **THIN** (API wrapper only)
- ✅ `features/appointments/` - **THIN** (API wrapper only)
- ✅ `features/cases/` - **THIN** (API wrapper only)

### 3. Primary Interface

**Before**: Traditional navigation (forms, lists, detail screens)
**After**: **Chat-first** (users talk to Mnesis for everything)

Example:
```
User: "Schedule an appointment for John Doe tomorrow at 2pm"
Mnesis: "I'll schedule that appointment. Checking availability... Done! Appointment scheduled for January 17, 2026 at 2:00 PM."
```

### 4. Backend Communication

**Before**: REST API (GET, POST, PUT, DELETE)
**After**:
- ✅ REST API (GET, POST for simple operations)
- ✅ **SSE Streaming** (for real-time chat responses)

### 5. Where Logic Lives

| Logic Type | Before | After |
|------------|--------|-------|
| Patient Management | Flutter + Backend | **Backend only** |
| Appointment Scheduling | Flutter + Backend | **Backend only** |
| Study Analysis | Flutter + Backend | **Backend only** |
| Natural Language Understanding | N/A | **Backend LLM** |
| Chat UI/UX | N/A | **Flutter only** |

---

## Implementation Impact

### What to Build

#### ✅ Implement Fully
1. **Chat Feature** (`features/chat/`)
   - Rich UI (message bubbles, typing indicators, voice input)
   - SSE streaming client
   - SQLite message cache
   - Riverpod state management

2. **Mnesis Theme/Design System**
   - Dark-first theme
   - Orange primary color
   - Chat-optimized components

#### ✅ Implement as Thin Wrappers
1. **Patients Feature** (`features/patients/`)
   - Simple list screen
   - GET /api/patients endpoint
   - No local CRUD

2. **Appointments Feature** (`features/appointments/`)
   - Simple list screen
   - POST /api/appointments, GET /api/appointments
   - No local scheduling logic

3. **Cases Feature** (`features/cases/`)
   - Detail screen
   - GET /api/cases/:id
   - No local management

#### ❌ Do NOT Build
1. ❌ Complex local patient database
2. ❌ Offline appointment scheduling
3. ❌ Local medical record CRUD
4. ❌ Complex form validation (backend handles this)
5. ❌ Sync logic (no offline-first needed)

---

## Backend API Contract

### Critical Endpoints

#### Chat (Most Important)
- `POST /api/chat/message` - Send message + stream AI response (SSE)
- `GET /api/chat/conversations` - List conversations
- `GET /api/chat/conversations/:id/messages` - Fetch message history

#### Patients (Simple)
- `GET /api/patients` - List patients
- `GET /api/patients/:id` - Get patient details
- Backend handles all patient management logic

#### Appointments (Simple)
- `POST /api/appointments` - Schedule appointment (backend validates)
- `GET /api/appointments` - List appointments
- Backend handles scheduling rules, conflicts, availability

#### Cases (Simple)
- `GET /api/cases/:id` - Get case details
- Backend manages all case logic

---

## Testing Strategy (Updated)

### Unit Tests
- ✅ Chat domain logic (send_message, stream_response)
- ✅ Thin feature use cases (get_patients, get_appointments)
- ❌ No complex business logic tests (lives in backend)

### Widget Tests
- ✅ Chat UI components (message bubbles, input field, typing indicator)
- ✅ Streaming message rendering
- ✅ Patient/appointment list screens

### Integration Tests
- ✅ SSE streaming client
- ✅ API communication
- ✅ SQLite message cache

---

## Migration from Volan

### Reuse from Volan (80%)
- ✅ Core infrastructure (`/lib/core/`)
- ✅ Auth feature (same structure)
- ✅ Shared widgets/theme (adapt colors)
- ✅ Testing setup (mocktail, patterns)

### New for Mnesis (20%)
- ✅ Chat feature (entirely new)
- ✅ SSE streaming client
- ✅ SQLite message cache
- ✅ Thin features (patients, appointments, cases)

---

## Validation Checklist

Before proceeding, confirm:

- [ ] Backend team agrees to LLM-powered API contract
- [ ] SSE streaming is supported by backend
- [ ] Backend handles ALL patient/appointment/case logic
- [ ] Flutter team understands "thin client" approach
- [ ] Chat will be the PRIMARY interface (not forms)
- [ ] Offline support is minimal (cached messages only)

---

## Next Steps

1. **Review with Team**
   - Share `MNESIS_ARCHITECTURE_REVISED.md` with backend/frontend teams
   - Confirm API contract with backend
   - Validate streaming approach (SSE vs WebSocket)

2. **Setup SQLite**
   - Create minimal schema (conversations + messages)
   - Add sqflite dependency
   - Create database helper

3. **Implement Chat Feature**
   - Follow Volan's 3-tier structure
   - Add SSE streaming client
   - Build rich chat UI

4. **Implement Thin Features**
   - Patients, appointments, cases as simple API wrappers
   - Minimal local state
   - Chat-first integration

5. **Testing**
   - 80%+ test coverage
   - Focus on chat feature (most complex)
   - Simple tests for thin features

---

## Questions?

**Q: Why not keep offline-first approach?**
**A**: Medical data requires server validation for security/compliance. Backend LLM needs full context for intelligent responses. Offline CRUD adds complexity without benefit.

**Q: What if users have no internet?**
**A**: They can read cached chat history. New messages require connection (same as WhatsApp, Telegram).

**Q: How does this differ from Volan?**
**A**: Volan is form-based with traditional navigation. Mnesis is chat-first with LLM-powered interactions. Volan has minimal local storage. Mnesis has even less (messages only).

**Q: What about performance?**
**A**: Streaming provides instant feedback. SQLite cache makes history reads fast. Backend handles heavy computation.

---

**Status**: ✅ Revision Complete
**Document**: `/documentation/mnesis/MNESIS_ARCHITECTURE_REVISED.md`
**Author**: fft-architecture (FlowForge Agent)
**Date**: 2026-01-16
