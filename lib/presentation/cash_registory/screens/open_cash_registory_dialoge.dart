import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sharp_cut/cubit/cash_registory/cash_registory_cubit.dart';
import 'package:sharp_cut/cubit/cash_registory/cash_registory_state.dart';
import 'package:sharp_cut/utils/helpers/enums.dart';
import 'package:sharp_cut/utils/helpers/toast_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/booking/booking_state.dart';
import 'package:sharp_cut/cubit/home/chair_cubit.dart';
import 'package:sharp_cut/domain/home/models/staff_model.dart';
import 'package:sharp_cut/utils/app_colors.dart';

Future<void> showCashRegistoryDialoge(BuildContext context) {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cashController = TextEditingController();
  StaffModel? selectedStaff;
  bool obscurePassword = true;

  // Fetch staffs from ChairCubit
  final chairCubit = context.read<ChairCubit>();
  List<StaffModel> staffListAll = List<StaffModel>.from(chairCubit.staffs);
  List<StaffModel> staffList = staffListAll;

  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return BlocConsumer<CashRegistoryCubit, CashRegistoryState>(
            listener: (context, state) {
              if (state is CashRegistoryAddSuccess) {
                Navigator.of(context).pop();
                ToastHelper.showSuccess(
                  "Cash Registory Successfull Added Now You Can Book Slot",
                );
              } else if (state is CashRegistoryAddError) {
                ToastHelper.showError(state.message);
              }
            },
            builder: (context, state) {
              return Dialog(
                backgroundColor: const Color(0xFF1E1E2C), // Dark background
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: 400,
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
                                "Open Cash Register",
                                textAlign: TextAlign.center,
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
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Staff Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withAlpha(77),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<StaffModel>(
                              value: selectedStaff,
                              dropdownColor: const Color(0xFF1E1E2C),
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                              isExpanded: true,
                              hint: Text(
                                "Select Admin",
                                style: GoogleFonts.rajdhani(
                                  color: Colors.white.withAlpha(179),
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
                                  selectedStaff = newValue;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withAlpha(77),
                            ),
                          ),
                          child: TextField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: "Enter Password",
                              hintStyle: GoogleFonts.rajdhani(
                                color: Colors.white.withAlpha(179),
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.white.withAlpha(128),
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withAlpha(77),
                            ),
                          ),
                          child: TextField(
                            controller: cashController,
                            style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            decoration: InputDecoration(
                              hintText: "Enter Cash",
                              hintStyle: GoogleFonts.rajdhani(
                                color: Colors.white.withAlpha(179),
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Submit Button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.violetNormal,
                                AppColors.redNormal,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: state is BookingLoading
                                ? null
                                : () {
                                    if (selectedStaff == null) {
                                      ToastHelper.showError(
                                        "Please select a staff",
                                      );
                                      return;
                                    }
                                    if (passwordController.text.isEmpty) {
                                      ToastHelper.showError(
                                        "Please enter password",
                                      );
                                      return;
                                    }

                                    if (cashController.text.isEmpty) {
                                      ToastHelper.showError(
                                        "Please enter cash",
                                      );
                                      return;
                                    }

                                    context
                                        .read<CashRegistoryCubit>()
                                        .openCashRegister(
                                          userId: selectedStaff!.id,
                                          role: selectedStaff!.role,
                                          amount: double.parse(
                                            cashController.text,
                                          ),
                                          password: passwordController.text,
                                        );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: state is BookingLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Submit',
                                    style: GoogleFonts.rajdhani(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}
