import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/models.dart';

class FinancePage extends ConsumerStatefulWidget {
  const FinancePage({super.key});
  @override
  ConsumerState<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends ConsumerState<FinancePage> {
  bool _showForm = false;
  final _formKey = GlobalKey<FormState>();
  String? _selectedPatientId, _selectedPatientName;
  String _paymentMethod = AppConstants.paymentCash;
  final _totalC = TextEditingController();
  final _descC = TextEditingController();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedPatientId == null) return;
    final now = DateTime.now();
    await FirebaseFirestore.instance.collection(AppConstants.colTransactions).add(TransactionModel(
      id: '', patientId: _selectedPatientId!, patientName: _selectedPatientName ?? '',
      date: now, items: [{'description': _descC.text.trim(), 'amount': double.tryParse(_totalC.text) ?? 0}],
      total: double.tryParse(_totalC.text) ?? 0, paymentMethod: _paymentMethod, createdAt: now,
    ).toFirestore());
    if (mounted) setState(() { _showForm = false; _totalC.clear(); _descC.clear(); });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Keuangan & Kasir', style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Kelola pembayaran dan laporan keuangan', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.grey500)),
        ]),
        const Spacer(),
        ElevatedButton.icon(onPressed: () => setState(() => _showForm = !_showForm),
          icon: Icon(_showForm ? Icons.close : Icons.add_rounded, size: 18), label: Text(_showForm ? 'Tutup' : 'Transaksi Baru'),
          style: ElevatedButton.styleFrom(backgroundColor: _showForm ? AppColors.grey600 : AppColors.primary)),
      ]),
      const SizedBox(height: 20),

      // Summary cards
      Row(children: [
        _summaryCard('Hari Ini', 'Rp 3.250.000', Icons.today_rounded, AppColors.primary),
        const SizedBox(width: 16),
        _summaryCard('Minggu Ini', 'Rp 18.500.000', Icons.date_range_rounded, AppColors.teal),
        const SizedBox(width: 16),
        _summaryCard('Bulan Ini', 'Rp 72.300.000', Icons.calendar_month_rounded, AppColors.success),
        const SizedBox(width: 16),
        _summaryCard('Total Transaksi', '156', Icons.receipt_long_rounded, AppColors.warning),
      ]),
      const SizedBox(height: 20),

      if (_showForm) Container(
        margin: const EdgeInsets.only(bottom: 20), padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primaryLight)),
        child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Transaksi Baru', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection(AppConstants.colPatients).where('isActive', isEqualTo: true).get(),
              builder: (_, snap) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Pasien', filled: true),
                items: (snap.data?.docs ?? []).map((d) => DropdownMenuItem(value: d.id, child: Text(d['name'] ?? ''))).toList(),
                onChanged: (v) { _selectedPatientId = v; _selectedPatientName = snap.data!.docs.firstWhere((d) => d.id == v)['name']; },
              ),
            )),
            const SizedBox(width: 16),
            Expanded(child: TextFormField(controller: _descC, decoration: const InputDecoration(labelText: 'Keterangan', filled: true))),
            const SizedBox(width: 16),
            SizedBox(width: 200, child: TextFormField(controller: _totalC, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Total', prefixText: 'Rp ', filled: true), validator: (v) => v!.isEmpty ? 'Wajib' : null)),
            const SizedBox(width: 16),
            SizedBox(width: 160, child: DropdownButtonFormField<String>(
              value: _paymentMethod, decoration: const InputDecoration(labelText: 'Pembayaran', filled: true),
              items: const [DropdownMenuItem(value: 'cash', child: Text('Tunai')), DropdownMenuItem(value: 'transfer', child: Text('Transfer')), DropdownMenuItem(value: 'bpjs', child: Text('BPJS'))],
              onChanged: (v) => setState(() => _paymentMethod = v!),
            )),
          ]),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            OutlinedButton(onPressed: () => setState(() => _showForm = false), child: const Text('Batal')),
            const SizedBox(width: 12),
            ElevatedButton.icon(onPressed: _save, icon: const Icon(Icons.save_rounded, size: 18), label: const Text('Simpan')),
          ]),
        ])),
      ),

      Expanded(child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(AppConstants.colTransactions).orderBy('createdAt', descending: true).limit(50).snapshots(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final txns = snap.data?.docs.map((d) => TransactionModel.fromFirestore(d)).toList() ?? [];
          if (txns.isEmpty) return Center(child: Text('Belum ada transaksi', style: GoogleFonts.plusJakartaSans(color: AppColors.grey500)));
          return Container(
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.grey200)),
            child: ClipRRect(borderRadius: BorderRadius.circular(16), child: SingleChildScrollView(child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.grey50),
              columns: const [DataColumn(label: Text('Tanggal')), DataColumn(label: Text('Pasien')), DataColumn(label: Text('Total')), DataColumn(label: Text('Metode')), DataColumn(label: Text('Status'))],
              rows: txns.map((t) => DataRow(cells: [
                DataCell(Text(DateFormat('dd/MM/yyyy HH:mm').format(t.date))),
                DataCell(Text(t.patientName)),
                DataCell(Text('Rp ${NumberFormat('#,###').format(t.total)}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600))),
                DataCell(_paymentBadge(t.paymentMethod)),
                DataCell(Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(20)),
                  child: Text(t.status == 'paid' ? 'Lunas' : t.status, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success)))),
              ])).toList(),
            ))),
          );
        },
      )),
    ]));
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.grey200)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.grey500)),
        ]),
      ]),
    ));
  }

  Widget _paymentBadge(String method) {
    final label = method == 'cash' ? 'Tunai' : method == 'transfer' ? 'Transfer' : 'BPJS';
    final color = method == 'bpjs' ? AppColors.teal : method == 'transfer' ? AppColors.primary : AppColors.warning;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: color)));
  }
}
