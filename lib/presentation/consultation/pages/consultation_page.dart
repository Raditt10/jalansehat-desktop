import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class ConsultationPage extends ConsumerWidget {
  const ConsultationPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(padding: const EdgeInsets.all(28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Konsultasi', style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Text('Chat konsultasi pasien dengan dokter', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.grey500)),
      const SizedBox(height: 24),
      Expanded(child: Row(children: [
        // List sesi konsultasi
        SizedBox(width: 320, child: Container(
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.grey200)),
          child: Column(children: [
            Padding(padding: const EdgeInsets.all(16), child: TextField(decoration: InputDecoration(hintText: 'Cari konsultasi...', prefixIcon: const Icon(Icons.search, size: 18), filled: true, fillColor: AppColors.grey50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
            Expanded(child: ListView(children: [
            ])),
          ]),
        )),
        const SizedBox(width: 20),
        // Area chat
        Expanded(child: Container(
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.grey200)),
          child: Column(children: [
            // Header chat
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.grey200))),
              child: Row(children: [
                CircleAvatar(radius: 20, backgroundColor: AppColors.primary, child: Text('A', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600))),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Pilih Sesi Konsultasi', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600)),
                  Text('-', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.grey500)),
                ]),
                const Spacer(),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(12)),
                  child: Text('Aktif', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success))),
              ])),
            // Messages
            Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
            ])),
            // Input
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.grey200))),
              child: Row(children: [
                IconButton(icon: const Icon(Icons.attach_file_rounded), onPressed: () {}, color: AppColors.grey500),
                Expanded(child: TextField(decoration: InputDecoration(hintText: 'Ketik pesan...', filled: true, fillColor: AppColors.grey50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)))),
                const SizedBox(width: 8),
                Container(decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                  child: IconButton(icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20), onPressed: () {})),
              ])),
          ]),
        )),
      ])),
    ]));
  }

  Widget _chatTile(String patient, String doctor, String lastMsg, String time, bool selected, bool unread) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: selected ? AppColors.surface : null, border: Border(bottom: BorderSide(color: AppColors.grey200))),
      child: Row(children: [
        CircleAvatar(radius: 20, backgroundColor: AppColors.primary.withValues(alpha: 0.8), child: Text(patient[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(patient, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: unread ? FontWeight.w700 : FontWeight.w500))),
            Text(time, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.grey400)),
          ]),
          const SizedBox(height: 2),
          Text('$doctor', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.teal)),
          Text(lastMsg, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.grey500), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
      ]),
    );
  }

  Widget _msgBubble(String text, bool isDoctor, String time) {
    return Align(
      alignment: isDoctor ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: isDoctor ? AppColors.surface : AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isDoctor ? 4 : 16), bottomRight: Radius.circular(isDoctor ? 16 : 4),
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: isDoctor ? AppColors.black : Colors.white, height: 1.4)),
          const SizedBox(height: 4),
          Text(time, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: isDoctor ? AppColors.grey400 : Colors.white70)),
        ]),
      ),
    );
  }
}
