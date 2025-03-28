import 'package:flutter/material.dart';

Widget buildStatCard({
  required IconData icon,
  required String value,
  required String label,
  required Color color,
}) {
  return Container(
    width: 120,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
