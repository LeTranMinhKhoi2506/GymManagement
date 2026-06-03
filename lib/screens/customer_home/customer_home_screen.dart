import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/route/routes.dart';
import '../../provider/auth_provider.dart';
import '../../screens/main_Screen_Customer/home_screen.dart';
import '../../widget/customer_home/customer_home_bottom_nav_bar.dart';
import '../../widget/customer_home/customer_home_profile_tab.dart';
import '../../widget/customer_home/customer_home_tab_placeholder.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  static const routeName = '/customer-home';

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentIndex = 0;

  Future<void> _handleLogout() async {
    final success = await context.read<AuthProvider>().signOut();
    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Dang xuat that bai. Vui long thu lai.'),
          ),
        );
      return;
    }

    context.go(Routes.customerLogin);
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select<AuthProvider, bool>((p) => p.loading);
    final pages = <Widget>[
      const HomeScreenCustomer(showCreateFab: true, bottomPadding: 120),
      const CustomerHomeTabPlaceholder(title: 'TRAINERS'),
      const CustomerHomeTabPlaceholder(title: 'WORKOUTS'),
      CustomerHomeProfileTab(onLogout: _handleLogout, loading: loading),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: CustomerHomeBottomNavBar(
        currentIndex: _currentIndex,
        onChanged: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
