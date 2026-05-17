import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/models.dart';

/// Provider daftar pasien
final patientListProvider = StreamProvider<List<PatientModel>>((ref) {
  return FirebaseFirestore.instance
      .collection(AppConstants.colPatients)
      .where('isActive', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((d) => PatientModel.fromFirestore(d)).toList());
});

/// Halaman daftar pasien
class PatientListPage extends ConsumerStatefulWidget {
  const PatientListPage({super.key});
  @override
  ConsumerState<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends ConsumerState<PatientListPage> {
  String _search = '';
  bool _showForm = false;
  PatientModel? _editingPatient;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _nikC = TextEditingController();
  final _nameC = TextEditingController();
  final _phoneC = TextEditingController();
  final _addressC = TextEditingController();
  final _allergyC = TextEditingController();
  final _historyC = TextEditingController();
  String _gender = 'Laki-laki';
  String _bloodType = 'O';
  DateTime _birthDate = DateTime(2000, 1, 1);

  @override
  void dispose() {
    _nikC.dispose(); _nameC.dispose(); _phoneC.dispose();
    _addressC.dispose(); _allergyC.dispose(); _historyC.dispose();
    super.dispose();
  }

  void _resetForm() {
    _nikC.clear(); _nameC.clear(); _phoneC.clear();
    _addressC.clear(); _allergyC.clear(); _historyC.clear();
    _gender = 'Laki-laki'; _bloodType = 'O';
    _birthDate = DateTime(2000, 1, 1); _editingPatient = null;
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;
    final fs = FirebaseFirestore.instance;
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd').format(now);

    if (_editingPatient != null) {
      await fs.collection(AppConstants.colPatients).doc(_editingPatient!.id).update({
        'nik': _nikC.text.trim(), 'name': _nameC.text.trim(),
        'phone': _phoneC.text.trim(), 'address': _addressC.text.trim(),
        'allergy': _allergyC.text.trim(), 'medicalHistory': _historyC.text.trim(),
        'gender': _gender, 'bloodType': _bloodType,
        'birthDate': Timestamp.fromDate(_birthDate),
      });
    } else {
      // Generate nomor rekam medis
      final countSnap = await fs.collection(AppConstants.colPatients)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(now.year, now.month, now.day)))
          .count().get();
      final seq = (countSnap.count ?? 0) + 1;
      final mrn = '${AppConstants.medicalRecordPrefix}-$dateStr-${seq.toString().padLeft(4, '0')}';

      await fs.collection(AppConstants.colPatients).add(PatientModel(
        id: '', medicalRecordNo: mrn, nik: _nikC.text.trim(),
        name: _nameC.text.trim(), birthDate: _birthDate, gender: _gender,
        address: _addressC.text.trim(), phone: _phoneC.text.trim(),
        bloodType: _bloodType, allergy: _allergyC.text.trim(),
        medicalHistory: _historyC.text.trim(), createdAt: now,
      ).toFirestore());
    }

    if (mounted) setState(() { _showForm = false; _resetForm(); });
  }

  void _editPatient(PatientModel p) {
    _nikC.text = p.nik; _nameC.text = p.name; _phoneC.text = p.phone;
    _addressC.text = p.address; _allergyC.text = p.allergy;
    _historyC.text = p.medicalHistory; _gender = p.gender;
    _bloodType = p.bloodType; _birthDate = p.birthDate;
    _editingPatient = p;
    setState(() => _showForm = true);
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientListProvider);

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Manajemen Pasien', style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Kelola data pasien klinik', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.grey500)),
          ]),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => setState(() { _resetForm(); _showForm = !_showForm; }),
            icon: Icon(_showForm ? Icons.close : Icons.person_add_rounded, size: 18),
            label: Text(_showForm ? 'Tutup Form' : 'Pasien Baru'),
            style: ElevatedButton.styleFrom(backgroundColor: _showForm ? AppColors.grey600 : AppColors.primary),
          ),
        ]),
        const SizedBox(height: 20),

        // Form registrasi
        if (_showForm) _buildRegistrationForm(),

        // Search bar
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Cari pasien (nama, NIK, no. rekam medis)...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              filled: true, fillColor: AppColors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.grey200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.grey200)),
            ),
          ),
        ),

        // Tabel pasien
        Expanded(
          child: patientsAsync.when(
            loading: () => const LoadingWidget(message: 'Memuat data pasien...'),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (patients) {
              final filtered = patients.where((p) {
                final q = _search.toLowerCase();
                return p.name.toLowerCase().contains(q) || p.nik.contains(q) || p.medicalRecordNo.toLowerCase().contains(q);
              }).toList();

              if (filtered.isEmpty) {
                return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.people_outline, size: 64, color: AppColors.grey300),
                  const SizedBox(height: 16),
                  Text('Belum ada data pasien', style: GoogleFonts.plusJakartaSans(fontSize: 16, color: AppColors.grey500)),
                ]));
              }

              return Container(
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.grey200)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AppColors.grey50),
                      columnSpacing: 24,
                      columns: const [
                        DataColumn(label: Text('No. RM')),
                        DataColumn(label: Text('Nama')),
                        DataColumn(label: Text('NIK')),
                        DataColumn(label: Text('Jenis Kelamin')),
                        DataColumn(label: Text('No. HP')),
                        DataColumn(label: Text('Gol. Darah')),
                        DataColumn(label: Text('Aksi')),
                      ],
                      rows: filtered.map((p) => DataRow(cells: [
                        DataCell(Text(p.medicalRecordNo, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 12))),
                        DataCell(Text(p.name)),
                        DataCell(Text(p.nik)),
                        DataCell(Text(p.gender)),
                        DataCell(Text(p.phone)),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(12)),
                          child: Text(p.bloodType, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error)),
                        )),
                        DataCell(Row(children: [
                          IconButton(icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.primary), onPressed: () => _editPatient(p), tooltip: 'Edit'),
                          IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error), onPressed: () => _confirmDelete(p), tooltip: 'Hapus'),
                        ])),
                      ])).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildRegistrationForm() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primaryLight)),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_editingPatient != null ? 'Edit Pasien' : 'Registrasi Pasien Baru', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _field('NIK', _nikC, 'Masukkan NIK', validator: (v) => v!.isEmpty ? 'NIK wajib diisi' : null)),
            const SizedBox(width: 16),
            Expanded(child: _field('Nama Lengkap', _nameC, 'Masukkan nama', validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null)),
            const SizedBox(width: 16),
            Expanded(child: _field('No. HP', _phoneC, 'Masukkan no HP')),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _dropdownField('Jenis Kelamin', _gender, AppConstants.genderOptions, (v) => setState(() => _gender = v!))),
            const SizedBox(width: 16),
            Expanded(child: _dropdownField('Golongan Darah', _bloodType, AppConstants.bloodTypes, (v) => setState(() => _bloodType = v!))),
            const SizedBox(width: 16),
            Expanded(child: _dateField('Tanggal Lahir', _birthDate, (d) => setState(() => _birthDate = d))),
          ]),
          const SizedBox(height: 16),
          _field('Alamat', _addressC, 'Masukkan alamat', maxLines: 2),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _field('Alergi', _allergyC, 'Alergi (opsional)')),
            const SizedBox(width: 16),
            Expanded(child: _field('Riwayat Penyakit', _historyC, 'Riwayat penyakit (opsional)')),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            OutlinedButton(onPressed: () => setState(() { _showForm = false; _resetForm(); }), child: const Text('Batal')),
            const SizedBox(width: 12),
            ElevatedButton.icon(onPressed: _savePatient, icon: const Icon(Icons.save_rounded, size: 18), label: Text(_editingPatient != null ? 'Update' : 'Simpan')),
          ]),
        ]),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, String hint, {int maxLines = 1, String? Function(String?)? validator}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.grey700)),
      const SizedBox(height: 6),
      TextFormField(controller: c, maxLines: maxLines, validator: validator, decoration: InputDecoration(hintText: hint, filled: true, fillColor: AppColors.grey50)),
    ]);
  }

  Widget _dropdownField(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.grey700)),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(value: value, items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: onChanged,
        decoration: InputDecoration(filled: true, fillColor: AppColors.grey50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.grey300)))),
    ]);
  }

  Widget _dateField(String label, DateTime date, ValueChanged<DateTime> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.grey700)),
      const SizedBox(height: 6),
      InkWell(
        onTap: () async {
          final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(1900), lastDate: DateTime.now());
          if (picked != null) onChanged(picked);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.grey300)),
          child: Row(children: [
            Text(DateFormat('dd/MM/yyyy').format(date), style: GoogleFonts.plusJakartaSans(fontSize: 14)),
            const Spacer(),
            const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.grey500),
          ]),
        ),
      ),
    ]);
  }

  Future<void> _confirmDelete(PatientModel p) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Hapus Pasien'),
      content: Text('Yakin ingin menonaktifkan data pasien ${p.name}?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
        ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), child: const Text('Hapus')),
      ],
    ));
    if (confirm == true) {
      await FirebaseFirestore.instance.collection(AppConstants.colPatients).doc(p.id).update({'isActive': false});
    }
  }
}
