// lib/screens/savings/savings_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'app_colors.dart';
import 'common_widgets.dart';
import 'api_servic.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});
  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  bool   _loading = true;
  int?   _userId;
  List<Map<String, dynamic>> _goals = [];

  final _labelCtrl  = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _addCtrl    = TextEditingController();

  @override
  void initState() { super.initState(); _init(); }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _targetCtrl.dispose();
    _addCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final res = await ApiService.getCurrentUser();
    if (!mounted) return;
    if (res.success) { _userId = res.data['id'] as int; await _load(); }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await ApiService.getSavingsGoals(_userId!);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.success) _goals = List<Map<String, dynamic>>.from(res.data);
    });
  }

  Color _c(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.primary;
    try { return Color(int.parse(hex.replaceFirst('#', '0xFF'))); }
    catch (_) { return AppColors.primary; }
  }

  void _showAddMoneySheet(Map<String, dynamic> g) {
    _addCtrl.clear();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24, right: 24, top: 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Row(children: [
            Icon(Iconsax.safe_home, color: _c(g['color'] as String?), size: 22),
            const SizedBox(width: 10),
            Text('Add to ${g['label']}',
                style: GoogleFonts.poppins(fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 20),
          TextField(
            controller: _addCtrl,
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Amount (₹)',
              prefixIcon: const Icon(Iconsax.money_2,
                  color: AppColors.textMuted, size: 20),
              labelStyle: GoogleFonts.poppins(
                  color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
          GradientButton(
            text: 'Add to Savings',
            onPressed: () async {
              if (_addCtrl.text.isEmpty) return;
              Navigator.pop(context);
              await ApiService.addMoneyToGoal(g['id'] as int,
                  amount: double.parse(_addCtrl.text));
              _load();
            },
            icon: Iconsax.tick_circle,
          ),
        ]),
      ),
    );
  }

  void _showAddGoalSheet() {
    _labelCtrl.clear();
    _targetCtrl.clear();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24, right: 24, top: 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Row(children: [
            const Icon(Iconsax.flag, color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Text('New Savings Goal',
                style: GoogleFonts.poppins(fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 20),
          TextField(
            controller: _labelCtrl,
            style: GoogleFonts.poppins(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Goal Name',
              prefixIcon: const Icon(Iconsax.flag,
                  color: AppColors.textMuted, size: 20),
              labelStyle: GoogleFonts.poppins(
                  color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _targetCtrl,
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Target Amount (₹)',
              prefixIcon: const Icon(Iconsax.money_2,
                  color: AppColors.textMuted, size: 20),
              labelStyle: GoogleFonts.poppins(
                  color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
          GradientButton(
            text: 'Create Goal',
            onPressed: () async {
              if (_labelCtrl.text.isEmpty || _targetCtrl.text.isEmpty) return;
              Navigator.pop(context);
              await ApiService.addSavingsGoal(
                userId: _userId!,
                label:  _labelCtrl.text.trim(),
                target: double.parse(_targetCtrl.text),
              );
              _load();
            },
            icon: Iconsax.add_circle,
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSaved =
    _goals.fold(0.0, (s, g) => s + (g['saved'] as num));
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
            child: const Icon(Iconsax.arrow_left_2,
                color: AppColors.textPrimary, size: 18),
          ),
        ),
        title: Text('Savings Goals',
            style: GoogleFonts.poppins(fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        actions: [
          GestureDetector(
            onTap: _showAddGoalSheet,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Iconsax.add,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
          child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total savings banner
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF00D4AA), Color(0xFF0094FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 24, offset: const Offset(0, 8))],
                ),
                child: Row(children: [
                  Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Savings',
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.white70)),
                        Text('₹${totalSaved.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                                fontSize: 32, fontWeight: FontWeight.w800,
                                color: Colors.white, letterSpacing: -1)),
                        const SizedBox(height: 8),
                        Text('${_goals.length} active goals',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.white70)),
                      ])),
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Iconsax.safe_home,
                        color: Colors.white, size: 32),
                  ),
                ]),
              ),
              const SizedBox(height: 28),
              const SectionHeader(title: 'Your Goals'),
              const SizedBox(height: 16),
              if (_goals.isEmpty)
                Center(child: Column(children: [
                  const Icon(Iconsax.safe_home,
                      color: AppColors.textMuted, size: 48),
                  const SizedBox(height: 12),
                  Text('No goals yet. Tap + to create one.',
                      style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: 13)),
                ]))
              else
                ..._goals.map((g) => _buildCard(g)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> g) {
    final saved   = (g['saved']   as num).toDouble();
    final target  = (g['target']  as num).toDouble();
    final percent = target > 0 ? (saved / target).clamp(0.0, 1.0) : 0.0;
    final color   = _c(g['color'] as String?);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Row(children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.25))),
            child: Icon(Iconsax.safe_home, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(g['label'] as String,
                    style: GoogleFonts.poppins(fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                Text('Target: ₹${target.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(fontSize: 12,
                        color: AppColors.textSecondary)),
              ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${(percent * 100).toStringAsFixed(0)}%',
                style: GoogleFonts.poppins(fontSize: 18,
                    fontWeight: FontWeight.w800, color: color)),
            Text('saved',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textMuted)),
          ]),
        ]),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
              value: percent,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8),
        ),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('₹${saved.toStringAsFixed(0)} saved',
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          GestureDetector(
            onTap: () => _showAddMoneySheet(g),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                const Icon(Iconsax.add_circle,
                    color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text('Add Money',
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ]),
            ),
          ),
        ]),
      ]),
    );
  }
}