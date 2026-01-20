import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:intl/intl.dart';
import 'package:sharp_cut/cubit/auth/auth_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_cubit.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/presentation/expense/widgets/payment_mode_card.dart';
import 'package:sharp_cut/presentation/expense/widgets/settlement_glass_container.dart';
import 'package:sharp_cut/presentation/expense/widgets/settlement_text_fields.dart';
import 'package:sharp_cut/presentation/expense/widgets/settlement_time_container.dart';
import 'package:sharp_cut/presentation/home/widgets/custom_text_field.dart';
import 'package:sharp_cut/domain/home/models/cart_item_model.dart';
import 'package:sharp_cut/presentation/printing/cubit/printing_cubit.dart';
import 'package:sharp_cut/utils/app_colors.dart';
import 'package:sharp_cut/utils/helpers/icon_helper.dart';
import 'package:sharp_cut/utils/helpers/toast_helper.dart';

Future<void> showSettlementDialog(
  BuildContext context, {
  required SettlePaymentRequestModel settlePayment,
  required String? staffName,
  required String? bookingTime,
  required String? invoiceNumber,
  required String? invoiceDate,
  required List<CartItemModel> cartItems,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) => SettlementDialog(
      invoiceDate: invoiceDate,
      invoiceNumber: invoiceNumber,
      settlePayment: settlePayment,
      staffName: staffName,
      bookingTime: bookingTime,
      cartItems: cartItems,
    ),
  );
}

class SettlementDialog extends StatefulWidget {
  final SettlePaymentRequestModel settlePayment;
  final String? staffName;
  final String? bookingTime;
  final String? invoiceNumber;
  final List<CartItemModel> cartItems;
  final String? invoiceDate;
  const SettlementDialog({
    super.key,
    required this.settlePayment,
    required this.staffName,
    required this.bookingTime,
    required this.invoiceNumber,
    required this.cartItems,
    required this.invoiceDate,
  });

  @override
  State<SettlementDialog> createState() => _SettlementDialogState();
}

class _SettlementDialogState extends State<SettlementDialog> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _trnController = TextEditingController();
  final TextEditingController _staffNameController = TextEditingController();

  // Payment Section Controllers
  final TextEditingController _amountController = TextEditingController(
    text: "",
  );
  final TextEditingController _tenderCashController = TextEditingController(
    text: "",
  );
  final TextEditingController _chargeController = TextEditingController(
    text: "",
  );

  // Totals Section Controllers
  final TextEditingController _totalQtyController = TextEditingController(
    text: "",
  );
  final TextEditingController _subTotalController = TextEditingController(
    text: "0.00",
  );
  final TextEditingController _discountController = TextEditingController(
    text: "",
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

  final TextEditingController _vatController = TextEditingController(
    text: "0.00",
  );

  final TextEditingController _invoiceController = TextEditingController(
    text: "0.00",
  );

  // Split Payment Controllers
  final TextEditingController _cashAmountController = TextEditingController(
    text: "",
  );
  final TextEditingController _cardAmountController = TextEditingController(
    text: "",
  );

  bool _splitPayment = false;
  // Track selected modes. If split is off, only one is true.
  bool _isCashSelected = true;
  bool _isCardSelected = false;

  double _finalTotal = 0.0;
  double _uiGrandTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _populateData();
  }

  void _populateData() {
    _mobileController.text = widget.settlePayment.customerNumber ?? '';
    _nameController.text = widget.settlePayment.customerName ?? '';
    _staffNameController.text = widget.staffName ?? "";
    _vatController.text = (widget.settlePayment.taxTotal ?? 0.0)
        .toStringAsFixed(2);
    _invoiceController.text = widget.invoiceNumber ?? "";
    // Calculate total quantity
    int totalQty = 0;
    if (widget.settlePayment.quantity != null) {
      for (var qty in widget.settlePayment.quantity!) {
        totalQty += qty;
      }
    }
    _totalQtyController.text = totalQty.toString();

    _subTotalController.text = (widget.settlePayment.subTotalValue ?? 0.0)
        .toStringAsFixed(2);

    _discountController.text =
        widget.settlePayment.discount == null ||
            widget.settlePayment.discount == 0
        ? ''
        : widget.settlePayment.discount!.toStringAsFixed(2);

    // Amount to pay is usually the final total
    _amountController.text = (widget.settlePayment.finalTotal ?? 0.0)
        .toStringAsFixed(2);

    // Initialize split controllers
    _cashAmountController.text = (widget.settlePayment.finalTotal ?? 0.0)
        .toStringAsFixed(2);
    _cardAmountController.text = "";

    // Grand total display at the bottom usually matches final total
    _calculateFinalTotal();
  }

  void _calculateFinalTotal() {
    final double subTotal = widget.settlePayment.subTotalValue ?? 0.0;
    final double taxTotal = widget.settlePayment.taxTotal ?? 0.0;

    // User requested: "like minus from grand total" for both discount and round off.
    // Final = SubTotal + Tax
    setState(() {
      _finalTotal = (subTotal + taxTotal);
      final double discount = double.tryParse(_discountController.text) ?? 0.0;
      _uiGrandTotal = _finalTotal - discount;
      _calculatePaymentAndBalance();
      _calculateChange();
    });
  }

  void _calculatePaymentAndBalance() {
    double cashAmount = 0.0;
    double cardAmount = 0.0;

    if (_splitPayment) {
      if (_isCashSelected) {
        cashAmount = double.tryParse(_cashAmountController.text) ?? 0.0;
      }
      if (_isCardSelected) {
        cardAmount = double.tryParse(_cardAmountController.text) ?? 0.0;
      }
    } else {
      final double amount = double.tryParse(_amountController.text) ?? 0.0;
      if (_isCashSelected) {
        cashAmount = amount;
      } else {
        cardAmount = amount;
      }
    }

    final double curPayment = cashAmount + cardAmount;
    final double discount = double.tryParse(_discountController.text) ?? 0.0;
    final double balance = _finalTotal - curPayment - discount;

    _curPaymentController.text = curPayment.toStringAsFixed(2);
    _balanceController.text = balance.toStringAsFixed(2);
  }

  void _calculateChange() {
    double tender = double.tryParse(_tenderCashController.text) ?? 0.0;
    double amount = 0.0;
    if (_splitPayment) {
      amount = double.tryParse(_cashAmountController.text) ?? 0.0;
    } else {
      amount = double.tryParse(_amountController.text) ?? 0.0;
    }

    double change = tender - amount;
    if (change < 0) change = 0;
    _chargeController.text = change.toStringAsFixed(2);
  }

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
    _paidController.dispose();
    _curPaymentController.dispose();
    _balanceController.dispose();
    _cashAmountController.dispose();
    _cardAmountController.dispose();
    super.dispose();
  }

  void _onSettle({required bool alsoPrint}) {
    final double discount = double.tryParse(_discountController.text) ?? 0.0;

    final double subTotal = widget.settlePayment.subTotalValue ?? 0.0;
    final double taxTotal = widget.settlePayment.taxTotal ?? 0.0;

    final double calculatedFinalTotal = _finalTotal;

    // Get amounts based on selection
    double cashAmount = 0.0;
    double cardAmount = 0.0;

    if (_splitPayment) {
      if (_isCashSelected) {
        cashAmount = double.tryParse(_cashAmountController.text) ?? 0.0;
      }
      if (_isCardSelected) {
        cardAmount = double.tryParse(_cardAmountController.text) ?? 0.0;
      }
    } else {
      final double amount = double.tryParse(_amountController.text) ?? 0.0;
      if (_isCashSelected) {
        cashAmount = amount;
      } else {
        cardAmount = amount;
      }
    }

    final double totalPaid = cashAmount + cardAmount;
    log("cash amount $cashAmount and cardamount $cardAmount");

    final paid = round2(totalPaid);
    final finalTotal = round2(calculatedFinalTotal);

    log("paid $paid and finalTotal $finalTotal");

    if (paid > finalTotal) {
      ToastHelper.showError("Total amount cannot be greater than Final Total");
      return;
    }

    if (_nameController.text.isEmpty) {
      ToastHelper.showError("Please Enter Customer Name");
      return;
    }
    // Also check if totalPaid is 0? Maybe allow 0 for partial?
    // User said "settlement is like can be partially gaven".
    // So < finalTotal is allowed. > finalTotal is NOT allowed.

    final double tenderCash =
        double.tryParse(_tenderCashController.text) ?? 0.0;
    final double change = double.tryParse(_chargeController.text) ?? 0.0;

    // Construct lists
    List<String> modes = [];
    List<double> amounts = [];
    List<double> tenders = [];
    List<double> changes = [];

    if (cashAmount > 0 || (_splitPayment && _isCashSelected)) {
      modes.add("Cash");
      amounts.add(cashAmount);
      tenders.add(tenderCash);
      changes.add(change);
    }

    if (cardAmount > 0 || (_splitPayment && _isCardSelected)) {
      modes.add("Card");
      amounts.add(cardAmount);
      // For card, tender is usually same as amount, change is 0
      tenders.add(cardAmount);
      changes.add(0.0);
    }

    // If nothing selected/entered but we need to send something?
    // If totalPaid is 0, maybe we still send the modes with 0?
    if (modes.isEmpty) {
      // Fallback to selected mode with 0
      if (_isCashSelected) {
        modes.add("Cash");
        amounts.add(0.0);
        tenders.add(0.0);
        changes.add(0.0);
      } else {
        modes.add("Card");
        amounts.add(0.0);
        tenders.add(0.0);
        changes.add(0.0);
      }
    }

    log("tax: $taxTotal");
    log("subtotal: $subTotal");
    log("discount : $discount");
    log("finalTotal : $finalTotal");

    final request = SettlePaymentRequestModel(
      paymentStatus: totalPaid == 0 ? "unpaid" : null,
      transactionId: widget.settlePayment.transactionId,
      customerName: _nameController.text,
      customerNumber: _mobileController.text,
      subTotalValue: subTotal,
      taxTotal: taxTotal,
      discount: discount,
      roundOff: 0,
      finalTotal: finalTotal,
      serviceId: widget.settlePayment.serviceId,
      quantity: widget.settlePayment.quantity,
      rate: widget.settlePayment.rate,
      taxAmount: widget.settlePayment.taxAmount,
      currency: widget.settlePayment.currency,
      amountTotal: widget.settlePayment.amountTotal,
      tax: widget.settlePayment.tax,
      subTotalList: widget.settlePayment.subTotalList,
      isTip: widget.settlePayment.isTip,
      collectedUserId:
          widget.settlePayment.collectedUserId != null &&
              widget.settlePayment.collectedUserId!.isNotEmpty
          ? List.filled(
              modes.length,
              widget.settlePayment.collectedUserId!.first,
            )
          : [],
      mode: modes,
      amount: amounts,
      tenderCash: tenders,
      change: changes,
    );

    if (alsoPrint) {
      final shopData = context.read<AuthCubit>().currentUser;
      if (shopData != null) {
        final printCubit = context.read<PrintingCubit>();
        printCubit.printInvoice(
          printCount: printCubit.state.settings?.printCount.settlePayment
              .toInt(),
          balanceAmount: double.tryParse(_balanceController.text) ?? 0.0,
          request: request,
          shopData: shopData,
          cartItems: widget.cartItems,
          staffName: widget.staffName,
          invoiceNumber: widget.invoiceNumber,
          bookingTime: widget.bookingTime != null
              ? DateFormat('HH:mm').format(DateTime.parse(widget.bookingTime!))
              : "--:--",
          invoiceDate: widget.invoiceDate,
        );
      }
      context.read<BookingCubit>().settlePayment(request: request);
    } else {
      context.read<BookingCubit>().settlePayment(request: request);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
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
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SettlementTimeContainer(
                          label: "Time Starts",
                          time: widget.bookingTime != null
                              ? DateFormat(
                                  'HH:mm',
                                ).format(DateTime.parse(widget.bookingTime!))
                              : "--:--",
                        ),
                        const Spacer(),
                        SettlementTimeContainer(
                          label: "Elapse Time",
                          time: DateFormat('HH:mm').format(DateTime.now()),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Customer Details Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            label: "Mobile No.",
                            hint: "Mobile no",
                            icon: Icons.phone,
                            controller: _mobileController,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: CustomTextField(
                            readOnly: true,
                            label: "Sales Man",
                            hint: "Sales Man",
                            icon: Icons.groups_outlined,
                            controller: _staffNameController,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: CustomTextField(
                            controller: _invoiceController,
                            label: "Invoice No.",
                            hint: "Invoice No.",
                            icon: Icons.receipt_long_outlined,
                            readOnly: true,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 10),

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
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (_splitPayment) {
                                          // If trying to deselect Cash, check if Card is selected
                                          if (_isCashSelected &&
                                              !_isCardSelected) {
                                            return; // Don't allow deselecting the last one
                                          }
                                          _isCashSelected = !_isCashSelected;
                                        } else {
                                          _isCashSelected = true;
                                          _isCardSelected = false;
                                        }
                                        _calculatePaymentAndBalance();
                                        _calculateChange();
                                      });
                                    },
                                    child: PaymentModeCard(
                                      title:
                                          "Cash (${_cashAmountController.text})",
                                      amount: _cashAmountController.text,
                                      color1: _isCashSelected
                                          ? AppColors.violetNormal
                                          : Colors.white10,
                                      color2: _isCashSelected
                                          ? AppColors.redNormal
                                          : Colors.transparent,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // Credit Card
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (_splitPayment) {
                                          // If trying to deselect Card, check if Cash is selected
                                          if (_isCardSelected &&
                                              !_isCashSelected) {
                                            return; // Don't allow deselecting the last one
                                          }
                                          _isCardSelected = !_isCardSelected;
                                        } else {
                                          _isCardSelected = true;
                                          _isCashSelected = false;
                                        }
                                        _calculatePaymentAndBalance();
                                        _calculateChange();
                                      });
                                    },
                                    child: PaymentModeCard(
                                      title:
                                          "Credit Card(${_cardAmountController.text})",
                                      amount: _cardAmountController.text,
                                      color1: _isCardSelected
                                          ? AppColors.violetNormal
                                          : Colors.white10,
                                      color2: _isCardSelected
                                          ? AppColors.redNormal
                                          : Colors.transparent,
                                    ),
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
                                              "Total Cash: ${_curPaymentController.text}",
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
                                                  onChanged: (val) => setState(() {
                                                    _splitPayment = val;
                                                    // Reset selections when toggling split
                                                    if (!_splitPayment) {
                                                      _isCashSelected = true;
                                                      _isCardSelected = false;
                                                      // Reset amounts?
                                                      _amountController.text =
                                                          (widget
                                                                      .settlePayment
                                                                      .finalTotal ??
                                                                  0.0)
                                                              .toStringAsFixed(
                                                                2,
                                                              );
                                                    } else {
                                                      // If turning on split, maybe select both?
                                                      // Or keep current selection.
                                                      // Let's default to Cash selected, Card unselected but available.
                                                      // Initialize controllers
                                                      _cashAmountController
                                                              .text =
                                                          _amountController
                                                              .text;
                                                      _cardAmountController
                                                              .text =
                                                          "0.00";
                                                    }
                                                    _calculatePaymentAndBalance();
                                                    _calculateChange();
                                                  }),
                                                  activeColor:
                                                      AppColors.violetNormal,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const Divider(color: Colors.white24),
                                        const SizedBox(height: 8),

                                        // Dynamic Inputs based on selection
                                        if (_isCashSelected) ...[
                                          SettlementLabelInput(
                                            label: _splitPayment
                                                ? "Cash Amount"
                                                : "Amount",
                                            controller: _splitPayment
                                                ? _cashAmountController
                                                : _amountController,
                                            onChanged: (val) {
                                              // If split is off, sync _amountController to _cashAmountController for display?
                                              // Actually, if split is off, we use _amountController in _onSettle.
                                              // But for consistent display in the card, we might want to update it.
                                              setState(() {
                                                if (!_splitPayment) {
                                                  _cashAmountController.text =
                                                      val;
                                                }
                                                _calculatePaymentAndBalance();
                                                _calculateChange();
                                              });
                                            },
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d{0,2}'),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: SettlementLabelInput(
                                                  label: "Tender Cash",
                                                  controller:
                                                      _tenderCashController,
                                                  onChanged: (val) =>
                                                      _calculateChange(),
                                                  keyboardType:
                                                      const TextInputType.numberWithOptions(
                                                        decimal: true,
                                                      ),
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter.allow(
                                                      RegExp(r'^\d*\.?\d{0,2}'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: SettlementLabelInput(
                                                  label: "Change",
                                                  controller: _chargeController,
                                                  keyboardType:
                                                      const TextInputType.numberWithOptions(
                                                        decimal: true,
                                                      ),
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter.allow(
                                                      RegExp(r'^\d*\.?\d{0,2}'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                        ],

                                        if (_isCardSelected) ...[
                                          SettlementLabelInput(
                                            label: _splitPayment
                                                ? "Card Amount"
                                                : "Amount",
                                            controller: _splitPayment
                                                ? _cardAmountController
                                                : _amountController,
                                            onChanged: (val) {
                                              setState(() {
                                                if (!_splitPayment) {
                                                  _cardAmountController.text =
                                                      val;
                                                }
                                                _calculatePaymentAndBalance();
                                              });
                                            },
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d{0,2}'),
                                              ),
                                            ],
                                          ),
                                        ],
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
                                      isReadOnly: true,
                                    ),
                                    const SizedBox(height: 10),
                                    SettlementRowInput(
                                      label: "Sub Total",
                                      controller: _subTotalController,
                                      isReadOnly: true,
                                    ),
                                    const SizedBox(height: 10),
                                    SettlementRowInput(
                                      label: "P. Discount",
                                      controller: _discountController,
                                      onChanged: (val) =>
                                          _calculateFinalTotal(),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+\.?\d{0,2}'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    SettlementRowInput(
                                      label: "VAT",
                                      controller: _vatController,
                                      isReadOnly: true,
                                    ),
                                    const SizedBox(height: 10),
                                    SettlementRowInput(
                                      isReadOnly: true,
                                      label: "Paid",
                                      controller: _paidController,
                                    ),
                                    const SizedBox(height: 15),

                                    // Grand Total
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 2,
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
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            _uiGrandTotal.toStringAsFixed(2),
                                            style: GoogleFonts.rajdhani(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
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
                                                controller:
                                                    _curPaymentController,
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
                              child: SingleChildScrollView(
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
                                    Container(
                                      // Placeholder for list
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
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () => _onSettle(alsoPrint: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.violetNormal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            "SETTLE & PRINT",
                            style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () => _onSettle(alsoPrint: false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.violetNormal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            "SETTLE",
                            style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
    );
  }
}
