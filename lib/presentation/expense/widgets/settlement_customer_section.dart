import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sharp_cut/presentation/home/widgets/custom_text_field.dart';

class SettlementCustomerSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController mobileController;
  final TextEditingController staffNameController;
  final TextEditingController? invoiceController;

  const SettlementCustomerSection({
    super.key,
    required this.nameController,
    required this.mobileController,
    required this.staffNameController,
    this.invoiceController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomTextField(
            label: "Name",
            hint: "Name",
            icon: Icons.person,
            controller: nameController,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: CustomTextField(
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            label: "Mobile No.",
            hint: "Mobile no",
            icon: Icons.phone,
            controller: mobileController,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: CustomTextField(
            readOnly: true,
            label: "Sales Man",
            hint: "Sales Man",
            icon: Icons.groups_outlined,
            controller: staffNameController,
          ),
        ),
        if (invoiceController != null) ...[
          const SizedBox(width: 20),
          Expanded(
            child: CustomTextField(
              controller: invoiceController!,
              label: "Invoice No.",
              hint: "Invoice No.",
              icon: Icons.receipt_long_outlined,
              readOnly: true,
            ),
          ),
        ],
      ],
    );
  }
}
