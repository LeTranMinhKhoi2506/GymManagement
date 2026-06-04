import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SwipableShellContainer extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  const SwipableShellContainer({
    super.key,
    required this.navigationShell,
    required this.children,
  });

  @override
  State<SwipableShellContainer> createState() => _SwipableShellContainerState();
}

class _SwipableShellContainerState extends State<SwipableShellContainer> {
  late PageController _pageController;
  bool _isUserGesture = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.navigationShell.currentIndex,
    );
  }

  @override
  void didUpdateWidget(covariant SwipableShellContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync PageController programmatically if GoRouter's index changed outside swiping
    if (widget.navigationShell.currentIndex != oldWidget.navigationShell.currentIndex) {
      final targetPage = widget.navigationShell.currentIndex;
      if (_pageController.hasClients && _pageController.page?.round() != targetPage) {
        _pageController.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollStartNotification) {
          // Detect if scroll was started by user drag gesture
          _isUserGesture = notification.dragDetails != null;
        }
        return false; // Let notification bubble up
      },
      child: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          // Switch GoRouter branch ONLY when user swipes manually
          if (_isUserGesture && index != widget.navigationShell.currentIndex) {
            widget.navigationShell.goBranch(index);
          }
        },
        children: widget.children,
      ),
    );
  }
}
