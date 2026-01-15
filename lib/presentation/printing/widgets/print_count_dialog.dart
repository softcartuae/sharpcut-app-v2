import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/domain/printing/model/printer_settings_model.dart';
import 'package:sharp_cut/presentation/printing/cubit/printing_cubit.dart';
import 'package:sharp_cut/utils/app_colors.dart';

class PrintCountDialog extends StatefulWidget {
  const PrintCountDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PrintCountDialog(),
    );
  }

  @override
  State<PrintCountDialog> createState() => _PrintCountDialogState();
}

class _PrintCountDialogState extends State<PrintCountDialog> {
  final TextEditingController _quickPaymentController = TextEditingController();
  final TextEditingController _settlePaymentController =
      TextEditingController();
  final TextEditingController _reportController = TextEditingController();
  final TextEditingController _invoiceListController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<PrintingCubit>().state;
    _updateControllers(state.settings?.printCount);
  }

  @override
  void dispose() {
    _quickPaymentController.dispose();
    _settlePaymentController.dispose();
    _reportController.dispose();
    _invoiceListController.dispose();
    super.dispose();
  }

  void _updateControllers(PrintCount? printCount) {
    if (printCount != null) {
      _quickPaymentController.text = printCount.quickPayment.toInt().toString();
      _settlePaymentController.text = printCount.settlePayment
          .toInt()
          .toString();
      _reportController.text = printCount.report.toInt().toString();
      _invoiceListController.text = printCount.invoiceList.toInt().toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PrintingCubit, PrintingState>(
      listener: (context, state) {
        if (state.settings?.printCount != null && !state.isLoading) {
          _updateControllers(state.settings?.printCount);
        }
      },
      builder: (context, state) {
        return Dialog(
          backgroundColor: const Color(0xFF1E1E2C), // Dark background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 400, // Fixed width for better look on tablets/desktop
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Print Count',
                          style: GoogleFonts.rajdhani(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  if (state.isLoading && state.settings == null)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    // Fields
                    _buildCountField('Quick Payment', _quickPaymentController),
                    const SizedBox(height: 16),
                    _buildCountField(
                      'Settle payment',
                      _settlePaymentController,
                    ),
                    const SizedBox(height: 16),
                    _buildCountField('Report', _reportController),
                    const SizedBox(height: 16),
                    _buildCountField('Invoice List', _invoiceListController),

                    const SizedBox(height: 32),

                    // Save Button
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [AppColors.violetNormal, AppColors.redNormal],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: state.isLoading
                            ? null
                            : () {
                                final currentSettings = state.settings;
                                if (currentSettings == null) return;

                                final newPrintCount = PrintCount(
                                  quickPayment:
                                      int.tryParse(
                                        _quickPaymentController.text,
                                      ) ??
                                      1,
                                  settlePayment:
                                      int.tryParse(
                                        _settlePaymentController.text,
                                      ) ??
                                      1,
                                  report:
                                      int.tryParse(_reportController.text) ?? 1,
                                  invoiceList:
                                      int.tryParse(
                                        _invoiceListController.text,
                                      ) ??
                                      1,
                                );

                                final newSettings = currentSettings.copyWith(
                                  printCount: newPrintCount,
                                );

                                context
                                    .read<PrintingCubit>()
                                    .updatePrinterSettings(newSettings)
                                    .then((_) {
                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                      }
                                    });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: state.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Save',
                                style: GoogleFonts.rajdhani(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCountField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Label positioned on the border
              Positioned(
                left: 12,
                top: -10,
                child: Container(
                  color: const Color(0xFF1E1E2C), // Match dialog background
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    label,
                    style: GoogleFonts.rajdhani(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: controller,
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
