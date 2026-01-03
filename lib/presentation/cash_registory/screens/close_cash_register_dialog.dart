import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/cubit/cash_registory/cash_registory_cubit.dart';
import 'package:sharp_cut/cubit/cash_registory/cash_registory_state.dart';
import 'package:sharp_cut/presentation/home/widgets/action_button.dart';
import 'package:sharp_cut/utils/helpers/toast_helper.dart';
import 'package:sharp_cut/cubit/home/chair_cubit.dart';
import 'package:sharp_cut/domain/home/models/staff_model.dart';

class CloseCashRegisterDialog extends StatefulWidget {
  const CloseCashRegisterDialog({super.key, required this.totalSales});
  final double? totalSales;

  static void show(BuildContext context, double? totalSales) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CloseCashRegisterDialog(totalSales: totalSales),
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
    return BlocListener<CashRegistoryCubit, CashRegistoryState>(
      listener: (context, state) {
        if (state is CashRegistoryAddSuccess) {
          Navigator.pop(context);
          ToastHelper.showSuccess(state.message);
          // Refresh status or handle post-close logic if needed
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "CLOSE CASH REGISTER",
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white54),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (widget.totalSales != null)
                  Text(
                    "Total Sales: ${widget.totalSales.toString()}",
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                if (widget.totalSales != null) const SizedBox(height: 16),

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
                const SizedBox(height: 16),

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
                const SizedBox(height: 32),
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
                          if (_passwordController.text.isEmpty) {
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
                          context.read<CashRegistoryCubit>().closeCashRegister(
                            amount: amount,
                            userId: _selectedStaff!.id,
                            role: _selectedStaff!.role,
                            password: _passwordController.text,
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
