import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/cubit/booking/booking_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_state.dart';
import 'package:sharp_cut/cubit/online_booking/online_booking_cubit.dart';
import 'package:sharp_cut/cubit/online_booking/online_booking_state.dart';
import 'package:sharp_cut/presentation/home/widgets/online_booking_card.dart';
import 'package:sharp_cut/presentation/home/widgets/online_booking_shimmer_loading.dart';
import 'package:sharp_cut/utils/app_colors.dart';

class ScreenOnlineBookings extends StatefulWidget {
  const ScreenOnlineBookings({super.key});

  @override
  State<ScreenOnlineBookings> createState() => _ScreenOnlineBookingsState();
}

class _ScreenOnlineBookingsState extends State<ScreenOnlineBookings> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _phoneSearchController = TextEditingController();
  Timer? _debounceTimer;

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
    _debounceTimer?.cancel();
    _phoneSearchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<OnlineBookingCubit>().loadMoreOnlineBookings();
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<OnlineBookingCubit>().fetchOnlineBookings(
          isRefresh: true,
          phoneNumber: query,
        );
      }
    });
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
              context.read<OnlineBookingCubit>().fetchOnlineBookings(
                isRefresh: true,
                phoneNumber: _phoneSearchController.text,
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: BlocListener<BookingCubit, BookingState>(
        listener: (context, bookingState) {
          if (bookingState is BookingInitial) {
            context.read<OnlineBookingCubit>().fetchOnlineBookings(
              isRefresh: true,
              phoneNumber: _phoneSearchController.text,
            );
          }
        },
        child: Column(
          children: [
            // Phone Number Filter Input Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2C),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.violetNormal.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _phoneSearchController,
                  builder: (context, value, child) {
                    return TextField(
                      controller: _phoneSearchController,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: "Filter by phone number (e.g. +971500000)...",
                        hintStyle: GoogleFonts.rajdhani(
                          color: Colors.white38,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.violetNormal,
                          size: 20,
                        ),
                        suffixIcon: value.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.white54,
                                  size: 18,
                                ),
                                onPressed: () {
                                  _phoneSearchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Online Bookings List / States
            Expanded(
              child: BlocBuilder<OnlineBookingCubit, OnlineBookingState>(
                builder: (context, state) {
                  if (state is OnlineBookingLoading) {
                    return const OnlineBookingShimmerLoading();
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
                                  .fetchOnlineBookings(
                                    isRefresh: true,
                                    phoneNumber: _phoneSearchController.text,
                                  );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
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
                    return Column(
                      children: [
                        if (state.isRefreshing)
                          const LinearProgressIndicator(
                            minHeight: 2,
                            color: AppColors.violetNormal,
                            backgroundColor: Colors.transparent,
                          ),
                        Expanded(
                          child: state.bookings.isEmpty
                              ? Center(
                                  child: Text(
                                    "No Online Bookings Found",
                                    style: GoogleFonts.rajdhani(
                                      color: Colors.white54,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : RefreshIndicator(
                                  color: AppColors.violetNormal,
                                  backgroundColor: Colors.black,
                                  onRefresh: () async {
                                    await context
                                        .read<OnlineBookingCubit>()
                                        .fetchOnlineBookings(
                                          isRefresh: true,
                                          phoneNumber: _phoneSearchController.text,
                                        );
                                  },
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    itemCount:
                                        state.bookings.length + (state.hasMore ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index >= state.bookings.length) {
                                        return const Padding(
                                          padding: EdgeInsets.only(bottom: 16),
                                          child: OnlineBookingCardShimmer(),
                                        );
                                      }

                                      final booking = state.bookings[index];
                                      return OnlineBookingCard(booking: booking);
                                    },
                                  ),
                                ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
