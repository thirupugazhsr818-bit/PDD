// lib/screens/transactions/transactions_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'app_colors.dart';
import 'common_widgets.dart';
import 'api_servic.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});
  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  bool   _loading = true;
  int?   _userId;
  String _filter  = 'All';  // All | expense | income
  List<Map<String, dynamic>> _txns = [];

  @override
  void initState() { super.initState(); _init(); }

  Future<void> _init() async {
    final res = await ApiService.getCurrentUser();
    if (!mounted) return;
    if (res.success) { _userId = res.data['id'] as int; await _load(); }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await ApiService.getTransactions(
      _userId!,
      type: _filter == 'All' ? null : _filter.toLowerCase(),
      limit: 100,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.success) _txns = List<Map<String, dynamic>>.from(res.data);
    });
  }

  Color _hexColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.primary;
    try { return Color(int.parse(hex.replaceFirst('#', '0xFF'))); }
    catch (_) { return AppColors.primary; }
  }

  @override
  Widget build(BuildContext context) {
    final totalIncome  = _txns
        .where((t) => t['type'] == 'income')
        .fold(0.0, (s, t) => s + (t['amount'] as num));
    final totalExpense = _txns
        .where((t) => t['type'] == 'expense')
        .fold(0.0, (s, t) => s + (t['amount'] as num));

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
        title: Text('All Transactions',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/add-expense')
                .then((_) => _load()),
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
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Summary row ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(children: [
                  _summaryChip(Iconsax.arrow_down_1,
                      '₹${totalIncome.toStringAsFixed(0)}',
                      'Income', AppColors.primary),
                  const SizedBox(width: 12),
                  _summaryChip(Iconsax.arrow_up_1,
                      '₹${totalExpense.toStringAsFixed(0)}',
                      'Expense', AppColors.accentRed),
                ]),
              ),
            ),

            // ── Filter chips ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(children: [
                  _filterChip('All'),
                  const SizedBox(width: 10),
                  _filterChip('Expense'),
                  const SizedBox(width: 10),
                  _filterChip('Income'),
                ]),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── List ──────────────────────────────────────────────────
            if (_txns.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Column(children: [
                      Icon(Iconsax.receipt_item,
                          color: AppColors.textMuted, size: 56),
                      const SizedBox(height: 14),
                      Text('No transactions yet',
                          style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                              fontSize: 14)),
                    ]),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (_, i) => _buildTile(_txns[i]),
                    childCount: _txns.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _summaryChip(
      IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.25))),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color)),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textMuted)),
          ]),
        ]),
      ),
    );
  }

  Widget _filterChip(String label) {
    final isActive = _filter == label;
    return GestureDetector(
      onTap: () {
        if (_filter != label) {
          setState(() => _filter = label);
          _load();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive ? AppColors.primaryGradient : null,
          color: isActive ? null : AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color:
              isActive ? AppColors.primary : AppColors.border),
        ),
        child: Text(label,
            style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? Colors.white
                    : AppColors.textSecondary)),
      ),
    );
  }

  Widget _buildTile(Map<String, dynamic> t) {
    final isExpense = t['type'] == 'expense';
    final color     = _hexColor(t['color'] as String?);
    return Dismissible(
      key: Key('txn_${t['id']}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
            color: AppColors.accentRed,
            borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Iconsax.trash, color: Colors.white, size: 22),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.bgCard,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Text('Delete Transaction',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            content: Text('Are you sure you want to delete this?',
                style: GoogleFonts.poppins(
                    color: AppColors.textSecondary, fontSize: 13)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel',
                    style: GoogleFonts.poppins(
                        color: AppColors.textMuted)),
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
      },
      onDismissed: (_) async {
        await ApiService.deleteTransaction(t['id'] as int);
        setState(() => _txns.remove(t));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          CategoryIcon(icon: Iconsax.wallet_2, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t['category'] as String,
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  if ((t['note'] as String? ?? '').isNotEmpty)
                    Text(t['note'] as String,
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary)),
                ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              '${isExpense ? '−' : '+'} ₹${(t['amount'] as num).toStringAsFixed(0)}',
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isExpense
                      ? AppColors.accentRed
                      : AppColors.primary),
            ),
            Text(t['txn_date'] as String,
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textMuted)),
          ]),
        ]),
      ),
    );
  }
}