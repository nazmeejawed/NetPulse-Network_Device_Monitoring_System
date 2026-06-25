import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ip_device.dart';
import '../providers/ip_checker_provider.dart';
import '../services/ping_service.dart';

class EditIPDialog extends StatefulWidget {
  final IPDevice device;

  const EditIPDialog({Key? key, required this.device}) : super(key: key);

  @override
  State<EditIPDialog> createState() => _EditIPDialogState();
}

class _EditIPDialogState extends State<EditIPDialog> {
  late final TextEditingController _ipController;
  late final TextEditingController _labelController;
  late final TextEditingController _categoryController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _ipController = TextEditingController(text: widget.device.ip);
    _labelController = TextEditingController(text: widget.device.label);
    _categoryController = TextEditingController(text: widget.device.category);
  }

  @override
  void dispose() {
    _ipController.dispose();
    _labelController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Device'),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Category',
                  hintText: 'e.g. Servers, Cameras',
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
              context.read<IPCheckerProvider>().editDevice(
                    widget.device.id,
                    _ipController.text.trim(),
                    _labelController.text.trim(),
                    _categoryController.text.trim().isEmpty ? 'General' : _categoryController.text.trim(),
                  );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
