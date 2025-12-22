import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/presentation/printing/widgets/print_count_dialog.dart';
import 'package:sharp_cut/utils/app_colors.dart';

class ScreenPrintingSettings extends StatefulWidget {
  const ScreenPrintingSettings({super.key});

  @override
  State<ScreenPrintingSettings> createState() => _ScreenPrintingSettingsState();
}

class _ScreenPrintingSettingsState extends State<ScreenPrintingSettings> {
  bool _openDrawerCash = true;
  bool _openDrawerCard = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Printer Settings",
          style: GoogleFonts.rajdhani(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine if we are on a wider screen (tablet)
          bool isTablet = constraints.maxWidth > 600;
          double contentWidth = isTablet ? 600 : constraints.maxWidth;

          return Center(
            child: SizedBox(
              width: contentWidth,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Drawer Settings Card
                    Card(
                      color: AppColors.violetLight,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            _buildSwitchTile(
                              title: "Open Drawer (Cash)",
                              value: _openDrawerCash,
                              onChanged: (val) =>
                                  setState(() => _openDrawerCash = val),
                            ),
                            _buildSwitchTile(
                              title: "Open Drawer (Card)",
                              value: _openDrawerCard,
                              onChanged: (val) =>
                                  setState(() => _openDrawerCard = val),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Scan Button
                    Card(
                      color: AppColors.violetLight,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(
                          color: AppColors.violetLightActive,
                        ),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        onTap: () {
                          PrintCountDialog.show(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.refresh,
                                color: AppColors.violetNormal,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Scan for USB Printers",
                                style: GoogleFonts.rajdhani(
                                  color: AppColors.violetNormal,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Discovered Printers Header
                    Text(
                      "Discovered USB Printers",
                      style: GoogleFonts.rajdhani(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Divider(height: 24, thickness: 1),

                    // Empty State
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "No USB printers found.",
                            style: GoogleFonts.rajdhani(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Please connect a printer and press scan.",
                            style: GoogleFonts.rajdhani(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: GoogleFonts.rajdhani(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.white,
      activeTrackColor: AppColors.violetNormal,
      inactiveThumbColor: Colors.grey,
      inactiveTrackColor: Colors.grey.shade300,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
