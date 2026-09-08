import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/domain/booking/models/online_booking_model.dart';
import 'package:sharp_cut/utils/app_colors.dart';

class OnlineBookingServicesDialog extends StatelessWidget {
  final List<OnlineServiceModel> services;
  final String customerName;

  const OnlineBookingServicesDialog({
    super.key,
    required this.services,
    required this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Services for $customerName",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.rajdhani(
                      color: AppColors.textPrimaryLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.textSecondaryLight,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(color: AppColors.borderLight),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: services.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: AppColors.chipLight),
                itemBuilder: (context, index) {
                  final s = services[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "${s.name ?? 'Service'} x${s.quantity ?? 1}",
                          style: GoogleFonts.rajdhani(
                            color: AppColors.textBodyLight,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        "AED ${(s.rate ?? 0).toStringAsFixed(2)}",
                        style: GoogleFonts.rajdhani(
                          color: AppColors.violetDark,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
