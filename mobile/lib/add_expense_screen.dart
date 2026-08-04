// lib/screens/expense/add_expense_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'app_colors.dart';
import 'common_widgets.dart';
import 'api_servic.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});
  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _amountController = TextEditingController();
  final _noteController   = TextEditingController();
  int      _selectedCategory = 0;
  DateTime _selectedDate     = DateTime.now();
  bool     _isLoading        = false;
  int?     _userId;

  final List<_Category> _categories = const [
    _Category(icon: Iconsax.cake,        label: 'Food',          color: Color(0xFFFF6B6B), iconName: 'cake',        colorHex: '#FF6B6B'),
    _Category(icon: Iconsax.bag_2,       label: 'Shopping',      color: Color(0xFF4ECDC4), iconName: 'bag_2',       colorHex: '#4ECDC4'),
    _Category(icon: Iconsax.car,         label: 'Transport',     color: Color(0xFFFFBE0B), iconName: 'car',         colorHex: '#FFBE0B'),
    _Category(icon: Iconsax.hospital,    label: 'Health',        color: Color(0xFF06D6A0), iconName: 'hospital',    colorHex: '#06D6A0'),
    _Category(icon: Iconsax.game,        label: 'Entertainment', color: Color(0xFFB5179E), iconName: 'game',        colorHex: '#B5179E'),
    _Category(icon: Iconsax.electricity, label: 'Bills',         color: Color(0xFF4361EE), iconName: 'electricity', colorHex: '#4361EE'),
    _Category(icon: Iconsax.book,        label: 'Education',     color: Color(0xFFFF9F1C), iconName: 'book',        colorHex: '#FF9F1C'),
    _Category(icon: Iconsax.home_2,      label: 'Housing',       color: Color(0xFF2EC4B6), iconName: 'home_2',      colorHex: '#2EC4B6'),
    _Category(icon: Iconsax.more_circle, label: 'Others',        color: Color(0xFF8338EC), iconName: 'more_circle', colorHex: '#8338EC'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    final res = await ApiService.getCurrentUser();
    if (mounted && res.success) {
      setState(() => _userId = res.data['id'] as int);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
              primary: AppColors.primary, surface: AppColors.bgCard),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _save() async {
    final amountStr = _amountController.text.trim();
    if (amountStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter an amount',
            style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: AppColors.accentRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    if (_userId == null) return;

    final cat     = _categories[_selectedCategory];
    final type    = _tabController.index == 0 ? 'expense' : 'income';
    final txnDate =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    setState(() => _isLoading = true);

    final result = await ApiService.addTransaction(
      userId:   _userId!,
      type:     type,
      amount:   double.parse(amountStr),
      category: cat.label,
      note:     _noteController.text.trim(),
      icon:     cat.iconName,
      color:    cat.colorHex,
      txnDate:  txnDate,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Transaction saved!',
            style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.error ?? 'Failed to save',
            style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: AppColors.accentRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('Add Transaction',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
      ),
      body: Column(
        children: [
          // ── Tab bar ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border)),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10)),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textMuted,
                dividerColor: Colors.transparent,
                labelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
                tabs: const [
                  Tab(text: '  Expense  '),
                  Tab(text: '  Income  '),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Amount input ───────────────────────────────────────────
                  GlassCard(
                    child: Column(children: [
                      Row(children: [
                        // ✅ no 'const' — Iconsax values are not compile-time constants
                        Icon(Iconsax.money_2,
                            color: AppColors.primary, size: 22),
                        const SizedBox(width: 6),
                        Text('Amount',
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.textSecondary)),
                      ]),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.poppins(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          hintStyle: GoogleFonts.poppins(
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMuted),
                          prefixText: '₹ ',
                          prefixStyle: GoogleFonts.poppins(
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // ── Category ───────────────────────────────────────────────
                  Text('Category',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 14),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.05,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final c = _categories[index];
                      final isSelected = _selectedCategory == index;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? c.color.withOpacity(0.18)
                                : AppColors.bgCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? c.color : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(c.icon, color: c.color, size: 26),
                              const SizedBox(height: 6),
                              Text(c.label,
                                  style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? c.color
                                          : AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Note ───────────────────────────────────────────────────
                  TextFormField(
                    controller: _noteController,
                    style: GoogleFonts.poppins(
                        color: AppColors.textPrimary, fontSize: 14),
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Note (optional)',
                      hintText: 'What was this for?',
                      // ✅ no 'const' here either
                      prefixIcon: Icon(Iconsax.note_text,
                          color: AppColors.textMuted, size: 20),
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 14, color: AppColors.textMuted),
                      labelStyle: GoogleFonts.poppins(
                          fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Date picker ────────────────────────────────────────────
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border)),
                      child: Row(children: [
                        // ✅ no 'const'
                        Icon(Iconsax.calendar_1,
                            color: AppColors.primary, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${_selectedDate.day} / ${_selectedDate.month} / ${_selectedDate.year}',
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        // ✅ no 'const'
                        Icon(Iconsax.arrow_right_3,
                            color: AppColors.textMuted, size: 18),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 32),

                  GradientButton(
                    text: 'Save Transaction',
                    onPressed: _save,
                    isLoading: _isLoading,
                    icon: Iconsax.tick_circle,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Category {
  final IconData icon;
  final String label, iconName, colorHex;
  final Color color;
  const _Category({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconName,
    required this.colorHex,
  });
}