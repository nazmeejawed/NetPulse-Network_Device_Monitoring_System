import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ip_checker_provider.dart';
import '../services/ping_service.dart';

class AddIPDialog extends StatefulWidget {
  const AddIPDialog({Key? key}) : super(key: key);

  @override
  State<AddIPDialog> createState() => _AddIPDialogState();
}

class _AddIPDialogState extends State<AddIPDialog> {
  final _ipController = TextEditingController();
  final _labelController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ipController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Single IP'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _ipController,
                decoration: InputDecoration(
                  labelText: 'IP Address *',
                  hintText: 'e.g. 192.168.1.100',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'IP address is required';
                  }
                  if (!PingService.isValidIP(value.trim())) {
                    return 'Invalid IPv4 format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _labelController,
                decoration: InputDecoration(
                  labelText: 'Device Name (Optional)',
                  hintText: 'e.g. Printer 1',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              context.read<IPCheckerProvider>().addManualIP(
                    _ipController.text.trim(),
                    _labelController.text.trim(),
                  );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add IP'),
        ),
      ],
    );
  }
}
