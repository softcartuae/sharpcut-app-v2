import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
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
      return DateFormat('EEE, dd MMM yyyy • hh:mm a').format(dt);
    } catch (_) {
      return timeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = booking.customer;
    final services = booking.services ?? [];
    final isAssignable = booking.status?.toLowerCase() == "pending" || booking.status?.toLowerCase() == "rescheduled";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 47, 55, 70),
            Color.fromARGB(255, 35, 42, 54),
            Color.fromARGB(255, 25, 31, 40),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        border: const GradientBoxBorder(
          gradient: LinearGradient(
            colors: [
              AppColors.violetNormal,
              AppColors.redNormal,
            ],
          ),
          width: 0.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Customer Name & Status Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
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
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer?.name ?? "Guest Customer",
                            style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (customer?.phoneNumber != null &&
                              customer!.phoneNumber!.isNotEmpty)
                            Text(
                              customer.phoneNumber!,
                              style: GoogleFonts.rajdhani(
                                color: Colors.white60,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Builder(
                builder: (context)  {
                  String status = booking.status ?? "N/A";
                  if(status.toLowerCase() == "in_progress"){
                    status = "IN PROGRESS";
                  }
                  
                  return OnlineBookingStatusChip(
                    status: status,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
          const SizedBox(height: 8),

          // Booking Time & Stylist Info
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 14,
                color: AppColors.violetNormal,
              ),
              const SizedBox(width: 4),
              Text(
                _formatBookingTime(booking.bookingTime),
                style: GoogleFonts.rajdhani(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.person_outline,
                size: 14,
                color: AppColors.redNormal,
              ),
              const SizedBox(width: 4),
              Text(
                booking.stylistName ?? "Any Stylist",
                style: GoogleFonts.rajdhani(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Services List
          if (services.isNotEmpty) ...[
            Text(
              "SERVICES (${services.length}):",
              style: GoogleFonts.rajdhani(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: services.map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.violetLight.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    "${s.name ?? 'Service'} x${s.quantity ?? 1} (AED ${(s.rate ?? 0).toStringAsFixed(2)})",
                    style: GoogleFonts.rajdhani(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
          ],

          // Footer: Total Amount & Assign to Chair Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TOTAL AMOUNT",
                    style: GoogleFonts.rajdhani(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    "AED ${booking.totalAmount.toStringAsFixed(2)}",
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              if (isAssignable)
                GestureDetector(
                  onTap: () {
                    CuttingMastersDialog.show(context, onlineBooking: booking);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.violetNormal,
                          AppColors.redNormal,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.violetNormal.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.event_seat,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "ASSIGN TO CHAIR",
                          style: GoogleFonts.rajdhani(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
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
    Color bgGradientStart;
    Color bgGradientEnd;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'completed':
        bgGradientStart = AppColors.greenNormal.withValues(alpha: 0.3);
        bgGradientEnd = AppColors.greenLight.withValues(alpha: 0.3);
        textColor = AppColors.greenLight;
        break;
      case 'cancelled':
        bgGradientStart = AppColors.redNormal.withValues(alpha: 0.3);
        bgGradientEnd = AppColors.redDark.withValues(alpha: 0.3);
        textColor = AppColors.redNormal;
        break;
      case 'rescheduled':
        bgGradientStart = Colors.orange.withValues(alpha: 0.3);
        bgGradientEnd = Colors.deepOrange.withValues(alpha: 0.3);
        textColor = Colors.orangeAccent;
        break;
      default:
        bgGradientStart = AppColors.violetNormal.withValues(alpha: 0.3);
        bgGradientEnd = AppColors.violetDark.withValues(alpha: 0.3);
        textColor = AppColors.violetLight;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [bgGradientStart, bgGradientEnd],
        ),
        border: Border.all(
          color: textColor.withValues(alpha: 0.5),
          width: 0.8,
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.rajdhani(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
