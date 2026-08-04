// lib/screens/emi/emi_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'app_colors.dart';
import 'common_widgets.dart';
import 'api_servic.dart';

class EmiScreen extends StatefulWidget {
  const EmiScreen({super.key});
  @override
  State<EmiScreen> createState() => _EmiScreenState();
}

class _EmiScreenState extends State<EmiScreen> {
  bool  _loading = true;
  int?  _userId;
  List<Map<String, dynamic>> _emis = [];

  final _labelCtrl  = TextEditingController();
  final _bankCtrl   = TextEditingController();
  final _amtCtrl    = TextEditingController();
  final _monthsCtrl = TextEditingController();
  final _dayCtrl    = TextEditingController();

  @override
  void initState() { super.initState(); _init(); }

  @override
  void dispose() {
    _labelCtrl.dispose(); _bankCtrl.dispose();
    _amtCtrl.dispose(); _monthsCtrl.dispose(); _dayCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final res = await ApiService.getCurrentUser();
    if (!mounted) return;
    if (res.success) { _userId = res.data['id'] as int; await _load(); }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await ApiService.getEmis(_userId!);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.success) _emis = List<Map<String, dynamic>>.from(res.data);
    });
  }

  Color _c(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.accentBlue;
    try { return Color(int.parse(hex.replaceFirst('#', '0xFF'))); }
    catch (_) { return AppColors.accentBlue; }
  }

  void _showAddSheet() {
    for (final c in [_labelCtrl,_bankCtrl,_amtCtrl,_monthsCtrl,_dayCtrl]) c.clear();
    showModalBottomSheet(
      context: context, backgroundColor: AppColors.bgCard,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SingleChildScrollView(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24, right: 24, top: 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Row(children: [
            Icon(Iconsax.bank, color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Text('Add Loan / EMI', style: GoogleFonts.poppins(
                fontSize: 17, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 16),
          _field(_labelCtrl,  'Loan Name',       Iconsax.document_text),
          const SizedBox(height: 12),
          _field(_bankCtrl,   'Bank / Lender',    Iconsax.bank),
          const SizedBox(height: 12),
          _field(_amtCtrl,    'Monthly EMI (₹)',  Iconsax.money_2, isNum: true),
          const SizedBox(height: 12),
          _field(_monthsCtrl, 'Total Months',     Iconsax.calendar_2, isNum: true),
          const SizedBox(height: 12),
          _field(_dayCtrl,    'Due Day (1–31)',   Iconsax.calendar_1, isNum: true),
          const SizedBox(height: 24),
          GradientButton(
            text: 'Add EMI',
            onPressed: () async {
              if (_labelCtrl.text.isEmpty || _amtCtrl.text.isEmpty ||
                  _monthsCtrl.text.isEmpty || _dayCtrl.text.isEmpty) return;
              Navigator.pop(context);
              await ApiService.addEmi(
                userId:      _userId!,
                label:       _labelCtrl.text.trim(),
                bank:        _bankCtrl.text.trim(),
                emiAmount:   double.parse(_amtCtrl.text),
                totalMonths: int.parse(_monthsCtrl.text),
                dueDay:      int.parse(_dayCtrl.text),
              );
              _load();
            },
            icon: Iconsax.add_circle,
          ),
        ]),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {bool isNum = false}) {
    return TextField(
      controller: c,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.poppins(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
        labelStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalEmi = _emis.fold(0.0, (s, e) => s + (e['emi_amount'] as num));
    final upcoming = _emis.where((e) {
      final d = e['days_left'] as int;
      return d >= 0 && d <= 7;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        leading: GestureDetector(
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
        title: Text('EMI Tracker', style: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary)),
        actions: [
          GestureDetector(
            onTap: _showAddSheet,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(Iconsax.add, color: Colors.white, size: 20),
            ),
          ),
        ],
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
            // Monthly outflow card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF1A1F35), Color(0xFF0F1628)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(children: [
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Monthly EMI Outflow', style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  Text('₹${totalEmi.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary, letterSpacing: -1)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Iconsax.document_text,
                        color: AppColors.textMuted, size: 14),
                    const SizedBox(width: 6),
                    Text('${_emis.length} active loans',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ]),
                ])),
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                      color: AppColors.accentBlue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.accentBlue.withOpacity(0.3))),
                  child: Icon(Iconsax.bank,
                      color: AppColors.accentBlue, size: 30),
                ),
              ]),
            ),
            if (upcoming.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppColors.accentGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.accentGold.withOpacity(0.3))),
                child: Row(children: [
                  Icon(Iconsax.alarm,
                      color: AppColors.accentGold, size: 22),
                  const SizedBox(width: 10),
                  Expanded(child: Text(
                    '${upcoming.length} EMI due in next 7 days — ₹${upcoming.fold(0.0, (s, e) => s + (e['emi_amount'] as num)).toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentGold),
                  )),
                ]),
              ),
            ],
            const SizedBox(height: 24),
            const SectionHeader(title: 'Active Loans'),
            const SizedBox(height: 16),
            if (_emis.isEmpty)
              Center(child: Column(children: [
                Icon(Iconsax.bank, color: AppColors.textMuted, size: 48),
                const SizedBox(height: 12),
                Text('No EMIs added yet.',
                    style: GoogleFonts.poppins(
                        color: AppColors.textSecondary, fontSize: 13)),
              ]))
            else
              ..._emis.map((e) => _buildCard(e)),
          ]),
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> e) {
    final paid    = e['paid_months']  as int;
    final total   = e['total_months'] as int;
    final percent = total > 0 ? (paid / total).clamp(0.0, 1.0) : 0.0;
    final daysLeft = e['days_left'] as int;
    final isUrgent = daysLeft >= 0 && daysLeft <= 5;
    final color    = _c(e['color'] as String?);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isUrgent
                  ? AppColors.accentGold.withOpacity(0.5)
                  : AppColors.border)),
      child: Column(children: [
        Row(children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.25))),
            child: Icon(Iconsax.bank, color: AppColors.accentBlue, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e['label'] as String,
                style: GoogleFonts.poppins(fontSize: 14,
                    fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            Text(e['bank'] as String? ?? '',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.textSecondary)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('₹${(e['emi_amount'] as num).toStringAsFixed(0)}/mo',
                style: GoogleFonts.poppins(fontSize: 15,
                    fontWeight: FontWeight.w800, color: color)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: isUrgent
                      ? AppColors.accentGold.withOpacity(0.15)
                      : AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(8)),
              child: Text(
                daysLeft == 0 ? 'Due Today!' : 'Due in $daysLeft d',
                style: GoogleFonts.poppins(fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isUrgent
                        ? AppColors.accentGold
                        : AppColors.textMuted),
              ),
            ),
          ]),
        ]),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('$paid/$total months paid',
              style: GoogleFonts.poppins(
                  fontSize: 11, color: AppColors.textMuted)),
          Text('Outstanding: ₹${(e['outstanding'] as num).toStringAsFixed(0)}',
              style: GoogleFonts.poppins(fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
              value: percent,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8),
        ),
        const SizedBox(height: 10),
        // Mark paid button
        GestureDetector(
          onTap: () async {
            await ApiService.markEmiPaid(e['id'] as int);
            _load();
          },
          child: Container(
            height: 38,
            decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Iconsax.tick_circle,
                    color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text('Mark This Month Paid',
                    style: GoogleFonts.poppins(fontSize: 12,
                        fontWeight: FontWeight.w700, color: Colors.white)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}