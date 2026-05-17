import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/models.dart';

class PharmacyPage extends ConsumerStatefulWidget {
  const PharmacyPage({super.key});
  @override
  ConsumerState<PharmacyPage> createState() => _PharmacyPageState();
}

class _PharmacyPageState extends ConsumerState<PharmacyPage> {
  bool _showForm = false;
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _genericC = TextEditingController();
  final _unitC = TextEditingController(text: 'Tablet');
  final _stockC = TextEditingController();
  final _minStockC = TextEditingController(text: '10');
  final _buyC = TextEditingController();
  final _sellC = TextEditingController();
  DateTime _expDate = DateTime.now().add(const Duration(days: 365));
  String? _editId;

  @override
  void dispose() { for (final c in [_nameC,_genericC,_unitC,_stockC,_minStockC,_buyC,_sellC]) c.dispose(); super.dispose(); }

  void _reset() { for (final c in [_nameC,_genericC,_stockC,_buyC,_sellC]) c.clear(); _unitC.text='Tablet'; _minStockC.text='10'; _expDate=DateTime.now().add(const Duration(days:365)); _editId=null; }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final data = MedicineModel(id:'', name:_nameC.text.trim(), genericName:_genericC.text.trim(), unit:_unitC.text.trim(),
      stock:int.tryParse(_stockC.text)??0, minStock:int.tryParse(_minStockC.text)??10,
      priceBuy:double.tryParse(_buyC.text)??0, priceSell:double.tryParse(_sellC.text)??0,
      expiredDate:_expDate, createdAt:DateTime.now()).toFirestore();
    if (_editId!=null) { data.remove('createdAt'); await FirebaseFirestore.instance.collection(AppConstants.colMedicines).doc(_editId).update(data); }
    else { await FirebaseFirestore.instance.collection(AppConstants.colMedicines).add(data); }
    if (mounted) setState(() { _showForm=false; _reset(); });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Manajemen Apotek', style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Kelola stok obat dan farmasi', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.grey500)),
        ]),
        const Spacer(),
        ElevatedButton.icon(onPressed: () => setState(() { _reset(); _showForm=!_showForm; }),
          icon: Icon(_showForm ? Icons.close : Icons.add_rounded, size: 18), label: Text(_showForm ? 'Tutup' : 'Tambah Obat'),
          style: ElevatedButton.styleFrom(backgroundColor: _showForm ? AppColors.grey600 : AppColors.primary)),
      ]),
      const SizedBox(height: 20),

      if (_showForm) Container(
        margin: const EdgeInsets.only(bottom: 20), padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primaryLight)),
        child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tambah Obat', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: TextFormField(controller: _nameC, decoration: const InputDecoration(labelText: 'Nama Obat', filled: true), validator: (v)=>v!.isEmpty?'Wajib':null)),
            const SizedBox(width: 16),
            Expanded(child: TextFormField(controller: _genericC, decoration: const InputDecoration(labelText: 'Nama Generik', filled: true))),
            const SizedBox(width: 16),
            SizedBox(width: 120, child: TextFormField(controller: _unitC, decoration: const InputDecoration(labelText: 'Satuan', filled: true))),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: TextFormField(controller: _stockC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stok', filled: true), validator: (v)=>v!.isEmpty?'Wajib':null)),
            const SizedBox(width: 16),
            Expanded(child: TextFormField(controller: _minStockC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stok Minimum', filled: true))),
            const SizedBox(width: 16),
            Expanded(child: TextFormField(controller: _buyC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga Beli', prefixText: 'Rp ', filled: true))),
            const SizedBox(width: 16),
            Expanded(child: TextFormField(controller: _sellC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga Jual', prefixText: 'Rp ', filled: true))),
          ]),
          const SizedBox(height: 16),
          InkWell(onTap: () async {
            final d = await showDatePicker(context: context, initialDate: _expDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 3650)));
            if (d != null) setState(() => _expDate = d);
          }, child: Container(width: 240, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.grey300)),
            child: Row(children: [Text('Exp: ${DateFormat('dd/MM/yyyy').format(_expDate)}'), const Spacer(), const Icon(Icons.calendar_today, size: 16)]))),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            OutlinedButton(onPressed: () => setState(() { _showForm=false; _reset(); }), child: const Text('Batal')),
            const SizedBox(width: 12),
            ElevatedButton.icon(onPressed: _save, icon: const Icon(Icons.save_rounded, size: 18), label: const Text('Simpan')),
          ]),
        ])),
      ),

      Expanded(child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(AppConstants.colMedicines).orderBy('name').snapshots(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final meds = snap.data?.docs.map((d) => MedicineModel.fromFirestore(d)).toList() ?? [];
          if (meds.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.local_pharmacy_outlined, size: 64, color: AppColors.grey300), const SizedBox(height: 16),
            Text('Belum ada data obat', style: GoogleFonts.plusJakartaSans(fontSize: 16, color: AppColors.grey500)),
          ]));
          return Container(
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.grey200)),
            child: ClipRRect(borderRadius: BorderRadius.circular(16), child: SingleChildScrollView(child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.grey50), columnSpacing: 20,
              columns: const [DataColumn(label: Text('Nama Obat')), DataColumn(label: Text('Generik')), DataColumn(label: Text('Satuan')), DataColumn(label: Text('Stok')), DataColumn(label: Text('Harga Jual')), DataColumn(label: Text('Kadaluarsa')), DataColumn(label: Text('Aksi'))],
              rows: meds.map((m) {
                final isLowStock = m.stock <= m.minStock;
                final isExpiring = m.expiredDate.difference(DateTime.now()).inDays < 90;
                return DataRow(cells: [
                  DataCell(Text(m.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600))),
                  DataCell(Text(m.genericName.isEmpty ? '-' : m.genericName)),
                  DataCell(Text(m.unit)),
                  DataCell(Row(children: [
                    Text(m.stock.toString(), style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: isLowStock ? AppColors.error : AppColors.black)),
                    if (isLowStock) ...[const SizedBox(width: 4), const Icon(Icons.warning_rounded, size: 14, color: AppColors.error)],
                  ])),
                  DataCell(Text('Rp ${NumberFormat('#,###').format(m.priceSell)}')),
                  DataCell(Text(DateFormat('dd/MM/yyyy').format(m.expiredDate), style: TextStyle(color: isExpiring ? AppColors.error : null))),
                  DataCell(IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                    onPressed: () => FirebaseFirestore.instance.collection(AppConstants.colMedicines).doc(m.id).delete())),
                ]);
              }).toList(),
            ))),
          );
        },
      )),
    ]));
  }
}
