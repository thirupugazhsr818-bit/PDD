// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'app_colors.dart';
import 'common_widgets.dart';
import 'api_servic.dart';
import 'spending_chart_screen.dart';
import 'budget_screen.dart';
import 'profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Iconsax.home_2,         activeIcon: Iconsax.home,            label: 'Home'),
    _NavItem(icon: Iconsax.chart_2,        activeIcon: Iconsax.chart_2,         label: 'Analytics'),
    _NavItem(icon: Iconsax.add_circle,     activeIcon: Iconsax.add_circle,      label: '', isCenter: true),
    _NavItem(icon: Iconsax.wallet,         activeIcon: Iconsax.wallet_1,        label: 'Budget'),
    _NavItem(icon: Iconsax.profile_circle, activeIcon: Iconsax.profile_circle,  label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _DashboardBody(),
          SpendingChartScreen(isTab: true),
          SizedBox.shrink(), // center FAB placeholder
          BudgetScreen(isTab: true),
          ProfileScreen(isTab: true),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildCenterFab(),
    );
  }

  Widget _buildCenterFab() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/add-expense'),
      child: Container(
        width: 60, height: 60,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.45),
              blurRadius: 20, offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(Iconsax.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0), _buildNavItem(1),
              const SizedBox(width: 64),
              _buildNavItem(3), _buildNavItem(4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? item.activeIcon : item.icon,
              color: isActive ? AppColors.primary : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(item.label,
                style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: isActive
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon, activeIcon;
  final String label;
  final bool isCenter;
  const _NavItem(
      {required this.icon,
        required this.activeIcon,
        required this.label,
        this.isCenter = false});
}

// ─── Dashboard Body ────────────────────────────────────────────────────────────
class _DashboardBody extends StatefulWidget {
  const _DashboardBody();
  @override
  State<_DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<_DashboardBody> {
  bool _loading   = true;
  String? _error;
  Map<String, dynamic> _dash = {};

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() { _loading = true; _error = null; });
    // Get current user first
    final userRes = await ApiService.getCurrentUser();
    if (!mounted) return;
    if (!userRes.success) {
      setState(() { _loading = false; _error = userRes.error; });
      return;
    }
    final userId = userRes.data['id'] as int;
    final dashRes = await ApiService.getDashboard(userId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (dashRes.success) {
        _dash = Map<String, dynamic>.from(dashRes.data);
      } else {
        _error = dashRes.error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error != null) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Iconsax.warning_2,
              color: AppColors.accentRed, size: 48),
          const SizedBox(height: 12),
          Text(_error!,
              style: GoogleFonts.poppins(
                  color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _loadDashboard,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12)),
              child: Text('Retry',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      );
    }

    final balance    = (_dash['balance']       ?? 0.0) as num;
    final income     = (_dash['month_income']  ?? 0.0) as num;
    final expense    = (_dash['month_expense'] ?? 0.0) as num;
    final saved      = (_dash['total_saved']   ?? 0.0) as num;
    final recent     = List<Map<String, dynamic>>.from(
        _dash['recent_transactions'] ?? []);
    final budgets    = List<Map<String, dynamic>>.from(
        _dash['budgets'] ?? []);
    final upcoming   = List<Map<String, dynamic>>.from(
        _dash['upcoming_bills'] ?? []);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadDashboard,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(
              child: _buildBalanceCard(balance, income, expense, saved)),
          if (upcoming.isNotEmpty)
            SliverToBoxAdapter(child: _buildBillsAlert(upcoming)),
          SliverToBoxAdapter(child: _buildQuickActions(context)),
          SliverToBoxAdapter(child: _buildBudgetOverview(budgets)),
          SliverToBoxAdapter(child: _buildRecentTransactions(recent)),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final name = (_dash['name'] as String?) ?? 'User';
    final initials = name.trim().split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .take(2)
        .join();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Good Morning 👋',
                style: GoogleFonts.poppins(
                    fontSize: 13, color: AppColors.textSecondary)),
            Text(name,
                style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5)),
          ]),
          Row(children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Text(initials,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(
      num balance, num income, num expense, num saved) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00D4AA), Color(0xFF0094FF)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 30,
                offset: const Offset(0, 12))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Balance',
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text('This Month',
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('₹ ${balance.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1)),
            const SizedBox(height: 20),
            Row(children: [
              _balanceStat(Iconsax.arrow_down_1,
                  '₹ ${income.toStringAsFixed(0)}', 'Income'),
              Container(
                  width: 1,
                  height: 36,
                  color: Colors.white.withOpacity(0.3)),
              _balanceStat(Iconsax.arrow_up_1,
                  '₹ ${expense.toStringAsFixed(0)}', 'Spent'),
              Container(
                  width: 1,
                  height: 36,
                  color: Colors.white.withOpacity(0.3)),
              _balanceStat(Iconsax.shield,
                  '₹ ${saved.toStringAsFixed(0)}', 'Saved'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _balanceStat(IconData icon, String amount, String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(children: [
          Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: Colors.white, size: 13),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(amount,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                Text(label,
                    style: GoogleFonts.poppins(
                        fontSize: 9, color: Colors.white60)),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildBillsAlert(List<Map<String, dynamic>> bills) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Container(
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
          Expanded(
            child: Text(
              '${bills.length} bill(s) due soon — '
                  '₹${bills.fold(0.0, (s, b) => s + (b['amount'] as num)).toStringAsFixed(0)}',
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentGold),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(icon: Iconsax.add_square,  label: 'Add\nExpense',     color: AppColors.primary,       route: '/add-expense'),
      _QuickAction(icon: Iconsax.chart_2,    label: 'Spending\nChart',  color: AppColors.accentBlue,    route: '/spending-chart'),
      _QuickAction(icon: Iconsax.save_2,     label: 'Savings\nGoals',   color: AppColors.accentGold,    route: '/savings'),
      _QuickAction(icon: Iconsax.bank,        label: 'EMI\nTracker',     color: AppColors.accentPurple,  route: '/emi'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader(title: 'Quick Actions'),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions
              .map((a) => GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, a.route)
                    .then((_) => _loadDashboard()),
            child: Column(children: [
              Container(
                width: 62, height: 62,
                decoration: BoxDecoration(
                  color: a.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: a.color.withOpacity(0.25)),
                ),
                child: Icon(a.icon, color: a.color, size: 26),
              ),
              const SizedBox(height: 8),
              Text(a.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      height: 1.3)),
            ]),
          ))
              .toList(),
        ),
      ]),
    );
  }

  Widget _buildBudgetOverview(List<Map<String, dynamic>> budgets) {
    if (budgets.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionHeader(
          title: 'Budget Overview',
          actionText: 'See All',
          onAction: () => Navigator.pushNamed(context, '/budget')
              .then((_) => _loadDashboard()),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            children: budgets.asMap().entries.map((e) {
              final b       = e.value;
              final limit   = (b['limit']  as num).toDouble();
              final spent   = (b['spent']  as num).toDouble();
              final percent = limit > 0
                  ? (spent / limit).clamp(0.0, 1.0)
                  : 0.0;
              final color   = _hexColor(b['color'] as String?);
              return Padding(
                padding: EdgeInsets.only(
                    bottom: e.key < budgets.length - 1 ? 16 : 0),
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(b['category'] as String,
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: '₹${spent.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: percent > 0.75
                                    ? AppColors.accentRed
                                    : AppColors.textPrimary),
                          ),
                          TextSpan(
                            text: ' / ₹${limit.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textMuted),
                          ),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: percent,
                      backgroundColor: AppColors.border,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                    ),
                  ),
                ]),
              );
            }).toList(),
          ),
        ),
      ]),
    );
  }

  Widget _buildRecentTransactions(
      List<Map<String, dynamic>> txns) {
    if (txns.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionHeader(
          title: 'Recent Transactions',
          actionText: 'View All',
          onAction: () => Navigator.pushNamed(context, '/transactions')
              .then((_) => _loadDashboard()),
        ),
        const SizedBox(height: 16),
        ...txns.map((t) {
          final isExpense = t['type'] == 'expense';
          final color     = _hexColor(t['color'] as String?);
          return Container(
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
                      Text(t['note'] as String? ?? '',
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
                        fontSize: 11,
                        color: AppColors.textMuted)),
              ]),
            ]),
          );
        }),
      ]),
    );
  }

  Color _hexColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.primary;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }
}

class _QuickAction {
  final IconData icon;
  final String label, route;
  final Color color;
  const _QuickAction(
      {required this.icon,
        required this.label,
        required this.color,
        required this.route});
}