# 💰 MoneyMate — Flutter Finance App

A beautiful, professional personal finance app built with Flutter.
Dark luxury design system with teal-green gradient accent.

---

## 📁 Project Structure

```
lib/
├── main.dart                          ← App entry + all routes
├── core/
│   ├── theme/
│   │   ├── app_colors.dart            ← Color palette & gradients
│   │   └── app_theme.dart             ← ThemeData configuration
│   └── widgets/
│       └── common_widgets.dart        ← Reusable UI components
└── screens/
    ├── splash/
    │   └── splash_screen.dart         ← Animated splash with logo + progress
    ├── onboarding/
    │   └── onboarding_screen.dart     ← 3-page illustrated onboarding
    ├── auth/
    │   ├── login_screen.dart          ← Email/password login + Google SSO
    │   └── signup_screen.dart         ← Full registration form
    ├── home/
    │   └── home_screen.dart           ← Dashboard + bottom nav
    ├── expense/
    │   └── add_expense_screen.dart    ← Add expense/income with categories
    ├── budget/
    │   └── budget_screen.dart         ← Monthly budget with alert system
    ├── savings/
    │   └── savings_screen.dart        ← Savings goal tracker
    ├── emi/
    │   └── emi_screen.dart            ← EMI tracker with due date alerts
    ├── bills/
    │   └── bills_screen.dart          ← Bill payment reminders
    ├── analytics/
    │   └── spending_chart_screen.dart ← Bar + donut spending charts
    └── goals/
        └── goal_tracker_screen.dart   ← Financial goal tracker + milestones
```

---

## 🚀 Setup Instructions

### 1. Prerequisites
```bash
flutter --version   # Requires Flutter 3.19+
dart --version      # Requires Dart 3.0+
```

### 2. Clone & Install
```bash
cd moneymate_flutter
flutter pub get
```

### 3. Add Poppins Font
- Download from: https://fonts.google.com/specimen/Poppins
- Extract and place font files in `assets/fonts/`:
  - `Poppins-Regular.ttf`
  - `Poppins-Medium.ttf`
  - `Poppins-SemiBold.ttf`
  - `Poppins-Bold.ttf`
  - `Poppins-ExtraBold.ttf`

### 4. Create Asset Directories
```bash
mkdir -p assets/fonts assets/images assets/icons
```

### 5. Run the App
```bash
flutter run
```

---

## 🎨 Design System

| Token | Value |
|-------|-------|
| Primary | `#00D4AA` (Emerald Teal) |
| Background | `#0A0E1A` (Deep Navy) |
| Card | `#111827` |
| Elevated | `#1A2234` |
| Accent Red | `#FF4D6A` |
| Accent Blue | `#4D9FFF` |
| Accent Gold | `#F5C842` |
| Accent Purple | `#9B6DFF` |
| Font | Poppins |

---

## 📱 Screens

| Screen | Route | Description |
|--------|-------|-------------|
| Splash | `/splash` | Logo animation + loading bar |
| Onboarding | `/onboarding` | 3-page value proposition |
| Login | `/login` | Email/password + social auth |
| Signup | `/signup` | Registration with validation |
| Home | `/home` | Dashboard with balance card |
| Add Expense | `/add-expense` | Category picker + amount input |
| Budget | `/budget` | Per-category budget with alerts |
| Savings | `/savings` | Goal cards with progress tracking |
| EMI | `/emi` | Loan tracker with due reminders |
| Bills | `/bills` | Bill reminders with pay now |
| Chart | `/spending-chart` | Bar chart + donut breakdown |
| Goals | `/goals` | Milestone-based goal tracking |

---

## 📦 Key Dependencies

```yaml
fl_chart: ^0.68.0                  # Bar & pie charts
google_fonts: ^6.2.1               # Font loading (fallback)
flutter_local_notifications        # EMI & bill reminders
shared_preferences                 # Local persistence
intl                               # Date formatting
provider                           # State management
```

---

## 🔌 Connecting Real Data

Each screen currently uses hardcoded mock data.
To connect real data:

1. **Add a state management layer** (Riverpod/BLoC recommended)
2. **Add a local DB** (`sqflite` or `drift`) for transactions
3. **Add Firebase** for auth + cloud sync
4. **Enable notifications** via `flutter_local_notifications`

---

## 📐 Recommended Next Steps

- [ ] Add Firebase Auth (replace mock login)
- [ ] Add Hive/SQLite for local expense persistence
- [ ] Implement `flutter_local_notifications` for bill/EMI alerts
- [ ] Add biometric authentication
- [ ] Add CSV export
- [ ] Add recurring transaction support
- [ ] Implement profile screen
- [ ] Add dark/light theme toggle
