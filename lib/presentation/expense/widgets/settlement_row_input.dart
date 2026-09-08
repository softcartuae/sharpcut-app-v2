import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/presentation/expense/widgets/settlement_simple_input.dart';

class SettlementRowInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isReadOnly;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const SettlementRowInput({
    super.key,
    required this.label,
    required this.controller,
    this.isReadOnly = false,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 14),
          ),
        ),
        Expanded(
          flex: 3,
          child: SettlementSimpleInput(
            controller: controller,
            isReadOnly: isReadOnly,
            onChanged: onChanged,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
          ),
        ),
      ],
    );
  }
}
