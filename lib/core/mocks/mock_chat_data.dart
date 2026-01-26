/// Mock chat response data for MVP development and testing.
///
/// This file contains realistic AI assistant responses that match
/// the ChatAssistentScreen design requirements shown in ChatAssistentScreen.png.
///
/// Design Requirements:
/// - Patient header: "Gustavo Belmante Ribeiro | 21 anos | 095.183.371-52"
/// - Chat bubbles: AI (left, dark gray), User (right, transparent)
/// - Mock responses simulate AI assistant behavior
/// - Context-aware responses use patient data
library;

import 'mock_patient_data.dart';

/// Mock chat message data structure.
class MockChatMessage {
  final String id;
  final String patientId;
  final String content;
  final bool isFromUser; // true = user message, false = AI assistant
  final DateTime timestamp;

  const MockChatMessage({
    required this.id,
    required this.patientId,
    required this.content,
    required this.isFromUser,
    required this.timestamp,
  });
}

/// Mock chat response generator for AI assistant.
///
/// Uses keyword matching and patient context to generate realistic responses.
/// Based on ChatAssistentScreen.png design showing AI assistant chat.
class MockChatService {
  /// Generate AI response based on user message and patient context.
  ///
  /// Returns a mock AI response after a simulated delay (1-3 seconds).
  /// Uses keyword matching for common queries.
  ///
  /// Example keywords:
  /// - "medicação", "remédio" → medication list
  /// - "exame", "resultado" → exam results
  /// - "consulta", "retorno" → appointment info
  /// - "sintoma", "dor" → symptom assessment
  static Future<String> generateResponse(
    String userMessage,
    String patientId,
  ) async {
    // Simulate AI "thinking" delay (1-3 seconds)
    await Future.delayed(
      Duration(seconds: 1 + (userMessage.length % 3)),
    );

    // Get patient context
    final patient = MockPatients.getById(patientId);
    final patientName = patient?.fullName.split(' ').first ?? 'paciente';

    // Lowercase for case-insensitive matching
    final message = userMessage.toLowerCase();

    // Keyword-based responses
    if (_containsAny(message, ['medicação', 'remédio', 'medicamento'])) {
      return _generateMedicationResponse(patientName);
    }

    if (_containsAny(message, ['exame', 'resultado', 'laudo'])) {
      return _generateExamResponse(patientName);
    }

    if (_containsAny(message, ['consulta', 'retorno', 'agendamento'])) {
      return _generateAppointmentResponse(patient);
    }

    if (_containsAny(message, ['sintoma', 'dor', 'sentindo'])) {
      return _generateSymptomResponse(patientName);
    }

    if (_containsAny(message, ['histórico', 'historico', 'passado'])) {
      return _generateHistoryResponse(patient);
    }

    if (_containsAny(message, ['anexo', 'documento', 'arquivo'])) {
      return _generateAttachmentResponse(patientName);
    }

    if (_containsAny(message, ['resumo', 'informação', 'informacao', 'dados'])) {
      return _generateSummaryResponse(patient);
    }

    // Greeting responses
    if (_containsAny(message, ['olá', 'ola', 'oi', 'bom dia', 'boa tarde'])) {
      return 'Olá! Sou o assistente virtual da Mnesis. Como posso ajudar $patientName hoje?';
    }

    // Default fallback response
    return _generateDefaultResponse(patientName);
  }

  /// Check if message contains any of the keywords
  static bool _containsAny(String message, List<String> keywords) {
    return keywords.any((keyword) => message.contains(keyword));
  }

  /// Generate medication response
  static String _generateMedicationResponse(String patientName) {
    return 'Com base no histórico de $patientName, as medicações atuais são:\n\n'
        '• Losartana 50mg - 1x ao dia (manhã)\n'
        '• Hidroclorotiazida 25mg - 1x ao dia (manhã)\n'
        '• Omeprazol 20mg - 1x ao dia (antes do café)\n\n'
        'A última prescrição foi atualizada há 15 dias. '
        'Gostaria de saber mais sobre alguma medicação específica?';
  }

  /// Generate exam results response
  static String _generateExamResponse(String patientName) {
    return 'Encontrei 3 exames recentes de $patientName:\n\n'
        '📋 Exame de Sangue Completo (5 dias atrás)\n'
        '• Hemoglobina: 14.2 g/dL (normal)\n'
        '• Glicemia: 98 mg/dL (normal)\n'
        '• Colesterol total: 185 mg/dL (normal)\n\n'
        '🔬 Urina Tipo 1 (10 dias atrás)\n'
        '• Resultado: Normal\n\n'
        '❤️ Eletrocardiograma (15 dias atrás)\n'
        '• Ritmo sinusal normal\n\n'
        'Deseja ver os laudos completos na seção de Anexos?';
  }

  /// Generate appointment response
  static String _generateAppointmentResponse(MockPatient? patient) {
    if (patient == null) {
      return 'Não encontrei informações de agendamento para este paciente.';
    }

    final appointmentDate = _formatDate(patient.appointmentDate);
    final status = patient.appointmentStatus == 'aguardando'
        ? 'confirmada'
        : 'realizada';

    return 'Encontrei a seguinte consulta:\n\n'
        '📅 ${patient.appointmentType}\n'
        '🕐 $appointmentDate às ${patient.appointmentTime}\n'
        '✅ Status: ${status.toUpperCase()}\n\n'
        '${patient.appointmentStatus == "aguardando" ? "Lembre-se de chegar com 15 minutos de antecedência. " : ""}'
        'Posso ajudar com algo mais sobre esta consulta?';
  }

  /// Generate symptom assessment response
  static String _generateSymptomResponse(String patientName) {
    return 'Entendo que você está relatando sintomas. Vou fazer algumas perguntas para ajudar:\n\n'
        '1. Quando os sintomas começaram?\n'
        '2. Qual é a intensidade (leve, moderada, intensa)?\n'
        '3. Os sintomas são constantes ou intermitentes?\n\n'
        'Com base nas respostas, posso sugerir se é necessário '
        'antecipar a consulta ou se podemos aguardar o retorno agendado. '
        'Em casos de emergência, sempre procure atendimento imediato.';
  }

  /// Generate medical history response
  static String _generateHistoryResponse(MockPatient? patient) {
    if (patient == null) {
      return 'Não encontrei histórico para este paciente.';
    }

    return 'Resumo do histórico médico de ${patient.fullName}:\n\n'
        '👤 Idade: ${patient.age} anos\n'
        '📋 Condições conhecidas:\n'
        '• Hipertensão arterial (controlada)\n'
        '• Gastrite crônica\n\n'
        '💊 Medicações em uso: 3 medicamentos\n'
        '📁 Anexos: 5 documentos disponíveis\n'
        '📅 Última consulta: ${_formatDate(patient.appointmentDate)}\n\n'
        '${patient.notes ?? "Sem observações adicionais."}\n\n'
        'Deseja mais detalhes sobre algum aspecto específico?';
  }

  /// Generate attachment guidance response
  static String _generateAttachmentResponse(String patientName) {
    return 'Para acessar os documentos e exames de $patientName:\n\n'
        '📎 Deslize a tela para a ESQUERDA\n'
        '📁 Você verá a seção "Anexos"\n'
        '👆 Toque em qualquer arquivo para visualizar\n\n'
        'Lá você encontrará:\n'
        '• Laudos de exames\n'
        '• Receitas médicas\n'
        '• Imagens (raio-x, ultrassom, etc.)\n'
        '• Documentos gerais\n\n'
        'Posso ajudar com algo mais?';
  }

  /// Generate patient summary response
  static String _generateSummaryResponse(MockPatient? patient) {
    if (patient == null) {
      return 'Não encontrei informações para este paciente.';
    }

    return 'Resumo rápido de ${patient.fullName}:\n\n'
        '👤 ${patient.age} anos\n'
        '🆔 CPF: ${patient.cpf}\n'
        '📅 Próxima consulta: ${patient.appointmentTime}\n'
        '📋 Tipo: ${patient.appointmentType}\n\n'
        'Para ver o resumo completo:\n'
        '➡️ Deslize para a DIREITA\n\n'
        'Lá você encontrará:\n'
        '• Dados demográficos completos\n'
        '• Histórico médico detalhado\n'
        '• Medicações atuais\n'
        '• Alergias e observações\n\n'
        'Como posso ajudar mais?';
  }

  /// Generate default fallback response
  static String _generateDefaultResponse(String patientName) {
    final responses = [
      'Desculpe, não entendi completamente. Posso ajudar $patientName com:\n\n'
          '• Informações sobre medicações\n'
          '• Resultados de exames\n'
          '• Agendamento de consultas\n'
          '• Histórico médico\n'
          '• Acesso a documentos\n\n'
          'O que você gostaria de saber?',
      'Não tenho certeza sobre isso. Posso ajudar com:\n\n'
          '📋 Consultas e agendamentos\n'
          '💊 Medicações prescritas\n'
          '🔬 Resultados de exames\n'
          '📁 Documentos e anexos\n\n'
          'Sobre qual assunto você gostaria de conversar?',
      'Ainda estou aprendendo! Posso ajudar $patientName com:\n\n'
          '• Ver informações de consultas\n'
          '• Listar medicações atuais\n'
          '• Acessar resultados de exames\n'
          '• Navegar pelos documentos anexados\n\n'
          'Tente perguntar sobre um desses tópicos!',
    ];

    // Return random response for variety
    return responses[DateTime.now().microsecond % responses.length];
  }

  /// Format date to Portuguese format
  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hoje';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Ontem';
    } else if (dateOnly == today.add(const Duration(days: 1))) {
      return 'Amanhã';
    }

    final months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];

    return '${date.day} de ${months[date.month - 1]}';
  }

  /// Get initial chat history for a patient (for demonstration)
  static List<MockChatMessage> getInitialHistory(String patientId) {
    final now = DateTime.now();

    return [
      MockChatMessage(
        id: 'msg_001',
        patientId: patientId,
        content: 'Olá! Preciso saber sobre minha próxima consulta.',
        isFromUser: true,
        timestamp: now.subtract(const Duration(minutes: 5)),
      ),
      MockChatMessage(
        id: 'msg_002',
        patientId: patientId,
        content: 'Olá! Claro, vou verificar suas informações de agendamento.',
        isFromUser: false,
        timestamp: now.subtract(const Duration(minutes: 4, seconds: 55)),
      ),
    ];
  }
}
