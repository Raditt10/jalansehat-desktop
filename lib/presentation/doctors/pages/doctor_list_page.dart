import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/models.dart';

final doctorListProvider = StreamProvider<List<DoctorModel>>((ref) {
  return FirebaseFirestore.instance.collection(AppConstants.colDoctors).orderBy('name').snapshots()
      .map((s) => s.docs.map((d) => DoctorModel.fromFirestore(d)).toList());
});

class DoctorListPage extends ConsumerStatefulWidget {
  const DoctorListPage({super.key});
  @override
  ConsumerState<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends ConsumerState<DoctorListPage> {
  bool _showForm = false;
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _specC = TextEditingController();
  final _sipC = TextEditingController();
  final _phoneC = TextEditingController();
  int _quota = 30;
  String? _editId;

  @override
  void dispose() { _nameC.dispose(); _specC.dispose(); _sipC.dispose(); _phoneC.dispose(); super.dispose(); }

  void _resetForm() { _nameC.clear(); _specC.clear(); _sipC.clear(); _phoneC.clear(); _quota = 30; _editId = null; }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final data = {'name': _nameC.text.trim(), 'specialization': _specC.text.trim(), 'sipNumber': _sipC.text.trim(), 'phone': _phoneC.text.trim(), 'quota': _quota, 'status': 'active', 'schedule': {}, 'createdAt': Timestamp.fromDate(DateTime.now())};
    if (_editId != null) {
      data.remove('createdAt');
      await FirebaseFirestore.instance.collection(AppConstants.colDoctors).doc(_editId).update(data);
    } else {
      await FirebaseFirestore.instance.collection(AppConstants.colDoctors).add(data);
    }
    if (mounted) setState(() { _showForm = false; _resetForm(); });
  }

  void _edit(DoctorModel d) {
    _nameC.text = d.name; _specC.text = d.specialization; _sipC.text = d.sipNumber; _phoneC.text = d.phone; _quota = d.quota; _editId = d.id;
    setState(() => _showForm = true);
  }

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(doctorListProvider);
    return Padding(padding: const EdgeInsets.all(28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Manajemen Dokter', style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Kelola data dan jadwal dokter', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.grey500)),
        ]),
        const Spacer(),
        ElevatedButton.icon(onPressed: () => setState(() { _resetForm(); _showForm = !_showForm; }),
          icon: Icon(_showForm ? Icons.close : Icons.person_add_rounded, size: 18),
          label: Text(_showForm ? 'Tutup Form' : 'Tambah Dokter'),
          style: ElevatedButton.styleFrom(backgroundColor: _showForm ? AppColors.grey600 : AppColors.primary)),
      ]),
      const SizedBox(height: 20),

      if (_showForm) Container(
        margin: const EdgeInsets.only(bottom: 20), padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primaryLight)),
        child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_editId != null ? 'Edit Dokter' : 'Tambah Dokter Baru', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: TextFormField(controller: _nameC, decoration: const InputDecoration(labelText: 'Nama Dokter', filled: true), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null)),
            const SizedBox(width: 16),
            Expanded(child: TextFormField(controller: _specC, decoration: const InputDecoration(labelText: 'Spesialisasi', filled: true), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: TextFormField(controller: _sipC, decoration: const InputDecoration(labelText: 'Nomor SIP', filled: true))),
            const SizedBox(width: 16),
            Expanded(child: TextFormField(controller: _phoneC, decoration: const InputDecoration(labelText: 'No. HP', filled: true))),
            const SizedBox(width: 16),
            SizedBox(width: 120, child: TextFormField(initialValue: _quota.toString(), decoration: const InputDecoration(labelText: 'Kuota', filled: true),
              keyboardType: TextInputType.number, onChanged: (v) => _quota = int.tryParse(v) ?? 30)),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            OutlinedButton(onPressed: () => setState(() { _showForm = false; _resetForm(); }), child: const Text('Batal')),
            const SizedBox(width: 12),
            ElevatedButton.icon(onPressed: _save, icon: const Icon(Icons.save_rounded, size: 18), label: Text(_editId != null ? 'Update' : 'Simpan')),
          ]),
        ])),
      ),

      Expanded(child: doctorsAsync.when(
        loading: () => const LoadingWidget(message: 'Memuat data dokter...'),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (doctors) {
          if (doctors.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.medical_services_outlined, size: 64, color: AppColors.grey300),
            const SizedBox(height: 16),
            Text('Belum ada data dokter', style: GoogleFonts.plusJakartaSans(fontSize: 16, color: AppColors.grey500)),
          ]));
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.6),
            itemCount: doctors.length,
            itemBuilder: (_, i) {
              final d = doctors[i];
              final isActive = d.status == AppConstants.doctorActive;
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isActive ? AppColors.grey200 : AppColors.grey300)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    CircleAvatar(radius: 24, backgroundColor: isActive ? AppColors.primary : AppColors.grey400,
                      child: Text(d.name.split(' ').last[0], style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600))),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(d.name, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                      Text(d.specialization, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.grey500)),
                    ])),
                    PopupMenuButton<String>(icon: const Icon(Icons.more_vert, size: 18), itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'toggle', child: Text(isActive ? 'Nonaktifkan' : 'Aktifkan')),
                      const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: AppColors.error))),
                    ], onSelected: (v) async {
                      if (v == 'edit') _edit(d);
                      if (v == 'toggle') await FirebaseFirestore.instance.collection(AppConstants.colDoctors).doc(d.id).update({'status': isActive ? AppConstants.doctorAbsent : AppConstants.doctorActive});
                      if (v == 'delete') await FirebaseFirestore.instance.collection(AppConstants.colDoctors).doc(d.id).delete();
                    }),
                  ]),
                  const Spacer(),
                  Row(children: [
                    Icon(Icons.badge_outlined, size: 14, color: AppColors.grey500),
                    const SizedBox(width: 6),
                    Text('SIP: ${d.sipNumber.isEmpty ? "-" : d.sipNumber}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.grey500)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: isActive ? AppColors.successLight : AppColors.grey200, borderRadius: BorderRadius.circular(12)),
                      child: Text(isActive ? 'Aktif' : 'Tidak Aktif', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? AppColors.success : AppColors.grey500)),
                    ),
                  ]),
                ]),
              );
            },
          );
        },
      )),
    ]));
  }
}
