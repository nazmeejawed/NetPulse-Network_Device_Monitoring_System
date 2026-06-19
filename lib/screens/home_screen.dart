import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ip_checker_provider.dart';
import '../widgets/stats_cards.dart';
import '../widgets/progress_bar.dart';
import '../widgets/filter_search_bar.dart';
import '../widgets/device_row.dart';
import '../widgets/add_ip_dialog.dart';

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
          children: [
            const Icon(Icons.wifi, color: Colors.blue),
            const SizedBox(width: 12),
            const Text(
              'IP Checker',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
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
            icon: const Icon(Icons.play_arrow),
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
            if (provider.successMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      provider.successMessage!,
                      style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      color: Colors.green.shade800,
                      onPressed: () => provider.clearMessages(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            
            if (provider.errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      provider.errorMessage!,
                      style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      color: Colors.red.shade800,
                      onPressed: () => provider.clearMessages(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

            const StatsCards(),
            const SizedBox(height: 16),
            const PingProgressBar(),
            const FilterSearchBar(),
            const SizedBox(height: 16),
            
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.black26, width: 1)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 40, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                  InkWell(
                    onTap: () => context.read<IPCheckerProvider>().toggleSortByStatus(),
                    child: SizedBox(
                      width: 100,
                      child: Row(
                        children: const [
                          Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                          Icon(Icons.unfold_more, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(flex: 2, child: Text('IP Address', style: TextStyle(fontWeight: FontWeight.bold))),
                  const Expanded(flex: 2, child: Text('Device Name', style: TextStyle(fontWeight: FontWeight.bold))),
                  const Expanded(flex: 1, child: Text('Ping (ms)', style: TextStyle(fontWeight: FontWeight.bold))),
                  const Expanded(flex: 1, child: Text('Last Checked', style: TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox(width: 100, child: Text('Actions', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            
            // Table Body
            Expanded(
              child: provider.filteredDevices.isEmpty
                  ? const Center(child: Text('No devices found.'))
                  : ListView.builder(
                      itemCount: provider.filteredDevices.length,
                      itemBuilder: (context, index) {
                        return DeviceRow(
                          device: provider.filteredDevices[index],
                          index: index,
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
