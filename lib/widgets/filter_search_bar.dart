import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ip_checker_provider.dart';

class FilterSearchBar extends StatelessWidget {
  const FilterSearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<IPCheckerProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            SegmentedButton<FilterMode>(
              segments: const [
                ButtonSegment<FilterMode>(
                  value: FilterMode.all,
                  label: Text('All'),
                ),
                ButtonSegment<FilterMode>(
                  value: FilterMode.online,
                  label: Text('Online'),
                ),
                ButtonSegment<FilterMode>(
                  value: FilterMode.offline,
                  label: Text('Offline'),
                ),
              ],
              selected: <FilterMode>{provider.filterMode},
              onSelectionChanged: (Set<FilterMode> newSelection) {
                provider.setFilterMode(newSelection.first);
              },
              style: ButtonStyle(
                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search IP or Device Name...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                onChanged: (value) {
                  provider.setSearchQuery(value);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
