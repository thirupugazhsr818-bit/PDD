// lib/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'app_colors.dart';
import 'common_widgets.dart';
import 'api_servic.dart';

class ProfileScreen extends StatefulWidget {
  final bool isTab;
  const ProfileScreen({super.key, this.isTab = false});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool   _loading = true;
  Map<String, dynamic> _user = {};

  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await ApiService.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.success) {
        _user = Map<String, dynamic>.from(res.data);
        _nameCtrl.text  = _user['name']  as String? ?? '';
        _phoneCtrl.text = _user['phone'] as String? ?? '';
      }
    });
  }

  String get _initials {
    final name = _user['name'] as String? ?? 'U';
    return name.trim().split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .take(2)
        .join();
  }

  void _showEditSheet() {
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
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Row(children: [
            Icon(Iconsax.user, color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Text('Edit Profile',
                style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 24),
          AppTextField(
            controller: _nameCtrl,
            label: 'Full Name',
            hint: 'Your name',
            prefixIcon: Iconsax.user,
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _phoneCtrl,
            label: 'Phone',
            hint: '+91 98765 43210',
            prefixIcon: Iconsax.call,
            keyboardType: TextInputType.phone,
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 24),
          GradientButton(
            text: 'Save Changes',
            onPressed: () async {
              final userId = _user['id'] as int;
              Navigator.pop(context);
              await ApiService.updateProfile(userId,
                  name: _nameCtrl.text.trim(),
                  phone: _phoneCtrl.text.trim());
              _load();
            },
            icon: Iconsax.tick_circle,
          ),
        ]),
      ),
    );
  }

  void _logout() async {
    final email = _user['email'] as String? ?? '';
    await ApiService.logout(email);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
        context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: _loading
          ? const Center(
          child: CircularProgressIndicator(color: AppColors.primary))
          : SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(children: [
              // ── Header banner ──────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 72, 24, 32),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF00D4AA), Color(0xFF0094FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 8))
                  ],
                ),
                child: Column(children: [
                  // Avatar
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 2),
                    ),
                    child: Center(
                      child: Text(_initials,
                          style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(_user['name'] as String? ?? '',
                      style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(_user['email'] as String? ?? '',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.white70)),
                ]),
              ),

              const SizedBox(height: 28),

              // ── Info cards ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(children: [
                  _infoCard([
                    _InfoItem(Iconsax.user,  'Full Name',
                        _user['name']  as String? ?? '—'),
                    _InfoItem(Iconsax.sms,   'Email',
                        _user['email'] as String? ?? '—'),
                    _InfoItem(Iconsax.call,  'Phone',
                        _user['phone'] as String? ?? '—'),
                  ]),
                  const SizedBox(height: 16),

                  // ── Menu items ───────────────────────────────────
                  _menuTile(Iconsax.edit_2, 'Edit Profile',
                      AppColors.primary, _showEditSheet),
                  const SizedBox(height: 10),
                  _menuTile(Iconsax.receipt_item, 'All Transactions',
                      AppColors.accentBlue, () =>
                          Navigator.pushNamed(
                              context, '/transactions')),
                  const SizedBox(height: 10),
                  _menuTile(Iconsax.chart_2, 'Spending Analytics',
                      AppColors.accentPurple, () =>
                          Navigator.pushNamed(
                              context, '/spending-chart')),
                  const SizedBox(height: 10),
                  _menuTile(Iconsax.flag, 'Goal Tracker',
                      AppColors.accentGold, () =>
                          Navigator.pushNamed(context, '/goals')),
                  const SizedBox(height: 10),
                  _menuTile(Iconsax.receipt_item, 'Bill Reminders',
                      const Color(0xFF06D6A0), () =>
                          Navigator.pushNamed(context, '/bills')),

                  const SizedBox(height: 24),

                  // ── Logout ───────────────────────────────────────
                  GestureDetector(
                    onTap: _logout,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.accentRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.accentRed.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.login,
                              color: AppColors.accentRed, size: 20),
                          const SizedBox(width: 10),
                          Text('Log Out',
                              style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accentRed)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _infoCard(List<_InfoItem> items) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border)),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 14),
              child: Row(children: [
                Icon(e.value.icon,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.value.label,
                            style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textMuted)),
                        Text(e.value.value,
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                      ]),
                ),
              ]),
            ),
            if (!isLast)
              Divider(height: 1, color: AppColors.border),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _menuTile(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ),
          Icon(Iconsax.arrow_right_2,
              color: AppColors.textMuted, size: 18),
        ]),
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label, value;
  const _InfoItem(this.icon, this.label, this.value);
}