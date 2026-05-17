import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/models.dart';

class MedicalRecordPage extends ConsumerStatefulWidget {
  const MedicalRecordPage({super.key});
  @override
  ConsumerState<MedicalRecordPage> createState() => _MedicalRecordPageState();
}

class _MedicalRecordPageState extends ConsumerState<MedicalRecordPage> {
  bool _showForm = false;
  final _formKey = GlobalKey<FormState>();
  // SOAP fields
  final _subjC = TextEditingController();
  final _bpC = TextEditingController(); final _tempC = TextEditingController();
  final _pulseC = TextEditingController(); final _weightC = TextEditingController();
  final _heightC = TextEditingController(); final _spo2C = TextEditingController();
  final _physExamC = TextEditingController();
  final _assessC = TextEditingController(); final _icdC = TextEditingController();
  final _planC = TextEditingController();
  String? _selectedPatientId, _selectedPatientName, _selectedDoctorId, _selectedDoctorName;

  @override
  void dispose() {
    for (final c in [_subjC, _bpC, _tempC, _pulseC, _weightC, _heightC, _spo2C, _physExamC, _assessC, _icdC, _planC]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedPatientId == null || _selectedDoctorId == null) return;
    final now = DateTime.now();
    await FirebaseFirestore.instance.collection(AppConstants.colMedicalRecords).add(MedicalRecordModel(
      id: '', patientId: _selectedPatientId!, patientName: _selectedPatientName ?? '',
      doctorId: _selectedDoctorId!, doctorName: _selectedDoctorName ?? '',
      visitDate: now, subjective: _subjC.text.trim(),
      objective: {'bp': _bpC.text, 'temp': _tempC.text, 'pulse': _pulseC.text, 'weight': _weightC.text, 'height': _heightC.text, 'spo2': _spo2C.text, 'physicalExam': _physExamC.text},
      assessment: _assessC.text.trim(), icd10Code: _icdC.text.trim(), plan: _planC.text.trim(), createdAt: now,
    ).toFirestore());
    if (mounted) setState(() => _showForm = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Rekam Medis', style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('SOAP Notes - Catatan pemeriksaan pasien', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.grey500)),
        ]),
        const Spacer(),
        ElevatedButton.icon(onPressed: () => setState(() => _showForm = !_showForm),
          icon: Icon(_showForm ? Icons.close : Icons.note_add_rounded, size: 18),
          label: Text(_showForm ? 'Tutup' : 'Buat Rekam Medis'),
          style: ElevatedButton.styleFrom(backgroundColor: _showForm ? AppColors.grey600 : AppColors.primary)),
      ]),
      const SizedBox(height: 20),

      if (_showForm) Expanded(child: SingleChildScrollView(child: _buildSOAPForm())),

      if (!_showForm) Expanded(child: _buildRecordList()),
    ]));
  }

  Widget _buildSOAPForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primaryLight)),
      child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Form SOAP Notes', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 20),
        // Patient & Doctor selection
        Row(children: [
          Expanded(child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection(AppConstants.colPatients).where('isActive', isEqualTo: true).get(),
            builder: (_, snap) => DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Pilih Pasien', filled: true),
              items: (snap.data?.docs ?? []).map((d) => DropdownMenuItem(value: d.id, child: Text(d['name'] ?? ''))).toList(),
              onChanged: (v) { _selectedPatientId = v; _selectedPatientName = snap.data!.docs.firstWhere((d) => d.id == v)['name']; },
              validator: (_) => _selectedPatientId == null ? 'Pilih pasien' : null,
            ),
          )),
          const SizedBox(width: 16),
          Expanded(child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection(AppConstants.colDoctors).where('status', isEqualTo: 'active').get(),
            builder: (_, snap) => DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Dokter Pemeriksa', filled: true),
              items: (snap.data?.docs ?? []).map((d) => DropdownMenuItem(value: d.id, child: Text(d['name'] ?? ''))).toList(),
              onChanged: (v) { _selectedDoctorId = v; _selectedDoctorName = snap.data!.docs.firstWhere((d) => d.id == v)['name']; },
              validator: (_) => _selectedDoctorId == null ? 'Pilih dokter' : null,
            ),
          )),
        ]),
        const SizedBox(height: 24),
        // S - Subjective
        _sectionHeader('S', 'Subjective', 'Keluhan pasien', AppColors.accent),
        const SizedBox(height: 8),
        TextFormField(controller: _subjC, maxLines: 3, decoration: const InputDecoration(hintText: 'Keluhan utama, riwayat penyakit sekarang...', filled: true), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
        const SizedBox(height: 24),
        // O - Objective
        _sectionHeader('O', 'Objective', 'Pemeriksaan fisik & vital signs', AppColors.teal),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _vitalsField('Tekanan Darah', _bpC, 'mmHg', '120/80')),
          const SizedBox(width: 12),
          Expanded(child: _vitalsField('Suhu', _tempC, '°C', '36.5')),
          const SizedBox(width: 12),
          Expanded(child: _vitalsField('Nadi', _pulseC, 'x/mnt', '80')),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _vitalsField('Berat Badan', _weightC, 'kg', '60')),
          const SizedBox(width: 12),
          Expanded(child: _vitalsField('Tinggi Badan', _heightC, 'cm', '165')),
          const SizedBox(width: 12),
          Expanded(child: _vitalsField('SpO2', _spo2C, '%', '98')),
        ]),
        const SizedBox(height: 12),
        TextFormField(controller: _physExamC, maxLines: 2, decoration: const InputDecoration(labelText: 'Pemeriksaan Fisik', hintText: 'Hasil pemeriksaan fisik...', filled: true)),
        const SizedBox(height: 24),
        // A - Assessment
        _sectionHeader('A', 'Assessment', 'Diagnosis', AppColors.warning),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(flex: 2, child: TextFormField(controller: _assessC, decoration: const InputDecoration(hintText: 'Diagnosis...', filled: true), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null)),
          const SizedBox(width: 12),
          Expanded(child: TextFormField(controller: _icdC, decoration: const InputDecoration(hintText: 'Kode ICD-10', filled: true))),
        ]),
        const SizedBox(height: 24),
        // P - Plan
        _sectionHeader('P', 'Plan', 'Rencana tindakan', AppColors.success),
        const SizedBox(height: 8),
        TextFormField(controller: _planC, maxLines: 3, decoration: const InputDecoration(hintText: 'Resep obat, tindakan, anjuran, rujukan...', filled: true), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
        const SizedBox(height: 32),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          OutlinedButton(onPressed: () => setState(() => _showForm = false), child: const Text('Batal')),
          const SizedBox(width: 12),
          ElevatedButton.icon(onPressed: _save, icon: const Icon(Icons.save_rounded, size: 18), label: const Text('Simpan Rekam Medis')),
        ]),
      ])),
    );
  }

  Widget _sectionHeader(String code, String title, String subtitle, Color color) {
    return Row(children: [
      Container(width: 36, height: 36, alignment: Alignment.center, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Text(code, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white))),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600)),
        Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.grey500)),
      ]),
    ]);
  }

  Widget _vitalsField(String label, TextEditingController c, String unit, String hint) {
    return TextFormField(controller: c, keyboardType: TextInputType.text, decoration: InputDecoration(labelText: label, hintText: hint, suffixText: unit, filled: true));
  }

  Widget _buildRecordList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(AppConstants.colMedicalRecords).orderBy('createdAt', descending: true).limit(50).snapshots(),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final records = snap.data?.docs.map((d) => MedicalRecordModel.fromFirestore(d)).toList() ?? [];
        if (records.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.assignment_outlined, size: 64, color: AppColors.grey300), const SizedBox(height: 16),
          Text('Belum ada rekam medis', style: GoogleFonts.plusJakartaSans(fontSize: 16, color: AppColors.grey500)),
        ]));
        return ListView.builder(itemCount: records.length, itemBuilder: (_, i) {
          final r = records[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.grey200)),
            child: Row(children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)), alignment: Alignment.center,
                child: const Icon(Icons.assignment_rounded, color: AppColors.primary)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.patientName, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Dokter: ${r.doctorName} • Diagnosis: ${r.assessment}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.grey500)),
              ])),
              if (r.icd10Code.isNotEmpty) Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(8)),
                child: Text(r.icd10Code, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.warning)),
              ),
            ]),
          );
        });
      },
    );
  }
}
