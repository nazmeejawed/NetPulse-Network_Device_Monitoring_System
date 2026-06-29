import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ip_checker_provider.dart';
import '../widgets/stats_cards.dart';
import '../widgets/progress_bar.dart';
import '../widgets/filter_search_bar.dart';
import '../widgets/device_row.dart';
import '../widgets/add_ip_dialog.dart';
import '../widgets/category_header.dart';
import '../models/ip_device.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _showAddIPDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddIPDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IPCheckerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo.png', height: 42, fit: BoxFit.cover),
            const SizedBox(width: 12),
            const Flexible(
              child: Text(
                'Netpulse',
                style: TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              const Text('Live Monitor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
              Switch(
                value: provider.isAutoMonitoring,
                onChanged: (val) => provider.toggleAutoMonitoring(val),
                activeColor: AppTheme.primaryColor,
              ),
            ],
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => provider.loadFile(),
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload File'),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () => _showAddIPDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add IP'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: provider.isPinging || provider.devices.isEmpty ? null : () => provider.pingAll(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            icon: const Icon(Icons.play_arrow, size: 24),
            label: const Text('Ping All'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1.0,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: provider.successMessage != null
                  ? Container(
                      key: const ValueKey('success_msg'),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.onlineColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.onlineColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            provider.successMessage!,
                            style: const TextStyle(color: AppTheme.onlineColor, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            color: AppTheme.onlineColor,
                            onPressed: () => provider.clearMessages(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('empty_success')),
            ),
            
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1.0,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: provider.errorMessage != null
                  ? Container(
                      key: const ValueKey('error_msg'),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.offlineColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.offlineColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            provider.errorMessage!,
                            style: const TextStyle(color: AppTheme.offlineColor, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            color: AppTheme.offlineColor,
                            onPressed: () => provider.clearMessages(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('empty_error')),
            ),

            const StatsCards(),
            const SizedBox(height: 16),
            const PingProgressBar(),
            const FilterSearchBar(),
            const SizedBox(height: 16),
            
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Row(
                children: [
                  const SizedBox(width: 40, child: Text('#', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54))),
                  InkWell(
                    onTap: () => context.read<IPCheckerProvider>().toggleSortByStatus(),
                    child: SizedBox(
                      width: 100,
                      child: Row(
                        children: const [
                          Text('STATUS', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.black54, letterSpacing: 1.0)),
                          Icon(Icons.unfold_more, size: 16, color: Colors.black38),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(flex: 2, child: Text('IP ADDRESS', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.black54, letterSpacing: 1.0))),
                  const Expanded(flex: 2, child: Text('DEVICE NAME', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.black54, letterSpacing: 1.0))),
                  const Expanded(flex: 1, child: Text('PING (MS)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.black54, letterSpacing: 1.0))),
                  const Expanded(flex: 1, child: Text('LAST CHECKED', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.black54, letterSpacing: 1.0))),
                  const SizedBox(width: 80, child: Text('ACTIONS', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.black54, letterSpacing: 1.0))),
                ],
              ),
            ),
            
            // Table Body
            Expanded(
              child: Builder(
                builder: (context) {
                  final items = provider.groupedListItems;
                  if (items.isEmpty) {
                    return const Center(child: Text('No devices found.'));
                  }
                  int deviceNumber = 0;
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      if (item is String) {
                        return CategoryHeader(categoryName: item);
                      } else if (item is IPDevice) {
                        deviceNumber++;
                        return DeviceRow(
                          device: item,
                          index: deviceNumber - 1,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
