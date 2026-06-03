import 'package:flutter/material.dart';

class CustomerHomeTabPlaceholder extends StatelessWidget {
  const CustomerHomeTabPlaceholder({super.key, required this.title});

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
