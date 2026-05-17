import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(padding: const EdgeInsets.all(28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Laporan & Statistik', style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Analisis data klinik', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.grey500)),
        ]),
        const Spacer(),
        OutlinedButton.icon(icon: const Icon(Icons.picture_as_pdf_rounded, size: 18), label: const Text('Export PDF'), onPressed: () {}),
        const SizedBox(width: 12),
        OutlinedButton.icon(icon: const Icon(Icons.table_chart_rounded, size: 18), label: const Text('Export Excel'), onPressed: () {}),
      ]),
      const SizedBox(height: 24),

      // Kunjungan bulanan chart
      Container(padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.grey200)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Kunjungan Bulanan 2026', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          SizedBox(height: 250, child: LineChart(LineChartData(
            gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: AppColors.grey200, strokeWidth: 1, dashArray: [5,5])),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                final m = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
                return v.toInt() < m.length ? Padding(padding: const EdgeInsets.only(top: 8), child: Text(m[v.toInt()], style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.grey400))) : const SizedBox();
              })),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v,_) => Text(v.toInt().toString(), style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.grey400)))),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(spots: [for (final e in [320,280,350,310,380,420,0,0,0,0,0,0].asMap().entries) FlSpot(e.key.toDouble(), e.value.toDouble())].where((s)=>s.y>0).toList(),
                isCurved: true, color: AppColors.primary, barWidth: 3, dotData: FlDotData(show: true),
                belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.08))),
            ],
          ))),
        ]),
      ),
      const SizedBox(height: 20),

      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Top diagnoses
        Expanded(child: Container(padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.grey200)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Diagnosis Terbanyak', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ...[('ISPA (J06.9)', 85, AppColors.primary), ('Hipertensi (I10)', 62, AppColors.teal), ('Diabetes Mellitus (E11)', 45, AppColors.warning),
              ('Gastritis (K29.7)', 38, AppColors.success), ('Demam (R50.9)', 32, AppColors.accent)].map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Text(d.$1, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500)), const Spacer(), Text('${d.$2} kasus', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.grey500))]),
                const SizedBox(height: 6),
                ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: d.$2 / 100, minHeight: 6, backgroundColor: AppColors.grey200, valueColor: AlwaysStoppedAnimation(d.$3 as Color))),
              ]),
            )),
          ]),
        )),
        const SizedBox(width: 20),
        // Revenue pie chart
        Expanded(child: Container(padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.grey200)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Pendapatan per Layanan', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: PieChart(PieChartData(
              sectionsSpace: 2, centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(value: 45, title: '45%', color: AppColors.primary, radius: 60, titleStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                PieChartSectionData(value: 25, title: '25%', color: AppColors.teal, radius: 60, titleStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                PieChartSectionData(value: 20, title: '20%', color: AppColors.warning, radius: 60, titleStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                PieChartSectionData(value: 10, title: '10%', color: AppColors.accent, radius: 60, titleStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ))),
            const SizedBox(height: 16),
            Wrap(spacing: 16, runSpacing: 8, children: [
              _legend('Konsultasi', AppColors.primary), _legend('Tindakan', AppColors.teal),
              _legend('Obat', AppColors.warning), _legend('Lainnya', AppColors.accent),
            ]),
          ]),
        )),
      ]),
    ]));
  }

  Widget _legend(String label, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 6),
      Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.grey600)),
    ]);
  }
}
