/// Mock patient data for MVP development and testing.
///
/// This file contains realistic patient data structures that match
/// the HomeScreen design requirements shown in HomeScreen.png.
///
/// Design Requirements:
/// - Patient cards show: avatar, name, age, appointment type, time
/// - Stats cards show: "X Aguardando", "Y Realizados"
/// - Two sections: "Pacientes Recentes" and "Próximos Pacientes"
library;

/// Mock patient data structure.
///
/// Matches the patients_cache table schema from database design.
class MockPatient {
  final String id;
  final String fullName;
  final int age;
  final String cpf; // Format: XXX.XXX.XXX-XX
  final String appointmentType; // "Consulta de Rotina", "Retorno", etc.
  final DateTime appointmentDate;
  final String appointmentTime; // "HH:MM" format
  final String appointmentStatus; // "aguardando" | "realizado" | "cancelado"
  final bool isRecent;
  final bool isUpcoming;
  final String? notes;

  const MockPatient({
    required this.id,
    required this.fullName,
    required this.age,
    required this.cpf,
    required this.appointmentType,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.appointmentStatus,
    this.isRecent = false,
    this.isUpcoming = false,
    this.notes,
  });
}

/// Mock patients for MVP development.
///
/// Based on HomeScreen.png design showing:
/// - Recent patients section
/// - Upcoming patients section
/// - Stats: "4 Aguardando", "2 Realizados"
class MockPatients {
  /// All mock patients (26 total for realistic list)
  static final List<MockPatient> all = [
    // RECENT PATIENTS (Pacientes Recentes) - Shown in HomeScreen.png
    MockPatient(
      id: 'patient_001',
      fullName: 'Maria Silva Santos',
      age: 34,
      cpf: '123.456.789-00',
      appointmentType: 'Consulta de Rotina',
      appointmentDate: DateTime.now(),
      appointmentTime: '14:30',
      appointmentStatus: 'aguardando',
      isRecent: true,
      isUpcoming: true,
      notes: 'Paciente regular, histórico de hipertensão',
    ),
    MockPatient(
      id: 'patient_002',
      fullName: 'João Pedro Oliveira',
      age: 45,
      cpf: '234.567.890-11',
      appointmentType: 'Retorno',
      appointmentDate: DateTime.now(),
      appointmentTime: '15:00',
      appointmentStatus: 'aguardando',
      isRecent: true,
      isUpcoming: true,
      notes: 'Acompanhamento pós-cirúrgico',
    ),
    MockPatient(
      id: 'patient_003',
      fullName: 'Ana Carolina Mendes',
      age: 28,
      cpf: '345.678.901-22',
      appointmentType: 'Consulta de Rotina',
      appointmentDate: DateTime.now().subtract(const Duration(days: 1)),
      appointmentTime: '10:00',
      appointmentStatus: 'realizado',
      isRecent: true,
      notes: 'Primeira consulta',
    ),
    MockPatient(
      id: 'patient_004',
      fullName: 'Pedro Henrique Costa',
      age: 52,
      cpf: '456.789.012-33',
      appointmentType: 'Exame de Rotina',
      appointmentDate: DateTime.now().subtract(const Duration(days: 1)),
      appointmentTime: '11:30',
      appointmentStatus: 'realizado',
      isRecent: true,
      notes: 'Exames laboratoriais anuais',
    ),

    // UPCOMING PATIENTS (Próximos Pacientes)
    MockPatient(
      id: 'patient_005',
      fullName: 'Carla Regina Ferreira',
      age: 38,
      cpf: '567.890.123-44',
      appointmentType: 'Primeira Consulta',
      appointmentDate: DateTime.now(),
      appointmentTime: '16:00',
      appointmentStatus: 'aguardando',
      isUpcoming: true,
      notes: 'Novo paciente',
    ),
    MockPatient(
      id: 'patient_006',
      fullName: 'Lucas Fernandes Ribeiro',
      age: 41,
      cpf: '678.901.234-55',
      appointmentType: 'Retorno',
      appointmentDate: DateTime.now(),
      appointmentTime: '16:30',
      appointmentStatus: 'aguardando',
      isUpcoming: true,
      notes: 'Revisão de tratamento',
    ),
    MockPatient(
      id: 'patient_007',
      fullName: 'Juliana Souza Lima',
      age: 29,
      cpf: '789.012.345-66',
      appointmentType: 'Consulta de Rotina',
      appointmentDate: DateTime.now().add(const Duration(days: 1)),
      appointmentTime: '09:00',
      appointmentStatus: 'aguardando',
      isUpcoming: true,
    ),

    // ADDITIONAL PATIENTS (for realistic list pagination)
    MockPatient(
      id: 'patient_008',
      fullName: 'Roberto Carlos Almeida',
      age: 56,
      cpf: '890.123.456-77',
      appointmentType: 'Retorno',
      appointmentDate: DateTime.now().add(const Duration(days: 2)),
      appointmentTime: '10:30',
      appointmentStatus: 'aguardando',
    ),
    MockPatient(
      id: 'patient_009',
      fullName: 'Fernanda Gomes Silva',
      age: 33,
      cpf: '901.234.567-88',
      appointmentType: 'Consulta de Rotina',
      appointmentDate: DateTime.now().add(const Duration(days: 3)),
      appointmentTime: '14:00',
      appointmentStatus: 'aguardando',
    ),
    MockPatient(
      id: 'patient_010',
      fullName: 'Marcos Antonio Santos',
      age: 47,
      cpf: '012.345.678-99',
      appointmentType: 'Exame de Rotina',
      appointmentDate: DateTime.now().add(const Duration(days: 3)),
      appointmentTime: '15:30',
      appointmentStatus: 'aguardando',
    ),
    MockPatient(
      id: 'patient_011',
      fullName: 'Patricia Helena Costa',
      age: 39,
      cpf: '111.222.333-44',
      appointmentType: 'Primeira Consulta',
      appointmentDate: DateTime.now().add(const Duration(days: 4)),
      appointmentTime: '09:30',
      appointmentStatus: 'aguardando',
    ),
    MockPatient(
      id: 'patient_012',
      fullName: 'Gustavo Belmante Ribeiro',
      age: 21,
      cpf: '095.183.371-52',
      appointmentType: 'Consulta de Rotina',
      appointmentDate: DateTime.now().subtract(const Duration(days: 2)),
      appointmentTime: '11:00',
      appointmentStatus: 'realizado',
      notes: 'Paciente do ChatAssistentScreen.png - usado no chat demo',
    ),
    MockPatient(
      id: 'patient_013',
      fullName: 'Beatriz Alves Pereira',
      age: 31,
      cpf: '222.333.444-55',
      appointmentType: 'Retorno',
      appointmentDate: DateTime.now().add(const Duration(days: 5)),
      appointmentTime: '13:00',
      appointmentStatus: 'aguardando',
    ),
    MockPatient(
      id: 'patient_014',
      fullName: 'Ricardo Mendes Oliveira',
      age: 44,
      cpf: '333.444.555-66',
      appointmentType: 'Consulta de Rotina',
      appointmentDate: DateTime.now().add(const Duration(days: 6)),
      appointmentTime: '10:00',
      appointmentStatus: 'aguardando',
    ),
    MockPatient(
      id: 'patient_015',
      fullName: 'Camila Rodrigues Santos',
      age: 27,
      cpf: '444.555.666-77',
      appointmentType: 'Primeira Consulta',
      appointmentDate: DateTime.now().add(const Duration(days: 7)),
      appointmentTime: '14:30',
      appointmentStatus: 'aguardando',
    ),
    MockPatient(
      id: 'patient_016',
      fullName: 'Bruno Henrique Lima',
      age: 50,
      cpf: '555.666.777-88',
      appointmentType: 'Exame de Rotina',
      appointmentDate: DateTime.now().subtract(const Duration(days: 3)),
      appointmentTime: '09:00',
      appointmentStatus: 'realizado',
    ),
    MockPatient(
      id: 'patient_017',
      fullName: 'Larissa Fernanda Costa',
      age: 35,
      cpf: '666.777.888-99',
      appointmentType: 'Retorno',
      appointmentDate: DateTime.now().add(const Duration(days: 8)),
      appointmentTime: '11:30',
      appointmentStatus: 'aguardando',
    ),
    MockPatient(
      id: 'patient_018',
      fullName: 'Diego Silva Almeida',
      age: 42,
      cpf: '777.888.999-00',
      appointmentType: 'Consulta de Rotina',
      appointmentDate: DateTime.now().add(const Duration(days: 9)),
      appointmentTime: '15:00',
      appointmentStatus: 'aguardando',
    ),
    MockPatient(
      id: 'patient_019',
      fullName: 'Vanessa Cristina Souza',
      age: 36,
      cpf: '888.999.000-11',
      appointmentType: 'Primeira Consulta',
      appointmentDate: DateTime.now().add(const Duration(days: 10)),
      appointmentTime: '13:30',
      appointmentStatus: 'aguardando',
    ),
    MockPatient(
      id: 'patient_020',
      fullName: 'Thiago Rodrigues Martins',
      age: 48,
      cpf: '999.000.111-22',
      appointmentType: 'Retorno',
      appointmentDate: DateTime.now().subtract(const Duration(days: 4)),
      appointmentTime: '10:30',
      appointmentStatus: 'realizado',
    ),
    MockPatient(
      id: 'patient_021',
      fullName: 'Amanda Silva Ferreira',
      age: 30,
      cpf: '000.111.222-33',
      appointmentType: 'Consulta de Rotina',
      appointmentDate: DateTime.now().add(const Duration(days: 11)),
      appointmentTime: '14:00',
      appointmentStatus: 'aguardando',
    ),
    MockPatient(
      id: 'patient_022',
      fullName: 'Felipe Augusto Santos',
      age: 53,
      cpf: '111.222.333-00',
      appointmentType: 'Exame de Rotina',
      appointmentDate: DateTime.now().add(const Duration(days: 12)),
      appointmentTime: '09:30',
      appointmentStatus: 'aguardando',
    ),
    MockPatient(
      id: 'patient_023',
      fullName: 'Gabriela Costa Lima',
      age: 26,
      cpf: '222.333.444-11',
      appointmentType: 'Primeira Consulta',
      appointmentDate: DateTime.now().add(const Duration(days: 13)),
      appointmentTime: '16:00',
      appointmentStatus: 'aguardando',
    ),
    MockPatient(
      id: 'patient_024',
      fullName: 'Rafael Henrique Oliveira',
      age: 40,
      cpf: '333.444.555-22',
      appointmentType: 'Retorno',
      appointmentDate: DateTime.now().add(const Duration(days: 14)),
      appointmentTime: '11:00',
      appointmentStatus: 'aguardando',
    ),
    MockPatient(
      id: 'patient_025',
      fullName: 'Daniela Cristina Alves',
      age: 37,
      cpf: '444.555.666-33',
      appointmentType: 'Consulta de Rotina',
      appointmentDate: DateTime.now().subtract(const Duration(days: 5)),
      appointmentTime: '15:30',
      appointmentStatus: 'realizado',
    ),
    MockPatient(
      id: 'patient_026',
      fullName: 'Leonardo Silva Costa',
      age: 49,
      cpf: '555.666.777-44',
      appointmentType: 'Exame de Rotina',
      appointmentDate: DateTime.now().add(const Duration(days: 15)),
      appointmentTime: '10:00',
      appointmentStatus: 'aguardando',
    ),
  ];

  /// Recent patients (isRecent = true)
  static List<MockPatient> get recent =>
      all.where((p) => p.isRecent).toList();

  /// Upcoming patients (isUpcoming = true)
  static List<MockPatient> get upcoming =>
      all.where((p) => p.isUpcoming).toList();

  /// Stats for HomeScreen cards (matches HomeScreen.png design)
  static Map<String, int> get stats {
    final aguardando =
        all.where((p) => p.appointmentStatus == 'aguardando').length;
    final realizado =
        all.where((p) => p.appointmentStatus == 'realizado').length;

    return {
      'aguardando': aguardando, // Shown as "X Pacientes Aguardando"
      'realizado': realizado, // Shown as "Y Atendimentos Realizados"
    };
  }

  /// Get patient by ID (for navigation from HomeScreen → ChatScreen)
  static MockPatient? getById(String id) {
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Search patients by name (for HomeScreen search bar)
  static List<MockPatient> search(String query) {
    if (query.isEmpty) return all;

    final lowerQuery = query.toLowerCase();
    return all
        .where((p) => p.fullName.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
