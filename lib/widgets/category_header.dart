import 'package:flutter/material.dart';

class CategoryHeader extends StatelessWidget {
  final String categoryName;

  const CategoryHeader({Key? key, required this.categoryName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 8, left: 32, right: 32),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.folder_open, size: 20, color: Colors.blueGrey.shade700),
          const SizedBox(width: 12),
          Text(
            categoryName.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.blueGrey.shade700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
