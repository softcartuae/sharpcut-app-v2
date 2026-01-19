import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sharp_cut/utils/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/presentation/printing/cubit/printing_cubit.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:sharp_cut/presentation/printing/widgets/paper_width_selection_dialog.dart';
import 'package:sharp_cut/domain/printing/model/printer_paper_size.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class ScreenPrintingSettings extends StatefulWidget {
  const ScreenPrintingSettings({super.key});

  @override
  State<ScreenPrintingSettings> createState() => _ScreenPrintingSettingsState();
}

class _ScreenPrintingSettingsState extends State<ScreenPrintingSettings> {
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
          if (state.showPaperSizeDialog && state.connectedPrinter != null) {
            showDialog<PrinterPaperSize>(
              context: context,
              barrierDismissible: false,
              builder: (context) => const PaperWidthSelectionDialog(),
            ).then((size) {
              if (size != null && context.mounted) {
                context.read<PrintingCubit>().setPaperSize(
                  state.connectedPrinter!,
                  size,
                );
              }
            });
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
                                  value:
                                      state.settings?.openDrawer.cash ?? false,
                                  onChanged: (val) {
                                    final currentSettings = state.settings;
                                    if (currentSettings != null) {
                                      context
                                          .read<PrintingCubit>()
                                          .updatePrinterSettings(
                                            currentSettings.copyWith(
                                              openDrawer: currentSettings
                                                  .openDrawer
                                                  .copyWith(cash: val),
                                            ),
                                          );
                                    }
                                  },
                                ),
                                _buildSwitchTile(
                                  title: "Open Drawer (Card)",
                                  value:
                                      state.settings?.openDrawer.card ?? false,
                                  onChanged: (val) {
                                    final currentSettings = state.settings;
                                    if (currentSettings != null) {
                                      context
                                          .read<PrintingCubit>()
                                          .updatePrinterSettings(
                                            currentSettings.copyWith(
                                              openDrawer: currentSettings
                                                  .openDrawer
                                                  .copyWith(card: val),
                                            ),
                                          );
                                    }
                                  },
                                ),
                                if (state.connectedPrinter != null &&
                                    state.status == PrintingStatus.connected)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 8,
                                    ),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: () => context
                                            .read<PrintingCubit>()
                                            .testPrint(),
                                        icon: const Icon(
                                          Icons.print,
                                          color: AppColors.violetNormal,
                                        ),
                                        label: Text(
                                          "Test Print",
                                          style: GoogleFonts.rajdhani(
                                            color: AppColors.violetNormal,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: AppColors.violetNormal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Scan Button (USB)
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
                            onTap:
                                (state.status == PrintingStatus.scanning &&
                                    state.scanningType != ConnectionType.USB)
                                ? null
                                : () {
                                    if (state.status ==
                                        PrintingStatus.scanning) {
                                      context.read<PrintingCubit>().stopScan();
                                    } else {
                                      context.read<PrintingCubit>().startScan(
                                        type: ConnectionType.USB,
                                      );
                                    }
                                  },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (state.status == PrintingStatus.scanning &&
                                      state.scanningType == ConnectionType.USB)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.violetNormal,
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons.usb,
                                      color:
                                          (state.status ==
                                                  PrintingStatus.scanning &&
                                              state.scanningType !=
                                                  ConnectionType.USB)
                                          ? Colors.grey
                                          : AppColors.violetNormal,
                                    ),
                                  const SizedBox(width: 8),
                                  Text(
                                    state.status == PrintingStatus.scanning &&
                                            state.scanningType ==
                                                ConnectionType.USB
                                        ? "Stop Scanning"
                                        : "Scan for USB Printers",
                                    style: GoogleFonts.rajdhani(
                                      color:
                                          (state.status ==
                                                  PrintingStatus.scanning &&
                                              state.scanningType !=
                                                  ConnectionType.USB)
                                          ? Colors.grey
                                          : AppColors.violetNormal,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Scan Button (Bluetooth)
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
                            onTap:
                                (state.status == PrintingStatus.scanning &&
                                    state.scanningType != ConnectionType.BLE)
                                ? null
                                : () async {
                                    if (state.status ==
                                        PrintingStatus.scanning) {
                                      context.read<PrintingCubit>().stopScan();
                                    } else {
                                      bool granted =
                                          await _requestBluetoothPermissions();
                                      if (granted && context.mounted) {
                                        context.read<PrintingCubit>().startScan(
                                          type: ConnectionType.BLE,
                                        );
                                      }
                                    }
                                  },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (state.status == PrintingStatus.scanning &&
                                      state.scanningType == ConnectionType.BLE)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.violetNormal,
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons.bluetooth,
                                      color:
                                          (state.status ==
                                                  PrintingStatus.scanning &&
                                              state.scanningType !=
                                                  ConnectionType.BLE)
                                          ? Colors.grey
                                          : AppColors.violetNormal,
                                    ),
                                  const SizedBox(width: 8),
                                  Text(
                                    state.status == PrintingStatus.scanning &&
                                            state.scanningType ==
                                                ConnectionType.BLE
                                        ? "Stop Scanning"
                                        : "Scan for Bluetooth Printers",
                                    style: GoogleFonts.rajdhani(
                                      color:
                                          (state.status ==
                                                  PrintingStatus.scanning &&
                                              state.scanningType !=
                                                  ConnectionType.BLE)
                                          ? Colors.grey
                                          : AppColors.violetNormal,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Scan Button (Network)
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
                            onTap:
                                (state.status == PrintingStatus.scanning &&
                                    state.scanningType !=
                                        ConnectionType.NETWORK)
                                ? null
                                : () {
                                    if (state.status ==
                                        PrintingStatus.scanning) {
                                      context.read<PrintingCubit>().stopScan();
                                    } else {
                                      context.read<PrintingCubit>().startScan(
                                        type: ConnectionType.NETWORK,
                                      );
                                    }
                                  },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (state.status == PrintingStatus.scanning &&
                                      state.scanningType ==
                                          ConnectionType.NETWORK)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.violetNormal,
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons.wifi,
                                      color:
                                          (state.status ==
                                                  PrintingStatus.scanning &&
                                              state.scanningType !=
                                                  ConnectionType.NETWORK)
                                          ? Colors.grey
                                          : AppColors.violetNormal,
                                    ),
                                  const SizedBox(width: 8),
                                  Text(
                                    state.status == PrintingStatus.scanning &&
                                            state.scanningType ==
                                                ConnectionType.NETWORK
                                        ? "Stop Scanning"
                                        : "Scan for Network Printers",
                                    style: GoogleFonts.rajdhani(
                                      color:
                                          (state.status ==
                                                  PrintingStatus.scanning &&
                                              state.scanningType !=
                                                  ConnectionType.NETWORK)
                                          ? Colors.grey
                                          : AppColors.violetNormal,
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
                          "Discovered Printers",
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
                                    "No printers found.",
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
                                state.connectedPrinter!.name == printer.name &&
                                state.status == PrintingStatus.connected;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.print),
                                title: Text(printer.name ?? "Unknown Printer"),
                                subtitle: Text(
                                  "Connection Type: ${printer.connectionType == ConnectionType.BLE
                                      ? "Bluetooth"
                                      : printer.connectionType == ConnectionType.USB
                                      ? "Usb"
                                      : "Network"} | Product ID: ${printer.productId ?? ""}",
                                ),
                                trailing: isConnected
                                    ? (state.status ==
                                              PrintingStatus.disconnecting
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.red,
                                              ),
                                            )
                                          : TextButton.icon(
                                              onPressed: () {
                                                context
                                                    .read<PrintingCubit>()
                                                    .disconnect();
                                              },
                                              icon: const Icon(
                                                Icons.close,
                                                color: Colors.red,
                                              ),
                                              label: Text(
                                                "Disconnect",
                                                style: GoogleFonts.rajdhani(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ))
                                    : (state.status == PrintingStatus.connecting
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.violetNormal,
                                              ),
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
                                              child: Text(
                                                "Connect",
                                                style: GoogleFonts.rajdhani(
                                                  color:
                                                      AppColors.redLightActive,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            )),
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

  Future<bool> _requestBluetoothPermissions() async {
    if (!Platform.isAndroid) return true;

    // Check for Android 12+ permissions
    if (await Permission.bluetoothScan.status.isDenied ||
        await Permission.bluetoothConnect.status.isDenied) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();

      if (statuses[Permission.bluetoothScan]!.isDenied ||
          statuses[Permission.bluetoothConnect]!.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Bluetooth permissions are required to scan."),
            ),
          );
        }
        return false;
      }
    }

    // Check for Location permission (required for BLE on older Android)
    if (await Permission.location.status.isDenied) {
      final status = await Permission.location.request();
      if (status.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Location permission is required for Bluetooth scanning.",
              ),
            ),
          );
        }
        return false;
      }
    }

    // Check if Bluetooth is actually on (optional but good UX)
    // Note: permission_handler doesn't check if adapter is on, just permission.
    // flutter_thermal_printer might handle the adapter check or throw error if off.

    return true;
  }
}
