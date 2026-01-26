# Mnesis MVP Implementation Plan

**Status**: ✅ Active
**Version**: 1.0.0
**Last Updated**: 2026-01-23
**Approach**: Option Charlie (Hybrid Preservation)
**Timeline**: 2 weeks (45-60 hours)

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Week 1: Infrastructure + Auth + Navigation](#week-1-infrastructure--auth--navigation)
3. [Week 2: Screens + Integration](#week-2-screens--integration)
4. [Testing Requirements](#testing-requirements)
5. [Quality Gates](#quality-gates)
6. [Daily Breakdown](#daily-breakdown)

---

## Overview

### MVP Scope (5+1 Screens)
1. Login (placeholder design)
2. Home (patient list)
3. Chat Assistente (AI chat per patient)
4. Resumo Paciente (patient summary)
5. Anexos (attachment list)
6. Visualização Anexo (PDF/image viewer)

### Architecture Approach
- **Option**: Charlie (Hybrid Preservation)
- **Preserve**: Design system (Grade A), DI, tests (1,165), SQLite foundation
- **Remove**: Chat Secretaria, Agenda, appointments_cache, horizontal navigation
- **Add**: 6 MVP screens with mock data

### Effort Estimate
- **Best Case**: 45 hours (9 days)
- **Expected**: 50-55 hours (10-11 days)
- **Worst Case**: 60 hours (12 days)
- **Buffer**: 2-3 days

---

## Week 1: Infrastructure + Auth + Navigation

**Goal**: Prepare foundation, clean unused features, implement auth + navigation
**Duration**: 20-25 hours

---

### Day 1-2: Refactoring (8 hours)

#### Task 1.1: Remove Chat Secretaria Feature (3h)
**Objective**: Clean up doctor ↔ secretary chat code

**Steps**:
1. Identify Chat Secretaria files:
   ```bash
   find lib/features -name "*secretaria*" -o -name "*secretary*"
   ```
2. Remove feature files:
   ```bash
   lib/features/chat_secretaria/
   ├── data/
   ├── domain/
   └── presentation/
   ```
3. Remove from navigation routes (go_router)
4. Remove from DI configuration (injection.dart)
5. Remove tests:
   ```bash
   test/features/chat_secretaria/
   ```
6. Update imports across codebase
7. Run `flutter analyze` to verify

**Acceptance Criteria**:
- [ ] No chat_secretaria references in codebase
- [ ] `flutter analyze` clean
- [ ] All tests still passing
- [ ] DI graph resolves correctly

---

#### Task 1.2: Remove Agenda Feature (2h)
**Objective**: Remove calendar view components

**Steps**:
1. Remove Agenda widgets:
   ```bash
   lib/features/agenda/
   lib/shared/widgets/calendar/
   ```
2. Remove from navigation
3. Remove agenda dependencies from pubspec.yaml (if any):
   ```yaml
   # Remove if present:
   # table_calendar: ^x.x.x
   ```
4. Remove tests
5. Update documentation references

**Acceptance Criteria**:
- [ ] No agenda/calendar references
- [ ] Unused dependencies removed
- [ ] Tests passing

---

#### Task 1.3: Remove appointments_cache Table (1h)
**Objective**: Simplify database schema

**Steps**:
1. Remove table from drift schema:
   ```dart
   // Remove from lib/core/database/app_database.dart
   @DriftDatabase(tables: [
     ConversationsTable,
     MessagesTable,
     // REMOVE: AppointmentsCacheTable,
   ])
   ```
2. Generate new database code:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
3. Remove related DAOs/queries
4. Update database migration version
5. Remove tests for appointments_cache

**Acceptance Criteria**:
- [ ] appointments_cache table removed
- [ ] Database migrations updated
- [ ] Code generation successful
- [ ] Database tests passing

---

#### Task 1.4: Simplify Navigation Structure (2h)
**Objective**: Remove horizontal scroll navigation, keep simple flow

**Steps**:
1. Update go_router configuration:
   ```dart
   final router = GoRouter(
     routes: [
       GoRoute(
         path: '/',
         builder: (context, state) => LoginScreen(),
       ),
       GoRoute(
         path: '/home',
         builder: (context, state) => HomeScreen(),
       ),
       GoRoute(
         path: '/patient/:patientId',
         builder: (context, state) {
           final patientId = state.params['patientId']!;
           return PatientPageView(patientId: patientId);
         },
       ),
     ],
   );
   ```
2. Remove horizontal scroll widgets
3. Update navigation tests
4. Verify deep linking still works

**Acceptance Criteria**:
- [ ] Clean navigation: Login → Home → PageView
- [ ] No horizontal scroll components
- [ ] Deep linking functional
- [ ] Navigation tests updated

---

### Day 3: Authentication (6 hours)

#### Task 2.1: Placeholder Login Screen (3h)
**Objective**: Functional login using existing design system

**Implementation**:
```dart
// lib/features/auth/presentation/screens/login_screen.dart
import 'package:mnesis_flutter/core/design_system/mnesis_colors.dart';
import 'package:mnesis_flutter/core/design_system/mnesis_spacings.dart';
import 'package:mnesis_flutter/core/design_system/mnesis_text_styles.dart';
import 'package:mnesis_flutter/shared/widgets/mnesis_button.dart';
import 'package:mnesis_flutter/shared/widgets/mnesis_input.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: MnesisColors.backgroundDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(MnesisSpacings.xl),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo placeholder
                  Icon(
                    Icons.medical_services,
                    size: 80,
                    color: MnesisColors.primaryOrange,
                  ),
                  SizedBox(height: MnesisSpacings.sm),
                  Text(
                    'Mnesis',
                    style: MnesisTextStyles.heading1.copyWith(
                      color: MnesisColors.primaryOrange,
                    ),
                  ),
                  SizedBox(height: MnesisSpacings.xl2),

                  // Email input
                  MnesisInput(
                    hintText: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email é obrigatório';
                      }
                      if (!value.contains('@')) {
                        return 'Email inválido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: MnesisSpacings.lg),

                  // Password input
                  MnesisInput(
                    hintText: 'Senha',
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Senha é obrigatória';
                      }
                      if (value.length < 6) {
                        return 'Senha deve ter pelo menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: MnesisSpacings.xl),

                  // Login button
                  authState.maybeWhen(
                    loading: () => const CircularProgressIndicator(
                      color: MnesisColors.primaryOrange,
                    ),
                    orElse: () => MnesisButton.primary(
                      label: 'Entrar',
                      onPressed: _handleLogin,
                      fullWidth: true,
                    ),
                  ),

                  // Error message
                  authState.maybeWhen(
                    error: (message) => Padding(
                      padding: EdgeInsets.only(top: MnesisSpacings.lg),
                      child: Text(
                        message,
                        style: MnesisTextStyles.bodyMedium.copyWith(
                          color: MnesisColors.error,
                        ),
                      ),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authNotifierProvider.notifier).login(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

**Acceptance Criteria**:
- [ ] Login screen renders correctly
- [ ] Uses existing MnesisInput + MnesisButton
- [ ] Form validation working
- [ ] Widget tests written

---

#### Task 2.2: Supabase Auth Integration (2h)
**Objective**: Integrate Supabase authentication

**Steps**:
1. Add Supabase dependency:
   ```yaml
   dependencies:
     supabase_flutter: ^2.0.0
   ```
2. Initialize Supabase in main.dart:
   ```dart
   await Supabase.initialize(
     url: EnvConfig.supabaseUrl,
     anonKey: EnvConfig.supabaseAnonKey,
   );
   ```
3. Implement AuthDataSource:
   ```dart
   class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
     final SupabaseClient client;

     @override
     Future<AuthUser> login({
       required String email,
       required String password,
     }) async {
       final response = await client.auth.signInWithPassword(
         email: email,
         password: password,
       );
       return AuthUser.fromSupabaseUser(response.user!);
     }
   }
   ```
4. Update DI configuration

**Acceptance Criteria**:
- [ ] Supabase initialized
- [ ] Login returns session token
- [ ] Error handling for invalid credentials
- [ ] Unit tests for AuthDataSource

---

#### Task 2.3: Session Management (1h)
**Objective**: Persist session, handle logout

**Implementation**:
```dart
// lib/features/auth/data/datasources/auth_local_datasource.dart
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage storage;

  @override
  Future<void> saveSession(String token) async {
    await storage.write(key: 'auth_token', value: token);
  }

  @override
  Future<String?> getSession() async {
    return await storage.read(key: 'auth_token');
  }

  @override
  Future<void> clearSession() async {
    await storage.delete(key: 'auth_token');
  }
}
```

**Acceptance Criteria**:
- [ ] Session persisted on login
- [ ] Session restored on app restart
- [ ] Logout clears session
- [ ] Navigation redirects correctly

---

### Day 4: Mock Data Setup (4 hours)

#### Task 3.1: Mock Patient Data (2h)
**Objective**: Create realistic patient mock data

**Implementation**:
```dart
// lib/shared/data/mock_patients.dart
import 'package:mnesis_flutter/features/patients/domain/entities/patient.dart';

class MockPatients {
  static final List<Patient> patients = [
    Patient(
      id: '1',
      name: 'João Silva',
      age: 45,
      gender: 'M',
      diagnosis: 'Hipertensão',
      lastVisit: DateTime(2026, 1, 15),
      status: PatientStatus.active,
      avatarUrl: null,
    ),
    Patient(
      id: '2',
      name: 'Maria Santos',
      age: 38,
      gender: 'F',
      diagnosis: 'Diabetes Tipo 2',
      lastVisit: DateTime(2026, 1, 20),
      status: PatientStatus.pending,
      avatarUrl: null,
    ),
    Patient(
      id: '3',
      name: 'Carlos Oliveira',
      age: 52,
      gender: 'M',
      diagnosis: 'Asma',
      lastVisit: DateTime(2026, 1, 10),
      status: PatientStatus.active,
      avatarUrl: null,
    ),
    // ... 10-15 total patients
  ];

  static Patient getById(String id) {
    return patients.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Patient not found'),
    );
  }

  static List<Patient> search(String query) {
    if (query.isEmpty) return patients;
    return patients.where((p) =>
      p.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
```

**Acceptance Criteria**:
- [ ] 10-15 diverse patient profiles
- [ ] Realistic names, ages, diagnoses
- [ ] Search functionality working
- [ ] Unit tests for search

---

#### Task 3.2: Mock Chat Responses (1h)
**Objective**: Simulate AI chat with context-aware responses

**Implementation**:
```dart
// lib/features/chat/data/datasources/mock_chat_datasource.dart
class MockChatDataSource implements ChatRemoteDataSource {
  @override
  Future<Stream<String>> streamChatResponse({
    required String message,
    String? conversationId,
  }) async {
    final response = _generateResponse(message);

    // Simulate streaming with 50ms delay per chunk
    return Stream.periodic(
      const Duration(milliseconds: 50),
      (index) {
        if (index >= response.length) return null;
        return response[index];
      },
    ).takeWhile((chunk) => chunk != null).cast<String>();
  }

  String _generateResponse(String userMessage) {
    final msg = userMessage.toLowerCase();

    if (msg.contains('exame')) {
      return 'Os exames do paciente indicam níveis normais de glicose e pressão arterial. Recomendo manter o acompanhamento mensal.';
    }
    if (msg.contains('medicação') || msg.contains('remédio')) {
      return 'A medicação atual inclui Losartana 50mg e Metformina 850mg. Não há contraindicações conhecidas.';
    }
    if (msg.contains('histórico')) {
      return 'O paciente apresenta histórico de hipertensão desde 2020, controlada com medicação. Última consulta em 15/01/2026.';
    }

    return 'Entendi. Posso ajudar com mais informações sobre o paciente. O que você gostaria de saber?';
  }
}
```

**Acceptance Criteria**:
- [ ] Contextual responses based on keywords
- [ ] Streaming simulation working
- [ ] Realistic medical content
- [ ] Unit tests for response generation

---

#### Task 3.3: Mock Attachments (1h)
**Objective**: Create attachment list with sample files

**Implementation**:
```dart
// lib/shared/data/mock_attachments.dart
class MockAttachments {
  static final List<Attachment> attachments = [
    Attachment(
      id: '1',
      name: 'Exame de Sangue - 15/01/2026.pdf',
      type: AttachmentType.pdf,
      size: 1024 * 250, // 250KB
      date: DateTime(2026, 1, 15),
      assetPath: 'assets/sample_exam.pdf',
    ),
    Attachment(
      id: '2',
      name: 'Raio-X Tórax.png',
      type: AttachmentType.image,
      size: 1024 * 512, // 512KB
      date: DateTime(2026, 1, 10),
      assetPath: 'assets/sample_xray.png',
    ),
    // ... 5-10 attachments
  ];

  static List<Attachment> getByPatientId(String patientId) {
    // For MVP, return same attachments for all patients
    return attachments;
  }
}
```

**Assets to Add**:
```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/sample_exam.pdf
    - assets/sample_xray.png
```

**Acceptance Criteria**:
- [ ] 5-10 mock attachments
- [ ] PDF and image types
- [ ] Sample files in assets/
- [ ] Unit tests

---

### Day 5: Navigation Setup (4 hours)

#### Task 4.1: go_router Configuration (2h)
**Objective**: Configure routing for MVP screens

**Implementation**:
```dart
// lib/core/router/app_router.dart
final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    // Auth guard
    final authState = context.read(authNotifierProvider);
    final isLoggedIn = authState.maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );

    final isGoingToLogin = state.location == '/';

    if (!isLoggedIn && !isGoingToLogin) {
      return '/';
    }
    if (isLoggedIn && isGoingToLogin) {
      return '/home';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/patient/:patientId',
      name: 'patient',
      builder: (context, state) {
        final patientId = state.pathParameters['patientId']!;
        return PatientPageView(patientId: patientId);
      },
    ),
    GoRoute(
      path: '/attachment/:attachmentId',
      name: 'attachment',
      builder: (context, state) {
        final attachmentId = state.pathParameters['attachmentId']!;
        return AttachmentViewerScreen(attachmentId: attachmentId);
      },
    ),
  ],
);
```

**Acceptance Criteria**:
- [ ] All MVP routes configured
- [ ] Auth guard redirects correctly
- [ ] Deep linking works
- [ ] Navigation tests written

---

#### Task 4.2: PageView Implementation (2h)
**Objective**: Setup Chat ↔ Resumo ↔ Anexos swipeable view

**Implementation**:
```dart
// lib/features/patients/presentation/screens/patient_page_view.dart
class PatientPageView extends ConsumerStatefulWidget {
  final String patientId;

  const PatientPageView({
    required this.patientId,
    super.key,
  });

  @override
  ConsumerState<PatientPageView> createState() => _PatientPageViewState();
}

class _PatientPageViewState extends ConsumerState<PatientPageView>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final patient = ref.watch(patientProvider(widget.patientId));

    return Scaffold(
      backgroundColor: MnesisColors.backgroundDark,
      appBar: AppBar(
        title: Text(patient.name),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          tabs: const [
            Tab(text: 'Chat'),
            Tab(text: 'Resumo'),
            Tab(text: 'Anexos'),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
          _tabController.animateTo(index);
        },
        children: [
          ChatAssistenteScreen(patientId: widget.patientId),
          ResumoPatienteScreen(patientId: widget.patientId),
          AnexosScreen(patientId: widget.patientId),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
```

**Acceptance Criteria**:
- [ ] 3 tabs: Chat, Resumo, Anexos
- [ ] Swipe gestures work
- [ ] Tab sync with page
- [ ] AppBar shows patient name
- [ ] Widget tests

---

## Week 2: Screens + Integration

**Goal**: Implement all 5 MVP screens and integrate
**Duration**: 25-35 hours

---

### Day 6: Home Screen (6 hours)

#### Task 5.1: Patient List (3h)
**Implementation**:
```dart
// lib/features/home/presentation/screens/home_screen.dart
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final patients = ref.watch(filteredPatientsProvider(_searchQuery));

    return Scaffold(
      backgroundColor: MnesisColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Pacientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(MnesisSpacings.lg),
            child: MnesisInput(
              hintText: 'Buscar paciente...',
              controller: _searchController,
              prefixIcon: const Icon(Icons.search),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Stats cards
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: MnesisSpacings.lg),
              children: [
                _buildStatCard('Total', patients.length.toString()),
                _buildStatCard('Ativos', _countByStatus(patients, PatientStatus.active).toString()),
                _buildStatCard('Pendentes', _countByStatus(patients, PatientStatus.pending).toString()),
              ],
            ),
          ),

          // Patient list
          Expanded(
            child: patients.isEmpty
                ? Center(
                    child: Text(
                      'Nenhum paciente encontrado',
                      style: MnesisTextStyles.bodyLarge.copyWith(
                        color: MnesisColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: patients.length,
                    padding: EdgeInsets.all(MnesisSpacings.lg),
                    itemBuilder: (context, index) {
                      final patient = patients[index];
                      return PatientCard(
                        patient: patient,
                        onTap: () {
                          context.push('/patient/${patient.id}');
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      width: 120,
      margin: EdgeInsets.only(right: MnesisSpacings.md),
      padding: EdgeInsets.all(MnesisSpacings.lg),
      decoration: BoxDecoration(
        color: MnesisColors.surfaceDark,
        borderRadius: BorderRadius.circular(MnesisSpacings.md),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: MnesisTextStyles.heading2.copyWith(color: MnesisColors.primaryOrange)),
          SizedBox(height: MnesisSpacings.xs),
          Text(label, style: MnesisTextStyles.bodySmall.copyWith(color: MnesisColors.textSecondary)),
        ],
      ),
    );
  }

  int _countByStatus(List<Patient> patients, PatientStatus status) {
    return patients.where((p) => p.status == status).length;
  }
}
```

**Acceptance Criteria**:
- [ ] Patient list displays all mock patients
- [ ] Search filters patients by name
- [ ] Stats cards show correct counts
- [ ] Tap navigates to Chat
- [ ] Widget tests

---

### Day 7-8: Chat Assistente (8 hours)

#### Task 6.1: Message List (4h)
**Implementation** in `lib/features/chat/presentation/screens/chat_assistente_screen.dart`

**Acceptance Criteria**:
- [ ] Message list with auto-scroll
- [ ] User and AI message bubbles
- [ ] Timestamp display
- [ ] Streaming indicator
- [ ] Widget tests

---

#### Task 6.2: Input Area (2h)
**Acceptance Criteria**:
- [ ] Text input field
- [ ] Send button
- [ ] Voice button (placeholder)
- [ ] Disable during streaming
- [ ] Widget tests

---

#### Task 6.3: Mock Streaming Integration (2h)
**Acceptance Criteria**:
- [ ] Connects to MockChatDataSource
- [ ] Displays streaming chunks in real-time
- [ ] Handles errors gracefully
- [ ] Widget tests

---

### Day 9: Resumo + Anexos (8 hours)

#### Task 7.1: Resumo Paciente Screen (4h)
**Acceptance Criteria**:
- [ ] Patient demographics display
- [ ] Medical history section
- [ ] Stats/metrics
- [ ] Widget tests

---

#### Task 7.2: Anexos Screen (4h)
**Acceptance Criteria**:
- [ ] Attachment list from mock data
- [ ] File metadata (name, size, date)
- [ ] Tap navigates to viewer
- [ ] Widget tests

---

### Day 10: Attachment Viewer (4 hours)

#### Task 8.1: PDF Viewer (2h)
**Dependencies**:
```yaml
dependencies:
  flutter_pdfview: ^1.3.0
```

**Acceptance Criteria**:
- [ ] PDF renders from assets
- [ ] Zoom controls
- [ ] Page navigation
- [ ] Widget tests

---

#### Task 8.2: Image Viewer (2h)
**Acceptance Criteria**:
- [ ] Image displays full-screen
- [ ] Pinch to zoom
- [ ] Close button
- [ ] Widget tests

---

### Day 11: Integration + Polish (4 hours)

#### Task 9.1: End-to-End Testing (2h)
**Test Flow**:
1. Login → Home
2. Search patient → Tap
3. Chat: Send message → See response
4. Swipe to Resumo → See details
5. Swipe to Anexos → Tap attachment
6. View PDF → Close
7. Logout

**Acceptance Criteria**:
- [ ] All screens navigable
- [ ] No crashes or errors
- [ ] Smooth transitions
- [ ] Mock data loads correctly

---

#### Task 9.2: Bug Fixes + Polish (2h)
**Checklist**:
- [ ] Fix any integration bugs
- [ ] Smooth animations
- [ ] Loading states
- [ ] Error handling
- [ ] Code review fixes

---

## Testing Requirements

### Minimum Test Coverage: 80%

#### Unit Tests
- [ ] Mock data providers (search, filtering)
- [ ] Chat response generation
- [ ] Navigation logic
- [ ] Form validation

#### Widget Tests
- [ ] LoginScreen (form, validation)
- [ ] HomeScreen (list, search, stats)
- [ ] ChatAssistenteScreen (messages, input)
- [ ] ResumoPatienteScreen (data display)
- [ ] AnexosScreen (list)
- [ ] AttachmentViewerScreen (viewer)

#### Integration Tests
- [ ] Login → Home flow
- [ ] Home → Patient PageView flow
- [ ] Chat streaming simulation
- [ ] Attachment viewing

---

## Quality Gates

### Before Week 2 Start
- [ ] Refactoring complete (unused features removed)
- [ ] Auth working (login + session)
- [ ] Mock data ready (patients, chat, attachments)
- [ ] Navigation configured
- [ ] All Week 1 tests passing

### Before MVP Completion
- [ ] All 6 screens implemented
- [ ] 80%+ test coverage achieved
- [ ] `flutter analyze` clean (zero issues)
- [ ] No hardcoded strings (use constants)
- [ ] All functions documented (Dart docs)
- [ ] No AI references in code/commits
- [ ] End-to-end flow tested

---

## Daily Breakdown

### Week 1 Schedule

| Day | Hours | Tasks | Deliverables |
|-----|-------|-------|--------------|
| Mon | 4h | Remove Chat Secretaria, Agenda | Clean codebase |
| Tue | 4h | Remove appointments_cache, simplify navigation | Updated navigation |
| Wed | 6h | Placeholder login, Supabase auth, session | Functional login |
| Thu | 4h | Mock patients, chat, attachments | Mock data ready |
| Fri | 4h | go_router config, PageView setup | Navigation complete |

**Week 1 Total**: 22 hours

---

### Week 2 Schedule

| Day | Hours | Tasks | Deliverables |
|-----|-------|-------|--------------|
| Mon | 6h | Home screen (list, search, stats) | Home complete |
| Tue | 4h | Chat: message list | Chat UI |
| Wed | 4h | Chat: input area, streaming | Chat functional |
| Thu (AM) | 4h | Resumo Paciente screen | Resumo complete |
| Thu (PM) | 4h | Anexos screen | Anexos complete |
| Fri (AM) | 4h | Attachment viewer (PDF + image) | Viewer complete |
| Fri (PM) | 4h | Integration testing, bug fixes, polish | MVP ready |

**Week 2 Total**: 30 hours

---

## Risk Mitigation

### High-Risk Tasks

#### Risk 1: PageView Navigation Complexity
**Mitigation**: Reference Flutter docs, test on devices, allocate buffer time

#### Risk 2: PDF Viewer Platform Issues
**Mitigation**: Test early on iOS + Android, have fallback (external viewer)

#### Risk 3: Refactoring Scope Creep
**Mitigation**: Time-box to 8 hours, focus only on MVP-excluded features

---

## Success Criteria

### Functional Requirements
- [ ] User can log in (placeholder UI)
- [ ] User can search/view patient list
- [ ] User can navigate to Chat per patient
- [ ] User can send messages, see mock AI responses
- [ ] User can swipe between Chat/Resumo/Anexos
- [ ] User can view patient summary
- [ ] User can see attachment list
- [ ] User can view PDF/image attachments

### Quality Requirements
- [ ] 80%+ test coverage
- [ ] Zero critical bugs
- [ ] `flutter analyze` clean
- [ ] Smooth navigation (60 FPS)
- [ ] WCAG AA accessibility compliance

### Documentation Requirements
- [ ] MVP_DECISIONS.md complete
- [ ] IMPLEMENTATION_PLAN.md complete (this doc)
- [ ] Updated ARCHITECTURE.md
- [ ] Updated README.md
- [ ] All functions documented (Dart docs)

---

## Next Steps After MVP

### v1 Planning (Post-MVP)
1. **Backend Integration** (30h)
   - Replace mock providers with real APIs
   - Implement SSE streaming
   - Error handling for network failures

2. **Final Auth Design** (2-3h)
   - Replace placeholder login UI
   - Keep authentication logic

3. **Restore Removed Features** (if needed)
   - Chat Secretaria (20h)
   - Agenda (15h)
   - appointments_cache (4h)

4. **Production Readiness** (15h)
   - Performance optimization
   - Security audit
   - App store submission

---

**Document Version**: 1.0.0
**Author**: fft-documentation (FlowForge Agent)
**Last Updated**: 2026-01-23
**Status**: ✅ Active - Ready for Development

---

> 💡 **Implementation Philosophy**: Preserve quality (Grade A design system, 1,165 tests), remove unused features, add MVP screens with mock data. Test-driven, documented, maintainable.
