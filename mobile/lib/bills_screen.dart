// lib/screens/bills/bills_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'app_colors.dart';
import 'common_widgets.dart';
import 'api_servic.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});
  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  int    _tabIndex = 0;
  bool   _loading  = true;
  int?   _userId;
  List<Map<String, dynamic>> _bills = [];

  final _labelCtrl  = TextEditingController();
  final _amtCtrl    = TextEditingController();
  final _dayCtrl    = TextEditingController();

  @override
  void initState() { super.initState(); _init(); }

  @override
  void dispose() {
    _labelCtrl.dispose(); _amtCtrl.dispose(); _dayCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final res = await ApiService.getCurrentUser();
    if (!mounted) return;
    if (res.success) { _userId = res.data['id'] as int; await _load(); }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await ApiService.getBills(_userId!);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.success) _bills = List<Map<String, dynamic>>.from(res.data);
    });
  }

  Color _c(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.primary;
    try { return Color(int.parse(hex.replaceFirst('#', '0xFF'))); }
    catch (_) { return AppColors.primary; }
  }

  void _showAddSheet() {
    for (final c in [_labelCtrl, _amtCtrl, _dayCtrl]) c.clear();
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
            const Icon(Iconsax.receipt_item,
                color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Text('Add Bill', style: GoogleFonts.poppins(
                fontSize: 17, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 16),
          TextField(
            controller: _labelCtrl,
            style: GoogleFonts.poppins(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Bill Name',
              prefixIcon: const Icon(Iconsax.document_text,
                  color: AppColors.textMuted, size: 20),
              labelStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amtCtrl,
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Amount (₹)',
              prefixIcon: const Icon(Iconsax.money_2,
                  color: AppColors.textMuted, size: 20),
              labelStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dayCtrl,
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Due Day of Month (1–31)',
              prefixIcon: const Icon(Iconsax.calendar_1,
                  color: AppColors.textMuted, size: 20),
              labelStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
          GradientButton(
            text: 'Add Bill',
            onPressed: () async {
              if (_labelCtrl.text.isEmpty || _amtCtrl.text.isEmpty ||
                  _dayCtrl.text.isEmpty) return;
              Navigator.pop(context);
              await ApiService.addBill(
                userId: _userId!,
                label:  _labelCtrl.text.trim(),
                amount: double.parse(_amtCtrl.text),
                dueDay: int.parse(_dayCtrl.text),
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
    final pending = _bills.where((b) => !(b['is_paid'] as bool)).toList();
    final paid    = _bills.where((b) =>  (b['is_paid'] as bool)).toList();
    final pendingTotal =
    pending.fold(0.0, (s, b) => s + (b['amount'] as num));

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
        title: Text('Bill Reminders', style: GoogleFonts.poppins(
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
          : Column(children: [
        // Summary chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(children: [
            _chip(Iconsax.clock, '${pending.length} Pending',
                '₹${pendingTotal.toStringAsFixed(0)}', AppColors.accentRed),
            const SizedBox(width: 12),
            _chip(Iconsax.tick_circle, '${paid.length} Paid',
                'This month', AppColors.primary),
          ]),
        ),
        // Tab bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border)),
            child: Row(children: [
              _tabBtn(0, 'Pending', Iconsax.clock),
              _tabBtn(1, 'Paid',    Iconsax.tick_circle),
            ]),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _load,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _tabIndex == 0 ? pending.length : paid.length,
              itemBuilder: (_, i) {
                final b = _tabIndex == 0 ? pending[i] : paid[i];
                return _buildCard(b);
              },
            ),
          ),
        ),
      ]),
    );
  }

  Widget _chip(IconData icon, String title, String sub, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2))),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.poppins(
                fontSize: 12, fontWeight: FontWeight.w700, color: color)),
            Text(sub, style: GoogleFonts.poppins(
                fontSize: 11, color: AppColors.textMuted)),
          ]),
        ]),
      ),
    );
  }

  Widget _tabBtn(int index, String label, IconData icon) {
    final isActive = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              gradient: isActive ? AppColors.primaryGradient : null,
              borderRadius: BorderRadius.circular(10)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon,
                color: isActive ? Colors.white : AppColors.textMuted,
                size: 16),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textMuted)),
          ]),
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> b) {
    final daysLeft = b['days_left'] as int;
    final isPaid   = b['is_paid']   as bool;
    Color urgencyColor = AppColors.primary;
    String urgencyText = 'Due in $daysLeft days';
    if (!isPaid) {
      if (daysLeft < 0)        { urgencyColor = AppColors.accentRed;  urgencyText = '${daysLeft.abs()} days overdue!'; }
      else if (daysLeft <= 3)  { urgencyColor = AppColors.accentRed;  urgencyText = 'Due in $daysLeft days!'; }
      else if (daysLeft <= 7)  { urgencyColor = AppColors.accentGold; urgencyText = 'Due in $daysLeft days'; }
    }
    final color = _c(b['color'] as String?);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: !isPaid && daysLeft <= 3
                  ? urgencyColor.withOpacity(0.4)
                  : AppColors.border)),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.25))),
          child: const Icon(Iconsax.receipt_item, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(b['label'] as String,
              style: GoogleFonts.poppins(fontSize: 14,
                  fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text(isPaid ? 'Paid' : urgencyText,
              style: GoogleFonts.poppins(fontSize: 12,
                  color: isPaid ? AppColors.primary : urgencyColor,
                  fontWeight: FontWeight.w500)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('₹${(b['amount'] as num).toStringAsFixed(0)}',
              style: GoogleFonts.poppins(fontSize: 15,
                  fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          if (!isPaid)
            GestureDetector(
              onTap: () async {
                await ApiService.markBillPaid(b['id'] as int);
                _load();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10)),
                child: Text('Pay Now', style: GoogleFonts.poppins(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: Colors.white)),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Icon(Iconsax.tick_circle,
                    color: AppColors.primary, size: 12),
                const SizedBox(width: 4),
                Text('Paid', style: GoogleFonts.poppins(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
              ]),
            ),
        ]),
      ]),
    );
  }
}