import 'package:cloud_firestore/cloud_firestore.dart';

/// Model data pengguna aplikasi
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'admin',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'email': email,
        'role': role,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

/// Model data pasien
class PatientModel {
  final String id;
  final String medicalRecordNo;
  final String nik;
  final String name;
  final DateTime birthDate;
  final String gender;
  final String address;
  final String phone;
  final String bloodType;
  final String allergy;
  final String medicalHistory;
  final bool isActive;
  final DateTime createdAt;

  const PatientModel({
    required this.id,
    required this.medicalRecordNo,
    required this.nik,
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.address,
    required this.phone,
    required this.bloodType,
    this.allergy = '',
    this.medicalHistory = '',
    this.isActive = true,
    required this.createdAt,
  });

  factory PatientModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PatientModel(
      id: doc.id,
      medicalRecordNo: data['medicalRecordNo'] ?? '',
      nik: data['nik'] ?? '',
      name: data['name'] ?? '',
      birthDate: (data['birthDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      gender: data['gender'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      bloodType: data['bloodType'] ?? '',
      allergy: data['allergy'] ?? '',
      medicalHistory: data['medicalHistory'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'medicalRecordNo': medicalRecordNo,
        'nik': nik,
        'name': name,
        'birthDate': Timestamp.fromDate(birthDate),
        'gender': gender,
        'address': address,
        'phone': phone,
        'bloodType': bloodType,
        'allergy': allergy,
        'medicalHistory': medicalHistory,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  PatientModel copyWith({
    String? id,
    String? medicalRecordNo,
    String? nik,
    String? name,
    DateTime? birthDate,
    String? gender,
    String? address,
    String? phone,
    String? bloodType,
    String? allergy,
    String? medicalHistory,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return PatientModel(
      id: id ?? this.id,
      medicalRecordNo: medicalRecordNo ?? this.medicalRecordNo,
      nik: nik ?? this.nik,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      bloodType: bloodType ?? this.bloodType,
      allergy: allergy ?? this.allergy,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Model data dokter
class DoctorModel {
  final String id;
  final String name;
  final String specialization;
  final String sipNumber;
  final String phone;
  final String status;
  final int quota;
  final Map<String, List<String>> schedule; // day -> [sessions]
  final DateTime createdAt;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialization,
    required this.sipNumber,
    required this.phone,
    this.status = 'active',
    this.quota = 30,
    this.schedule = const {},
    required this.createdAt,
  });

  factory DoctorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final scheduleRaw = data['schedule'] as Map<String, dynamic>? ?? {};
    final schedule = scheduleRaw.map(
      (key, value) => MapEntry(key, List<String>.from(value as List)),
    );

    return DoctorModel(
      id: doc.id,
      name: data['name'] ?? '',
      specialization: data['specialization'] ?? '',
      sipNumber: data['sipNumber'] ?? '',
      phone: data['phone'] ?? '',
      status: data['status'] ?? 'active',
      quota: data['quota'] ?? 30,
      schedule: schedule,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'specialization': specialization,
        'sipNumber': sipNumber,
        'phone': phone,
        'status': status,
        'quota': quota,
        'schedule': schedule,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

/// Model data antrian
class QueueModel {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final DateTime date;
  final int queueNumber;
  final String status;
  final DateTime createdAt;

  const QueueModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.date,
    required this.queueNumber,
    required this.status,
    required this.createdAt,
  });

  factory QueueModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QueueModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      queueNumber: data['queueNumber'] ?? 0,
      status: data['status'] ?? 'waiting',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'patientId': patientId,
        'patientName': patientName,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'date': Timestamp.fromDate(date),
        'queueNumber': queueNumber,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

/// Model rekam medis (SOAP)
class MedicalRecordModel {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final DateTime visitDate;
  final String subjective;
  final Map<String, dynamic> objective; // vital signs
  final String assessment;
  final String icd10Code;
  final String plan;
  final List<Map<String, dynamic>> prescriptions;
  final DateTime createdAt;

  const MedicalRecordModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.visitDate,
    required this.subjective,
    required this.objective,
    required this.assessment,
    this.icd10Code = '',
    required this.plan,
    this.prescriptions = const [],
    required this.createdAt,
  });

  factory MedicalRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MedicalRecordModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      visitDate:
          (data['visitDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      subjective: data['subjective'] ?? '',
      objective: Map<String, dynamic>.from(data['objective'] ?? {}),
      assessment: data['assessment'] ?? '',
      icd10Code: data['icd10Code'] ?? '',
      plan: data['plan'] ?? '',
      prescriptions: List<Map<String, dynamic>>.from(
          data['prescriptions'] ?? []),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'patientId': patientId,
        'patientName': patientName,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'visitDate': Timestamp.fromDate(visitDate),
        'subjective': subjective,
        'objective': objective,
        'assessment': assessment,
        'icd10Code': icd10Code,
        'plan': plan,
        'prescriptions': prescriptions,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

/// Model obat
class MedicineModel {
  final String id;
  final String name;
  final String genericName;
  final String unit;
  final int stock;
  final int minStock;
  final double priceBuy;
  final double priceSell;
  final DateTime expiredDate;
  final DateTime createdAt;

  const MedicineModel({
    required this.id,
    required this.name,
    this.genericName = '',
    required this.unit,
    required this.stock,
    this.minStock = 10,
    required this.priceBuy,
    required this.priceSell,
    required this.expiredDate,
    required this.createdAt,
  });

  factory MedicineModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MedicineModel(
      id: doc.id,
      name: data['name'] ?? '',
      genericName: data['genericName'] ?? '',
      unit: data['unit'] ?? '',
      stock: data['stock'] ?? 0,
      minStock: data['minStock'] ?? 10,
      priceBuy: (data['priceBuy'] ?? 0).toDouble(),
      priceSell: (data['priceSell'] ?? 0).toDouble(),
      expiredDate:
          (data['expiredDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'genericName': genericName,
        'unit': unit,
        'stock': stock,
        'minStock': minStock,
        'priceBuy': priceBuy,
        'priceSell': priceSell,
        'expiredDate': Timestamp.fromDate(expiredDate),
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

/// Model transaksi
class TransactionModel {
  final String id;
  final String patientId;
  final String patientName;
  final DateTime date;
  final List<Map<String, dynamic>> items;
  final double total;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.date,
    required this.items,
    required this.total,
    required this.paymentMethod,
    this.status = 'paid',
    required this.createdAt,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      total: (data['total'] ?? 0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? 'cash',
      status: data['status'] ?? 'paid',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'patientId': patientId,
        'patientName': patientName,
        'date': Timestamp.fromDate(date),
        'items': items,
        'total': total,
        'paymentMethod': paymentMethod,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
