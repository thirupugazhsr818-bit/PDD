// client/src/App.jsx
import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import SplashScreen from './pages/SplashScreen';
import OnboardingScreen from './pages/OnboardingScreen';
import LoginScreen from './pages/LoginScreen';
import SignupScreen from './pages/SignupScreen';
import HomeScreen from './pages/HomeScreen';
import AddExpenseScreen from './pages/AddExpenseScreen';
import BudgetScreen from './pages/BudgetScreen';
import SavingsScreen from './pages/SavingsScreen';
import EmiScreen from './pages/EmiScreen';
import BillsScreen from './pages/BillsScreen';
import SpendingChartScreen from './pages/SpendingChartScreen';
import GoalTrackerScreen from './pages/GoalTrackerScreen';
import TransactionsScreen from './pages/TransactionsScreen';
import ProfileScreen from './pages/ProfileScreen';
import './styles/theme.css';

export default function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<SplashScreen />} />
        <Route path="/splash" element={<SplashScreen />} />
        <Route path="/onboarding" element={<OnboardingScreen />} />
        <Route path="/login" element={<LoginScreen />} />
        <Route path="/signup" element={<SignupScreen />} />
        <Route path="/home" element={<HomeScreen />} />
        <Route path="/add-expense" element={<AddExpenseScreen />} />
        <Route path="/budget" element={<BudgetScreen />} />
        <Route path="/savings" element={<SavingsScreen />} />
        <Route path="/emi" element={<EmiScreen />} />
        <Route path="/bills" element={<BillsScreen />} />
        <Route path="/spending-chart" element={<SpendingChartScreen />} />
        <Route path="/goals" element={<GoalTrackerScreen />} />
        <Route path="/transactions" element={<TransactionsScreen />} />
        <Route path="/profile" element={<ProfileScreen />} />
      </Routes>
    </Router>
  );
}
