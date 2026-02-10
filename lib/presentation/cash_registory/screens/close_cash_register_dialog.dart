import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/cubit/auth/auth_cubit.dart';
import 'package:sharp_cut/cubit/cash_registory/cash_registory_cubit.dart';
import 'package:sharp_cut/cubit/cash_registory/cash_registory_state.dart';
import 'package:sharp_cut/domain/auth/models/shop_model.dart';
import 'package:sharp_cut/domain/cash_registory/models/close_register_model.dart';
import 'package:sharp_cut/presentation/home/widgets/action_button.dart';
import 'package:sharp_cut/presentation/printing/cubit/printing_cubit.dart';
import 'package:sharp_cut/utils/helpers/toast_helper.dart';
import 'package:sharp_cut/cubit/home/chair_cubit.dart';
import 'package:sharp_cut/domain/home/models/staff_model.dart';
import 'package:sharp_cut/utils/helpers/check_no_chair.dart';

class CloseCashRegisterDialog extends StatefulWidget {
  const CloseCashRegisterDialog({
    super.key,
    required this.closeRegisterDetails,
  });
  final CloseRegisterModel closeRegisterDetails;

  static void show(
    BuildContext context,
    CloseRegisterModel? closeRegisterDetails,
  ) {
    if (closeRegisterDetails == null) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          CloseCashRegisterDialog(closeRegisterDetails: closeRegisterDetails),
    );
  }

  @override
  State<CloseCashRegisterDialog> createState() =>
      _CloseCashRegisterDialogState();
}

class _CloseCashRegisterDialogState extends State<CloseCashRegisterDialog> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  StaffModel? _selectedStaff;
  bool _obscurePassword = true;
  double _balance = 0.0;
  bool _printReceipt = true;

  @override
  void initState() {
    super.initState();
    _balance = widget.closeRegisterDetails.expectedClosingAmount.toDouble();
    _amountController.addListener(_updateBalance);
  }

  void _updateBalance() {
    final enteredAmount = double.tryParse(_amountController.text) ?? 0.0;
    setState(() {
      _balance =
          widget.closeRegisterDetails.expectedClosingAmount.toDouble() -
          enteredAmount;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chairCubit = context.read<ChairCubit>();
    List<StaffModel> staffList = List<StaffModel>.from(chairCubit.staffs);
    final shop = context.read<AuthCubit>().currentUser;
    final isNoChair = CheckNoChair.checkIsThisAppNoChairOrNot(shop);
    return BlocListener<CashRegistoryCubit, CashRegistoryState>(
      listener: (context, state) {
        if (state is CashRegistoryCloseSuccess) {
          Navigator.pop(context);
          ToastHelper.showSuccess(state.response.message);
          final report = state.response.report;
          if (report != null) {
            final ShopModel? shop = context.read<AuthCubit>().currentUser;
            if (shop != null) {
              context.read<PrintingCubit>().printCloseRegisterReport(
                report: report,
                shop: shop,
                printCount: 1,
              );
            }
          }
        } else if (state is CashRegistoryAddError) {
          ToastHelper.showError(state.message);
        }
      },
      child: Dialog(
        backgroundColor: const Color(0xFF1E1E2C),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2C),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Centered text
                    Text(
                      "CLOSE CASH REGISTER",
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Left icon
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white54),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Builder(
                  builder: (context) {
                    return Text(
                      "Opening Date: ${widget.closeRegisterDetails.openingDate}",
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Opening Amount: ${widget.closeRegisterDetails.openingAmount}",
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Total Cash Sales: ${widget.closeRegisterDetails.totalSales}",
                        textAlign: TextAlign.end,
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Expected Amount: ${widget.closeRegisterDetails.expectedClosingAmount}",
                        style: GoogleFonts.rajdhani(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Balance: ${_balance.toStringAsFixed(2)}",
                        textAlign: TextAlign.end,
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Admin Selection
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<StaffModel>(
                      value: _selectedStaff,
                      dropdownColor: const Color(0xFF1E1E2C),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                      isExpanded: true,
                      hint: Text(
                        "Select User",
                        style: GoogleFonts.rajdhani(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      items: staffList.map((StaffModel staff) {
                        return DropdownMenuItem<StaffModel>(
                          value: staff,
                          child: Text(staff.name),
                        );
                      }).toList(),
                      onChanged: (StaffModel? newValue) {
                        setState(() {
                          _selectedStaff = newValue;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field
                if (!isNoChair)
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                      hintText: "Enter Password",
                      hintStyle: GoogleFonts.rajdhani(color: Colors.white24),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.white54,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                if (!isNoChair) const SizedBox(height: 16),

                Text(
                  "Closing Amount",
                  style: GoogleFonts.rajdhani(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _amountController,
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    hintText: "Enter amount",
                    hintStyle: GoogleFonts.rajdhani(color: Colors.white24),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 5),
                Row(
                  children: [
                    Checkbox(
                      value: _printReceipt,
                      onChanged: (value) {
                        setState(() {
                          _printReceipt = value ?? false;
                        });
                      },
                      side: const BorderSide(color: Colors.white54),
                      activeColor: Colors.white,
                      checkColor: const Color(0xFF1E1E2C),
                    ),
                    Text(
                      "Print Report",
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                BlocBuilder<CashRegistoryCubit, CashRegistoryState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      child: ActionButton(
                        label: "CLOSE REGISTER",
                        isPrimary: true,
                        isLoading: state is CashRegistoryLoading,
                        onTap: () {
                          if (_selectedStaff == null) {
                            ToastHelper.showError("Please select an admin");
                            return;
                          }
                          if (!isNoChair && _passwordController.text.isEmpty) {
                            ToastHelper.showError("Please enter password");
                            return;
                          }
                          if (_amountController.text.isEmpty) {
                            ToastHelper.showError(
                              "Please enter closing amount",
                            );
                            return;
                          }
                          final amount = double.tryParse(
                            _amountController.text,
                          );
                          if (amount == null) {
                            ToastHelper.showError("Invalid amount");
                            return;
                          }
                          if (_printReceipt) {}
                          context.read<CashRegistoryCubit>().closeCashRegister(
                            isPrint: _printReceipt,
                            amount: amount,
                            userId: _selectedStaff!.id,
                            role: _selectedStaff!.role,
                            password: isNoChair
                                ? "0000"
                                : _passwordController.text,
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
