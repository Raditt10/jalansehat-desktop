import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(padding: const EdgeInsets.all(28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Pengaturan', style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Text('Konfigurasi sistem dan preferensi', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.grey500)),
      const SizedBox(height: 28),

      // Profil Klinik
      _section('Profil Klinik', Icons.local_hospital_rounded, [
        _infoRow('Nama Klinik', AppConstants.clinicName),
        _infoRow('Alamat', AppConstants.clinicAddress),
        _infoRow('Telepon', AppConstants.clinicPhone),
        _infoRow('Jam Operasional', AppConstants.clinicHours),
      ]),
      const SizedBox(height: 20),

      // Manajemen User
      _section('Manajemen Pengguna', Icons.people_rounded, [
        _actionRow('Tambah Admin Baru', 'Buat akun administrator', Icons.person_add_rounded, () {
          _showRegisterDialog(context, ref);
        }),
        _actionRow('Tambah Akun Dokter', 'Buat akun login dokter', Icons.medical_services_rounded, () {
          _showRegisterDialog(context, ref, role: AppConstants.roleDoctor);
        }),
      ]),
      const SizedBox(height: 20),

      // Tampilan
      _section('Tampilan', Icons.palette_rounded, [
        _toggleRow('Mode Gelap', 'Aktifkan tampilan gelap', false, (_) {}),
      ]),
      const SizedBox(height: 20),

      // Database
      _section('Database & Backup', Icons.storage_rounded, [
        _actionRow('Backup Database', 'Export data ke file backup', Icons.backup_rounded, () {}),
        _actionRow('Restore Database', 'Import dari file backup', Icons.restore_rounded, () {}),
      ]),
      const SizedBox(height: 20),

      // Info Aplikasi
      _section('Tentang Aplikasi', Icons.info_rounded, [
        _infoRow('Nama Aplikasi', AppConstants.appName),
        _infoRow('Versi', AppConstants.appVersion),
        _infoRow('Deskripsi', AppConstants.appDescription),
      ]),
    ]));
  }

  Widget _section(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.grey200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600)),
        ]),
        const Divider(height: 32),
        ...children,
      ]),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 160, child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.grey500))),
      Expanded(child: Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500))),
    ]));
  }

  Widget _actionRow(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppColors.primary, size: 20)),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600)),
        Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.grey500)),
      ])),
      const Icon(Icons.chevron_right_rounded, color: AppColors.grey400),
    ])));
  }

  Widget _toggleRow(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600)),
        Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.grey500)),
      ])),
      Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
    ]));
  }

  void _showRegisterDialog(BuildContext context, WidgetRef ref, {String role = AppConstants.roleAdmin}) {
    final nameC = TextEditingController();
    final emailC = TextEditingController();
    final passC = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text('Tambah ${role == AppConstants.roleAdmin ? "Admin" : "Dokter"}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
      content: SizedBox(width: 400, child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Nama', filled: true)),
        const SizedBox(height: 12),
        TextField(controller: emailC, decoration: const InputDecoration(labelText: 'Email', filled: true)),
        const SizedBox(height: 12),
        TextField(controller: passC, obscureText: true, decoration: const InputDecoration(labelText: 'Password', filled: true)),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
        ElevatedButton(onPressed: () async {
          await ref.read(authProvider.notifier).registerUser(name: nameC.text, email: emailC.text, password: passC.text, role: role);
          if (ctx.mounted) Navigator.pop(ctx);
        }, child: const Text('Daftar')),
      ],
    ));
  }
}
