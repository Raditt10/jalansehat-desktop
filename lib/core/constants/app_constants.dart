/// Konstanta aplikasi Jalan Sehat
class AppConstants {
  AppConstants._();

  // Informasi Klinik
  static const String clinicName = 'Klinik Pratama Medina';
  static const String clinicAddress =
      'Komplek Permata Biru Blok S No. 28, Cinunuk, Kec. Cileunyi, Kabupaten Bandung, Jawa Barat';
  static const String clinicPhone = '(022) 63724336';
  static const String clinicHours = '24 Jam / Setiap Hari';
  static const String clinicEmail = 'info@klinikmedina.com';

  // App Info
  static const String appName = 'Jalan Sehat';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Sistem Manajemen Klinik Pratama Medina';

  // Format Nomor Rekam Medis: MED-YYYYMMDD-XXXX
  static const String medicalRecordPrefix = 'MED';

  // Role pengguna
  static const String roleAdmin = 'admin';
  static const String roleDoctor = 'doctor';
  static const String rolePatient = 'patient';

  // Status Antrian
  static const String queueWaiting = 'waiting';
  static const String queueCalled = 'called';
  static const String queueExamining = 'examining';
  static const String queueDone = 'done';
  static const String queueCancelled = 'cancelled';

  // Status Dokter
  static const String doctorActive = 'active';
  static const String doctorAbsent = 'absent';
  static const String doctorLeave = 'leave';

  // Metode Pembayaran
  static const String paymentCash = 'cash';
  static const String paymentTransfer = 'transfer';
  static const String paymentBpjs = 'bpjs';

  // Status Konsultasi
  static const String consultationActive = 'active';
  static const String consultationClosed = 'closed';

  // Firestore Collection Names
  static const String colUsers = 'users';
  static const String colPatients = 'patients';
  static const String colDoctors = 'doctors';
  static const String colQueues = 'queues';
  static const String colMedicalRecords = 'medical_records';
  static const String colMedicines = 'medicines';
  static const String colTransactions = 'transactions';
  static const String colConsultations = 'consultations';
  static const String colConsultationMessages = 'messages';
  static const String colChatHistories = 'chat_histories';
  static const String colSettings = 'settings';

  // Gemini API
  static const String geminiModel = 'gemini-1.5-flash';
  // Ganti dengan API key Anda
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';

  // Sesi Praktik Dokter
  static const List<String> sessionLabels = ['Pagi', 'Siang', 'Malam'];

  // Golongan Darah
  static const List<String> bloodTypes = [
    'A', 'B', 'AB', 'O',
    'A+', 'A-', 'B+', 'B-',
    'AB+', 'AB-', 'O+', 'O-',
  ];

  // Jenis Kelamin
  static const List<String> genderOptions = ['Laki-laki', 'Perempuan'];

  // Window config
  static const double minWindowWidth = 1200;
  static const double minWindowHeight = 700;
  static const double defaultWindowWidth = 1400;
  static const double defaultWindowHeight = 850;
}
