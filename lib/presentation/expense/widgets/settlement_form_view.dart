import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:intl/intl.dart';
import 'package:sharp_cut/cubit/settlement/settlement_form_cubit.dart';
import 'package:sharp_cut/cubit/settlement/settlement_form_state.dart';
import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/injection_container.dart' as di;
import 'package:sharp_cut/presentation/expense/widgets/settlement_customer_section.dart';
import 'package:sharp_cut/presentation/expense/widgets/settlement_glass_container.dart';
import 'package:sharp_cut/presentation/expense/widgets/settlement_payment_modes_section.dart';
import 'package:sharp_cut/presentation/expense/widgets/settlement_text_fields.dart';
import 'package:sharp_cut/presentation/expense/widgets/settlement_time_container.dart';
import 'package:sharp_cut/presentation/expense/widgets/settlement_totals_section.dart';
import 'package:sharp_cut/utils/app_colors.dart';
import 'package:sharp_cut/utils/helpers/settlement_calculator.dart';
import 'package:sharp_cut/utils/helpers/toast_helper.dart';

class SettlementFormView extends StatefulWidget {
  final SettlePaymentRequestModel settlePayment;
  final CustomerModel? customer;
  final String? staffName;
  final String? bookingTime;
  final String? invoiceNumber;
  final String? paidAmount;
  final double? initialBalance;
  final double walletBalance;
  final bool isReSettlement;
  final void Function({
    required bool alsoPrint,
    required SettlePaymentRequestModel request,
    required double discount,
    required double cashAmount,
    required double cardAmount,
    required double walletAmount,
    required double tenderCash,
    required double change,
    required List<String> modes,
    required List<double> amounts,
    required List<double> tenders,
    required List<double> changes,
    required String customerName,
    required String customerNumber,
  }) onSettleSubmit;

  const SettlementFormView({
    super.key,
    required this.settlePayment,
    this.customer,
    required this.staffName,
    required this.bookingTime,
    this.invoiceNumber,
    this.paidAmount,
    this.initialBalance,
    required this.walletBalance,
    this.isReSettlement = false,
    required this.onSettleSubmit,
  });

  @override
  State<SettlementFormView> createState() => _SettlementFormViewState();
}

class _SettlementFormViewState extends State<SettlementFormView> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _staffNameController = TextEditingController();
  final TextEditingController _invoiceController = TextEditingController();

  final TextEditingController _amountController = TextEditingController(text: "");
  final TextEditingController _tenderCashController = TextEditingController(text: "");
  final TextEditingController _chargeController = TextEditingController(text: "");

  final TextEditingController _totalQtyController = TextEditingController(text: "0");
  final TextEditingController _subTotalController = TextEditingController(text: "0.00");
  final TextEditingController _discountController = TextEditingController(text: "");
  final TextEditingController _paidController = TextEditingController(text: "0.00");
  final TextEditingController _curPaymentController = TextEditingController(text: "0.00");
  final TextEditingController _balanceController = TextEditingController(text: "0.00");
  final TextEditingController _vatController = TextEditingController(text: "0.00");

  final TextEditingController _cashAmountController = TextEditingController(text: "");
  final TextEditingController _cardAmountController = TextEditingController(text: "");
  final TextEditingController _walletAmountController = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    _populateData();
  }

  void _populateData() {
    _mobileController.text = widget.settlePayment.customerNumber ?? '';
    _nameController.text = widget.settlePayment.customerName ?? '';
    _staffNameController.text = widget.staffName ?? "";
    _vatController.text = (widget.settlePayment.taxTotal ?? 0.0).toStringAsFixed(2);
    _invoiceController.text = widget.invoiceNumber ?? "";

    int totalQty = 0;
    if (widget.settlePayment.quantity != null) {
      for (var qty in widget.settlePayment.quantity!) {
        totalQty += qty;
      }
    }
    _totalQtyController.text = totalQty.toString();
    _subTotalController.text = (widget.settlePayment.subTotalValue ?? 0.0).toStringAsFixed(2);

    final double subTotal = widget.settlePayment.subTotalValue ?? 0.0;
    final double initialDiscount = (widget.settlePayment.discount != null && widget.settlePayment.discount! > 0)
        ? widget.settlePayment.discount!
        : widget.customer?.calculateDiscountAmount(subTotal) ?? 0.0;
    _discountController.text = initialDiscount == 0 ? "" : initialDiscount.toStringAsFixed(2);

    if (widget.isReSettlement) {
      _paidController.text = widget.paidAmount ?? "0.00";
      final double balanceVal = widget.initialBalance ?? 0.0;
      _amountController.text = balanceVal == 0 ? "" : balanceVal.toStringAsFixed(2);
      _cashAmountController.text = balanceVal == 0 ? "" : balanceVal.toStringAsFixed(2);
    } else {
      final double gross = subTotal + (widget.settlePayment.taxTotal ?? 0.0);
      final double net = gross - initialDiscount;
      final double finalVal = net < 0 ? 0.0 : net;
      _amountController.text = finalVal.toStringAsFixed(2);
      _cashAmountController.text = finalVal.toStringAsFixed(2);
    }

    _cardAmountController.text = "";
    _walletAmountController.text = "";
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _nameController.dispose();
    _staffNameController.dispose();
    _invoiceController.dispose();
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
    _walletAmountController.dispose();
    _vatController.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context, {required bool alsoPrint}) {
    final cubit = context.read<SettlementFormCubit>();
    final state = cubit.state;

    if (widget.isReSettlement && _nameController.text.isEmpty) {
      ToastHelper.showError("Please Enter Customer Name");
      return;
    }

    if (state.walletError != null) {
      ToastHelper.showError(state.walletError!);
      return;
    }

    if (state.overpayError != null) {
      ToastHelper.showError(state.overpayError!);
      return;
    }

    final double cashAmount = state.cashAmount;
    final double cardAmount = state.cardAmount;
    final double walletAmount = state.walletAmount;
    final double tenderCash = state.tenderCash;
    final double change = state.change;
    final double discount = state.discount;
    final double subTotal = widget.settlePayment.subTotalValue ?? 0.0;
    final double taxTotal = widget.settlePayment.taxTotal ?? 0.0;
    final double calculatedFinalTotal = state.grossTotal;

    List<String> modes = [];
    List<double> amounts = [];
    List<double> tenders = [];
    List<double> changes = [];

    if (widget.isReSettlement) {
      if (cashAmount != 0 || (state.splitPayment && state.isCashSelected)) {
        modes.add("Cash");
        amounts.add(cashAmount);
        tenders.add(tenderCash);
        changes.add(change);
      }
      if (cardAmount != 0 || (state.splitPayment && state.isCardSelected)) {
        modes.add("Card");
        amounts.add(cardAmount);
        tenders.add(cardAmount);
        changes.add(0.0);
      }
      if (walletAmount != 0 || (state.splitPayment && state.isWalletSelected)) {
        modes.add("Wallet");
        amounts.add(walletAmount);
        tenders.add(walletAmount);
        changes.add(0.0);
      }
    } else {
      if (cashAmount > 0 || (state.splitPayment && state.isCashSelected)) {
        modes.add("Cash");
        amounts.add(cashAmount);
        tenders.add(tenderCash);
        changes.add(change);
      }
      if (cardAmount > 0 || (state.splitPayment && state.isCardSelected)) {
        modes.add("Card");
        amounts.add(cardAmount);
        tenders.add(cardAmount);
        changes.add(0.0);
      }
      if (walletAmount > 0 || (state.splitPayment && state.isWalletSelected)) {
        modes.add("Wallet");
        amounts.add(walletAmount);
        tenders.add(walletAmount);
        changes.add(0.0);
      }
    }

    if (modes.isEmpty) {
      if (state.isCashSelected) {
        modes.add("Cash");
        amounts.add(0.0);
        tenders.add(0.0);
        changes.add(0.0);
      } else if (state.isCardSelected) {
        modes.add("Card");
        amounts.add(0.0);
        tenders.add(0.0);
        changes.add(0.0);
      } else {
        modes.add("Wallet");
        amounts.add(0.0);
        tenders.add(0.0);
        changes.add(0.0);
      }
    }

    final double effectivePaid = widget.isReSettlement ? (state.curPayment + state.paidAmount) : state.curPayment;
    final String paymentStatus = SettlementCalculator.determinePaymentStatus(
      totalPaid: effectivePaid,
      finalTotal: calculatedFinalTotal,
    );

    final request = widget.settlePayment.copyWith(
      paymentStatus: paymentStatus,
      customerName: _nameController.text,
      customerNumber: _mobileController.text,
      subTotalValue: subTotal,
      taxTotal: taxTotal,
      discount: discount,
      roundOff: 0.0,
      finalTotal: widget.isReSettlement ? (calculatedFinalTotal - discount) : calculatedFinalTotal,
      mode: modes,
      amount: amounts,
      tenderCash: tenders,
      change: changes,
    );

    widget.onSettleSubmit(
      alsoPrint: alsoPrint,
      request: request,
      discount: discount,
      cashAmount: cashAmount,
      cardAmount: cardAmount,
      walletAmount: walletAmount,
      tenderCash: tenderCash,
      change: change,
      modes: modes,
      amounts: amounts,
      tenders: tenders,
      changes: changes,
      customerName: _nameController.text,
      customerNumber: _mobileController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double subTotal = widget.settlePayment.subTotalValue ?? 0.0;
    final double taxTotal = widget.settlePayment.taxTotal ?? 0.0;
    final double paidAmount = double.tryParse(widget.paidAmount ?? "0.00") ?? 0.0;
    final double initialDiscount = (widget.settlePayment.discount != null && widget.settlePayment.discount! > 0)
        ? widget.settlePayment.discount!
        : widget.customer?.calculateDiscountAmount(subTotal) ?? 0.0;
    final double initialBalance = widget.initialBalance ?? 0.0;
    final double initialFinalTotal = widget.settlePayment.finalTotal ?? 0.0;

    return BlocProvider<SettlementFormCubit>(
      create: (context) => di.sl<SettlementFormCubit>()
        ..initForm(
          subTotal: subTotal,
          taxTotal: taxTotal,
          discount: initialDiscount,
          initialFinalTotal: initialFinalTotal,
          walletBalance: widget.walletBalance,
          isReSettlement: widget.isReSettlement,
          paidAmount: paidAmount,
          initialBalance: initialBalance,
        ),
      child: BlocListener<SettlementFormCubit, SettlementFormState>(
        listener: (context, state) {
          _curPaymentController.text = state.curPayment.toStringAsFixed(2);
          _balanceController.text = state.balance.toStringAsFixed(2);
          _chargeController.text = state.change.toStringAsFixed(2);
        },
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(15),
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
                          color: const Color(0xFF2A1A3A).withValues(alpha: 0.9),
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

                  // Content Layout
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SettlementTimeContainer(
                              label: "Time Starts",
                              time: widget.bookingTime ?? "--:--",
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

                        // Customer Details Section Widget
                        SettlementCustomerSection(
                          nameController: _nameController,
                          mobileController: _mobileController,
                          staffNameController: _staffNameController,
                          invoiceController: widget.invoiceNumber != null ? _invoiceController : null,
                        ),

                        const SizedBox(height: 8),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 8),

                        // Main Content: Payment Modes, Inputs, Totals
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Column 1: Payment Mode Cards
                              const Expanded(
                                flex: 1,
                                child: SettlementPaymentModesSection(),
                              ),
                              const SizedBox(width: 20),

                              // Column 2: Split Payment & Dynamic Inputs
                              Expanded(
                                flex: 3,
                                child: BlocBuilder<SettlementFormCubit, SettlementFormState>(
                                  builder: (context, state) {
                                    final cubit = context.read<SettlementFormCubit>();
                                    return SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          SettlementGlassContainer(
                                            padding: const EdgeInsets.all(12),
                                            child: Column(
                                              children: [
                                                Wrap(
                                                  alignment: WrapAlignment.spaceBetween,
                                                  crossAxisAlignment: WrapCrossAlignment.center,
                                                  children: [
                                                    Text(
                                                      "Total Cash: ${state.curPayment.toStringAsFixed(2)}",
                                                      style: GoogleFonts.rajdhani(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          "Split Payment",
                                                          style: GoogleFonts.rajdhani(color: Colors.white),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Switch(
                                                          value: state.splitPayment,
                                                          onChanged: (val) {
                                                            cubit.toggleSplitPayment(val);
                                                            if (!val) {
                                                              _amountController.text = (widget.settlePayment.finalTotal ?? 0.0).toStringAsFixed(2);
                                                            } else {
                                                              _cashAmountController.text = _amountController.text;
                                                              _cardAmountController.text = "";
                                                              _walletAmountController.text = "";
                                                            }
                                                          },
                                                          activeTrackColor: AppColors.violetNormal,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const Divider(color: Colors.white24),
                                                const SizedBox(height: 8),

                                                if (state.isCashSelected) ...[
                                                  SettlementLabelInput(
                                                    label: state.splitPayment ? "Cash Amount" : "Amount",
                                                    controller: state.splitPayment ? _cashAmountController : _amountController,
                                                    onChanged: (val) {
                                                      final double d = double.tryParse(val) ?? 0.0;
                                                      if (state.splitPayment) {
                                                        cubit.updateCashAmount(d);
                                                      } else {
                                                        _cashAmountController.text = val;
                                                        cubit.updateAmount(d);
                                                      }
                                                    },
                                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: SettlementLabelInput(
                                                          label: "Tender Cash",
                                                          controller: _tenderCashController,
                                                          onChanged: (val) {
                                                            final double d = double.tryParse(val) ?? 0.0;
                                                            cubit.updateTenderCash(d);
                                                          },
                                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: SettlementLabelInput(
                                                          label: "Change",
                                                          controller: _chargeController,
                                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                ],

                                                if (state.isCardSelected) ...[
                                                  SettlementLabelInput(
                                                    label: state.splitPayment ? "Card Amount" : "Amount",
                                                    controller: state.splitPayment ? _cardAmountController : _amountController,
                                                    onChanged: (val) {
                                                      final double d = double.tryParse(val) ?? 0.0;
                                                      if (state.splitPayment) {
                                                        cubit.updateCardAmount(d);
                                                      } else {
                                                        _cardAmountController.text = val;
                                                        cubit.updateAmount(d);
                                                      }
                                                    },
                                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                ],

                                                if (state.isWalletSelected) ...[
                                                  SettlementLabelInput(
                                                    label: state.splitPayment ? "Wallet Amount" : "Amount",
                                                    controller: state.splitPayment ? _walletAmountController : _amountController,
                                                    onChanged: (val) {
                                                      final double d = double.tryParse(val) ?? 0.0;
                                                      if (state.splitPayment) {
                                                        cubit.updateWalletAmount(d);
                                                      } else {
                                                        _walletAmountController.text = val;
                                                        cubit.updateAmount(d);
                                                      }
                                                    },
                                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 20),

                              // Column 3: Totals & Action Buttons
                              Expanded(
                                flex: 3,
                                child: Builder(
                                  builder: (ctx) => SettlementTotalsSection(
                                    totalQtyController: _totalQtyController,
                                    subTotalController: _subTotalController,
                                    discountController: _discountController,
                                    vatController: _vatController,
                                    paidController: _paidController,
                                    curPaymentController: _curPaymentController,
                                    balanceController: _balanceController,
                                    onSettleAndPrint: () => _onSubmit(ctx, alsoPrint: true),
                                    onSettle: () => _onSubmit(ctx, alsoPrint: false),
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
          ),
        ),
      ),
    );
  }
}
