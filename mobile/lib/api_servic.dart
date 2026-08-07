// lib/core/services/api_service.dart
//
// Central HTTP service — all screens import this, nobody touches raw http.
// Pattern mirrors the url.dart approach: one place for the base URL,
// one place for every request.

import 'dart:convert';
import 'package:http/http.dart' as http;

// ─── Base URL ─────────────────────────────────────────────────────────────────
class Url {
  static const String base = 'https://pdd-backend-4otv.onrender.com';
}

// ─── Response wrapper ─────────────────────────────────────────────────────────
class ApiResult {
  final bool success;
  final dynamic data;
  final String? error;

  const ApiResult({required this.success, this.data, this.error});

  factory ApiResult.ok(dynamic data) =>
      ApiResult(success: true, data: data);

  factory ApiResult.err(String msg) =>
      ApiResult(success: false, error: msg);
}

// ─── API Service ──────────────────────────────────────────────────────────────
class ApiService {
  static const _headers = {'Content-Type': 'application/json'};

  // ── internal helpers ────────────────────────────────────────────────────────

  static Future<ApiResult> _get(String path,
      {Map<String, String>? params}) async {
    try {
      final uri = Uri.parse('${Url.base}$path')
          .replace(queryParameters: params);
      final res = await http.get(uri, headers: _headers);
      final body = jsonDecode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return ApiResult.ok(body);
      }
      return ApiResult.err(body['error'] ?? 'Request failed');
    } catch (e) {
      return ApiResult.err('Network error: $e');
    }
  }

  static Future<ApiResult> _post(String path,
      Map<String, dynamic> payload) async {
    try {
      final uri = Uri.parse('${Url.base}$path');
      final res = await http.post(uri,
          headers: _headers, body: jsonEncode(payload));
      final body = jsonDecode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return ApiResult.ok(body);
      }
      return ApiResult.err(body['error'] ?? 'Request failed');
    } catch (e) {
      return ApiResult.err('Network error: $e');
    }
  }

  static Future<ApiResult> _put(String path,
      Map<String, dynamic> payload) async {
    try {
      final uri = Uri.parse('${Url.base}$path');
      final res = await http.put(uri,
          headers: _headers, body: jsonEncode(payload));
      final body = jsonDecode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return ApiResult.ok(body);
      }
      return ApiResult.err(body['error'] ?? 'Request failed');
    } catch (e) {
      return ApiResult.err('Network error: $e');
    }
  }

  static Future<ApiResult> _delete(String path) async {
    try {
      final uri = Uri.parse('${Url.base}$path');
      final res = await http.delete(uri, headers: _headers);
      final body = jsonDecode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return ApiResult.ok(body);
      }
      return ApiResult.err(body['error'] ?? 'Request failed');
    } catch (e) {
      return ApiResult.err('Network error: $e');
    }
  }

  // ── AUTH ────────────────────────────────────────────────────────────────────

  static Future<ApiResult> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) =>
      _post('/signup', {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'confirm_password': confirmPassword,
      });

  static Future<ApiResult> login({
    required String email,
    required String password,
  }) =>
      _post('/login', {'email': email, 'password': password});

  static Future<ApiResult> getCurrentUser() => _get('/get_current_user');

  static Future<ApiResult> logout(String email) =>
      _post('/logout', {'email': email});

  // ── PROFILE ─────────────────────────────────────────────────────────────────

  static Future<ApiResult> getProfile(int userId) =>
      _get('/profile/$userId');

  static Future<ApiResult> updateProfile(int userId,
      {String? name, String? phone, String? currency}) =>
      _put('/profile/$userId', {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (currency != null) 'currency': currency,
      });

  // ── DASHBOARD ───────────────────────────────────────────────────────────────

  static Future<ApiResult> getDashboard(int userId, {String? month}) =>
      _get('/dashboard/$userId',
          params: month != null ? {'month': month} : null);

  // ── TRANSACTIONS ────────────────────────────────────────────────────────────

  static Future<ApiResult> getTransactions(int userId,
      {String? type, String? category, String? month, int limit = 50}) =>
      _get('/transactions/$userId', params: {
        if (type != null) 'type': type,
        if (category != null) 'category': category,
        if (month != null) 'month': month,
        'limit': '$limit',
      });

  static Future<ApiResult> addTransaction({
    required int userId,
    required String type,
    required double amount,
    required String category,
    String note = '',
    String icon = '',
    String color = '',
    String? txnDate,
  }) =>
      _post('/transactions', {
        'user_id': userId,
        'type': type,
        'amount': amount,
        'category': category,
        'note': note,
        'icon': icon,
        'color': color,
        if (txnDate != null) 'txn_date': txnDate,
      });

  static Future<ApiResult> deleteTransaction(int txnId) =>
      _delete('/transactions/$txnId');

  static Future<ApiResult> getTransactionSummary(int userId,
      {String? month}) =>
      _get('/transactions/summary/$userId',
          params: month != null ? {'month': month} : null);

  static Future<ApiResult> getMonthlyChart(int userId) =>
      _get('/transactions/monthly_chart/$userId');

  // ── BUDGETS ─────────────────────────────────────────────────────────────────

  static Future<ApiResult> getBudgets(int userId, {String? month}) =>
      _get('/budgets/$userId',
          params: month != null ? {'month': month} : null);

  static Future<ApiResult> addBudget({
    required int userId,
    required String category,
    required double amount,
    String icon = '',
    String color = '',
    String? month,
  }) =>
      _post('/budgets', {
        'user_id': userId,
        'category': category,
        'amount': amount,
        'icon': icon,
        'color': color,
        if (month != null) 'month': month,
      });

  static Future<ApiResult> updateBudget(int budgetId, double amount) =>
      _put('/budgets/$budgetId', {'amount': amount});

  static Future<ApiResult> deleteBudget(int budgetId) =>
      _delete('/budgets/$budgetId');

  // ── SAVINGS GOALS ───────────────────────────────────────────────────────────

  static Future<ApiResult> getSavingsGoals(int userId) =>
      _get('/savings_goals/$userId');

  static Future<ApiResult> addSavingsGoal({
    required int userId,
    required String label,
    required double target,
    String icon = '',
    String color = '',
  }) =>
      _post('/savings_goals', {
        'user_id': userId,
        'label': label,
        'target': target,
        'icon': icon,
        'color': color,
      });

  static Future<ApiResult> addMoneyToGoal(int goalId,
      {required double amount, String note = ''}) =>
      _post('/savings_goals/$goalId/add_money',
          {'amount': amount, 'note': note});

  static Future<ApiResult> deleteSavingsGoal(int goalId) =>
      _delete('/savings_goals/$goalId');

  static Future<ApiResult> getContributions(int goalId) =>
      _get('/savings_goals/$goalId/contributions');

  // ── EMIS ────────────────────────────────────────────────────────────────────

  static Future<ApiResult> getEmis(int userId, {String status = 'active'}) =>
      _get('/emis/$userId', params: {'status': status});

  static Future<ApiResult> addEmi({
    required int userId,
    required String label,
    required double emiAmount,
    required int totalMonths,
    required int dueDay,
    String bank = '',
    String icon = '',
    String color = '',
    int paidMonths = 0,
  }) =>
      _post('/emis', {
        'user_id': userId,
        'label': label,
        'emi_amount': emiAmount,
        'total_months': totalMonths,
        'due_day': dueDay,
        'bank': bank,
        'icon': icon,
        'color': color,
        'paid_months': paidMonths,
      });

  static Future<ApiResult> markEmiPaid(int emiId) =>
      _post('/emis/$emiId/pay', {});

  static Future<ApiResult> deleteEmi(int emiId) =>
      _delete('/emis/$emiId');

  // ── BILLS ───────────────────────────────────────────────────────────────────

  static Future<ApiResult> getBills(int userId, {int? isPaid}) =>
      _get('/bills/$userId',
          params: isPaid != null ? {'is_paid': '$isPaid'} : null);

  static Future<ApiResult> addBill({
    required int userId,
    required String label,
    required double amount,
    required int dueDay,
    String icon = '',
    String color = '',
  }) =>
      _post('/bills', {
        'user_id': userId,
        'label': label,
        'amount': amount,
        'due_day': dueDay,
        'icon': icon,
        'color': color,
      });

  static Future<ApiResult> markBillPaid(int billId) =>
      _post('/bills/$billId/pay', {});

  static Future<ApiResult> markBillUnpaid(int billId) =>
      _post('/bills/$billId/unpay', {});

  static Future<ApiResult> deleteBill(int billId) =>
      _delete('/bills/$billId');

  // ── GOALS (MILESTONE TRACKER) ───────────────────────────────────────────────

  static Future<ApiResult> getGoals(int userId) =>
      _get('/goals/$userId');

  static Future<ApiResult> addGoal({
    required int userId,
    required String label,
    String icon = '',
    String color = '',
    double progress = 0,
    List<String> milestones = const [],
  }) =>
      _post('/goals', {
        'user_id': userId,
        'label': label,
        'icon': icon,
        'color': color,
        'progress': progress,
        'milestones': milestones,
      });

  static Future<ApiResult> updateGoal(int goalId,
      {String? label, double? progress, List<String>? milestones}) =>
      _put('/goals/$goalId', {
        if (label != null) 'label': label,
        if (progress != null) 'progress': progress,
        if (milestones != null) 'milestones': milestones,
      });

  static Future<ApiResult> deleteGoal(int goalId) =>
      _delete('/goals/$goalId');
}