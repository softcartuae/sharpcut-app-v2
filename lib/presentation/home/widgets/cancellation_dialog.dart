import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/cubit/booking/booking_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_state.dart';
import 'package:sharp_cut/cubit/home/chair_cubit.dart';
import 'package:sharp_cut/domain/home/models/staff_model.dart';
import 'package:sharp_cut/utils/app_colors.dart';
import 'package:sharp_cut/utils/helpers/enums.dart';
import 'package:sharp_cut/utils/helpers/toast_helper.dart';
import 'package:sharp_cut/cubit/auth/auth_cubit.dart';
import 'package:sharp_cut/utils/helpers/check_no_chair.dart';

class CancellationDialog extends StatefulWidget {
  final int transactionId;

  const CancellationDialog({super.key, required this.transactionId});

  static void show(BuildContext context, int transactionId) {
    final chairCubit = context.read<ChairCubit>();
    final staffList = chairCubit.staffs;

    final hasAdmin = staffList.any((staff) => staff.role == Role.admin);
    if (!hasAdmin) {
      ToastHelper.showError("Admin staff not found");
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CancellationDialog(transactionId: transactionId),
    );
  }

  @override
  State<CancellationDialog> createState() => _CancellationDialogState();
}

class _CancellationDialogState extends State<CancellationDialog> {
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  StaffModel? selectedStaff;
  List<StaffModel> adminStaffList = [];

  @override
  void initState() {
    super.initState();
    final chairCubit = context.read<ChairCubit>();
    adminStaffList = chairCubit.staffs
        .where((staff) => staff.role == Role.admin)
        .toList();
    if (adminStaffList.isNotEmpty) {
      selectedStaff = adminStaffList.first;
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state is BookingCancelled) {
          Navigator.of(context).pop();
          ToastHelper.showSuccess(state.message);
        } else if (state is BookingError) {
          ToastHelper.showError(state.message);
        }
      },
      child: Dialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      "Cancel Booking",
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
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withAlpha(77)),
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
                    items: adminStaffList.map((StaffModel staff) {
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

              // Reason Field
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withAlpha(77)),
                ),
                child: TextField(
                  controller: _reasonController,
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Cancellation Reason",
                    hintStyle: GoogleFonts.rajdhani(
                      color: Colors.white.withAlpha(179),
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),

              if (!CheckNoChair.checkIsThisAppNoChairOrNot(
                context.read<AuthCubit>().currentShop,
              ))
                const SizedBox(height: 16),

              // Password Field
              if (!CheckNoChair.checkIsThisAppNoChairOrNot(
                context.read<AuthCubit>().currentShop,
              ))
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withAlpha(77)),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: "Enter Admin User Password",
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
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.white.withAlpha(128),
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
                ),
              const SizedBox(height: 32),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: BlocBuilder<BookingCubit, BookingState>(
                      builder: (context, state) {
                        return state is BookingLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Container(
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
                                    if (_reasonController.text.isEmpty) {
                                      ToastHelper.showError(
                                        "Please enter cancellation reason",
                                      );
                                      return;
                                    }

                                    final shop = context
                                        .read<AuthCubit>()
                                        .currentShop;

                                    final isNoChair =
                                        CheckNoChair.checkIsThisAppNoChairOrNot(
                                          shop,
                                        );

                                    if (!isNoChair &&
                                        _passwordController.text.isEmpty) {
                                      ToastHelper.showError(
                                        "Please enter password",
                                      );
                                      return;
                                    }

                                    if (selectedStaff == null) {
                                      ToastHelper.showError(
                                        "Please select an admin",
                                      );
                                      return;
                                    }

                                    context.read<BookingCubit>().cancelBooking(
                                      transactionId: widget.transactionId,
                                      userId: selectedStaff!.id,
                                      userPassword: isNoChair
                                          ? "0000"
                                          : _passwordController.text,
                                      reason: _reasonController.text,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
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
                              );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
