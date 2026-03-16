import 'package:flutter/material.dart';
import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';

class EditCustomerNameDialog extends StatefulWidget {
  final String currentName;
  final String currentNumber;
  final Function(String, String) onSave;
  final BookingResponseModel booking;

  const EditCustomerNameDialog({
    super.key,
    required this.currentName,
    required this.currentNumber,
    required this.onSave,
    required this.booking,
  });

  @override
  State<EditCustomerNameDialog> createState() => _EditCustomerNameDialogState();
}

class _EditCustomerNameDialogState extends State<EditCustomerNameDialog> {
  late TextEditingController _nameController;
  late TextEditingController _numberController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _numberController = TextEditingController(text: widget.currentNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Customer Details'),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Customer Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _numberController,
            keyboardType: TextInputType.number,
            maxLength: 15,
            decoration: const InputDecoration(
              labelText: 'Customer Number',
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_nameController.text, _numberController.text);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
