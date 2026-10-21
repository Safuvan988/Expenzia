import 'package:expence_management_/screens/add_edit_expense_screen.dart';
import 'package:expence_management_/screens/credit_screen.dart';
import 'package:expence_management_/screens/history_screen.dart';
import 'package:expence_management_/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../providers/expense_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/expense_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  void _openAdd() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddEditExpenseScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeTab(onSeeAll: () => setState(() => _index = 1)),
      const HistoryScreen(),
      const CreditScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 2,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: AppColors.primary,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_outlined, 0),
              _navItem(Icons.history, 1),
              const SizedBox(width: 56), // space for the FAB
              _navItem(Icons.account_balance_wallet_outlined, 2),
              _navItem(Icons.person_outline, 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int i) {
    final selected = _index == i;
    return IconButton(
      onPressed: () => setState(() => _index = i),
      icon: Icon(
        icon,
        size: 26,
        color: selected ? Colors.white : Colors.white60,
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final VoidCallback onSeeAll;
  const _HomeTab({required this.onSeeAll});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  String _money(double v) => '$kCurrency${NumberFormat('#,##0.00').format(v)}';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<ExpenseProvider>(
        builder: (context, p, _) {
          final recent = p.expenses.take(5).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              Text(
                _greeting(),
                style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
              ),
              const Text(
                kUserName,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),

              // Balance card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _money(p.balance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _summary(
                          Icons.arrow_downward,
                          'Income',
                          _money(p.totalIncome),
                          CrossAxisAlignment.start,
                        ),
                        _summary(
                          Icons.arrow_upward,
                          'Expenses',
                          _money(p.totalExpense),
                          CrossAxisAlignment.end,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Daily average / weekly
              Row(
                children: [
                  Expanded(
                    child: _statBox('DAILY AVERAGE', _money(p.dailyAverage)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _statBox('WEEKLY', _money(p.weeklyExpense))),
                ],
              ),
              const SizedBox(height: 24),

              // Transactions header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transactions History',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  GestureDetector(
                    onTap: onSeeAll,
                    child: const Text(
                      'See all',
                      style: TextStyle(fontSize: 10, color: AppColors.textGrey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (p.isLoading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (p.error != null)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      p.error!,
                      style: const TextStyle(color: AppColors.expense),
                    ),
                  ),
                )
              else if (recent.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: EmptyState(),
                )
              else
                ...recent.map(
                  (e) => ExpenseTile(
                    expense: e,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddEditExpenseScreen(expense: e),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _summary(
    IconData icon,
    String label,
    String value,
    CrossAxisAlignment align,
  ) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.white70),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _statBox(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: AppColors.textGrey),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _ComingSoon extends StatelessWidget {
  final String title;
  const _ComingSoon({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(child: Text('Coming soon')),
    );
  }
}
