import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ip_checker_provider.dart';

class PingProgressBar extends StatelessWidget {
  const PingProgressBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<IPCheckerProvider>(
      builder: (context, provider, child) {
        if (!provider.isPinging || provider.isAutoMonitoring) {
          return const SizedBox.shrink();
        }

        final progress = provider.totalPingCount == 0
            ? 0.0
            : provider.pingedCount / provider.totalPingCount;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pinging ${provider.pingedCount} of ${provider.totalPingCount} devices...',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                color: Colors.blue,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          ),
        );
      },
    );
  }
}
