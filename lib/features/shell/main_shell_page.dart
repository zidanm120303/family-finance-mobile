import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../home/home_page.dart';
import '../profile/profile_page.dart';
import '../transaction/add_transaction_page.dart';
import '../transaction/transaction_history_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _index = 0;

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onAdd: () => _select(1), onHistory: () => _select(2)),
      AddTransactionPage(onSaved: () => _select(0)),
      const TransactionHistoryPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primarySoft,
        elevation: 8,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(
              Icons.home_rounded,
              color: AppColors.primaryDark,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline_rounded),
            selectedIcon: Icon(
              Icons.add_circle_rounded,
              color: AppColors.primaryDark,
            ),
            label: 'Tambah',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            selectedIcon: Icon(
              Icons.history_rounded,
              color: AppColors.primaryDark,
            ),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(
              Icons.person_rounded,
              color: AppColors.primaryDark,
            ),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
