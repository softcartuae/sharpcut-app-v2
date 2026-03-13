import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/cubit/home/chair_cubit.dart';
import 'package:sharp_cut/domain/home/models/chair_model.dart';
import 'package:sharp_cut/domain/home/models/staff_model.dart';
import 'package:sharp_cut/utils/comon/password_showdialoge.dart';
import 'package:sharp_cut/cubit/booking/booking_cubit.dart';
import 'package:sharp_cut/cubit/auth/auth_cubit.dart';
import 'package:sharp_cut/utils/helpers/check_no_chair.dart';
import 'package:sharp_cut/utils/helpers/enums.dart';

Future<StaffModel?> showStaffSelectionDialog(
  BuildContext context,
  ChairModel chair,
) {
  // Fetch staffs from ChairCubit
  final chairCubit = context.read<ChairCubit>();
  List<StaffModel> staffListAll = List<StaffModel>.from(chairCubit.staffs);
  List<StaffModel> staffList = staffListAll
      .where((element) => element.role != Role.admin)
      .toList();

  return showDialog<StaffModel>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: const Color(0xFF1E1E2C), // Dark background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                  Text(
                    "Select Staff",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (staffList.isEmpty)
                Text(
                  "staffs are empty you have to add in dashboard",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                )
              else
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: staffList.map((staff) {
                    return InkWell(
                      onTap: () {
                        final shop = context.read<AuthCubit>().currentUser;
                        final isNoChair =
                            CheckNoChair.checkIsThisAppNoChairOrNot(shop);

                        if (isNoChair) {
                          context.read<BookingCubit>().bookSlot(
                            chairId: chair.id ?? 0,
                            userId: staff.id,
                            userPassword: "0000",
                          );
                          Navigator.pop(context);
                        } else {
                          showPasswordDialoge(context, chair, staff);
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 140,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              staff.name.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.rajdhani(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    },
  );
}
