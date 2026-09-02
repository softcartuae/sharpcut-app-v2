import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:intl/intl.dart';
import 'package:sharp_cut/cubit/online_booking/online_booking_cubit.dart';
import 'package:sharp_cut/cubit/online_booking/online_booking_state.dart';
import 'package:sharp_cut/domain/booking/models/online_booking_model.dart';
import 'package:sharp_cut/presentation/home/widgets/cutting_masters_dialog.dart';
import 'package:sharp_cut/utils/app_colors.dart';

class ScreenOnlineBookings extends StatefulWidget {
  const ScreenOnlineBookings({super.key});

  @override
  State<ScreenOnlineBookings> createState() => _ScreenOnlineBookingsState();
}

class _ScreenOnlineBookingsState extends State<ScreenOnlineBookings> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnlineBookingCubit>().fetchOnlineBookings(isRefresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<OnlineBookingCubit>().loadMoreOnlineBookings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
        title: Text(
          "ONLINE BOOKINGS",
          style: GoogleFonts.rajdhani(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.violetNormal),
            onPressed: () {
              context
                  .read<OnlineBookingCubit>()
                  .fetchOnlineBookings(isRefresh: true);
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: BlocBuilder<OnlineBookingCubit, OnlineBookingState>(
        builder: (context, state) {
          if (state is OnlineBookingLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.violetNormal,
              ),
            );
          }

          if (state is OnlineBookingError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: GoogleFonts.rajdhani(
                      color: AppColors.redNormal,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      context
                          .read<OnlineBookingCubit>()
                          .fetchOnlineBookings(isRefresh: true);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [AppColors.violetNormal, AppColors.redNormal],
                        ),
                      ),
                      child: Text(
                        "RETRY",
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is OnlineBookingLoaded) {
            if (state.bookings.isEmpty) {
              return Center(
                child: Text(
                  "No Online Bookings Found",
                  style: GoogleFonts.rajdhani(
                    color: Colors.white54,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.violetNormal,
              backgroundColor: Colors.black,
              onRefresh: () async {
                await context
                    .read<OnlineBookingCubit>()
                    .fetchOnlineBookings(isRefresh: true);
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                itemCount: state.bookings.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.bookings.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.violetNormal,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }

                  final booking = state.bookings[index];
                  return OnlineBookingCard(booking: booking);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

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
    final isAssignable = booking.status?.toLowerCase() != 'cancelled';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
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
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer?.name ?? "Guest Customer",
                            style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          if (customer?.phoneNumber != null &&
                              customer!.phoneNumber!.isNotEmpty)
                            Text(
                              customer.phoneNumber!,
                              style: GoogleFonts.rajdhani(
                                color: Colors.white60,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              OnlineBookingStatusChip(status: booking.status ?? "pending"),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
          const SizedBox(height: 14),

          // Booking Time & Stylist Info
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.violetNormal,
              ),
              const SizedBox(width: 6),
              Text(
                _formatBookingTime(booking.bookingTime),
                style: GoogleFonts.rajdhani(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 20),
              const Icon(
                Icons.person_outline,
                size: 16,
                color: AppColors.redNormal,
              ),
              const SizedBox(width: 6),
              Text(
                booking.stylistName ?? "Any Stylist",
                style: GoogleFonts.rajdhani(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Services List
          if (services.isNotEmpty) ...[
            Text(
              "SERVICES (${services.length}):",
              style: GoogleFonts.rajdhani(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: services.map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.violetLight.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    "${s.name ?? 'Service'} x${s.quantity ?? 1} (AED ${(s.rate ?? 0).toStringAsFixed(2)})",
                    style: GoogleFonts.rajdhani(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
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
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    "AED ${booking.totalAmount.toStringAsFixed(2)}",
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
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
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.violetNormal,
                          AppColors.redNormal,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.violetNormal.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.event_seat,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "ASSIGN TO CHAIR",
                          style: GoogleFonts.rajdhani(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
          fontSize: 12,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
