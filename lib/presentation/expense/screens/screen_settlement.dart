import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:intl/intl.dart';
import 'package:sharp_cut/presentation/expense/widgets/payment_mode_card.dart';
import 'package:sharp_cut/presentation/expense/widgets/settlement_glass_container.dart';
import 'package:sharp_cut/presentation/expense/widgets/settlement_text_fields.dart';
import 'package:sharp_cut/presentation/expense/widgets/settlement_time_container.dart';
import 'package:sharp_cut/presentation/home/widgets/custom_text_field.dart';
import 'package:sharp_cut/utils/app_colors.dart';

Future<void> showSettlementDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) => const SettlementDialog(),
  );
}

class SettlementDialog extends StatefulWidget {
  const SettlementDialog({super.key});

  @override
  State<SettlementDialog> createState() => _SettlementDialogState();
}

class _SettlementDialogState extends State<SettlementDialog> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _trnController = TextEditingController();

  // Payment Section Controllers
  final TextEditingController _amountController = TextEditingController(
    text: "0.00",
  );
  final TextEditingController _tenderCashController = TextEditingController(
    text: "0.00",
  );
  final TextEditingController _chargeController = TextEditingController(
    text: "0.00",
  );

  // Totals Section Controllers
  final TextEditingController _totalQtyController = TextEditingController(
    text: "0.00",
  );
  final TextEditingController _subTotalController = TextEditingController(
    text: "0.00",
  );
  final TextEditingController _discountController = TextEditingController(
    text: "0.00",
  );
  final TextEditingController _roundOffController = TextEditingController(
    text: "0.00",
  );
  final TextEditingController _vatController = TextEditingController(
    text: "0.00",
  );
  final TextEditingController _paidController = TextEditingController(
    text: "0.00",
  );
  final TextEditingController _curPaymentController = TextEditingController(
    text: "0.00",
  );
  final TextEditingController _balanceController = TextEditingController(
    text: "0.00",
  );

  DateTime _selectedDate = DateTime.now();
  bool _splitPayment = false;

  @override
  void dispose() {
    _mobileController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _trnController.dispose();
    _amountController.dispose();
    _tenderCashController.dispose();
    _chargeController.dispose();
    _totalQtyController.dispose();
    _subTotalController.dispose();
    _discountController.dispose();
    _roundOffController.dispose();
    _vatController.dispose();
    _paidController.dispose();
    _curPaymentController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.violetNormal,
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
            // ignore: deprecated_member_use
            dialogBackgroundColor: const Color(0xFF1E1E1E),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Stack(
          children: [
            // Glassmorphism Background
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF2A1A3A,
                    ).withValues(alpha: 0.9), // Darker background
                    borderRadius: BorderRadius.circular(20),
                    border: const GradientBoxBorder(
                      gradient: LinearGradient(
                        colors: [Colors.white24, Colors.white10],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SettlementTimeContainer(
                        label: "Time Starts",
                        time: "10:15",
                      ),
                      const Spacer(),
                      const SettlementTimeContainer(
                        label: "Elapse Time",
                        time: "12:15",
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Customer Details Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: "Mobile No.",
                          hint: "Mobile no",
                          icon: Icons.grid_view,
                          controller: _mobileController,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: CustomTextField(
                          label: "Name",
                          hint: "Name",
                          icon: Icons.person,
                          controller: _nameController,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: CustomTextField(
                          label: "Customer Address",
                          hint: "Customer Address",
                          icon: Icons.home,
                          controller: _addressController,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: CustomTextField(
                          label: "TRN (VAT- TIN)",
                          hint: "TRN(VAT-TIN)",
                          icon: Icons.card_membership,
                          controller: _trnController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Date Row
                  Row(
                    children: [
                      SizedBox(
                        width:
                            MediaQuery.of(context).size.width *
                            0.22, // Match approx width of expanded above
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Bill Date",
                              style: GoogleFonts.rajdhani(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: Container(
                                    height: 48,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: const GradientBoxBorder(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.violetLight,
                                            AppColors.violetDark,
                                          ],
                                        ),
                                        width: .5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(_selectedDate),
                                          style: GoogleFonts.rajdhani(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 20),

                  // Main Content: 3 Columns
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 1,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // Cash Card
                                const PaymentModeCard(
                                  title: "Cash (0.00)",
                                  amount: "0.00",
                                  color1: AppColors.violetNormal,
                                  color2: AppColors.redNormal,
                                ),
                                const SizedBox(height: 10),
                                // Credit Card
                                const PaymentModeCard(
                                  title: "Credit Card(0.00)",
                                  amount: "0.00",
                                  color1: Colors.white10,
                                  color2: Colors.transparent,
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Column 1: Payment Modes
                        Expanded(
                          flex: 3,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // Split Payment & Inputs
                                SettlementGlassContainer(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Wrap(
                                        alignment: WrapAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          Text(
                                            "Total Cash: 0.00",
                                            style: GoogleFonts.rajdhani(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "Split Payment",
                                                style: GoogleFonts.rajdhani(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Switch(
                                                value: _splitPayment,
                                                onChanged: (val) => setState(
                                                  () => _splitPayment = val,
                                                ),
                                                activeColor:
                                                    AppColors.violetNormal,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Divider(color: Colors.white24),
                                      const SizedBox(height: 10),
                                      SettlementLabelInput(
                                        label: "Amount",
                                        controller: _amountController,
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: SettlementLabelInput(
                                              label: "Tender Cash",
                                              controller: _tenderCashController,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: SettlementLabelInput(
                                              label: "Charge",
                                              controller: _chargeController,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Column 2: Totals & Calculations
                        Expanded(
                          flex: 3,
                          child: SettlementGlassContainer(
                            padding: const EdgeInsets.all(16),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  SettlementRowInput(
                                    label: "Total Qty",
                                    controller: _totalQtyController,
                                  ),
                                  const SizedBox(height: 10),
                                  SettlementRowInput(
                                    label: "Sub Total",
                                    controller: _subTotalController,
                                  ),
                                  const SizedBox(height: 10),
                                  SettlementRowInput(
                                    label: "P. Discount",
                                    controller: _discountController,
                                  ),
                                  const SizedBox(height: 10),
                                  SettlementRowInput(
                                    label: "Round Off",
                                    controller: _roundOffController,
                                  ),
                                  const SizedBox(height: 10),
                                  SettlementRowInput(
                                    label: "VAT",
                                    controller: _vatController,
                                  ),
                                  const SizedBox(height: 10),
                                  SettlementRowInput(
                                    label: "Paid",
                                    controller: _paidController,
                                  ),
                                  const SizedBox(height: 20),

                                  // Grand Total
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.violetNormal,
                                          AppColors.redNormal,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Grand Total",
                                          style: GoogleFonts.rajdhani(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "0.00",
                                          style: GoogleFonts.rajdhani(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Cur. Payment",
                                              style: GoogleFonts.rajdhani(
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            SettlementSimpleInput(
                                              controller: _curPaymentController,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Balance",
                                              style: GoogleFonts.rajdhani(
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            SettlementSimpleInput(
                                              controller: _balanceController,
                                              isReadOnly: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Column 3: Payment History
                        Expanded(
                          flex: 3,
                          child: SettlementGlassContainer(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  "Payment History",
                                  style: GoogleFonts.rajdhani(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Expanded(
                                  child: Container(
                                    // Placeholder for list
                                  ),
                                ),
                                const Divider(color: Colors.white24),
                                const SizedBox(height: 10),
                                Text(
                                  "History Of Invoice",
                                  style: GoogleFonts.rajdhani(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
