import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ip_checker_provider.dart';

class StatsCards extends StatelessWidget {
  const StatsCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<IPCheckerProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            Expanded(
              child: _buildCard(
                title: 'Total Devices',
                value: provider.totalPingCount.toString(),
                icon: Icons.devices,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCard(
                title: 'Online',
                value: provider.onlineCount.toString(),
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCard(
                title: 'Offline',
                value: provider.offlineCount.toString(),
                icon: Icons.error,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCard(
                title: 'Average Ping',
                value: provider.avgPingMs > 0 ? '${provider.avgPingMs.toStringAsFixed(1)} ms' : '-',
                icon: Icons.speed,
                color: Colors.orange,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 36, color: color.withOpacity(0.8)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
