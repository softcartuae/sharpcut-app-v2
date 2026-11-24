import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/presentation/printing/cubit/printing_cubit.dart';
import 'package:sharp_cut/utils/app_colors.dart';

class DialogAddNetworkPrinter extends StatefulWidget {
  const DialogAddNetworkPrinter({super.key});

  @override
  State<DialogAddNetworkPrinter> createState() => _DialogAddNetworkPrinterState();
}

class _DialogAddNetworkPrinterState extends State<DialogAddNetworkPrinter> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: "Thermal Printer");
  final _ipController = TextEditingController();
  final _portController = TextEditingController(text: "9100");
  bool _isConnecting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _handleConnect() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isConnecting = true;
    });

    final name = _nameController.text.trim();
    final ip = _ipController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 9100;

    final success = await context.read<PrintingCubit>().connectManualNetworkPrinter(
          name: name,
          ipAddress: ip,
          port: port,
        );

    if (mounted) {
      setState(() {
        _isConnecting = false;
      });
      if (success) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              "Add Network Printer",
              style: GoogleFonts.rajdhani(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: _isConnecting ? null : () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Enter the local IP address and port of your thermal printer (default port is 9100).",
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Printer Name",
                  hintText: "e.g. Receipt Printer",
                  labelStyle: GoogleFonts.rajdhani(),
                  hintStyle: GoogleFonts.rajdhani(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.print, color: AppColors.violetNormal),
                ),
                style: GoogleFonts.rajdhani(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ipController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "IP Address",
                  hintText: "e.g. 192.168.1.100",
                  labelStyle: GoogleFonts.rajdhani(),
                  hintStyle: GoogleFonts.rajdhani(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.wifi, color: AppColors.violetNormal),
                ),
                style: GoogleFonts.rajdhani(),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Please enter IP address";
                  }
                  final trimmed = val.trim();
                  // Basic IPv4 format validation
                  final ipRegex = RegExp(
                    r'^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$',
                  );
                  if (!ipRegex.hasMatch(trimmed)) {
                    return "Please enter a valid IP address";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _portController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Port",
                  hintText: "9100",
                  labelStyle: GoogleFonts.rajdhani(),
                  hintStyle: GoogleFonts.rajdhani(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.settings_ethernet, color: AppColors.violetNormal),
                ),
                style: GoogleFonts.rajdhani(),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Please enter port";
                  }
                  final port = int.tryParse(val.trim());
                  if (port == null || port <= 0 || port > 65535) {
                    return "Valid port range: 1 - 65535";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isConnecting ? null : _handleConnect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.violetNormal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isConnecting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        "Connect Printer",
                        style: GoogleFonts.rajdhani(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

