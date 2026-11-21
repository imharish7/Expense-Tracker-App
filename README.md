# LuxeSpend • Executive Wealth & Expense Intelligence

> **A Commercial-Grade Flutter Application Built for Freelance Portfolios**  
> *Targeted at winning high-ticket Fintech, Neobank, and SaaS mobile contracts.*

[![Flutter](https://img.shields.io/badge/Flutter-3.44.6-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12.2-0175C2?logo=dart)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2F%20Feature--First-brightgreen)]()
[![Analysis](https://img.shields.io/badge/flutter%20analyze-0%20issues-success)]()
[![Tests](https://img.shields.io/badge/tests-passing-success)]()

### 📲 [Download Ready-to-Install Android APK (v1.0.0)](https://github.com/imharish7/Expense-Tracker-App/raw/main/apk/luxespend-release.apk)

---

## 🌟 Why This App Wins High-Value Freelance Clients

Clients on Upwork, Toptal, and direct B2B contracts look for **proof of commercial maturity** beyond basic UI clones. **LuxeSpend** demonstrates the exact skills enterprise and startup clients pay premium hourly rates for:

1. **Enterprise Clean Architecture**: Separation of concerns (`core/`, `data/`, `providers/`, `presentation/`).
2. **Interactive Data Visualizations (`fl_chart`)**:
   - Touch-responsive Donut Expense Allocation chart with dynamic center stats.
   - Dual-rod Weekly Cashflow Bar Chart (Inflows vs. Outflows).
3. **Multi-Wallet Liquidity Engine**:
   - Manages checking accounts, luxury credit lines, cold storage crypto vaults, and cash reserves.
   - Real-time balance calculations, account-to-account fund transfers, and ledger reversibility.
4. **Tactile Custom Keypad & Modal Entry**:
   - Segmented Expense / Income / Transfer control.
   - Custom numpad with fast preset increments (+$10, +$50, +$100, +$500).
   - Category picker and date selector.
5. **Obsidian Dark & Alabaster Light Luxury Theme**:
   - Polished glassmorphism, Champagne Gold (`#E5B869`) & Emerald (`#10B981`) color system.
   - Smooth 350ms animated theme interpolation across all components.
   - Privacy Shield mode (one-tap balance masking).
   - Multi-currency engine (USD, EUR, GBP, JPY, INR, CAD, AUD, CHF, AED).
6. **Offline-First Persistence**:
   - Zero-delay local storage with clean zero-balance state.

---

## 🏛️ Code Architecture

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart          # Currency list, preference keys, app metadata
│   ├── theme/
│   │   ├── app_colors.dart             # Luxury dark/light palettes, gradients, accents
│   │   ├── app_theme.dart              # Material 3 ThemeData configurations
│   │   └── app_typography.dart         # Tabular numerals, hierarchy, spacing
│   └── utils/
│       └── currency_formatter.dart     # Multi-currency & compact numerical formatting
├── data/
│   ├── models/
│   │   ├── category_item.dart          # Categorization engine with icons & colors
│   │   ├── wallet_model.dart           # Bank / credit / crypto / cash models
│   │   ├── transaction_model.dart      # Immutable transaction entries
│   │   └── budget_model.dart           # Monthly caps & tracking metrics
│   ├── repositories/
│   │   └── expense_repository.dart     # SharedPreferences persistence & serialization
│   └── mock_data.dart                  # Starter dataset configuration
├── providers/
│   └── expense_controller.dart         # Reactive state controller & business logic
└── presentation/
    ├── screens/
    │   ├── main_navigation_screen.dart # Docked navigation bar with central quick-add
    │   ├── dashboard_screen.dart       # Executive summary, hero card, quick stats
    │   ├── transactions_screen.dart    # Filterable ledger, search, statement export
    │   ├── analytics_screen.dart       # Cashflow trends, pie allocation, peak velocity
    │   ├── wallets_screen.dart         # Account management & fund transfer workflow
    │   ├── budgets_screen.dart         # Category spending caps & health score
    │   ├── settings_screen.dart        # Currency switcher, dark/light mode, reset data
    │   ├── add_transaction_sheet.dart  # Tactile numeric keypad & quick logging
    │   └── wallet_detail_sheet.dart    # Account ledger, top up, withdraw, and edit modal
    └── widgets/
        ├── balance_card.dart           # Ambient glow hero card with privacy mask
        ├── quick_stat_chip.dart        # Micro KPI cards
        ├── wallet_card.dart            # Realistic luxury card mockup
        ├── transaction_tile.dart       # Dismissible swipe-to-delete transaction row
        ├── spending_pie_chart.dart     # Touch-interactive donut chart (fl_chart)
        ├── cashflow_bar_chart.dart     # 7-day inflow/outflow bar visualizer (fl_chart)
        ├── budget_progress_card.dart   # Linear progress indicator with warning thresholds
        └── glass_card.dart             # Frosted glass container widget
```

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (3.44+ recommended)
* Dart SDK (3.12+)

### Run the App
```bash
# Clone or navigate to the workspace
cd "f:\Antigravity\Portfolio\New folder"

# Fetch packages
flutter pub get

# Run tests
flutter test

# Run static analysis
flutter analyze

# Launch on Chrome, Windows, or Mobile emulator
flutter run
```
