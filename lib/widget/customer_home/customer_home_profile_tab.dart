import 'package:flutter/material.dart';

class CustomerHomeProfileTab extends StatelessWidget {
  const CustomerHomeProfileTab({
    super.key,
    required this.onLogout,
    required this.loading,
  });

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
