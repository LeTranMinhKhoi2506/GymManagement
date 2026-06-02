import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  const SearchBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.search,
            color: Color(0xFFC8C8C8),
            size: 28,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'SEARCH EXERCISES, TRAINERS...',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFF6F6F6F),
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

