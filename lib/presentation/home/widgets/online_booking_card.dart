import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sharp_cut/domain/booking/models/online_booking_model.dart';
import 'package:sharp_cut/presentation/home/widgets/cutting_masters_dialog.dart';
import 'package:sharp_cut/utils/app_colors.dart';

class OnlineBookingCard extends StatelessWidget {
  final OnlineBookingModel booking;

  const OnlineBookingCard({super.key, required this.booking});

  String _formatBookingTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return "N/A";
    try {
      final dt = DateTime.parse(timeStr);
      return DateFormat('EEE, dd MMM • hh:mm a').format(dt);
    } catch (_) {
      return timeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = booking.customer;
    final services = booking.services ?? [];
    final isAssignable =
        booking.status?.toLowerCase() == "pending" ||
        booking.status?.toLowerCase() == "rescheduled";

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. CUSTOMER (flex: 3)
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.violetNormal,
                        AppColors.violetDark,
                      ],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    (customer?.name?.isNotEmpty == true)
                        ? customer!.name![0].toUpperCase()
                        : "C",
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        customer?.name ?? "Guest Customer",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.rajdhani(
                          color: AppColors.textPrimaryLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (customer?.phoneNumber != null &&
                          customer!.phoneNumber!.isNotEmpty)
                        Text(
                          customer.phoneNumber!,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.rajdhani(
                            color: AppColors.textSecondaryLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 2. DATE & TIME (flex: 3)
          Expanded(
            flex: 3,
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppColors.violetNormal,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _formatBookingTime(booking.bookingTime),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.rajdhani(
                      color: AppColors.textBodyLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 3. STYLIST (flex: 2)
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 14,
                  color: AppColors.redNormal,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    booking.stylistName ?? "Any Stylist",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.rajdhani(
                      color: AppColors.textBodyLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 4. SERVICES (flex: 3)
          Expanded(
            flex: 3,
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (services.isEmpty) {
                  return Text(
                    "No services",
                    style: GoogleFonts.rajdhani(
                      color: AppColors.textMutedLight,
                      fontSize: 12,
                    ),
                  );
                }

                final displayServices = services.take(2).toList();
                final remainingCount = services.length - displayServices.length;

                return InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => OnlineBookingServicesDialog(
                        services: services,
                        customerName: customer?.name ?? "Customer",
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ...displayServices.map((s) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.chipLight,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.violetNormal.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            "${s.name ?? 'Service'} x${s.quantity ?? 1}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: GoogleFonts.rajdhani(
                              color: AppColors.textBodyLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }),
                      if (remainingCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.violetNormal.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.violetNormal.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            "+$remainingCount more",
                            style: GoogleFonts.rajdhani(
                              color: AppColors.violetDark,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),

          // 5. TOTAL AMOUNT (flex: 2)
          Expanded(
            flex: 2,
            child: Text(
              "AED ${(booking.totalAmount).toStringAsFixed(2)}",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: GoogleFonts.rajdhani(
                color: AppColors.textPrimaryLight,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 6. STATUS (flex: 2)
          Expanded(
            flex: 2,
            child: Center(
              child: Builder(
                builder: (context) {
                  String status = booking.status ?? "N/A";
                  if (status.toLowerCase() == "in_progress") {
                    status = "IN PROGRESS";
                  }
                  return OnlineBookingStatusChip(status: status);
                },
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 7. ACTION (flex: 3)
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: isAssignable
                  ? GestureDetector(
                      onTap: () {
                        CuttingMastersDialog.show(
                          context,
                          onlineBooking: booking,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.violetNormal,
                              AppColors.redNormal,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.violetNormal
                                  .withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.event_seat,
                              color: Colors.white,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "ASSIGN TO CHAIR",
                              style: GoogleFonts.rajdhani(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class OnlineBookingStatusChip extends StatelessWidget {
  final String status;

  const OnlineBookingStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'completed':
        bgColor = AppColors.statusConfirmedBg;
        borderColor = AppColors.statusConfirmedBorder;
        textColor = AppColors.statusConfirmedText;
        break;
      case 'cancelled':
        bgColor = AppColors.statusCancelledBg;
        borderColor = AppColors.statusCancelledBorder;
        textColor = AppColors.statusCancelledText;
        break;
      case 'rescheduled':
        bgColor = AppColors.statusRescheduledBg;
        borderColor = AppColors.statusRescheduledBorder;
        textColor = AppColors.statusRescheduledText;
        break;
      default:
        bgColor = AppColors.statusPendingBg;
        borderColor = AppColors.statusPendingBorder;
        textColor = AppColors.statusPendingText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 0.8,
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.rajdhani(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

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
