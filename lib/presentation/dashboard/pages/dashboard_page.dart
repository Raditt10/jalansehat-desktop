import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../data/models/models.dart';
import '../../providers/auth_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(ref.watch(authProvider).user),
          const SizedBox(height: 28),
          _buildStatCards(),
          const SizedBox(height: 28),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildWeeklyChart()),
              const SizedBox(width: 20),
              Expanded(flex: 2, child: _buildRecentActivity()),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildActiveQueue()),
              const SizedBox(width: 20),
              Expanded(child: _buildDoctorSchedule()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(UserModel? user) {
    final hour = DateTime.now().hour;
    final greeting = hour < 11 ? 'Selamat Pagi' : hour < 15 ? 'Selamat Siang' : hour < 18 ? 'Selamat Sore' : 'Selamat Malam';
    
    String displayName = '';
    if (user != null) {
      displayName = user.name.isNotEmpty ? user.name : user.email.split('@').first;
    }
    final greetingText = displayName.isNotEmpty ? '$greeting, $displayName' : greeting;
    final now = DateTime.now();
    final days = ['Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'];
    final months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    final dateStr = '${days[now.weekday-1]}, ${now.day} ${months[now.month-1]} ${now.year}';

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard', style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.black)),
            const SizedBox(height: 4),
            Text(greetingText, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.grey500)),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.grey200)),
          child: Row(children: [
            const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(dateStr, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.grey700)),
          ]),
        ),
      ],
    );
  }

  Widget _buildStatCards() {
    return Row(children: [
      Expanded(child: StatCard(title: 'Pasien Hari Ini', value: '24', subtitle: '+12%', icon: Icons.people_rounded, color: AppColors.primary)),
      const SizedBox(width: 16),
      Expanded(child: StatCard(title: 'Antrian Aktif', value: '8', subtitle: '3 menunggu', icon: Icons.format_list_numbered_rounded, color: AppColors.teal)),
      const SizedBox(width: 16),
      Expanded(child: StatCard(title: 'Dokter Aktif', value: '5', subtitle: '2 sesi', icon: Icons.medical_services_rounded, color: AppColors.warning)),
      const SizedBox(width: 16),
      Expanded(child: StatCard(title: 'Pendapatan', value: 'Rp 3.2 Jt', subtitle: '+8%', icon: Icons.account_balance_wallet_rounded, color: AppColors.success)),
    ]);
  }

  Widget _buildWeeklyChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.grey200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Kunjungan Mingguan', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
            child: Text('Minggu Ini', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary)),
          ),
        ]),
        const SizedBox(height: 24),
        SizedBox(
          height: 220,
          child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround, maxY: 40,
            barTouchData: BarTouchData(enabled: true, touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.primaryDark,
              getTooltipItem: (group, gi, rod, ri) {
                final d = ['Sen','Sel','Rab','Kam','Jum','Sab','Min'];
                return BarTooltipItem('${d[group.x]}\n${rod.toY.toInt()} pasien', GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12));
              },
            )),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
                final d = ['Sen','Sel','Rab','Kam','Jum','Sab','Min'];
                return Padding(padding: const EdgeInsets.only(top: 8), child: Text(d[v.toInt()], style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.grey500)));
              })),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.grey400)))),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 10, getDrawingHorizontalLine: (v) => FlLine(color: AppColors.grey200, strokeWidth: 1, dashArray: [5,5])),
            borderData: FlBorderData(show: false),
            barGroups: [for (final e in [22,28,18,32,26,15,10].asMap().entries) BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.toDouble(), width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)), gradient: const LinearGradient(colors: [AppColors.accent, AppColors.primary], begin: Alignment.bottomCenter, end: Alignment.topCenter))])],
          )),
        ),
      ]),
    );
  }

  Widget _buildRecentActivity() {
    final List<(String, String, IconData, Color, String)> items = [];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.grey200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Aktivitas Terbaru', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 20),
        ...items.map((a) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: a.$4.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(a.$3, color: a.$4, size: 18)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.$1, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.black)),
              const SizedBox(height: 2),
              Text(a.$2, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.grey500)),
            ])),
            Text(a.$5, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.grey400)),
          ]),
        )),
      ]),
    );
  }

  Widget _buildActiveQueue() {
    final List<(String, String, String, String, Color)> q = [];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.grey200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Text('Antrian Aktif', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600)), const Spacer(), TextButton.icon(onPressed: () {}, icon: const Icon(Icons.arrow_forward_rounded, size: 16), label: Text('Lihat Semua', style: GoogleFonts.plusJakartaSans(fontSize: 12)))]),
        const SizedBox(height: 16),
        ...q.map((e) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)), alignment: Alignment.center, child: Text(e.$1, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e.$2, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)), Text(e.$3, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.grey500))])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: e.$5.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)), child: Text(e.$4, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: e.$5))),
        ]))),
      ]),
    );
  }

  Widget _buildDoctorSchedule() {
    final List<(String, String, String, bool)> docs = [];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.grey200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Jadwal Dokter Hari Ini', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        ...docs.map((d) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
          CircleAvatar(radius: 20, backgroundColor: d.$4 ? AppColors.primary : AppColors.grey300, child: Text(d.$1.split(' ').last[0], style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(d.$1, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)), Text('${d.$2} • ${d.$3}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.grey500))])),
          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: d.$4 ? AppColors.success : AppColors.grey400)),
        ]))),
      ]),
    );
  }
}
