// lib/screens/budget/budget_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'app_colors.dart';
import 'common_widgets.dart';
import 'api_servic.dart';

class BudgetScreen extends StatefulWidget {
  final bool isTab;
  const BudgetScreen({super.key, this.isTab = false});
  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _budgets = [];
  int? _userId;

  final _categoryCtrl = TextEditingController();
  final _amountCtrl   = TextEditingController();
  final _editCtrl     = TextEditingController();

  @override
  void initState() { super.initState(); _init(); }

  @override
  void dispose() {
    _categoryCtrl.dispose();
    _amountCtrl.dispose();
    _editCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final userRes = await ApiService.getCurrentUser();
    if (!mounted) return;
    if (userRes.success) {
      _userId = userRes.data['id'] as int;
      await _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await ApiService.getBudgets(_userId!);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.success) _budgets = List<Map<String, dynamic>>.from(res.data);
    });
  }

  Color _c(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.primary;
    try { return Color(int.parse(hex.replaceFirst('#', '0xFF'))); }
    catch (_) { return AppColors.primary; }
  }

  // ── Add budget ─────────────────────────────────────────────────────────────
  void _showAddSheet() {
    _categoryCtrl.clear();
    _amountCtrl.clear();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SingleChildScrollView(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24, right: 24, top: 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _sheetHandle(),
          const SizedBox(height: 20),
          Row(children: [
            Icon(Iconsax.wallet_add, color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Text('Add Budget Category',
                style: GoogleFonts.poppins(
                    fontSize: 17, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 20),
          TextField(
            controller: _categoryCtrl,
            style: GoogleFonts.poppins(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Category Name',
              hintText: 'e.g. Food, Transport',
              prefixIcon: Icon(Iconsax.category,
                  color: AppColors.textMuted, size: 20),
              labelStyle:
              GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Budget Limit (₹)',
              hintText: 'e.g. 5000',
              prefixIcon: Icon(Iconsax.money_2,
                  color: AppColors.textMuted, size: 20),
              labelStyle:
              GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
          GradientButton(
            text: 'Add Budget',
            onPressed: () async {
              if (_categoryCtrl.text.isEmpty || _amountCtrl.text.isEmpty) return;
              Navigator.pop(context);
              await ApiService.addBudget(
                userId:   _userId!,
                category: _categoryCtrl.text.trim(),
                amount:   double.parse(_amountCtrl.text),
              );
              _load();
            },
            icon: Iconsax.add_circle,
          ),
        ]),
      ),
    );
  }

  // ── Edit limit ─────────────────────────────────────────────────────────────
  void _showEditSheet(Map<String, dynamic> b) {
    _editCtrl.text = (b['limit'] as num).toStringAsFixed(0);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SingleChildScrollView(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24, right: 24, top: 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _sheetHandle(),
          const SizedBox(height: 20),
          Row(children: [
            Icon(Iconsax.edit_2, color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Edit: ${b['category']}',
                  style: GoogleFonts.poppins(
                      fontSize: 17, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ),
          ]),
          const SizedBox(height: 8),
          // current spent info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppColors.bgElevated,
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statPill('Spent',
                    '₹${(b['spent'] as num).toStringAsFixed(0)}',
                    AppColors.accentRed),
                _statPill('Current Limit',
                    '₹${(b['limit'] as num).toStringAsFixed(0)}',
                    AppColors.textMuted),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _editCtrl,
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(
                color: AppColors.textPrimary, fontSize: 18,
                fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              labelText: 'New Budget Limit (₹)',
              prefixIcon: Icon(Iconsax.money_2,
                  color: AppColors.textMuted, size: 20),
              labelStyle:
              GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
          GradientButton(
            text: 'Update Limit',
            onPressed: () async {
              if (_editCtrl.text.isEmpty) return;
              Navigator.pop(context);
              await ApiService.updateBudget(
                  b['id'] as int, double.parse(_editCtrl.text));
              _load();
            },
            icon: Iconsax.tick_circle,
          ),
        ]),
      ),
    );
  }

  // ── Delete budget ──────────────────────────────────────────────────────────
  Future<void> _deleteBudget(Map<String, dynamic> b) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Budget',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        content: Text(
            'Remove "${b['category']}" budget? This won\'t delete your transactions.',
            style: GoogleFonts.poppins(
                color: AppColors.textSecondary, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete',
                style: GoogleFonts.poppins(
                    color: AppColors.accentRed, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ApiService.deleteBudget(b['id'] as int);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalLimit = _budgets.fold(0.0, (s, b) => s + (b['limit'] as num));
    final totalSpent = _budgets.fold(0.0, (s, b) => s + (b['spent'] as num));
    final overCount  = _budgets
        .where((b) => (b['spent'] as num) > (b['limit'] as num))
        .length;

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
            child: const Icon(Iconsax.arrow_left_2,
                color: AppColors.textPrimary, size: 18),
          ),
        ),
        title: Text('Monthly Budget',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
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
          ? const Center(
          child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            // ── Summary card ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF1A1F35), Color(0xFF0F1628)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Budget',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textMuted)),
                          Text('₹${totalLimit.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary)),
                        ]),
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color:
                              AppColors.primary.withOpacity(0.3))),
                      child: const Icon(Iconsax.wallet_3,
                          color: AppColors.primary, size: 26),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(children: [
                  _chip(Iconsax.arrow_up_1,
                      '₹${totalSpent.toStringAsFixed(0)}',
                      'Spent', AppColors.accentRed),
                  const SizedBox(width: 12),
                  _chip(Iconsax.arrow_down_1,
                      '₹${(totalLimit - totalSpent).toStringAsFixed(0)}',
                      'Remaining', AppColors.primary),
                ]),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: totalLimit > 0
                        ? (totalSpent / totalLimit).clamp(0.0, 1.0)
                        : 0,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        totalSpent > totalLimit * 0.8
                            ? AppColors.accentRed
                            : AppColors.primary),
                    minHeight: 8,
                  ),
                ),
              ]),
            ),

            // ── Over-budget warning ──────────────────────────────────
            if (overCount > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppColors.accentRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.accentRed.withOpacity(0.3))),
                child: Row(children: [
                  const Icon(Iconsax.warning_2,
                      color: AppColors.accentRed, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$overCount ${overCount == 1 ? 'category has' : 'categories have'} exceeded budget!',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentRed),
                    ),
                  ),
                ]),
              ),
            ],

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionHeader(title: 'Categories'),
                // hint label
                Text('Tap to edit • Swipe to delete',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: 16),

            if (_budgets.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Column(children: [
                  const Icon(Iconsax.wallet_3,
                      color: AppColors.textMuted, size: 48),
                  const SizedBox(height: 12),
                  Text('No budgets yet. Tap + to add one.',
                      style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: 13)),
                ]),
              )
            else
              ..._budgets.map((b) => _buildCard(b)),
          ]),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color)),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 10, color: AppColors.textMuted)),
          ]),
        ]),
      ),
    );
  }

  Widget _statPill(String label, String value, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.poppins(
              fontSize: 11, color: AppColors.textMuted)),
      Text(value,
          style: GoogleFonts.poppins(
              fontSize: 15, fontWeight: FontWeight.w700, color: color)),
    ]);
  }

  Widget _buildCard(Map<String, dynamic> b) {
    final limit   = (b['limit'] as num).toDouble();
    final spent   = (b['spent'] as num).toDouble();
    final percent = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final isOver  = spent > limit;
    final isNear  = !isOver && percent > 0.75;
    final color   = _c(b['color'] as String?);

    return Dismissible(
      key: Key('budget_${b['id']}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
            color: AppColors.accentRed,
            borderRadius: BorderRadius.circular(18)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Iconsax.trash, color: Colors.white, size: 22),
      ),
      confirmDismiss: (_) async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.bgCard,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Text('Delete Budget',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            content: Text(
                'Remove "${b['category']}" budget?',
                style: GoogleFonts.poppins(
                    color: AppColors.textSecondary, fontSize: 13)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel',
                    style:
                    GoogleFonts.poppins(color: AppColors.textMuted)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete',
                    style: GoogleFonts.poppins(
                        color: AppColors.accentRed,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
        return confirm ?? false;
      },
      onDismissed: (_) async {
        await ApiService.deleteBudget(b['id'] as int);
        _load();
      },
      child: GestureDetector(
        onTap: () => _showEditSheet(b),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isOver
                  ? AppColors.accentRed.withOpacity(0.5)
                  : isNear
                  ? AppColors.accentGold.withOpacity(0.5)
                  : AppColors.border,
            ),
          ),
          child: Column(children: [
            Row(children: [
              CategoryIcon(icon: Iconsax.wallet_2, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b['category'] as String,
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      Text(
                          '₹${spent.toStringAsFixed(0)} of ₹${limit.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                    ]),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(
                    text: isOver
                        ? 'Over Limit'
                        : isNear
                        ? 'Near Limit'
                        : 'On Track',
                    color: isOver
                        ? AppColors.accentRed
                        : isNear
                        ? AppColors.accentGold
                        : AppColors.primary,
                  ),
                  const SizedBox(height: 6),
                  // Edit hint
                  Row(children: [
                    Icon(Iconsax.edit_2,
                        color: AppColors.textMuted, size: 12),
                    const SizedBox(width: 3),
                    Text('Edit limit',
                        style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.textMuted)),
                  ]),
                ],
              ),
            ]),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(isOver
                    ? AppColors.accentRed
                    : isNear
                    ? AppColors.accentGold
                    : color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(percent * 100).toStringAsFixed(0)}% used',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.textMuted)),
                Text(
                  isOver
                      ? '₹${(spent - limit).toStringAsFixed(0)} over!'
                      : '₹${(limit - spent).toStringAsFixed(0)} left',
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isOver
                          ? AppColors.accentRed
                          : AppColors.primary),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  Widget _sheetHandle() => Center(
    child: Container(
      width: 40, height: 4,
      decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(2)),
    ),
  );
}