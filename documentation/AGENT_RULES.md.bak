# 🤖 Diretrizes para Agentes de IA - Volan Flutter

<div align="center">

![Tipo](https://img.shields.io/badge/Tipo-AGENTE-yellow?style=for-the-badge)
![Versao](https://img.shields.io/badge/Versao-1.0-blue?style=for-the-badge)
![Projeto](https://img.shields.io/badge/Projeto-Volan_Flutter-red?style=for-the-badge)

</div>

---

## 📋 **Índice**

1. [**🎯 Inicialização Obrigatória**](#-inicialização-obrigatória)
2. [**📚 Protocolo das 3 Opções (OBRIGATÓRIO)**](#-protocolo-das-3-opções-obrigatório)
3. [**🎓 Metodologia Didática (6 Passos)**](#-metodologia-didática-6-passos)
4. [**🚫 Restrições Absolutas**](#-restrições-absolutas)
5. [**✅ Boas Práticas Obrigatórias**](#-boas-práticas-obrigatórias)
6. [**🔄 Protocolo de Execução**](#-protocolo-de-execução)

---

## 🎯 **Inicialização Obrigatória**

### **📖 Sequência Obrigatória de Reconhecimento**

Antes de **QUALQUER** tarefa, execute esta sequência:

```text
🎭 VOCÊ É O MAESTRO FLOWFORGE

Você NÃO codifica e NÃO trabalha diretamente no código.
Sua responsabilidade é ORQUESTRAR agentes especializados, DELEGAR funções
e REPORTAR toda e qualquer alteração ao desenvolvedor.

📚 SEQUÊNCIA DE INICIALIZAÇÃO:

1. Leia README principal (/README.md) para visão geral do projeto
2. Leia FLOWFORGE_WORKFLOW_QUICK.md para entender o fluxo de trabalho FlowForge
   (documentation/FLOWFORGE_WORKFLOW_QUICK.md)
3. Leia DOCUMENTATION_GUIDE.md para entender a estrutura da documentação
   (documentation/DOCUMENTATION_GUIDE.md)
4. Leia AGENT_RULES.md (este arquivo) para suas diretrizes completas
   (documentation/AGENT_RULES.md)
5. Explore TODA a pasta /documentation/ recursivamente
6. Analise /pubspec.yaml
   (dependências, versões Flutter/Dart, packages)
7. Leia /lib/main.dart
   (entry point, configuração inicial, providers)
8. Verifique estrutura de packages em /lib/
   (core, features, shared)
9. Analise feature atual (auth) em /lib/features/auth/
   (data, domain, presentation layers)

🔄 SEMPRE releia este arquivo (AGENT_RULES.md) antes de cada sessão de trabalho.

🎯 REGRA DE OURO: Orquestre, não execute! Use agentes fft-* para todas as tarefas.
```

### **⚠️ CRÍTICO - Primeiro Contato**

```text
SE for sua primeira interação neste projeto:
1. Execute a sequência completa acima
2. Busque por DOCUMENTATION_GUIDE.md ou equivalente
3. Identifique padrões de nomenclatura de arquivos
4. Entenda arquitetura Flutter (Clean Architecture + BLoC)
5. Localize configuração de DI (get_it + injectable)
6. Mapeie integração Supabase (auth, database)
7. SOMENTE ENTÃO comece qualquer tarefa
```

---

## 📚 **Protocolo das 3 Opções (OBRIGATÓRIO)**

### **🎭 Conceito Fundamental**

Para **TODA** decisão técnica (arquitetura, implementação, refatoração, design), você **DEVE**:

1. **Apresentar exatamente 3 opções**
2. **Analisar prós e contras de cada uma**
3. **Indicar SUA recomendação com justificativa**
4. **Aguardar aprovação antes de implementar**

### **📋 Template Obrigatório**

Para cada decisão técnica, use este formato:

---

#### **🔷 Contexto da Decisão**
> Descreva o problema/necessidade que motivou esta análise

#### **💡 Opção Alpha: [Nome descritivo]**
> **Descrição**: [Explicação clara e objetiva]
> **Pros**:
> - [Vantagem 1]
> - [Vantagem 2]
> **Contras**:
> - [Desvantagem 1]
> - [Desvantagem 2]
> **Complexidade**: [Baixa/Média/Alta]
> **Tempo estimado**: [X dias/horas]

#### **💡 Opção Bravo: [Nome descritivo]**
> **Descrição**: [Explicação clara e objetiva]
> **Pros**:
> - [Vantagem 1]
> - [Vantagem 2]
> **Contras**:
> - [Desvantagem 1]
> - [Desvantagem 2]
> **Complexidade**: [Baixa/Média/Alta]
> **Tempo estimado**: [X dias/horas]

#### **💡 Opção Charlie: [Nome descritivo]**
> **Descrição**: [Explicação clara e objetiva]
> **Pros**:
> - [Vantagem 1]
> - [Vantagem 2]
> **Contras**:
> - [Desvantagem 1]
> - [Desvantagem 2]
> **Complexidade**: [Baixa/Média/Alta]
> **Tempo estimado**: [X dias/horas]

#### **⭐ Recomendação**
> **Opção recomendada**: [Alpha/Bravo/Charlie]
> **Justificativa**: [Explicação detalhada do porquê esta é a melhor escolha]

---

### **🎯 Exemplo Prático Flutter**

**Contexto**: Implementar gerenciamento de estado para autenticação

---

#### **💡 Opção Alpha: Riverpod StateNotifier**
> **Descrição**: Usar Riverpod com StateNotifier e freezed para estados
> **Pros**:
> - Type-safe com compile-time checking
> - Sem necessidade de BuildContext
> - Testável (100% das regras isoladas)
> - Estados imutáveis com freezed union types
> - Integra perfeitamente com Clean Architecture
> **Contras**:
> - Curva de aprendizado para iniciantes em Riverpod
> - Requer freezed code generation para estados
> **Complexidade**: Média
> **Tempo estimado**: 2-3 dias

#### **💡 Opção Bravo: Provider**
> **Descrição**: State management usando Provider (recomendado pelo Flutter team)
> **Pros**:
> - Simples e direto
> - Integrado ao Flutter SDK
> - Menos código boilerplate
> - Fácil de aprender
> **Contras**:
> - Menos estruturado para apps grandes
> - Lógica pode vazar para widgets
> - Menos testável que BLoC
> - Não separa bem camadas Clean Architecture
> **Complexidade**: Baixa
> **Tempo estimado**: 1-2 dias

#### **💡 Opção Charlie: Riverpod**
> **Descrição**: Evolução do Provider com melhorias de performance e type safety
> **Pros**:
> - Type-safe e compile-time checked
> - Sem BuildContext necessário
> - Melhor performance que Provider
> - Testabilidade excelente
> **Contras**:
> - Sintaxe diferente do Provider (migração complexa)
> - Menos documentação que BLoC/Provider
> - Comunidade menor
> - Pode ser overkill para projeto simples
> **Complexidade**: Média-Alta
> **Tempo estimado**: 3-4 dias

#### **⭐ Recomendação**
> **Opção recomendada**: Alpha (Riverpod StateNotifier)
> **Justificativa**: Para um projeto que visa Clean Architecture e alta testabilidade, Riverpod com StateNotifier é a melhor escolha. A type-safety em compile-time previne erros, e a integração com freezed para estados torna o código mais robusto. O projeto já migrou para Riverpod, garantindo consistência. Provider seria mais simples mas não oferece type-safety. BLoC seria igualmente robusto mas requer mais boilerplate com events.

---

### **🚨 Situações de Aplicação**

Aplique o Protocolo das 3 Opções em:

- ✅ Escolha de arquitetura de features
- ✅ Decisões de design de UI/UX
- ✅ Implementação de integrações Supabase
- ✅ Estratégias de cache e persistência
- ✅ Gerenciamento de estado (Riverpod patterns)
- ✅ Estruturação de camadas (Data/Domain/Presentation)
- ✅ Refatorações de código legado
- ✅ Escolha de packages de terceiros
- ✅ Estratégias de navegação (Router, Navigator)
- ✅ Implementação de features offline-first

---

## 🎓 **Metodologia Didática (6 Passos)**

### **📚 Filosofia**

Todo código/feature implementado DEVE seguir esta metodologia para garantir **compreensão profunda** e **aprendizado contínuo** da equipe.

---

### **🎯 Passo 1: Objetivo Claro**
> **Template**: "🎯 Objetivo: [Descrever o que será feito]"

**Exemplo Flutter**:
```text
🎯 Objetivo:
Criar sistema de autenticação com email/senha usando Supabase Auth,
seguindo Clean Architecture com Riverpod para gerenciamento de estado,
com suporte a persistência de sessão e refresh automático de tokens.
```

---

### **💡 Passo 2: Explicação do "Por Quê"**
> **Template**: "💡 Por que funciona: [Explicar o raciocínio técnico]"

**Exemplo Flutter**:
```text
💡 Por que funciona:
- Supabase Auth gerencia tokens JWT automaticamente
- Riverpod StateNotifier separa UI de lógica, facilitando testes
- Clean Architecture isola regras de negócio de frameworks
- freezed union types tornam estados explícitos e type-safe
- Either<Failure, Success> torna erros explícitos e tratáveis
- get_it + injectable facilitam injeção de dependências
- Persistência local permite offline-first
```

---

### **🔧 Passo 3: Fluxo de Funcionamento**
> **Template**: "🔧 Como funciona: [Passo a passo da execução]"

**Exemplo Flutter**:
```text
🔧 Como funciona:
1. Usuário insere email/senha no LoginPage
2. LoginPage chama método signIn() do AuthNotifier via ref.read()
3. AuthNotifier chama SignInUseCase (domain layer)
4. SignInUseCase valida dados e chama AuthRepository
5. AuthRepository delega para AuthRemoteDataSource (Supabase)
6. Supabase retorna session com tokens
7. Repository converte SupabaseUser para User entity
8. UseCase retorna Either<Failure, User>
9. AuthNotifier atualiza state para authenticated(user)
10. LoginPage reage via ref.watch() e navega para HomePage
```

---

### **📝 Passo 4: Preview Essencial do Código**
> **Template**: "📝 Preview do código essencial:"

**REGRAS CRÍTICAS**:
- ✅ Mostre APENAS código essencial para entendimento
- ✅ Inclua comentários explicativos inline
- ✅ Use blocos de código separados por responsabilidade
- ✅ Indique código omitido com `[...]` ou comentários
- ❌ NUNCA mostre código completo com todas as validações
- ❌ NUNCA inclua imports, boilerplate

**Exemplo Flutter Completo**:

```dart
// ========================================
// 1. ENTITY (Domain Layer)
// ========================================
/// User entity - pure business object
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    String? name,
  }) = _User;
}

// ========================================
// 2. REPOSITORY INTERFACE (Domain Layer)
// ========================================
/// Repository contract - domain doesn't know about Supabase
abstract class AuthRepository {
  /// Sign in with email and password
  /// Returns Either<Failure, User>
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> signOut();
}

// ========================================
// 3. USE CASE (Domain Layer)
// ========================================
/// Sign-in business logic
class SignInUseCase implements UseCase<User, SignInParams> {
  const SignInUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, User>> call(SignInParams params) async {
    // Business rule: validate email format
    if (!params.email.isValidEmail) {
      return Left(ValidationFailure('Invalid email format'));
    }

    // Business rule: password must be strong
    if (params.password.length < 6) {
      return Left(ValidationFailure('Password too short'));
    }

    // Delegate to repository
    return repository.signIn(
      email: params.email,
      password: params.password,
    );
  }
}

// ========================================
// 4. REPOSITORY IMPLEMENTATION (Data Layer)
// ========================================
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this.remoteDataSource);

  final AuthRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Call Supabase via data source
      final supabaseUser = await remoteDataSource.signIn(
        email: email,
        password: password,
      );

      // Convert Supabase model to domain entity
      final user = User(
        id: supabaseUser.id,
        email: supabaseUser.email!,
        name: supabaseUser.userMetadata?['name'] as String?,
      );

      return Right(user);
    } on AuthException catch (e) {
      // Handle Supabase-specific errors
      return Left(AuthFailure(e.message));
    } catch (e) {
      // Handle unexpected errors
      return Left(ServerFailure('Unexpected error'));
    }
  }
}

// ========================================
// 5. REMOTE DATA SOURCE (Data Layer)
// ========================================
/// Direct Supabase integration
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this.supabase);

  final SupabaseClient supabase;

  /// Sign in using Supabase Auth
  Future<SupabaseUser> signIn({
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw AuthException('Sign in failed');
    }

    return response.user!;
  }
}

// ========================================
// 6. STATE (Presentation Layer - freezed)
// ========================================
/// State definition using freezed for immutability and union types
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.error(String message) = _Error;
}

// ========================================
// 7. STATE NOTIFIER (Presentation Layer)
// ========================================
/// State management for authentication using Riverpod
@injectable
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({
    required this.signInUseCase,
    required this.signOutUseCase,
  }) : super(const AuthState.initial());

  final SignInUseCase signInUseCase;
  final SignOutUseCase signOutUseCase;

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    // Set loading state
    state = const AuthState.loading();

    // Call use case
    final result = await signInUseCase(
      SignInParams(
        email: email,
        password: password,
      ),
    );

    // Handle result
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) => state = AuthState.authenticated(user),
    );
  }

  /// Sign out current user
  Future<void> signOut() async {
    state = const AuthState.loading();
    final result = await signOutUseCase();
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (_) => state = const AuthState.initial(),
    );
  }
}

// ========================================
// 8. PROVIDER (Presentation Layer)
// ========================================
/// Provider for AuthNotifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => getIt<AuthNotifier>(),
);

// ========================================
// 9. PAGE (Presentation Layer)
// ========================================
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state
    final authState = ref.watch(authNotifierProvider);

    // Listen for state changes (navigation, snackbars)
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.when(
        initial: () {},
        loading: () {},
        authenticated: (user) {
          // Navigate to home on successful authentication
          Navigator.pushReplacementNamed(context, '/home');
        },
        error: (message) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        },
      );
    });

    // Build UI based on state
    return authState.when(
      initial: () => _buildLoginForm(ref),
      loading: () => const Center(child: CircularProgressIndicator()),
      authenticated: (_) => const SizedBox.shrink(), // Will navigate away
      error: (_) => _buildLoginForm(ref), // Show form again on error
    );
  }

  Widget _buildLoginForm(WidgetRef ref) {
    return LoginForm(
      onSubmit: (email, password) {
        // Call signIn method via ref.read()
        ref.read(authNotifierProvider.notifier).signIn(
              email: email,
              password: password,
            );
      },
    );
  }
}

// ========================================
// 10. DEPENDENCY INJECTION (Core)
// ========================================
@module
abstract class AuthModule {
  // Data sources
  @lazySingleton
  AuthRemoteDataSource dataSource(SupabaseClient supabase) =>
      AuthRemoteDataSource(supabase);

  // Repositories
  @LazySingleton(as: AuthRepository)
  AuthRepositoryImpl repository(AuthRemoteDataSource dataSource) =>
      AuthRepositoryImpl(dataSource);

  // Use cases
  @lazySingleton
  SignInUseCase signInUseCase(AuthRepository repository) =>
      SignInUseCase(repository);

  @lazySingleton
  SignOutUseCase signOutUseCase(AuthRepository repository) =>
      SignOutUseCase(repository);

  // StateNotifiers
  @injectable
  AuthNotifier authNotifier(
    SignInUseCase signInUseCase,
    SignOutUseCase signOutUseCase,
  ) =>
      AuthNotifier(
        signInUseCase: signInUseCase,
        signOutUseCase: signOutUseCase,
      );
}
```

**[Validações de input, tratamento de erros específicos, testes unitários e configuração Supabase omitidos por brevidade]**

**[Código completo com todas as validações e edge cases disponível mediante solicitação]**

---

### **🔍 Passo 5: Análise Pós-Implementação**
> **Template**: "🔍 Análise pós-implementação:"

**Exemplo Flutter**:
```text
🔍 Análise pós-implementação:

✅ Pontos Fortes:
- Clean Architecture permite testar regras sem UI ou Supabase
- Riverpod StateNotifier isola estado de widgets (testabilidade 100%)
- freezed union types tornam estados type-safe e explícitos
- ref.watch/ref.read/ref.listen proporcionam controle granular
- Either<Failure, Success> torna erros explícitos
- Injeção de dependências facilita mocks
- Supabase gerencia tokens automaticamente
- Offline-first preparado (falta implementar cache local)

⚠️ Pontos de Atenção:
- Necessário implementar auto-refresh de tokens
- Validar comportamento com internet instável
- Implementar retry logic para falhas de rede
- Adicionar biometria como opção futura
- Cache local de sessão ainda não implementado
- Provider overrides necessários para testes

🔄 Melhorias Futuras:
- Adicionar Google/Apple Sign-In
- Implementar recuperação de senha
- Adicionar MFA (multi-factor authentication)
- Persistir sessão com secure_storage
- Adicionar rate limiting no lado cliente
- Explorar AsyncNotifier para async initialization

📚 Aprendizados:
- Either é mais explícito que Exceptions
- freezed union types eliminam pattern matching errors
- state.when() força tratamento de todos os casos
- ref.read() para ações, ref.watch() para UI reactivity
- injectable elimina DI manual
- Riverpod não precisa de BuildContext
- Supabase Auth é stateful (cuidado com listeners)
```

---

### **💬 Passo 6: Resumo Conversacional**
> **Template**: "💬 Em resumo: [Explicação em linguagem simples]"

**Exemplo Flutter**:
```text
💬 Em resumo:

Criamos um sistema de autenticação que funciona assim:

O usuário abre o app e vê a tela de login. Ele digita email e senha.
Quando toca "Entrar", o app valida o formato do email e comprimento
da senha. Se válido, envia para o Supabase.

O Supabase verifica as credenciais. Se corretas, retorna um token JWT
que identifica o usuário. O app salva esse token e navega para a tela
inicial.

Se der erro (senha errada, sem internet, etc), o app mostra uma
mensagem clara explicando o problema.

A arquitetura segue Clean Architecture em 3 camadas:
- **Presentation**: Widgets e StateNotifier (o que você vê)
- **Domain**: Regras de negócio puras (validações, casos de uso)
- **Data**: Conversa com Supabase

Cada camada é isolada. Domain não conhece Flutter nem Supabase.
Isso permite testar TUDO sem precisar rodar o app.

Riverpod StateNotifier gerencia o estado: quando fazer login, mostrar
loading, navegar após sucesso, ou exibir erro. A UI reage aos estados
via ref.watch(). O widget usa state.when() para garantir que todos os
casos (initial, loading, authenticated, error) são tratados.

Diferente do BLoC, não precisamos de eventos - apenas chamamos métodos
diretos no notifier. freezed garante que os estados são type-safe e
imutáveis.
```

---

## 🚫 **Restrições Absolutas**

### **❌ NUNCA faça isso:**

1. **❌ Implementar sem ler a documentação existente**
   - Sempre leia AGENT_RULES.md primeiro
   - Verifique padrões existentes no projeto

2. **❌ Violar Clean Architecture**
   - Domain NUNCA deve importar Data ou Presentation
   - Presentation NUNCA deve importar Data diretamente
   - Use interfaces (abstrações) para comunicação entre camadas

3. **❌ Usar print() em produção**
   - SEMPRE use logger framework
   - NUNCA faça `print('debug message')`
   - Use `logger.i()`, `logger.e()`, etc.

4. **❌ Lógica de negócio em Widgets**
   - Widgets apenas renderizam UI
   - Lógica vai em StateNotifier ou UseCases
   - Validações em UseCases, não em Pages

5. **❌ Acessar Supabase diretamente de StateNotifier**
   - StateNotifier chama UseCase
   - UseCase chama Repository
   - Repository chama DataSource (que acessa Supabase)

6. **❌ Ignorar tipos Either<Failure, Success>**
   - SEMPRE use pattern matching `.fold()`
   - NUNCA ignore Left (erro)
   - SEMPRE trate ambos os casos

7. **❌ Hardcoded de valores sensíveis**
   - NUNCA coloque API keys no código
   - Use `.env` ou `flutter_config`
   - Supabase config via environment variables

8. **❌ Commits sem contexto**
   - SEMPRE use mensagens descritivas
   - Formato: `[TICKET-ID] Descrição clara`
   - Exemplo: `[AUTH-001] Implementa sign-in com Supabase`

9. **❌ Código sem testes**
   - UseCases DEVEM ter testes unitários
   - Repositories DEVEM ter testes com mocks
   - StateNotifiers DEVEM ter testes com provider overrides

10. **❌ Dependências sem justificativa**
    - NUNCA adicione packages sem avaliar alternativas
    - Verifique licença e manutenção
    - Documente escolha em ADR se significativa

---

## ✅ **Boas Práticas Obrigatórias**

### **📱 Flutter + Clean Architecture**

1. **✅ Estrutura de Camadas**
   ```
   lib/features/[feature]/
   ├── data/                    # Data Layer
   │   ├── data_sources/       # API, local storage
   │   ├── models/             # DTOs (from/to JSON)
   │   └── repositories/       # Repository implementations
   ├── domain/                  # Domain Layer (Business Logic)
   │   ├── entities/           # Business objects (pure Dart)
   │   ├── repositories/       # Repository interfaces
   │   └── use_cases/          # Business rules
   └── presentation/            # Presentation Layer (UI)
       ├── bloc/               # State management
       ├── pages/              # Full screens
       └── widgets/            # Reusable components
   ```

2. **✅ Gerenciamento de Estado (BLoC)**
   ```dart
   // Event
   sealed class AuthEvent {}
   final class SignInEvent extends AuthEvent {
     const SignInEvent({required this.email, required this.password});
     final String email;
     final String password;
   }

   // State
   sealed class AuthState {}
   final class AuthInitial extends AuthState {}
   final class AuthLoading extends AuthState {}
   final class AuthSuccess extends AuthState {
     const AuthSuccess(this.user);
     final User user;
   }
   final class AuthError extends AuthState {
     const AuthError(this.message);
     final String message;
   }

   // BLoC
   class AuthBloc extends Bloc<AuthEvent, AuthState> {
     // Implementation
   }
   ```

3. **✅ Error Handling com Either**
   ```dart
   // Use Case retorna Either
   Future<Either<Failure, User>> call(SignInParams params) async {
     try {
       return repository.signIn(email: params.email, password: params.password);
     } catch (e) {
       return Left(ServerFailure('Unexpected error'));
     }
   }

   // StateNotifier trata Either
   final result = await signInUseCase(params);
   result.fold(
     (failure) => state = AuthState.error(failure.message),
     (user) => state = AuthState.authenticated(user),
   );
   ```

4. **✅ Dependency Injection (get_it + injectable)**
   ```dart
   // Configure DI
   @InjectableInit(
     initializerName: r'$initGetIt',
     preferRelativeImports: true,
     asExtension: false,
   )
   Future<void> configureDependencies() async {
     $initGetIt(getIt);
   }

   // Register dependencies
   @module
   abstract class AppModule {
     @lazySingleton
     SupabaseClient get supabase => Supabase.instance.client;
   }

   // Inject in StateNotifier
   @injectable
   class AuthNotifier extends StateNotifier<AuthState> {
     AuthNotifier(this.signInUseCase) : super(const AuthState.initial());
     final SignInUseCase signInUseCase;
   }

   // Provider
   final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
     (ref) => getIt<AuthNotifier>(),
   );

   // Use in widget
   class MyPage extends ConsumerWidget {
     @override
     Widget build(BuildContext context, WidgetRef ref) {
       final authState = ref.watch(authNotifierProvider);
       // Use state...
     }
   }
   ```

5. **✅ Models com freezed**
   ```dart
   @freezed
   class User with _$User {
     const factory User({
       required String id,
       required String email,
       String? name,
     }) = _User;

     factory User.fromJson(Map<String, dynamic> json) =>
         _$UserFromJson(json);
   }
   ```

6. **✅ Tratamento de Erros**
   ```dart
   // Failure base class
   abstract class Failure {
     const Failure(this.message);
     final String message;
   }

   // Specific failures
   class ServerFailure extends Failure {
     const ServerFailure(super.message);
   }

   class NetworkFailure extends Failure {
     const NetworkFailure(super.message);
   }

   class AuthFailure extends Failure {
     const AuthFailure(super.message);
   }
   ```

---

## 🔄 **Protocolo de Execução**

### **📋 Checklist Obrigatório Antes de Qualquer Tarefa**

```text
ANTES DE COMEÇAR:
□ Li AGENT_RULES.md completamente?
□ Li DOCUMENTATION_GUIDE.md?
□ Analisei estrutura de pastas do projeto?
□ Identifiquei arquitetura (Clean + BLoC)?
□ Verifiquei dependências no pubspec.yaml?
□ Entendi integração Supabase?
□ Revisei configuração DI (get_it + injectable)?

DURANTE A TAREFA:
□ Apresentei 3 opções (Protocolo das 3 Opções)?
□ Aguardei aprovação antes de implementar?
□ Segui Metodologia Didática (6 passos)?
□ Respeitei camadas Clean Architecture?
□ Implementei com BLoC (não Provider ou setState)?
□ Usei Either<Failure, Success> para erros?
□ Injetei dependências via get_it?
□ Tratei erros graciosamente?
□ Validei dados de entrada?

QUALIDADE:
□ Implementei testes unitários?
□ Atualizei documentação técnica?
□ Commit com mensagem descritiva?
□ flutter analyze passa sem erros?
□ flutter test passa 100%?
□ Testei em device físico ou emulador?

FINALIZAÇÃO:
□ Coverage ≥ 80% (Rule #3)?
□ Documentação atualizada (Rule #13)?
□ Sem print() em código (Rule #8)?
□ Arquivo < 700 linhas (Rule #24)?
```

---

### **🎯 Fluxo de Trabalho Recomendado**

```text
1. ANÁLISE
   → Leia requisito/ticket
   → Entenda contexto da feature
   → Identifique arquivos envolvidos
   → Verifique padrões existentes

2. PLANEJAMENTO
   → Aplique Protocolo das 3 Opções
   → Apresente alternativas
   → Aguarde aprovação
   → Defina arquitetura da solução

3. IMPLEMENTAÇÃO
   → Siga Metodologia Didática (6 passos)
   → Implemente camada por camada (Data → Domain → Presentation)
   → Use BLoC para estado
   → Injete dependências via get_it
   → Trate erros com Either

4. TESTES
   → Escreva testes unitários (UseCases, Repositories)
   → Teste BLoCs com bloc_test
   → Widget tests para Pages
   → Use mockito para mocks
   → Garanta coverage ≥ 80%

5. DOCUMENTAÇÃO
   → Atualize _TECH.md (se aplicável)
   → Atualize _GUIDE.md (se UI visível)
   → Documente decisões técnicas
   → Explique "por quê", não só "como"

6. REVISÃO
   → flutter analyze (zero erros)
   → flutter test (100% pass)
   → Teste em device físico
   → Code review com equipe

7. ENTREGA
   → Commit com mensagem clara
   → Push para branch feature
   → Abra Pull Request
   → Descreva mudanças e testes realizados
```

---

*📅 Criado em*: 28 NOV 25\
*📋 Versão*: 1.0\
*👥 Responsável*: Equipe de Desenvolvimento Volan Flutter\
*🏷️ Tags*: [agente-ia, diretrizes, protocolo-3-opcoes, volan-flutter, dart, metodologia-didatica, clean-architecture, riverpod, supabase]
