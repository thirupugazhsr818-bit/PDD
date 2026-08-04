// lib/screens/analytics/spending_chart_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'app_colors.dart';
import 'common_widgets.dart';
import 'api_servic.dart';

class SpendingChartScreen extends StatefulWidget {
  final bool isTab;
  const SpendingChartScreen({super.key, this.isTab = false});
  @override
  State<SpendingChartScreen> createState() => _SpendingChartScreenState();
}

class _SpendingChartScreenState extends State<SpendingChartScreen> {
  bool   _loading = true;
  int?   _userId;
  int    _selectedPeriod   = 1;
  int    _selectedBarIndex = -1;

  Map<String, dynamic> _summary = {};
  List<Map<String, dynamic>> _chartData    = [];
  List<Map<String, dynamic>> _categories   = [];

  @override
  void initState() { super.initState(); _init(); }

  Future<void> _init() async {
    final res = await ApiService.getCurrentUser();
    if (!mounted) return;
    if (res.success) {
      _userId = res.data['id'] as int;
      await _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      ApiService.getTransactionSummary(_userId!),
      ApiService.getMonthlyChart(_userId!),
    ]);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (results[0].success) {
        _summary    = Map<String, dynamic>.from(results[0].data);
        _categories = List<Map<String, dynamic>>.from(
            _summary['categories'] ?? []);
      }
      if (results[1].success) {
        _chartData = List<Map<String, dynamic>>.from(results[1].data);
      }
    });
  }

  Color _c(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.primary;
    try { return Color(int.parse(hex.replaceFirst('#', '0xFF'))); }
    catch (_) { return AppColors.primary; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        automaticallyImplyLeading: false,
        leading: widget.isTab ? null : GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border)),
            child: Icon(Iconsax.arrow_left_2,
                color: AppColors.textPrimary, size: 18),
          ),
        ),
        title: Text('Spending Analytics', style: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Period selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border)),
              child: Row(children: [
                _periodTab(0, 'Week'),
                _periodTab(1, 'Month'),
                _periodTab(2, 'Year'),
              ]),
            ),
            const SizedBox(height: 24),
            // Stat cards
            Row(children: [
              _statCard('Total Spent',
                  '₹${(_summary['total_expense'] ?? 0).toStringAsFixed(0)}',
                  Iconsax.arrow_up_1, AppColors.accentRed),
              const SizedBox(width: 12),
              _statCard('Income',
                  '₹${(_summary['total_income'] ?? 0).toStringAsFixed(0)}',
                  Iconsax.arrow_down_1, AppColors.primary),
              const SizedBox(width: 12),
              _statCard('Net',
                  '₹${(_summary['net_balance'] ?? 0).toStringAsFixed(0)}',
                  Iconsax.chart_2, AppColors.accentGold),
            ]),
            const SizedBox(height: 24),
            // Bar chart
            if (_chartData.isNotEmpty) ...[
              GlassCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Monthly Overview', style: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                            Icon(Iconsax.chart_2,
                                color: AppColors.primary, size: 18),
                          ]),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 160,
                        child: CustomPaint(
                          size: const Size(double.infinity, 160),
                          painter: _BarChartPainter(
                              data: _chartData,
                              selectedIndex: _selectedBarIndex),
                          child: GestureDetector(
                            onTapDown: (details) {
                              final bw = (MediaQuery.of(context).size.width - 96) /
                                  _chartData.length;
                              final idx =
                              (details.localPosition.dx / bw).floor();
                              setState(() => _selectedBarIndex =
                                  idx.clamp(0, _chartData.length - 1));
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: _chartData.asMap().entries.map((e) =>
                            Text(e.value['month'] as String,
                                style: GoogleFonts.poppins(fontSize: 11,
                                    fontWeight: e.key == _selectedBarIndex
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    color: e.key == _selectedBarIndex
                                        ? AppColors.primary
                                        : AppColors.textMuted)),
                        ).toList(),
                      ),
                      if (_selectedBarIndex >= 0 &&
                          _selectedBarIndex < _chartData.length) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              '${_chartData[_selectedBarIndex]['month']}: ₹${(_chartData[_selectedBarIndex]['total'] as num).toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ]),
              ),
              const SizedBox(height: 24),
            ],
            // Category breakdown
            const SectionHeader(title: 'Category Breakdown'),
            const SizedBox(height: 16),
            if (_categories.isEmpty)
              Center(child: Text('No expenses this month.',
                  style: GoogleFonts.poppins(
                      color: AppColors.textSecondary, fontSize: 13)))
            else
              ..._categories.map((c) => _buildCategoryRow(c)),
          ]),
        ),
      ),
    );
  }

  Widget _periodTab(int index, String label) {
    final isActive = _selectedPeriod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
              gradient: isActive ? AppColors.primaryGradient : null,
              borderRadius: BorderRadius.circular(8)),
          child: Center(
            child: Text(label, style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textMuted)),
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.poppins(
              fontSize: 13, fontWeight: FontWeight.w800,
              color: AppColors.textPrimary)),
          Text(label, style: GoogleFonts.poppins(
              fontSize: 10, color: AppColors.textMuted)),
        ]),
      ),
    );
  }

  Widget _buildCategoryRow(Map<String, dynamic> c) {
    final total    = (c['total']   as num).toDouble();
    final allTotal = (_summary['total_expense'] as num? ?? 1).toDouble();
    final percent  = allTotal > 0 ? total / allTotal : 0.0;
    final color    = _c(c['color'] as String?);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border)),
      child: Row(children: [
        CategoryIcon(icon: Iconsax.wallet_2, color: color, size: 42),
        const SizedBox(width: 12),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(c['category'] as String, style: GoogleFonts.poppins(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
                value: percent.clamp(0.0, 1.0),
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4),
          ),
        ])),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('₹${total.toStringAsFixed(0)}', style: GoogleFonts.poppins(
              fontSize: 13, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
          Text('${(percent * 100).toStringAsFixed(0)}%',
              style: GoogleFonts.poppins(fontSize: 11,
                  color: color, fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final int selectedIndex;
  const _BarChartPainter({required this.data, required this.selectedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxVal = data.map((d) => (d['total'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) return;
    final barWidth = size.width / data.length;
    final padding  = barWidth * 0.25;

    for (int i = 0; i < data.length; i++) {
      final barH = ((data[i]['total'] as num).toDouble() / maxVal) *
          (size.height - 16);
      final x = i * barWidth;
      final isSelected = i == selectedIndex;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x + padding, size.height - barH,
            barWidth - padding * 2, barH),
        const Radius.circular(8),
      );
      if (isSelected) {
        final gradient = const LinearGradient(
          colors: [AppColors.primary, AppColors.accentBlue],
          begin: Alignment.bottomCenter, end: Alignment.topCenter,
        );
        canvas.drawRRect(rect, Paint()
          ..shader = gradient.createShader(Rect.fromLTWH(
              x + padding, size.height - barH, barWidth - padding * 2, barH)));
      } else {
        canvas.drawRRect(rect,
            Paint()..color = AppColors.border.withOpacity(0.8));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) =>
      old.selectedIndex != selectedIndex || old.data != data;
}