import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/models.dart';

final queueTodayProvider = StreamProvider<List<QueueModel>>((ref) {
  final today = DateTime.now();
  final start = DateTime(today.year, today.month, today.day);
  final end = start.add(const Duration(days: 1));
  return FirebaseFirestore.instance
      .collection(AppConstants.colQueues)
      .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
      .where('date', isLessThan: Timestamp.fromDate(end))
      .orderBy('date')
      .orderBy('queueNumber')
      .snapshots()
      .map((s) => s.docs.map((d) => QueueModel.fromFirestore(d)).toList());
});

class QueuePage extends ConsumerStatefulWidget {
  const QueuePage({super.key});
  @override
  ConsumerState<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends ConsumerState<QueuePage> {
  String _filterStatus = 'all';

  Color _statusColor(String status) {
    switch (status) {
      case AppConstants.queueCalled: return AppColors.queueCalled;
      case AppConstants.queueExamining: return AppColors.queueExamining;
      case AppConstants.queueDone: return AppColors.queueDone;
      case AppConstants.queueCancelled: return AppColors.queueCancelled;
      default: return AppColors.queueWaiting;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case AppConstants.queueCalled: return 'Dipanggil';
      case AppConstants.queueExamining: return 'Pemeriksaan';
      case AppConstants.queueDone: return 'Selesai';
      case AppConstants.queueCancelled: return 'Batal';
      default: return 'Menunggu';
    }
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    await FirebaseFirestore.instance.collection(AppConstants.colQueues).doc(id).update({'status': newStatus});
  }

  Future<void> _addToQueue() async {
    // Dialog tambah antrian
    final patients = await FirebaseFirestore.instance.collection(AppConstants.colPatients).where('isActive', isEqualTo: true).get();
    final doctors = await FirebaseFirestore.instance.collection(AppConstants.colDoctors).where('status', isEqualTo: 'active').get();
    if (!mounted) return;

    String? selectedPatientId, selectedPatientName, selectedDoctorId, selectedDoctorName;

    await showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
      title: Text('Tambah Antrian', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
      content: SizedBox(width: 400, child: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Pilih Pasien', filled: true),
          items: patients.docs.map((d) {
            final data = d.data();
            return DropdownMenuItem(value: d.id, child: Text('${data['name']} - ${data['medicalRecordNo']}'));
          }).toList(),
          onChanged: (v) { selectedPatientId = v; selectedPatientName = patients.docs.firstWhere((d) => d.id == v).data()['name']; },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Pilih Dokter', filled: true),
          items: doctors.docs.map((d) {
            final data = d.data();
            return DropdownMenuItem(value: d.id, child: Text('${data['name']} - ${data['specialization']}'));
          }).toList(),
          onChanged: (v) { selectedDoctorId = v; selectedDoctorName = doctors.docs.firstWhere((d) => d.id == v).data()['name']; },
        ),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
        ElevatedButton(onPressed: () async {
          if (selectedPatientId == null || selectedDoctorId == null) return;
          final now = DateTime.now();
          final todayStart = DateTime(now.year, now.month, now.day);
          final todayEnd = todayStart.add(const Duration(days: 1));
          final countSnap = await FirebaseFirestore.instance.collection(AppConstants.colQueues)
              .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
              .where('date', isLessThan: Timestamp.fromDate(todayEnd))
              .count().get();
          final nextNum = (countSnap.count ?? 0) + 1;
          await FirebaseFirestore.instance.collection(AppConstants.colQueues).add(QueueModel(
            id: '', patientId: selectedPatientId!, patientName: selectedPatientName ?? '',
            doctorId: selectedDoctorId!, doctorName: selectedDoctorName ?? '',
            date: now, queueNumber: nextNum, status: AppConstants.queueWaiting, createdAt: now,
          ).toFirestore());
          if (ctx.mounted) Navigator.pop(ctx);
        }, child: const Text('Tambah')),
      ],
    )));
  }

  @override
  Widget build(BuildContext context) {
    final queueAsync = ref.watch(queueTodayProvider);

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Sistem Antrian', style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Kelola antrian pasien hari ini', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.grey500)),
          ]),
          const Spacer(),
          // Filter chips
          ...[('all','Semua'), ('waiting','Menunggu'), ('called','Dipanggil'), ('examining','Periksa'), ('done','Selesai')].map((f) =>
            Padding(padding: const EdgeInsets.only(left: 8), child: FilterChip(
              label: Text(f.$2, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500)),
              selected: _filterStatus == f.$1,
              onSelected: (_) => setState(() => _filterStatus = f.$1),
              selectedColor: AppColors.surface,
              checkmarkColor: AppColors.primary,
            )),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(onPressed: _addToQueue, icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Tambah Antrian')),
        ]),
        const SizedBox(height: 24),

        // Display antrian besar (current)
        queueAsync.when(
          loading: () => const Expanded(child: LoadingWidget(message: 'Memuat antrian...')),
          error: (e, _) => Expanded(child: Center(child: Text('Error: $e'))),
          data: (queues) {
            final filtered = _filterStatus == 'all' ? queues : queues.where((q) => q.status == _filterStatus).toList();
            final current = queues.where((q) => q.status == AppConstants.queueCalled).toList();
            final waiting = queues.where((q) => q.status == AppConstants.queueWaiting).toList();

            return Expanded(child: Column(children: [
              // Current number display
              if (current.isNotEmpty)
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(32), margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryMedium]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('NOMOR ANTRIAN SAAT INI', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryLight, letterSpacing: 2)),
                      const SizedBox(height: 8),
                      Text(current.first.queueNumber.toString().padLeft(2, '0'), style: GoogleFonts.plusJakartaSans(fontSize: 72, fontWeight: FontWeight.w800, color: Colors.white)),
                    ]),
                    const SizedBox(width: 32),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(current.first.patientName, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('Dokter: ${current.first.doctorName}', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.primaryLight)),
                    ])),
                    const SizedBox(width: 16),
                    Column(children: [
                      ElevatedButton.icon(
                        onPressed: () => _updateStatus(current.first.id, AppConstants.queueExamining),
                        icon: const Icon(Icons.medical_services_rounded, size: 16),
                        label: const Text('Mulai Periksa'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      if (waiting.isNotEmpty)
                        OutlinedButton.icon(
                          onPressed: () async {
                            await _updateStatus(current.first.id, AppConstants.queueDone);
                            await _updateStatus(waiting.first.id, AppConstants.queueCalled);
                          },
                          icon: const Icon(Icons.skip_next_rounded, size: 16),
                          label: const Text('Panggil Berikutnya'),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54)),
                        ),
                    ]),
                  ]),
                ),

              if (current.isEmpty && waiting.isNotEmpty)
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(20), margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primaryLight)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('${waiting.length} pasien menunggu', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.primary)),
                    const SizedBox(width: 16),
                    ElevatedButton(onPressed: () => _updateStatus(waiting.first.id, AppConstants.queueCalled), child: const Text('Panggil Pertama')),
                  ]),
                ),

              // Table
              Expanded(
                child: Container(
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.grey200)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SingleChildScrollView(child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AppColors.grey50),
                      columns: const [DataColumn(label: Text('No')), DataColumn(label: Text('Pasien')), DataColumn(label: Text('Dokter')), DataColumn(label: Text('Waktu')), DataColumn(label: Text('Status')), DataColumn(label: Text('Aksi'))],
                      rows: filtered.map((q) => DataRow(cells: [
                        DataCell(Container(
                          width: 36, height: 36, alignment: Alignment.center,
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
                          child: Text(q.queueNumber.toString().padLeft(2, '0'), style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppColors.primary)),
                        )),
                        DataCell(Text(q.patientName)),
                        DataCell(Text(q.doctorName)),
                        DataCell(Text(DateFormat('HH:mm').format(q.createdAt))),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: _statusColor(q.status).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                          child: Text(_statusLabel(q.status), style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor(q.status))),
                        )),
                        DataCell(PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded, size: 18),
                          itemBuilder: (_) => [
                            if (q.status == AppConstants.queueWaiting) const PopupMenuItem(value: 'called', child: Text('Panggil')),
                            if (q.status == AppConstants.queueCalled) const PopupMenuItem(value: 'examining', child: Text('Mulai Periksa')),
                            if (q.status == AppConstants.queueExamining) const PopupMenuItem(value: 'done', child: Text('Selesai')),
                            if (q.status != AppConstants.queueDone && q.status != AppConstants.queueCancelled) const PopupMenuItem(value: 'cancelled', child: Text('Batalkan')),
                          ],
                          onSelected: (v) => _updateStatus(q.id, v),
                        )),
                      ])).toList(),
                    )),
                  ),
                ),
              ),
            ]));
          },
        ),
      ]),
    );
  }
}
