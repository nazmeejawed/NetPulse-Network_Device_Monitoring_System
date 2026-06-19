import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ip_device.dart';
import '../providers/ip_checker_provider.dart';
import '../theme/app_theme.dart';

class DeviceRow extends StatelessWidget {
  final IPDevice device;
  final int index;

  const DeviceRow({Key? key, required this.device, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = index % 2 == 0 ? Colors.white : AppTheme.surfaceColor;
    
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

    Color pingColor = Colors.black87;
    String pingText = '—';
    if (device.status == DeviceStatus.online && device.pingMs != null) {
      pingText = '${device.pingMs!.toStringAsFixed(0)} ms';
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

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          left: BorderSide(color: statusColor, width: 4),
          bottom: const BorderSide(color: Colors.black12, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(
            width: 100,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.5)),
              ),
              child: Text(
                statusText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: Text(device.ip, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(flex: 2, child: Text(device.label)),
          Expanded(
            flex: 1, 
            child: Text(
              pingText, 
              style: TextStyle(color: pingColor, fontWeight: FontWeight.bold),
            )
          ),
          Expanded(flex: 1, child: Text(lastCheckedText, style: const TextStyle(color: Colors.black54))),
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  color: Colors.blue,
                  tooltip: 'Re-ping',
                  onPressed: () {
                    context.read<IPCheckerProvider>().pingOne(device.id);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Colors.red,
                  tooltip: 'Remove',
                  onPressed: () {
                    context.read<IPCheckerProvider>().removeDevice(device.id);
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
