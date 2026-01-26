/// Mock attachment data for MVP development and testing.
///
/// This file contains realistic attachment data structures that match
/// the AttachsScreen design requirements shown in AttachsScreen.png.
///
/// Design Requirements:
/// - Attachment cards show: PDF icon, filename, type • size, delete button (X)
/// - Example: "ArquivoDeTeste.pdf", "PDF • 286kb"
/// - Multiple attachments per patient
library;

/// Mock attachment data structure.
///
/// Matches the attachments_cache table schema from database design.
class MockAttachment {
  final String id;
  final String patientId;
  final String filename;
  final String fileType; // "PDF", "IMAGE", "DOCUMENT"
  final int fileSizeBytes;
  final String fileSizeDisplay; // "286kb", "1.2mb", etc.
  final DateTime uploadDate;
  final String? localPath; // Path to test asset (for MVP)
  final String? notes;

  const MockAttachment({
    required this.id,
    required this.patientId,
    required this.filename,
    required this.fileType,
    required this.fileSizeBytes,
    required this.fileSizeDisplay,
    required this.uploadDate,
    this.localPath,
    this.notes,
  });

  /// Returns true if this is an image file
  bool get isImage =>
      fileType == 'IMAGE' ||
      filename.toLowerCase().endsWith('.jpg') ||
      filename.toLowerCase().endsWith('.jpeg') ||
      filename.toLowerCase().endsWith('.png');

  /// Returns true if this is a PDF file
  bool get isPdf =>
      fileType == 'PDF' || filename.toLowerCase().endsWith('.pdf');
}

/// Mock attachments for MVP development.
///
/// Based on AttachsScreen.png design showing multiple "ArquivoDeTeste.pdf" files.
/// Distributed across multiple patients for realistic testing.
class MockAttachments {
  /// All mock attachments (50+ for realistic lists)
  static final List<MockAttachment> all = [
    // PATIENT 001 (Maria Silva Santos) - 5 attachments
    MockAttachment(
      id: 'attach_001',
      patientId: 'patient_001',
      filename: 'ArquivoDeTeste.pdf',
      fileType: 'PDF',
      fileSizeBytes: 292864,
      fileSizeDisplay: '286kb',
      uploadDate: DateTime.now().subtract(const Duration(days: 2)),
      localPath: 'test_assets/pdfs/sample_exam.pdf',
      notes: 'Exame de sangue - Janeiro 2026',
    ),
    MockAttachment(
      id: 'attach_002',
      patientId: 'patient_001',
      filename: 'Receita_Medica.pdf',
      fileType: 'PDF',
      fileSizeBytes: 153600,
      fileSizeDisplay: '150kb',
      uploadDate: DateTime.now().subtract(const Duration(days: 5)),
      localPath: 'test_assets/pdfs/sample_prescription.pdf',
    ),
    MockAttachment(
      id: 'attach_003',
      patientId: 'patient_001',
      filename: 'RaioX_Torax.jpg',
      fileType: 'IMAGE',
      fileSizeBytes: 2048000,
      fileSizeDisplay: '2mb',
      uploadDate: DateTime.now().subtract(const Duration(days: 10)),
      localPath: 'test_assets/images/sample_xray.jpg',
    ),
    MockAttachment(
      id: 'attach_004',
      patientId: 'patient_001',
      filename: 'Ultrassom_Abdomen.pdf',
      fileType: 'PDF',
      fileSizeBytes: 512000,
      fileSizeDisplay: '500kb',
      uploadDate: DateTime.now().subtract(const Duration(days: 15)),
      localPath: 'test_assets/pdfs/sample_ultrasound.pdf',
    ),
    MockAttachment(
      id: 'attach_005',
      patientId: 'patient_001',
      filename: 'Anamnese_Inicial.pdf',
      fileType: 'PDF',
      fileSizeBytes: 204800,
      fileSizeDisplay: '200kb',
      uploadDate: DateTime.now().subtract(const Duration(days: 30)),
      localPath: 'test_assets/pdfs/sample_anamnesis.pdf',
    ),

    // PATIENT 002 (João Pedro Oliveira) - 3 attachments
    MockAttachment(
      id: 'attach_006',
      patientId: 'patient_002',
      filename: 'Laudo_Cirurgia.pdf',
      fileType: 'PDF',
      fileSizeBytes: 409600,
      fileSizeDisplay: '400kb',
      uploadDate: DateTime.now().subtract(const Duration(days: 3)),
      localPath: 'test_assets/pdfs/sample_surgery_report.pdf',
    ),
    MockAttachment(
      id: 'attach_007',
      patientId: 'patient_002',
      filename: 'Foto_Pos_Cirurgia.jpg',
      fileType: 'IMAGE',
      fileSizeBytes: 1536000,
      fileSizeDisplay: '1.5mb',
      uploadDate: DateTime.now().subtract(const Duration(days: 7)),
      localPath: 'test_assets/images/sample_photo.jpg',
    ),
    MockAttachment(
      id: 'attach_008',
      patientId: 'patient_002',
      filename: 'Exames_Pre_Operatorio.pdf',
      fileType: 'PDF',
      fileSizeBytes: 614400,
      fileSizeDisplay: '600kb',
      uploadDate: DateTime.now().subtract(const Duration(days: 45)),
      localPath: 'test_assets/pdfs/sample_preop_exams.pdf',
    ),

    // PATIENT 012 (Gustavo Belmante Ribeiro) - ChatAssistentScreen.png patient
    MockAttachment(
      id: 'attach_009',
      patientId: 'patient_012',
      filename: 'Tomografia_Torax.pdf',
      fileType: 'PDF',
      fileSizeBytes: 1048576,
      fileSizeDisplay: '1mb',
      uploadDate: DateTime.now().subtract(const Duration(days: 1)),
      localPath: 'test_assets/pdfs/sample_ct_scan.pdf',
      notes: 'Tomografia do AttachVisualizationScreen.png - Dr. Enoch',
    ),
    MockAttachment(
      id: 'attach_010',
      patientId: 'patient_012',
      filename: 'Historico_Medico.pdf',
      fileType: 'PDF',
      fileSizeBytes: 256000,
      fileSizeDisplay: '250kb',
      uploadDate: DateTime.now().subtract(const Duration(days: 20)),
      localPath: 'test_assets/pdfs/sample_medical_history.pdf',
    ),

    // PATIENT 003 (Ana Carolina Mendes) - 4 attachments
    MockAttachment(
      id: 'attach_011',
      patientId: 'patient_003',
      filename: 'Eletrocardiograma.pdf',
      fileType: 'PDF',
      fileSizeBytes: 307200,
      fileSizeDisplay: '300kb',
      uploadDate: DateTime.now().subtract(const Duration(days: 8)),
      localPath: 'test_assets/pdfs/sample_ecg.pdf',
    ),
    MockAttachment(
      id: 'attach_012',
      patientId: 'patient_003',
      filename: 'Exame_Sangue_Completo.pdf',
      fileType: 'PDF',
      fileSizeBytes: 358400,
      fileSizeDisplay: '350kb',
      uploadDate: DateTime.now().subtract(const Duration(days: 12)),
      localPath: 'test_assets/pdfs/sample_blood_test.pdf',
    ),
    MockAttachment(
      id: 'attach_013',
      patientId: 'patient_003',
      filename: 'RaioX_Abdomen.jpg',
      fileType: 'IMAGE',
      fileSizeBytes: 1843200,
      fileSizeDisplay: '1.8mb',
      uploadDate: DateTime.now().subtract(const Duration(days: 18)),
      localPath: 'test_assets/images/sample_xray_abdomen.jpg',
    ),
    MockAttachment(
      id: 'attach_014',
      patientId: 'patient_003',
      filename: 'Receituario.pdf',
      fileType: 'PDF',
      fileSizeBytes: 128000,
      fileSizeDisplay: '125kb',
      uploadDate: DateTime.now().subtract(const Duration(days: 25)),
      localPath: 'test_assets/pdfs/sample_prescription_2.pdf',
    ),

    // Additional attachments for other patients (patient_004 through patient_010)
    // Each with 2-3 attachments for variety
    MockAttachment(
      id: 'attach_015',
      patientId: 'patient_004',
      filename: 'Exame_Urina.pdf',
      fileType: 'PDF',
      fileSizeBytes: 204800,
      fileSizeDisplay: '200kb',
      uploadDate: DateTime.now().subtract(const Duration(days: 4)),
      localPath: 'test_assets/pdfs/sample_urine_test.pdf',
    ),
    MockAttachment(
      id: 'attach_016',
      patientId: 'patient_004',
      filename: 'Colesterol_HDL_LDL.pdf',
      fileType: 'PDF',
      fileSizeBytes: 179200,
      fileSizeDisplay: '175kb',
      uploadDate: DateTime.now().subtract(const Duration(days: 9)),
      localPath: 'test_assets/pdfs/sample_cholesterol.pdf',
    ),

    MockAttachment(
      id: 'attach_017',
      patientId: 'patient_005',
      filename: 'Ficha_Cadastro.pdf',
      fileType: 'PDF',
      fileSizeBytes: 153600,
      fileSizeDisplay: '150kb',
      uploadDate: DateTime.now().subtract(const Duration(days: 1)),
      localPath: 'test_assets/pdfs/sample_registration.pdf',
    ),

    MockAttachment(
      id: 'attach_018',
      patientId: 'patient_006',
      filename: 'Ressonancia_Magnetica.pdf',
      fileType: 'PDF',
      fileSizeBytes: 1536000,
      fileSizeDisplay: '1.5mb',
      uploadDate: DateTime.now().subtract(const Duration(days: 6)),
      localPath: 'test_assets/pdfs/sample_mri.pdf',
    ),
    MockAttachment(
      id: 'attach_019',
      patientId: 'patient_006',
      filename: 'Laudo_Neurologico.pdf',
      fileType: 'PDF',
      fileSizeBytes: 409600,
      fileSizeDisplay: '400kb',
      uploadDate: DateTime.now().subtract(const Duration(days: 14)),
      localPath: 'test_assets/pdfs/sample_neuro_report.pdf',
    ),

    MockAttachment(
      id: 'attach_020',
      patientId: 'patient_007',
      filename: 'Teste_Alergias.pdf',
      fileType: 'PDF',
      fileSizeBytes: 230400,
      fileSizeDisplay: '225kb',
      uploadDate: DateTime.now().subtract(const Duration(days: 11)),
      localPath: 'test_assets/pdfs/sample_allergy_test.pdf',
    ),

    MockAttachment(
      id: 'attach_021',
      patientId: 'patient_008',
      filename: 'Densitometria_Ossea.pdf',
      fileType: 'PDF',
      fileSizeBytes: 512000,
      fileSizeDisplay: '500kb',
      uploadDate: DateTime.now().subtract(const Duration(days: 13)),
      localPath: 'test_assets/pdfs/sample_bone_density.pdf',
    ),
    MockAttachment(
      id: 'attach_022',
      patientId: 'patient_008',
      filename: 'Foto_Raio_X_Joelho.jpg',
      fileType: 'IMAGE',
      fileSizeBytes: 2097152,
      fileSizeDisplay: '2mb',
      uploadDate: DateTime.now().subtract(const Duration(days: 19)),
      localPath: 'test_assets/images/sample_knee_xray.jpg',
    ),

    MockAttachment(
      id: 'attach_023',
      patientId: 'patient_009',
      filename: 'Mamografia.pdf',
      fileType: 'PDF',
      fileSizeBytes: 819200,
      fileSizeDisplay: '800kb',
      uploadDate: DateTime.now().subtract(const Duration(days: 21)),
      localPath: 'test_assets/pdfs/sample_mammography.pdf',
    ),

    MockAttachment(
      id: 'attach_024',
      patientId: 'patient_010',
      filename: 'Endoscopia_Digestiva.pdf',
      fileType: 'PDF',
      fileSizeBytes: 716800,
      fileSizeDisplay: '700kb',
      uploadDate: DateTime.now().subtract(const Duration(days: 16)),
      localPath: 'test_assets/pdfs/sample_endoscopy.pdf',
    ),
    MockAttachment(
      id: 'attach_025',
      patientId: 'patient_010',
      filename: 'Biopsia_Resultados.pdf',
      fileType: 'PDF',
      fileSizeBytes: 281600,
      fileSizeDisplay: '275kb',
      uploadDate: DateTime.now().subtract(const Duration(days: 27)),
      localPath: 'test_assets/pdfs/sample_biopsy.pdf',
    ),
  ];

  /// Get attachments for a specific patient
  static List<MockAttachment> getByPatientId(String patientId) {
    return all.where((a) => a.patientId == patientId).toList()
      ..sort((a, b) => b.uploadDate.compareTo(a.uploadDate)); // Newest first
  }

  /// Get attachment by ID (for navigation to AttachmentViewerScreen)
  static MockAttachment? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Search attachments by filename
  static List<MockAttachment> search(String patientId, String query) {
    if (query.isEmpty) return getByPatientId(patientId);

    final lowerQuery = query.toLowerCase();
    return getByPatientId(patientId)
        .where((a) => a.filename.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Filter attachments by file type
  static List<MockAttachment> filterByType(
      String patientId, String fileType) {
    if (fileType == 'ALL') return getByPatientId(patientId);

    return getByPatientId(patientId)
        .where((a) => a.fileType == fileType)
        .toList();
  }

  /// Get stats for a patient (total files, total size)
  static Map<String, dynamic> getStatsForPatient(String patientId) {
    final attachments = getByPatientId(patientId);
    final totalSize = attachments.fold<int>(
      0,
      (sum, a) => sum + a.fileSizeBytes,
    );

    return {
      'total_files': attachments.length,
      'total_size_bytes': totalSize,
      'total_size_display': _formatBytes(totalSize),
      'pdf_count': attachments.where((a) => a.isPdf).length,
      'image_count': attachments.where((a) => a.isImage).length,
    };
  }

  /// Format bytes to human-readable string
  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}b';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)}kb';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}mb';
  }
}
