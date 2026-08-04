// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moneymate/profile.dart';
import 'package:moneymate/savings_screen.dart';
import 'package:moneymate/signup_screen.dart';
import 'package:moneymate/spending_chart_screen.dart';
import 'package:moneymate/splash_screen.dart';
import 'package:moneymate/transactions.dart';

import 'add_expense_screen.dart';
import 'app_theme.dart';
import 'bills_screen.dart';
import 'budget_screen.dart';
import 'emi_screen.dart';
import 'goal_tracker_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A0E1A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MoneyMateApp());
}

class MoneyMateApp extends StatelessWidget {
  const MoneyMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoneyMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/home': (_) => const HomeScreen(),
        '/add-expense': (_) => const AddExpenseScreen(),
        '/budget': (_) => const BudgetScreen(),
        '/savings': (_) => const SavingsScreen(),
        '/emi': (_) => const EmiScreen(),
        '/bills': (_) => const BillsScreen(),
        '/spending-chart': (_) => const SpendingChartScreen(),
        '/goals':          (_) => const GoalTrackerScreen(),
        '/transactions':   (_) => const TransactionsScreen(),
        '/profile':        (_) => const ProfileScreen(),
      },
    );
  }
}