# Mnesis Architecture - Backend-Heavy Chat-First Design

**Status**: ✅ Active (REVISED)
**Version**: 2.0.0
**Last Updated**: 2026-01-16
**Paradigm**: Backend-Heavy with LLM Integration, Minimal Local Storage

---

## 📋 Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Core Philosophy](#core-philosophy)
3. [System Architecture](#system-architecture)
4. [Minimal SQLite Schema](#minimal-sqlite-schema)
5. [Feature Structure](#feature-structure)
6. [Backend API Contract](#backend-api-contract)
7. [State Management](#state-management)
8. [Streaming Chat Implementation](#streaming-chat-implementation)
9. [Error Handling](#error-handling)
10. [Testing Strategy](#testing-strategy)
11. [Migration from Volan](#migration-from-volan)

---

## Architecture Overview

### Critical Design Decision

**Mnesis does NOT require extensive local storage or complex client-side logic.**

**Why?**
- **LLM-Powered Backend**: All business logic for patients, appointments, scheduling, studies, and medical records lives in the backend LLM
- **Chat-First Interface**: Users interact with ALL functionality through conversational AI, not traditional CRUD forms
- **Minimal Offline Support**: Medical data requires server validation and security; offline-first is unnecessary
- **Streaming Responses**: Real-time chat streaming requires persistent backend connection

### Architecture Principles

1. **Backend-Heavy**: 90% of logic in backend APIs + LLM, 10% in Flutter UI
2. **Chat as Primary Interface**: Users talk to Mnesis, not click through forms
3. **Thin Client**: Flutter app is primarily a chat UI with API wrappers
4. **Minimal Local State**: Only cache chat messages and user session
5. **Streaming-First**: Real-time SSE/WebSocket streaming for chat responses
6. **Clean Architecture**: Maintain 3-tier separation (Presentation → Domain → Data)

---

## Core Philosophy

### Backend-Heavy vs Offline-First

| Aspect | Traditional App (Volan) | Mnesis (Backend-Heavy) |
|--------|-------------------------|------------------------|
| **Data Storage** | SQLite with full CRUD | Minimal SQLite (messages only) |
| **Business Logic** | Flutter app + backend | LLM backend (primary) |
| **Offline Support** | Extensive (sync later) | Minimal (read-only cached messages) |
| **Primary Interface** | Forms + navigation | Chat conversation |
| **Feature Implementation** | Local state + API sync | API calls + streaming responses |

### What Lives Where?

#### Backend (LLM + APIs)
- ✅ Patient management logic
- ✅ Appointment scheduling rules
- ✅ Medical record validation
- ✅ Study analysis and recommendations
- ✅ Natural language understanding
- ✅ Context maintenance across conversations
- ✅ Security and authorization

#### Flutter Client
- ✅ Chat UI/UX (message bubbles, typing indicators)
- ✅ Streaming message rendering
- ✅ Local message cache (read-only history)
- ✅ Authentication state
- ✅ Voice input capture
- ✅ API communication layer

---

## System Architecture

### High-Level Architecture Diagram

```
┌────────────────────────────────────────────────────────────────┐
│                    FLUTTER CLIENT (Thin)                       │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │           PRESENTATION LAYER (UI)                        │ │
│  │  - ChatScreen (primary interface)                        │ │
│  │  - MessageBubbles (user + AI)                            │ │
│  │  - VoiceInputButton                                      │ │
│  │  - TypingIndicator                                       │ │
│  └──────────────────────────────────────────────────────────┘ │
│                          ↕                                      │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │           DOMAIN LAYER (Business Rules)                  │ │
│  │  - SendMessage UseCase                                   │ │
│  │  - GetConversations UseCase                              │ │
│  │  - StreamChatResponse UseCase                            │ │
│  └──────────────────────────────────────────────────────────┘ │
│                          ↕                                      │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │           DATA LAYER (API + Cache)                       │ │
│  │  ┌──────────────────┐       ┌────────────────┐          │ │
│  │  │ RemoteDataSource │       │ LocalDataSource│          │ │
│  │  │ (HTTP + SSE)     │       │ (SQLite cache) │          │ │
│  │  └──────────────────┘       └────────────────┘          │ │
│  └──────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────┘
                          ↕
┌────────────────────────────────────────────────────────────────┐
│                  BACKEND (LLM + APIs)                          │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  LLM Engine (GPT-4/Claude)                               │ │
│  │  - Natural language understanding                        │ │
│  │  - Context management                                    │ │
│  │  - Response generation                                   │ │
│  └──────────────────────────────────────────────────────────┘ │
│                          ↕                                      │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  Business Logic Services                                 │ │
│  │  - PatientService                                        │ │
│  │  - AppointmentService                                    │ │
│  │  - StudyService                                          │ │
│  │  - MedicalRecordService                                  │ │
│  └──────────────────────────────────────────────────────────┘ │
│                          ↕                                      │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  Database (PostgreSQL/Supabase)                          │ │
│  │  - patients, appointments, studies, medical_records      │ │
│  └──────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────┘
```

### 3-Tier Clean Architecture (Simplified)

#### Presentation Layer
```dart
lib/features/chat/
├── presentation/
│   ├── providers/
│   │   └── chat_provider.dart           // Riverpod StateNotifier
│   ├── screens/
│   │   └── chat_screen.dart            // Main chat interface
│   └── widgets/
│       ├── message_bubble.dart         // AI + User bubbles
│       ├── message_input.dart          // Text + voice input
│       ├── typing_indicator.dart       // "Mnesis is typing..."
│       └── suggestion_chips.dart       // Quick action chips
```

#### Domain Layer
```dart
lib/features/chat/
└── domain/
    ├── entities/
    │   ├── message.dart                // Domain message entity
    │   └── conversation.dart           // Domain conversation entity
    ├── repositories/
    │   └── chat_repository.dart        // Abstract interface
    └── usecases/
        ├── send_message.dart           // Send message to backend
        ├── get_conversations.dart      // Fetch conversation list
        └── stream_chat_response.dart   // Stream AI responses (SSE)
```

#### Data Layer
```dart
lib/features/chat/
└── data/
    ├── models/
    │   ├── message_model.dart          // JSON serialization
    │   └── conversation_model.dart     // JSON serialization
    ├── datasources/
    │   ├── chat_remote_datasource.dart // HTTP + SSE client
    │   └── chat_local_datasource.dart  // SQLite cache
    └── repositories/
        └── chat_repository_impl.dart   // Implements domain interface
```

---

## Minimal SQLite Schema

### Database: `mnesis_cache.db`

**Purpose**: Offline-readable chat history only (no CRUD operations)

```sql
-- Conversations table
CREATE TABLE conversations (
  id TEXT PRIMARY KEY,                  -- UUID from backend
  title TEXT NOT NULL,                 -- "Chat with Mnesis - Jan 16"
  created_at INTEGER NOT NULL,         -- Unix timestamp
  updated_at INTEGER NOT NULL,         -- Unix timestamp
  is_archived INTEGER DEFAULT 0        -- 0 = active, 1 = archived
);

-- Messages table
CREATE TABLE messages (
  id TEXT PRIMARY KEY,                  -- UUID from backend
  conversation_id TEXT NOT NULL,       -- Foreign key to conversations
  text TEXT NOT NULL,                  -- Message content
  is_user INTEGER NOT NULL,            -- 1 = user, 0 = AI
  timestamp INTEGER NOT NULL,          -- Unix timestamp
  status TEXT DEFAULT 'sent',          -- 'sending', 'sent', 'error'
  metadata TEXT,                       -- JSON for extra data (e.g., voice_input: true)
  FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE
);

-- Indexes for performance
CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_messages_timestamp ON messages(timestamp DESC);
CREATE INDEX idx_conversations_updated ON conversations(updated_at DESC);
```

### Schema Rationale

**Why so minimal?**
1. **No patient/appointment tables**: All data managed by backend
2. **No local CRUD**: Messages are append-only (from API)
3. **Cache-only purpose**: Enable offline reading of past chats
4. **Simple sync**: Fetch new messages via API, insert into SQLite
5. **Low storage footprint**: Text-only messages (no blobs)

**What about offline editing?**
- ❌ **Not supported**: Medical data requires server validation
- ✅ **Alternative**: Queue messages locally, sync when online (simple implementation)

---

## Feature Structure

### features/chat/ - Primary Feature (Rich Implementation)

**Scope**: Full chat UI/UX with streaming, voice input, message actions

```dart
lib/features/chat/
├── data/
│   ├── datasources/
│   │   ├── chat_remote_datasource.dart      // POST /api/chat/message, SSE streaming
│   │   └── chat_local_datasource.dart       // SQLite CRUD for messages
│   ├── models/
│   │   ├── message_model.dart               // { id, conversation_id, text, is_user, timestamp }
│   │   └── conversation_model.dart          // { id, title, created_at }
│   └── repositories/
│       └── chat_repository_impl.dart        // Orchestrates remote + local
├── domain/
│   ├── entities/
│   │   ├── message.dart                     // Domain entity (immutable)
│   │   └── conversation.dart
│   ├── repositories/
│   │   └── chat_repository.dart             // Abstract interface
│   └── usecases/
│       ├── send_message.dart                // Send message + handle streaming response
│       ├── get_conversation_history.dart    // Fetch from cache or API
│       └── create_conversation.dart         // POST /api/chat/conversations
└── presentation/
    ├── providers/
    │   └── chat_provider.dart               // Riverpod StateNotifier
    ├── screens/
    │   └── chat_screen.dart                // Main chat UI
    └── widgets/
        ├── message_bubble.dart             // AI + User variants
        ├── message_actions.dart            // Copy, Like, Dislike, Share
        ├── message_input.dart              // Text field + voice button
        ├── typing_indicator.dart           // Animated dots
        └── suggestion_chips.dart           // Quick actions
```

**Key Implementation Details**:
- **Streaming**: SSE (Server-Sent Events) for real-time AI responses
- **Voice Input**: Flutter plugin → send audio to backend → backend transcribes → send as text
- **Message Actions**: Like/Dislike feedback sent to backend for ML training

---

### features/cases/ - Thin API Wrapper (Display Only)

**Scope**: Display case information from backend, no local logic

```dart
lib/features/cases/
├── data/
│   ├── datasources/
│   │   └── cases_remote_datasource.dart    // GET /api/cases/:id
│   ├── models/
│   │   └── case_model.dart                 // JSON model from API
│   └── repositories/
│       └── cases_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── case.dart                       // Domain entity
│   ├── repositories/
│   │   └── cases_repository.dart
│   └── usecases/
│       └── get_case_details.dart           // Fetch from API
└── presentation/
    ├── providers/
    │   └── case_provider.dart              // Simple API state
    ├── screens/
    │   └── case_details_screen.dart       // Display case data
    └── widgets/
        └── case_info_card.dart             // Read-only display
```

**Key Points**:
- ❌ **No local CRUD**: Cases managed entirely by backend
- ✅ **API display**: Fetch case details via GET /api/cases/:id
- ✅ **Chat integration**: "Show me case #123" → backend returns case data → display in chat or navigation

---

### features/appointments/ - Thin API Wrapper (Backend Logic)

**Scope**: Call backend API for appointments, minimal local state

```dart
lib/features/appointments/
├── data/
│   ├── datasources/
│   │   └── appointments_remote_datasource.dart  // POST /api/appointments, GET /api/appointments
│   ├── models/
│   │   └── appointment_model.dart              // JSON model
│   └── repositories/
│       └── appointments_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── appointment.dart
│   ├── repositories/
│   │   └── appointments_repository.dart
│   └── usecases/
│       ├── schedule_appointment.dart           // POST to backend
│       └── get_appointments.dart               // GET from backend
└── presentation/
    ├── providers/
    │   └── appointments_provider.dart
    ├── screens/
    │   └── appointments_list_screen.dart      // Display appointments
    └── widgets/
        └── appointment_card.dart               // Read-only card
```

**Key Points**:
- ❌ **No local scheduling logic**: Backend validates availability, conflicts, etc.
- ✅ **API calls**: All CRUD operations via REST API
- ✅ **Chat-first**: "Schedule appointment for John Doe tomorrow at 2pm" → backend handles logic

---

### features/patients/ - Thin API Wrapper (List Only)

**Scope**: Display patient list from API, no local CRUD

```dart
lib/features/patients/
├── data/
│   ├── datasources/
│   │   └── patients_remote_datasource.dart    // GET /api/patients
│   ├── models/
│   │   └── patient_model.dart                 // JSON model
│   └── repositories/
│       └── patients_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── patient.dart
│   ├── repositories/
│   │   └── patients_repository.dart
│   └── usecases/
│       └── get_patients.dart                  // Fetch list from API
└── presentation/
    ├── providers/
    │   └── patients_provider.dart
    ├── screens/
    │   └── patients_list_screen.dart         // Simple list
    └── widgets/
        └── patient_card.dart                  // Read-only card
```

**Key Points**:
- ❌ **No local patient database**: All data from backend API
- ✅ **Search**: Backend handles search logic (GET /api/patients?q=john)
- ✅ **Chat-first**: "Show me patient John Doe" → backend returns patient data

---

## Backend API Contract

### Base URL
```
https://api.mnesis.ai/v1
```

### Authentication
All requests require `Authorization: Bearer {access_token}` header.

---

### Chat Endpoints

#### POST /api/chat/message
**Purpose**: Send user message and stream AI response

**Request**:
```json
{
  "conversation_id": "uuid-1234",  // Optional (creates new if null)
  "message": "Schedule an appointment for John Doe tomorrow at 2pm",
  "metadata": {
    "voice_input": true,           // Optional
    "context": {}                  // Optional extra context
  }
}
```

**Response (SSE Stream)**:
```
event: message_chunk
data: {"chunk": "I'll schedule", "token_index": 0}

event: message_chunk
data: {"chunk": " that appointment", "token_index": 1}

event: message_complete
data: {"message_id": "uuid-5678", "full_text": "I'll schedule that appointment for John Doe tomorrow at 2pm.", "actions": ["confirm_appointment"]}

event: done
data: {}
```

**Flutter Implementation**:
```dart
Future<Stream<String>> sendMessage({
  required String message,
  String? conversationId,
}) async {
  final uri = Uri.parse('$baseUrl/api/chat/message');
  final request = http.Request('POST', uri);
  request.headers.addAll({
    'Authorization': 'Bearer $accessToken',
    'Content-Type': 'application/json',
  });
  request.body = jsonEncode({
    'conversation_id': conversationId,
    'message': message,
  });

  final response = await httpClient.send(request);

  return response.stream
    .transform(utf8.decoder)
    .transform(const LineSplitter())
    .where((line) => line.startsWith('data:'))
    .map((line) => line.substring(5).trim())
    .map((data) => jsonDecode(data)['chunk'] as String);
}
```

---

#### GET /api/chat/conversations
**Purpose**: Fetch conversation list

**Response**:
```json
{
  "conversations": [
    {
      "id": "uuid-1234",
      "title": "Chat with Mnesis - Jan 16",
      "created_at": 1737052800,
      "updated_at": 1737056400,
      "last_message": "I'll schedule that appointment..."
    }
  ],
  "total": 1,
  "page": 1,
  "per_page": 20
}
```

---

#### GET /api/chat/conversations/:id/messages
**Purpose**: Fetch messages for a conversation

**Query Parameters**:
- `limit` (default: 50)
- `before` (message_id for pagination)

**Response**:
```json
{
  "messages": [
    {
      "id": "uuid-5678",
      "conversation_id": "uuid-1234",
      "text": "Schedule an appointment for John Doe tomorrow at 2pm",
      "is_user": true,
      "timestamp": 1737056000,
      "metadata": {}
    },
    {
      "id": "uuid-5679",
      "conversation_id": "uuid-1234",
      "text": "I'll schedule that appointment for John Doe tomorrow at 2pm.",
      "is_user": false,
      "timestamp": 1737056005,
      "metadata": {
        "actions": ["confirm_appointment"]
      }
    }
  ],
  "has_more": false
}
```

---

### Patient Endpoints

#### GET /api/patients
**Purpose**: List patients (backend handles search, filtering)

**Query Parameters**:
- `q` (search query)
- `limit` (default: 20)
- `offset` (pagination)

**Response**:
```json
{
  "patients": [
    {
      "id": "uuid-patient-1",
      "name": "John Doe",
      "email": "john@example.com",
      "phone": "+1234567890",
      "created_at": 1737052800
    }
  ],
  "total": 1
}
```

---

#### GET /api/patients/:id
**Purpose**: Get patient details

**Response**:
```json
{
  "id": "uuid-patient-1",
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "medical_history": [...],
  "appointments": [...],
  "created_at": 1737052800
}
```

---

### Appointment Endpoints

#### POST /api/appointments
**Purpose**: Schedule appointment (backend validates availability)

**Request**:
```json
{
  "patient_id": "uuid-patient-1",
  "datetime": 1737142800,        // Unix timestamp
  "duration_minutes": 30,
  "type": "consultation",
  "notes": "Follow-up appointment"
}
```

**Response**:
```json
{
  "id": "uuid-appt-1",
  "patient_id": "uuid-patient-1",
  "datetime": 1737142800,
  "status": "scheduled",
  "created_at": 1737056400
}
```

---

#### GET /api/appointments
**Purpose**: List appointments

**Query Parameters**:
- `patient_id` (optional filter)
- `start_date` (Unix timestamp)
- `end_date` (Unix timestamp)

**Response**:
```json
{
  "appointments": [
    {
      "id": "uuid-appt-1",
      "patient_name": "John Doe",
      "datetime": 1737142800,
      "duration_minutes": 30,
      "status": "scheduled"
    }
  ],
  "total": 1
}
```

---

### Cases Endpoints

#### GET /api/cases/:id
**Purpose**: Get case details (backend manages all case logic)

**Response**:
```json
{
  "id": "uuid-case-1",
  "patient_id": "uuid-patient-1",
  "title": "Annual Checkup",
  "status": "open",
  "created_at": 1737052800,
  "notes": [...],
  "attachments": [...]
}
```

---

## State Management

### Riverpod Architecture

**Why Riverpod?**
- ✅ **Type-safe**: Compile-time safety for providers
- ✅ **Testable**: Easy to mock providers in tests
- ✅ **Scalable**: Family providers for dynamic state
- ✅ **DevTools**: Excellent debugging support

### Chat State Example

```dart
// lib/features/chat/presentation/providers/chat_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

@freezed
class ChatState with _$ChatState {
  const factory ChatState.initial() = _Initial;
  const factory ChatState.loading() = _Loading;
  const factory ChatState.loaded({
    required List<Message> messages,
    required Conversation conversation,
  }) = _Loaded;
  const factory ChatState.streaming({
    required List<Message> messages,
    required String currentChunk,
  }) = _Streaming;
  const factory ChatState.error(String message) = _Error;
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _repository;

  ChatNotifier(this._repository) : super(const ChatState.initial());

  Future<void> loadConversation(String conversationId) async {
    state = const ChatState.loading();
    final result = await _repository.getConversationHistory(conversationId);
    result.fold(
      (failure) => state = ChatState.error(failure.message),
      (data) => state = ChatState.loaded(
        messages: data.messages,
        conversation: data.conversation,
      ),
    );
  }

  Future<void> sendMessage(String text) async {
    // Add user message optimistically
    final userMessage = Message(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final currentMessages = state.maybeMap(
      loaded: (s) => s.messages,
      streaming: (s) => s.messages,
      orElse: () => <Message>[],
    );

    state = ChatState.loaded(
      messages: [...currentMessages, userMessage],
      conversation: const Conversation(id: 'current', title: 'Chat'),
    );

    // Stream AI response
    final streamResult = await _repository.sendMessage(text);
    await streamResult.fold(
      (failure) async {
        state = ChatState.error(failure.message);
      },
      (stream) async {
        String fullResponse = '';
        await for (final chunk in stream) {
          fullResponse += chunk;
          state = ChatState.streaming(
            messages: [...currentMessages, userMessage],
            currentChunk: fullResponse,
          );
        }

        // Stream complete, add AI message
        final aiMessage = Message(
          id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
          text: fullResponse,
          isUser: false,
          timestamp: DateTime.now(),
        );

        state = ChatState.loaded(
          messages: [...currentMessages, userMessage, aiMessage],
          conversation: const Conversation(id: 'current', title: 'Chat'),
        );
      },
    );
  }
}

// Provider definition
final chatNotifierProvider = StateNotifierProvider<ChatNotifier, ChatState>(
  (ref) => ChatNotifier(ref.watch(chatRepositoryProvider)),
);
```

---

## Streaming Chat Implementation

### SSE (Server-Sent Events) Client

**Why SSE over WebSocket?**
- ✅ **Simpler**: One-way stream (server → client) is sufficient
- ✅ **Auto-reconnect**: Built-in reconnection logic
- ✅ **HTTP-based**: Works through proxies/firewalls
- ✅ **Flutter support**: `http` package supports streaming

### Implementation

```dart
// lib/features/chat/data/datasources/chat_remote_datasource.dart

import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class ChatRemoteDataSource {
  Future<Stream<String>> streamChatResponse({
    required String message,
    String? conversationId,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final http.Client httpClient;
  final String baseUrl;
  final String Function() getAccessToken;

  ChatRemoteDataSourceImpl({
    required this.httpClient,
    required this.baseUrl,
    required this.getAccessToken,
  });

  @override
  Future<Stream<String>> streamChatResponse({
    required String message,
    String? conversationId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/chat/message');
    final request = http.Request('POST', uri);

    request.headers.addAll({
      'Authorization': 'Bearer ${getAccessToken()}',
      'Content-Type': 'application/json',
      'Accept': 'text/event-stream',
    });

    request.body = jsonEncode({
      'conversation_id': conversationId,
      'message': message,
    });

    final response = await httpClient.send(request);

    if (response.statusCode != 200) {
      throw ServerException(
        message: 'Failed to stream response: ${response.statusCode}',
      );
    }

    return response.stream
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .where((line) => line.isNotEmpty && line.startsWith('data:'))
      .map((line) {
        final data = line.substring(5).trim();
        if (data == '[DONE]') {
          return null; // Stream complete signal
        }
        try {
          final json = jsonDecode(data);
          return json['chunk'] as String;
        } catch (e) {
          return null;
        }
      })
      .where((chunk) => chunk != null)
      .cast<String>();
  }
}
```

### UI Integration (Typing Effect)

```dart
// lib/features/chat/presentation/widgets/streaming_message_bubble.dart

class StreamingMessageBubble extends StatelessWidget {
  final String currentChunk;

  const StreamingMessageBubble({required this.currentChunk, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: MnesisColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentChunk,
            style: MnesisTextStyles.bodyLarge,
          ),
          const SizedBox(height: 4),
          const TypingIndicator(), // Animated dots
        ],
      ),
    );
  }
}
```

---

## Error Handling

### Error Types

```dart
// lib/core/errors/failures.dart

abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}

class StreamFailure extends Failure {
  const StreamFailure(String message) : super(message);
}
```

### Error Handling in UI

```dart
// lib/features/chat/presentation/screens/chat_screen.dart

@override
Widget build(BuildContext context) {
  final chatState = ref.watch(chatNotifierProvider);

  return chatState.when(
    initial: () => const Center(child: Text('Start a conversation')),
    loading: () => const Center(child: CircularProgressIndicator()),
    loaded: (messages, conversation) => _buildChatList(messages),
    streaming: (messages, currentChunk) => _buildChatListWithStreaming(messages, currentChunk),
    error: (message) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: MnesisColors.error),
          const SizedBox(height: 16),
          Text(message, style: MnesisTextStyles.bodyMedium),
          const SizedBox(height: 16),
          MnesisButton.primary(
            label: 'Retry',
            onPressed: () => ref.read(chatNotifierProvider.notifier).loadConversation('current'),
          ),
        ],
      ),
    ),
  );
}
```

---

## Testing Strategy

### Unit Tests (Domain Layer)

```dart
// test/features/chat/domain/usecases/send_message_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late SendMessage usecase;
  late MockChatRepository mockRepository;

  setUp(() {
    mockRepository = MockChatRepository();
    usecase = SendMessage(mockRepository);
  });

  test('should send message and return stream from repository', () async {
    // Arrange
    final testStream = Stream.fromIterable(['Hello', ' world']);
    when(() => mockRepository.sendMessage('test message'))
      .thenAnswer((_) async => Right(testStream));

    // Act
    final result = await usecase(SendMessageParams(message: 'test message'));

    // Assert
    expect(result.isRight(), true);
    result.fold(
      (failure) => fail('Should not fail'),
      (stream) async {
        final chunks = await stream.toList();
        expect(chunks, ['Hello', ' world']);
      },
    );
  });
}
```

### Widget Tests (Presentation Layer)

```dart
// test/features/chat/presentation/widgets/message_bubble_test.dart

import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MessageBubble displays AI message correctly', (tester) async {
    // Arrange
    const message = Message(
      id: '1',
      text: 'Hello from AI',
      isUser: false,
      timestamp: DateTime(2026, 1, 16, 10, 30),
    );

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessageBubble(message: message),
        ),
      ),
    );

    // Assert
    expect(find.text('Hello from AI'), findsOneWidget);
    expect(find.text('10:30'), findsOneWidget);

    final container = tester.widget<Container>(find.byType(Container).first);
    expect(
      (container.decoration as BoxDecoration).color,
      MnesisColors.surfaceDark,
    );
  });
}
```

### Integration Tests (API Mocking)

```dart
// test/features/chat/data/datasources/chat_remote_datasource_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late ChatRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = ChatRemoteDataSourceImpl(
      httpClient: mockHttpClient,
      baseUrl: 'https://api.test.com',
      getAccessToken: () => 'test-token',
    );
  });

  test('should stream chat response chunks', () async {
    // Arrange
    final streamData = 'data: {"chunk": "Hello"}\ndata: {"chunk": " world"}\ndata: [DONE]\n';
    when(() => mockHttpClient.send(any())).thenAnswer(
      (_) async => http.StreamedResponse(
        Stream.value(utf8.encode(streamData)),
        200,
      ),
    );

    // Act
    final stream = await dataSource.streamChatResponse(message: 'test');
    final chunks = await stream.toList();

    // Assert
    expect(chunks, ['Hello', ' world']);
  });
}
```

---

## Migration from Volan

### Key Differences

| Aspect | Volan Flutter | Mnesis |
|--------|---------------|--------|
| **Primary Feature** | Authentication | Chat |
| **State Management** | Riverpod | Riverpod (same) |
| **Backend Communication** | HTTP REST | HTTP REST + SSE Streaming |
| **Local Storage** | Flutter Secure Storage (minimal) | SQLite (messages cache) |
| **Offline Support** | Session cache only | Chat history cache only |
| **Architecture** | 3-tier Clean Architecture | 3-tier Clean Architecture (same) |
| **Testing** | Mocktail | Mocktail (same) |

### Migration Steps

1. **Copy Core Infrastructure**
   - ✅ Copy `/lib/core/` directory (DI, errors, utils)
   - ✅ Copy `/lib/shared/` directory (widgets, themes)
   - ✅ Adapt theme to Mnesis design system (orange primary, dark background)

2. **Adapt Auth Feature**
   - ✅ Keep auth structure from Volan
   - ✅ Update to Mnesis theme/colors

3. **Create Chat Feature (New)**
   - ✅ Implement chat feature from scratch (no equivalent in Volan)
   - ✅ Add SSE streaming client
   - ✅ Add SQLite message cache

4. **Create Thin Features (New)**
   - ✅ Implement patients, appointments, cases as thin API wrappers
   - ✅ Follow Volan's 3-tier structure but minimal logic

5. **Update DI Configuration**
   - ✅ Add SQLite database provider
   - ✅ Add SSE client provider
   - ✅ Add new feature providers

### Code Reuse from Volan

**100% Reusable**:
- `/lib/core/di/injection_container.dart`
- `/lib/core/errors/` (exceptions, failures)
- `/lib/core/utils/app_logger.dart`
- `/test/helpers/` (test mocks, helpers)

**Adaptable**:
- `/lib/shared/widgets/` (change colors to Mnesis theme)
- `/lib/features/auth/` (keep structure, update theme)

**New (Mnesis-Specific)**:
- `/lib/features/chat/` (entirely new)
- `/lib/features/patients/`, `/appointments/`, `/cases/` (new thin features)
- `/lib/core/database/` (SQLite setup)

---

## Conclusion

### Architecture Summary

Mnesis is a **backend-heavy, chat-first application** where:
- 🧠 **LLM backend handles all business logic** (patients, appointments, studies)
- 💬 **Chat is the primary interface** for all functionality
- 📱 **Flutter app is a thin client** (UI + API wrappers)
- 💾 **Minimal local storage** (messages cache only)
- 🌊 **Streaming-first** (SSE for real-time AI responses)

### Next Steps

1. **Review this architecture** with backend team to confirm API contract
2. **Create SQLite schema** in Flutter (messages + conversations tables)
3. **Implement chat feature** following Volan's 3-tier structure
4. **Add SSE streaming client** for real-time responses
5. **Create thin features** (patients, appointments, cases) as API wrappers
6. **Write tests** (unit, widget, integration) with 80%+ coverage

---

**Document Version**: 2.0.0
**Author**: fft-architecture (FlowForge Agent)
**Last Updated**: 2026-01-16
**Status**: ✅ Active - Ready for Implementation

---

> 💡 **Critical Reminder**: Mnesis does NOT need complex local CRUD logic. Almost all business logic lives in the backend LLM. Keep the Flutter app simple, focused on chat UI/UX, and streaming integration.
