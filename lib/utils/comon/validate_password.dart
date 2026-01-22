import 'package:flutter/material.dart';
import 'package:sharp_cut/utils/helpers/enums.dart';
import 'package:sharp_cut/utils/helpers/toast_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/home/chair_cubit.dart';
import 'package:sharp_cut/domain/home/models/staff_model.dart';
import 'package:sharp_cut/utils/app_colors.dart';
import 'package:sharp_cut/cubit/password/password_cubit.dart';

Future<void> showPasswordForValidation(
  BuildContext context,
  bool isAdmin, {
  bool showAdminToo = false,
  StaffModel? preSelectedStaff,
  VoidCallback? onSuccess,
  Function(StaffModel)? onSuccessWithStaff,
}) {
  final TextEditingController passwordController = TextEditingController();
  StaffModel? selectedStaff;
  bool obscurePassword = true;

  // Fetch staffs from ChairCubit
  final chairCubit = context.read<ChairCubit>();
  List<StaffModel> staffListAll = List<StaffModel>.from(chairCubit.staffs);
  List<StaffModel> staffList = staffListAll
      .where(
        (element) => showAdminToo == true ? true : element.role != Role.admin,
      )
      .toList();

  // If preSelectedStaff is provided, try to find it in the list to ensure object equality for Dropdown
  if (preSelectedStaff != null) {
    try {
      selectedStaff = staffList.firstWhere(
        (element) => element.id == preSelectedStaff.id,
      );
    } catch (e) {
      // Fallback if not found in the list (shouldn't happen ideally if data is consistent)
      selectedStaff = preSelectedStaff;
    }
  }

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return BlocConsumer<PasswordCubit, PasswordState>(
            listener: (context, state) {
              if (state is PasswordValidationSuccess) {
                Navigator.of(context).pop();
                ToastHelper.showSuccess(state.message);
                if (onSuccess != null) {
                  onSuccess();
                }
                if (onSuccessWithStaff != null && selectedStaff != null) {
                  onSuccessWithStaff(selectedStaff!);
                }
              } else if (state is PasswordValidationFailure) {
                if (state.error == "RESET_REQUIRED") {
                  Navigator.of(context).pop(); // Close current dialog
                  ToastHelper.showError("Password Reset Required");
                } else {
                  ToastHelper.showError(state.error);
                }
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
                              showAdminToo == true
                                  ? "Select User"
                                  : "Select Staff",
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

                      // Scrollable Content
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Staff Dropdown
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
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
                                    // Disable dropdown if staff is pre-selected
                                    onChanged: preSelectedStaff != null
                                        ? null
                                        : (StaffModel? newValue) {
                                            setState(() {
                                              selectedStaff = newValue;
                                            });
                                          },
                                    hint: Text(
                                      showAdminToo == true
                                          ? "Select User"
                                          : "Select Staff",
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
                              const SizedBox(height: 32),

                              // Submit Button
                              state is PasswordValidationLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Container(
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
                                        onPressed: () {
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
                                          // if show admin too is true and selected staff is admin then set isAdmin to true
                                          if (showAdminToo == true) {
                                            if (selectedStaff?.role ==
                                                Role.admin) {
                                              isAdmin = true;
                                            }
                                          }

                                          context
                                              .read<PasswordCubit>()
                                              .validatePassword(
                                                isAdmin: isAdmin,
                                                password:
                                                    passwordController.text,
                                                userId: selectedStaff!.id,
                                              );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: Text(
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
                    ],
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
