import 'package:flutter/material.dart';

class HomeSocialFeedTheme {
  static const Color bg = Color(0xFF0B0B0B);
  static const Color card = Color(0xFF121418);
  static const Color cardAlt = Color(0xFF171A1F);
  static const Color accent = Color(0xFFE9EFB5);
  static const Color muted = Color(0xFF8A8E95);
}

String homeRelativeTime(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  return '${diff.inDays}d ago';
}
