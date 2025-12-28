import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sharp_cut/utils/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/data/printing/printing_repo_imp.dart';
import 'package:sharp_cut/presentation/printing/cubit/printing_cubit.dart';

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
    return BlocProvider(
      create: (context) => PrintingCubit(PrintingRepoImp()),
      child: Scaffold(
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
        body: BlocConsumer<PrintingCubit, PrintingState>(
          listener: (context, state) {
            if (state.status == PrintingStatus.error &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
            if (state.status == PrintingStatus.connected) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Connected to ${state.connectedPrinter?.name}"),
                ),
              );
            }
          },
          builder: (context, state) {
            return LayoutBuilder(
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
                                if (state.status == PrintingStatus.scanning) {
                                  context.read<PrintingCubit>().stopScan();
                                } else {
                                  context.read<PrintingCubit>().startScan();
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (state.status == PrintingStatus.scanning)
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.violetNormal,
                                        ),
                                      )
                                    else
                                      const Icon(
                                        Icons.refresh,
                                        color: AppColors.violetNormal,
                                      ),
                                    const SizedBox(width: 8),
                                    Text(
                                      state.status == PrintingStatus.scanning
                                          ? "Stop Scanning"
                                          : "Scan for USB Printers",
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

                          // Printers List
                          if (state.printers.isEmpty &&
                              state.status != PrintingStatus.scanning)
                            Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Center(
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
                            )
                          else
                            ...state.printers.map((printer) {
                              final isConnected =
                                  state.connectedPrinter != null &&
                                  state.connectedPrinter!.name == printer.name;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: const Icon(Icons.print),
                                  title: Text(
                                    printer.name ?? "Unknown Printer",
                                  ),
                                  subtitle: Text(
                                    "Vendor ID: ${printer.vendorId} | Product ID: ${printer.productId}",
                                  ),
                                  trailing: isConnected
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        )
                                      : ElevatedButton(
                                          onPressed: () {
                                            context
                                                .read<PrintingCubit>()
                                                .connect(printer);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.violetNormal,
                                          ),
                                          child: const Text("Connect"),
                                        ),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
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
