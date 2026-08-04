// lib/screens/goals/goal_tracker_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'app_colors.dart';
import 'common_widgets.dart';
import 'api_servic.dart';

class GoalTrackerScreen extends StatefulWidget {
  const GoalTrackerScreen({super.key});
  @override
  State<GoalTrackerScreen> createState() => _GoalTrackerScreenState();
}

class _GoalTrackerScreenState extends State<GoalTrackerScreen> {
  bool  _loading = true;
  int?  _userId;
  List<Map<String, dynamic>> _goals = [];

  final _labelCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _init(); }

  @override
  void dispose() { _labelCtrl.dispose(); super.dispose(); }

  Future<void> _init() async {
    final res = await ApiService.getCurrentUser();
    if (!mounted) return;
    if (res.success) { _userId = res.data['id'] as int; await _load(); }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await ApiService.getGoals(_userId!);
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

  void _showAddSheet() {
    _labelCtrl.clear();
    showModalBottomSheet(
      context: context, backgroundColor: AppColors.bgCard,
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
            Text('Add Financial Goal', style: GoogleFonts.poppins(
                fontSize: 17, fontWeight: FontWeight.w700,
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
          const SizedBox(height: 24),
          GradientButton(
            text: 'Create Goal',
            onPressed: () async {
              if (_labelCtrl.text.isEmpty) return;
              Navigator.pop(context);
              await ApiService.addGoal(
                  userId: _userId!, label: _labelCtrl.text.trim());
              _load();
            },
            icon: Iconsax.add_circle,
          ),
        ]),
      ),
    );
  }

  void _showDetailSheet(Map<String, dynamic> g) {
    final milestones = List<String>.from(g['milestones'] ?? []);
    showModalBottomSheet(
      context: context, backgroundColor: AppColors.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        double sliderVal = (g['progress'] as num).toDouble();
        return StatefulBuilder(builder: (ctx, setS) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Row(children: [
              const Icon(Iconsax.flag, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(child: Text(g['label'] as String,
                  style: GoogleFonts.poppins(fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary))),
              Text('${sliderVal.toStringAsFixed(0)}%',
                  style: GoogleFonts.poppins(fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _c(g['color'] as String?))),
            ]),
            const SizedBox(height: 16),
            Slider(
              value: sliderVal,
              min: 0, max: 100,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.border,
              onChanged: (v) => setS(() => sliderVal = v),
            ),
            const SizedBox(height: 20),
            GradientButton(
              text: 'Update Progress',
              onPressed: () async {
                Navigator.pop(context);
                await ApiService.updateGoal(g['id'] as int,
                    progress: sliderVal);
                _load();
              },
              icon: Iconsax.edit_2,
            ),
          ]),
        ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final avgProgress = _goals.isEmpty
        ? 0.0
        : _goals.fold(0.0, (s, g) => s + (g['progress'] as num)) /
        _goals.length;

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
        title: Text('Goal Tracker', style: GoogleFonts.poppins(
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
              child: const Icon(Iconsax.add, color: Colors.white, size: 20),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Motivation banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF00D4AA), Color(0xFF0094FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Row(children: [
                  Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Overall Progress', style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.white70)),
                        Text('${avgProgress.toStringAsFixed(0)}% Complete 🎯',
                            style: GoogleFonts.poppins(fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(height: 8),
                        Text("Keep going! You're doing great.",
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.white70)),
                      ])),
                  const Icon(Iconsax.cup,
                      color: Colors.white, size: 48),
                ]),
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Financial Goals'),
              const SizedBox(height: 16),
              if (_goals.isEmpty)
                Center(child: Column(children: [
                  const Icon(Iconsax.flag,
                      color: AppColors.textMuted, size: 48),
                  const SizedBox(height: 12),
                  Text('No goals yet. Tap + to add one.',
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
    final progress    = (g['progress'] as num).toDouble();
    final milestones  = List<String>.from(g['milestones'] ?? []);
    final completed   = (progress / 100 * milestones.length).floor();
    final color       = _c(g['color'] as String?);

    return GestureDetector(
      onTap: () => _showDetailSheet(g),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withOpacity(0.25))),
              child: Icon(Iconsax.flag, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(g['label'] as String,
                  style: GoogleFonts.poppins(fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              Text('$completed/${milestones.length} milestones',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.textSecondary)),
            ])),
            Text('${progress.toStringAsFixed(0)}%',
                style: GoogleFonts.poppins(fontSize: 20,
                    fontWeight: FontWeight.w800, color: color)),
          ]),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
                value: (progress / 100).clamp(0.0, 1.0),
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8),
          ),
          if (milestones.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...milestones.asMap().entries.map((e) {
              final isDone = e.key < completed;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Container(
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                        color: isDone ? color : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: isDone ? color : AppColors.border,
                            width: 2)),
                    child: isDone
                        ? const Icon(Iconsax.tick_square,
                        color: Colors.white, size: 12)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(e.value, style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDone
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      decoration: isDone
                          ? TextDecoration.lineThrough
                          : null)),
                ]),
              );
            }),
          ],
        ]),
      ),
    );
  }
}