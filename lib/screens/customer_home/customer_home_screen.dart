import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/auth_provider.dart';
import '../main_Screen_Customer/home_screen.dart';
import '../customer_login/login_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  static const routeName = '/customer-home';

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentIndex = 0;

  static const List<_BottomNavItemData> _items = [
    _BottomNavItemData(label: 'HOME', icon: Icons.home_rounded),
    _BottomNavItemData(label: 'TRAINERS', icon: Icons.sports_gymnastics_rounded),
    _BottomNavItemData(label: 'WORKOUTS', icon: Icons.bolt_rounded),
    _BottomNavItemData(label: 'PROFILE', icon: Icons.person_rounded),
  ];

  Future<void> _handleLogout() async {
    final success = await context.read<AuthProvider>().signOut();
    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Dang xuat that bai. Vui long thu lai.')),
        );
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      LoginScreen.routeName,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select<AuthProvider, bool>((p) => p.loading);
    final pages = <Widget>[
      const HomeScreenCustomerContent(),
      const _TabPlaceholder(title: 'TRAINERS'),
      const _TabPlaceholder(title: 'WORKOUTS'),
      _ProfileTab(onLogout: _handleLogout, loading: loading),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 74,
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF202020)),
          ),
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final selected = index == _currentIndex;
              return Expanded(
                child: _BottomBarItem(
                  item: item,
                  selected: selected,
                  onTap: () => setState(() => _currentIndex = index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  const _BottomBarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _BottomNavItemData item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFFE9D84D);
    final normalColor = const Color(0xFF8E8E8E);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: selected ? const Color(0xFF212121) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  size: 19,
                  color: selected ? activeColor : normalColor,
                ),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  style: TextStyle(
                    color: selected ? activeColor : normalColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 26,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.onLogout, required this.loading});

  final Future<void> Function() onLogout;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: loading ? null : onLogout,
        icon: const Icon(Icons.logout_rounded),
        label: Text(loading ? 'DANG XUAT...' : 'DANG XUAT'),
      ),
    );
  }
}

class _BottomNavItemData {
  const _BottomNavItemData({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

