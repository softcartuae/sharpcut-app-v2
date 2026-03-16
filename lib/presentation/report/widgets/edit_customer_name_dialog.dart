import 'package:flutter/material.dart';
import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';

class EditCustomerNameDialog extends StatefulWidget {
  final String currentName;
  final Function(String) onSave;
  final BookingResponseModel booking;

  const EditCustomerNameDialog({
    super.key,
    required this.currentName,
    required this.onSave,
    required this.booking,
  });

  @override
  State<EditCustomerNameDialog> createState() => _EditCustomerNameDialogState();
}

class _EditCustomerNameDialogState extends State<EditCustomerNameDialog> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Customer Name'),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'Customer Name',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_nameController.text);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
