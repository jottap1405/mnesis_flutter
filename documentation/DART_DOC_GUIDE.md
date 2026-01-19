# 📝 Mnesis Flutter - Guia de Padrões Dart Documentation

<div align="center">

![Tipo](https://img.shields.io/badge/Tipo-GUIA-orange?style=for-the-badge)
![Versão](https://img.shields.io/badge/Versão-1.0-blue?style=for-the-badge)
![Linguagem](https://img.shields.io/badge/Linguagem-Dart-blue?style=for-the-badge)

</div>

Guia completo de padrões e convenções para Dart documentation comments (///) no projeto **Volan Flutter** - Sistema de Autenticação Flutter com Clean Architecture + BLoC + Supabase.

## 📋 **Índice**

1. [**🎯 Objetivo**](#-objetivo)
2. [**📐 Princípios Fundamentais**](#-princípios-fundamentais)
3. [**🏗️ Estrutura Organizacional**](#️-estrutura-organizacional)
4. [**📝 Templates Dart Docs**](#-templates-dart-docs)
5. [**🎨 Formatação e Convenções**](#-formatação-e-convenções)
6. [**✅ Checklist Final**](#-checklist-final)

---

## 🎯 **Objetivo**

Este guia estabelece padrões consistentes de Dart documentation para garantir:
- **Clareza**: Código autodocumentado e compreensível
- **Manutenibilidade**: Facilitar onboarding e manutenção
- **Profissionalismo**: Padrões enterprise de documentação
- **Rastreabilidade**: Links claros entre código, tickets e documentação externa

---

## 📐 **Princípios Fundamentais**

### **1. Toda API pública requer Dart docs**
- Classes, interfaces, abstract classes públicas
- Funções e propriedades públicas
- Constantes e enums

### **2. Dart docs contextualiza, não repete**
```dart
// ❌ ERRADO - Apenas repete o óbvio
/// Get user name
/// Returns user name
String getUserName();

// ✅ CORRETO - Adiciona contexto e valor
/// Retrieves the authenticated user's full name from Supabase Auth.
/// Falls back to "User" if name is not available.
///
/// Returns full name or default placeholder string.
/// Throws [AuthException] if no user is authenticated.
/// See also:
/// * [SupabaseAuth.currentUser]
String getUserName();
```

### **3. Use triplo-slash (///) para documentação**
```dart
/// This is a documentation comment.
/// It can span multiple lines.
/// Use /// for all public APIs.

// This is a regular comment (não aparece na documentação)
```

### **4. Markdown é suportado**
- Use formatação para destacar informações importantes
- Listas, código inline, links são bem-vindos
- Seções com `##` para organizar docs longos

---

## 🏗️ **Estrutura Organizacional**

### **📱 1. Page / Screen**

```dart
/// Main authentication page for user sign-in.
///
/// This page provides a form for users to authenticate using:
/// - **Email**: User's registered email address
/// - **Password**: Account password
///
/// ## Navigation
/// - **Entry**: Splash screen -> [LoginPage]
/// - **Exit**: Successful login -> Home screen
///
/// ## State Management
/// Uses [AuthBloc] to handle authentication flow:
/// - [SignInEvent] triggers authentication
/// - [AuthLoading] shows loading indicator
/// - [AuthSuccess] navigates to home
/// - [AuthError] displays error message
///
/// ## Integration
/// - **Supabase**: Uses `supabase.auth.signInWithPassword()`
/// - **Route**: `/login`
///
/// Example:
/// ```dart
/// Navigator.pushNamed(context, LoginPage.routeName);
/// ```
///
/// See also:
/// * [AuthBloc] for authentication logic
/// * [SignUpPage] for account creation
/// * Technical docs: `documentation/technical/pages/auth/LoginPage_TECH.md`
class LoginPage extends StatelessWidget {
  /// Creates a [LoginPage].
  const LoginPage({super.key});

  /// Route name for navigation.
  static const String routeName = '/login';

  @override
  Widget build(BuildContext context) {
    // Implementation
  }
}
```

### **🎨 2. Widget**

```dart
/// Custom text field widget with built-in validation and styling.
///
/// Provides a consistent text input component across the app with:
/// - Material Design 3 styling
/// - Built-in error handling
/// - Custom validators
/// - Obscure text support (for passwords)
///
/// ## Usage
/// ```dart
/// CustomTextField(
///   label: 'Email',
///   controller: emailController,
///   validator: EmailValidator(),
///   keyboardType: TextInputType.emailAddress,
/// )
/// ```
///
/// ## Validation
/// Use [validator] parameter to provide custom validation:
/// ```dart
/// validator: (value) {
///   if (value == null || value.isEmpty) {
///     return 'Field is required';
///   }
///   return null;
/// }
/// ```
///
/// See also:
/// * [TextFormField] for base implementation
/// * [FormValidator] for validation utilities
class CustomTextField extends StatelessWidget {
  /// Creates a [CustomTextField].
  ///
  /// The [label] and [controller] parameters must not be null.
  const CustomTextField({
    required this.label,
    required this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    super.key,
  });

  /// The label text displayed above the text field.
  final String label;

  /// Controller for managing the text field's value.
  final TextEditingController controller;

  /// Optional validator function for form validation.
  ///
  /// Return `null` if valid, error message string if invalid.
  final String? Function(String?)? validator;

  /// Whether to obscure the text (for password fields).
  ///
  /// Defaults to `false`.
  final bool obscureText;

  /// The type of keyboard to display.
  ///
  /// Defaults to [TextInputType.text].
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    // Implementation
  }
}
```

### **🔄 3. BLoC**

```dart
/// BLoC responsible for managing authentication state.
///
/// Handles user authentication flow including:
/// - Sign in with email/password
/// - Sign up for new accounts
/// - Sign out
/// - Session management
///
/// ## Events
/// - [SignInEvent]: Initiates sign-in with credentials
/// - [SignUpEvent]: Creates new user account
/// - [SignOutEvent]: Logs out current user
/// - [CheckAuthStatusEvent]: Verifies current session
///
/// ## States
/// - [AuthInitial]: Initial state, no user authenticated
/// - [AuthLoading]: Authentication in progress
/// - [AuthSuccess]: User authenticated successfully
/// - [AuthError]: Authentication failed with error
///
/// ## Dependencies
/// Uses [SignInUseCase] and [SignOutUseCase] from domain layer.
///
/// ## Error Handling
/// Errors are caught and emitted as [AuthError] state with message:
/// - Network errors: "Connection failed. Check internet."
/// - Invalid credentials: "Invalid email or password."
/// - Account not found: "Account does not exist."
///
/// Example usage:
/// ```dart
/// BlocProvider(
///   create: (context) => getIt<AuthBloc>(),
///   child: LoginPage(),
/// )
/// ```
///
/// See also:
/// * [SignInUseCase] for authentication logic
/// * [AuthRepository] for data operations
/// * Technical docs: `documentation/technical/blocs/auth/AuthBloc_TECH.md`
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// Creates an [AuthBloc] with required use cases.
  ///
  /// The [signInUseCase] and [signOutUseCase] must not be null.
  AuthBloc({
    required this.signInUseCase,
    required this.signOutUseCase,
  }) : super(AuthInitial()) {
    on<SignInEvent>(_onSignIn);
    on<SignOutEvent>(_onSignOut);
  }

  /// Use case for signing in users.
  final SignInUseCase signInUseCase;

  /// Use case for signing out users.
  final SignOutUseCase signOutUseCase;

  // Event handlers
  Future<void> _onSignIn(
    SignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    // Implementation
  }
}
```

### **💾 4. Repository**

```dart
/// Repository implementation for authentication data operations.
///
/// Implements [AuthRepository] interface from domain layer.
/// Coordinates between remote data source (Supabase) and local cache.
///
/// ## Data Sources
/// - **Remote**: Supabase Auth API
/// - **Local**: Secure storage for session tokens
///
/// ## Operations
/// - `signIn()`: Authenticate user with email/password
/// - `signUp()`: Create new user account
/// - `signOut()`: End current session
/// - `getCurrentUser()`: Get authenticated user data
///
/// ## Error Handling
/// Returns `Either<Failure, Success>`:
/// - `Left(Failure)`: Operation failed with specific failure type
/// - `Right(Success)`: Operation succeeded with data
///
/// Example:
/// ```dart
/// final result = await repository.signIn(
///   email: 'user@example.com',
///   password: 'password123',
/// );
///
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (user) => print('Success: ${user.email}'),
/// );
/// ```
///
/// See also:
/// * [AuthRepository] for interface definition
/// * [AuthRemoteDataSource] for Supabase implementation
/// * [Either] from dartz package
class AuthRepositoryImpl implements AuthRepository {
  /// Creates an [AuthRepositoryImpl] with required data source.
  const AuthRepositoryImpl(this.remoteDataSource);

  /// Remote data source for Supabase operations.
  final AuthRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  }) async {
    // Implementation
  }
}
```

### **🎯 5. Use Case**

```dart
/// Use case for signing in users with email and password.
///
/// Implements business logic for user authentication:
/// - Validates email format
/// - Validates password strength (if needed)
/// - Calls repository to authenticate
/// - Returns success or failure
///
/// ## Parameters
/// Uses [SignInParams] with:
/// - `email`: User's email address
/// - `password`: User's password
///
/// ## Return Type
/// Returns `Either<Failure, User>`:
/// - `Left(Failure)`: Authentication failed
/// - `Right(User)`: Authentication succeeded with user data
///
/// ## Failures
/// Can return:
/// - [ServerFailure]: Supabase error
/// - [NetworkFailure]: No internet connection
/// - [AuthFailure]: Invalid credentials
///
/// Example usage:
/// ```dart
/// final result = await signInUseCase(
///   SignInParams(
///     email: 'user@example.com',
///     password: 'password123',
///   ),
/// );
///
/// result.fold(
///   (failure) {
///     if (failure is AuthFailure) {
///       print('Invalid credentials');
///     }
///   },
///   (user) => print('Signed in: ${user.email}'),
/// );
/// ```
///
/// See also:
/// * [AuthRepository] for data operations
/// * [UseCase] base class
/// * [SignInParams] for parameter definition
class SignInUseCase implements UseCase<User, SignInParams> {
  /// Creates a [SignInUseCase] with required repository.
  const SignInUseCase(this.repository);

  /// Repository for authentication operations.
  final AuthRepository repository;

  @override
  Future<Either<Failure, User>> call(SignInParams params) async {
    // Implementation
  }
}

/// Parameters for [SignInUseCase].
class SignInParams {
  /// Creates [SignInParams] for sign-in operation.
  const SignInParams({
    required this.email,
    required this.password,
  });

  /// User's email address.
  final String email;

  /// User's password.
  final String password;
}
```

### **📦 6. Model / Entity**

```dart
/// User entity representing authenticated user data.
///
/// This is a domain entity (pure business logic, no dependencies).
///
/// ## Properties
/// - `id`: Unique user identifier from Supabase
/// - `email`: User's email address
/// - `name`: Optional user display name
/// - `createdAt`: Account creation timestamp
///
/// ## Immutability
/// Uses `freezed` for immutable data classes with:
/// - Automatic `copyWith` method
/// - Equality comparison
/// - JSON serialization
///
/// Example:
/// ```dart
/// final user = User(
///   id: 'uuid-123',
///   email: 'user@example.com',
///   name: 'John Doe',
///   createdAt: DateTime.now(),
/// );
///
/// final updatedUser = user.copyWith(name: 'Jane Doe');
/// ```
///
/// See also:
/// * [UserModel] for data layer representation
/// * Technical docs: `documentation/technical/models/auth/UserEntity_TECH.md`
@freezed
class User with _$User {
  /// Creates a [User] entity.
  const factory User({
    /// Unique identifier from Supabase Auth.
    required String id,

    /// User's email address (used for authentication).
    required String email,

    /// Optional display name.
    String? name,

    /// Timestamp when account was created.
    required DateTime createdAt,
  }) = _User;
}
```

### **🔌 7. Extension**

```dart
/// Extension methods for [String] to add validation utilities.
///
/// Provides common validation methods used throughout the app:
/// - Email format validation
/// - Password strength validation
/// - Empty/null checks
///
/// Example:
/// ```dart
/// final email = 'user@example.com';
/// if (email.isValidEmail) {
///   print('Valid email');
/// }
///
/// final password = 'MyPass123!';
/// if (password.isStrongPassword) {
///   print('Strong password');
/// }
/// ```
extension StringValidation on String {
  /// Checks if string is a valid email format.
  ///
  /// Returns `true` if string matches email pattern:
  /// - Contains @ symbol
  /// - Has domain with extension
  /// - No whitespace
  ///
  /// Example:
  /// ```dart
  /// 'user@example.com'.isValidEmail // true
  /// 'invalid-email'.isValidEmail    // false
  /// ```
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Checks if string is a strong password.
  ///
  /// Password is considered strong if it has:
  /// - At least 8 characters
  /// - Contains uppercase letter
  /// - Contains lowercase letter
  /// - Contains number
  /// - Contains special character
  ///
  /// Returns `true` if all criteria are met.
  bool get isStrongPassword {
    if (length < 8) return false;
    if (!contains(RegExp(r'[A-Z]'))) return false;
    if (!contains(RegExp(r'[a-z]'))) return false;
    if (!contains(RegExp(r'[0-9]'))) return false;
    if (!contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }
}
```

### **🧪 8. Test File**

```dart
/// Unit tests for [SignInUseCase].
///
/// ## Coverage
/// - Success scenario with valid credentials
/// - Failure scenarios (invalid credentials, network error)
/// - Edge cases (empty email, weak password)
///
/// ## Mocks
/// - [MockAuthRepository]: Mocked repository using mockito
///
/// ## Setup
/// ```dart
/// setUp(() {
///   mockRepository = MockAuthRepository();
///   useCase = SignInUseCase(mockRepository);
/// });
/// ```
///
/// See also:
/// * [SignInUseCase] for implementation
void main() {
  late SignInUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInUseCase(mockRepository);
  });

  group('SignInUseCase', () {
    /// Tests successful sign-in with valid credentials.
    ///
    /// **Scenario:**
    /// - Valid email and password provided
    /// - Repository returns success with user data
    ///
    /// **Expected:**
    /// - Use case returns `Right(User)`
    /// - User has correct email
    test('should return User when credentials are valid', () async {
      // Arrange
      final params = SignInParams(
        email: 'test@example.com',
        password: 'Password123!',
      );
      final expectedUser = User(
        id: '123',
        email: params.email,
        createdAt: DateTime.now(),
      );

      when(
        mockRepository.signIn(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => Right(expectedUser));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, Right(expectedUser));
      verify(
        mockRepository.signIn(
          email: params.email,
          password: params.password,
        ),
      ).called(1);
    });

    /// Tests failure when credentials are invalid.
    ///
    /// **Scenario:**
    /// - Invalid credentials provided
    /// - Repository returns [AuthFailure]
    ///
    /// **Expected:**
    /// - Use case returns `Left(AuthFailure)`
    test('should return AuthFailure when credentials are invalid', () async {
      // Test implementation
    });
  });
}
```

---

## 📝 **Templates Dart Docs**

### **📄 Template: Função Pública**

```dart
/// [Brief description of what function does in 1-2 lines]
///
/// [Additional context, use cases, special behavior - optional]
///
/// Example:
/// ```dart
/// final result = functionName(param1, param2);
/// ```
///
/// Returns [description of return value].
/// Throws [ExceptionType] when [condition].
///
/// See also:
/// * [RelatedClass]
ReturnType functionName(ParamType param1, ParamType param2) {
  // Implementation
}
```

### **📄 Template: Propriedade**

```dart
/// [Description of what the property represents]
///
/// [Additional context about when it's updated, who observes, etc]
///
/// Example:
/// ```dart
/// print(object.propertyName);
/// ```
///
/// See also:
/// * [RelatedType]
final String propertyName;
```

### **📄 Template: Constante**

```dart
/// [Description of the constant]
///
/// Used for:
/// - [Use case 1]
/// - [Use case 2]
///
/// Value chosen because: [reasoning]
static const String constantName = 'value';
```

---

## 🎨 **Formatação e Convenções**

### **📋 1. Seções Markdown Comuns**

```dart
/// Brief description.
///
/// ## Usage
/// How and when to use
///
/// ## Example
/// Code example
///
/// ## Parameters
/// Details about parameters
///
/// ## Returns
/// What is returned
///
/// ## Throws
/// Exceptions that can be thrown
///
/// See also:
/// * [RelatedClass]
```

### **📋 2. Listas**

```dart
/// This function:
/// - Validates input
/// - Queries database
/// - Returns result or error
```

### **📋 3. Code Blocks**

````dart
/// Example usage:
/// ```dart
/// final result = await repository.getData();
/// result.fold(
///   (failure) => print('Error: $failure'),
///   (data) => print('Success: $data'),
/// );
/// ```
````

### **📋 4. Links**

```dart
/// See [AuthBloc] for state management.
/// See also:
/// * [SignInUseCase] for business logic
/// * [AuthRepository] for data operations
```

### **📋 5. Warnings e Notas**

```dart
/// Updates user data in Supabase.
///
/// **Note:** This function does NOT validate input.
/// Use [validateUserData] before calling.
///
/// **Warning:** Requires active authentication session.
```

---

## ✅ **Checklist Final**

### **📋 Documentação Completa**
- [ ] Classes públicas têm Dart docs com descrição clara
- [ ] Funções públicas têm Dart docs
- [ ] Propriedades expostas estão documentadas
- [ ] Enums têm descrição de cada valor
- [ ] Constantes têm justificativa de valores escolhidos

### **📋 Qualidade do Conteúdo**
- [ ] Dart docs adiciona contexto, não apenas repete nome
- [ ] Exemplos de uso incluídos quando apropriado
- [ ] Exceções possíveis documentadas
- [ ] Links para documentação técnica adicionados
- [ ] Tickets relacionados referenciados (se aplicável)

### **📋 Padrões FlowForge**
- [ ] Nenhum uso de `print()` em exemplos (Rule #21)
- [ ] Documentação em arquivo < 700 linhas (Rule #24)
- [ ] Sem referências a AI/GPT/Claude (Rule #33)

### **📋 Formatação**
- [ ] Markdown bem formatado (headings, listas, code blocks)
- [ ] Links para classes usam colchetes: `[ClassName]`
- [ ] Code blocks usam syntax highlighting (```dart)

---

*📅 Criado em*: 28 NOV 25\
*📋 Versão*: 1.0\
*👥 Responsável*: Equipe de Desenvolvimento Mnesis Flutter\
*🏷️ Tags*: [dart, documentação, flutter, padrões, boas-práticas, flowforge]
