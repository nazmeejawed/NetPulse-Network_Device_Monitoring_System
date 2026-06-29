import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ip_device.dart';
import '../providers/ip_checker_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/edit_ip_dialog.dart';

class DeviceRow extends StatelessWidget {
  final IPDevice device;
  final int index;

  const DeviceRow({Key? key, required this.device, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    
    switch (device.status) {
      case DeviceStatus.online:
        statusColor = AppTheme.onlineColor;
        statusText = 'ONLINE';
        break;
      case DeviceStatus.offline:
        statusColor = AppTheme.offlineColor;
        statusText = 'OFFLINE';
        break;
      case DeviceStatus.checking:
        statusColor = AppTheme.checkingColor;
        statusText = 'CHECKING';
        break;
      case DeviceStatus.idle:
      default:
        statusColor = AppTheme.idleColor;
        statusText = 'IDLE';
        break;
    }

    Color pingColor = const Color(0xFF6B7280); // Gray 500
    if (device.status == DeviceStatus.online && device.pingMs != null) {
      if (device.pingMs! < 50) {
        pingColor = AppTheme.onlineColor;
      } else if (device.pingMs! < 150) {
        pingColor = AppTheme.checkingColor;
      } else {
        pingColor = AppTheme.offlineColor;
      }
    }

    String lastCheckedText = '—';
    if (device.lastChecked != null) {
      final t = device.lastChecked!;
      lastCheckedText = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
                child: Text(statusText, textAlign: TextAlign.center),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              device.ip,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              device.label.isEmpty ? '-' : device.label,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            flex: 1,
            child: device.status == DeviceStatus.online && device.pingMs != null
                ? TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: device.pingMs!),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutQuart,
                    builder: (context, val, child) {
                      return Text(
                        '${val.toStringAsFixed(0)} ms',
                        style: TextStyle(
                          color: pingColor,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  )
                : Text(
                    '—',
                    style: TextStyle(
                      color: pingColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              lastCheckedText,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: AppTheme.primaryColor.withValues(alpha: 0.8),
                  splashRadius: 20,
                  tooltip: 'Edit',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => EditIPDialog(device: device),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  color: AppTheme.primaryColor.withValues(alpha: 0.6),
                  splashRadius: 20,
                  tooltip: 'Re-ping',
                  onPressed: () {
                    context.read<IPCheckerProvider>().pingOne(device.id);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppTheme.offlineColor.withValues(alpha: 0.8),
                  splashRadius: 20,
                  tooltip: 'Remove',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete IP'),
                        content: Text('Are you sure you want to delete ${device.ip}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<IPCheckerProvider>().removeDevice(device.id);
                              Navigator.of(context).pop();
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
