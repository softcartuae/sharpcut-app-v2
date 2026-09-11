import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/cubit/booking/booking_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_state.dart';
import 'package:sharp_cut/cubit/online_booking/online_booking_cubit.dart';
import 'package:sharp_cut/cubit/online_booking/online_booking_state.dart';
import 'package:sharp_cut/presentation/home/widgets/online_booking_card.dart';
import 'package:sharp_cut/presentation/home/widgets/online_booking_card_shimmer.dart';
import 'package:sharp_cut/presentation/home/widgets/online_booking_date_filter_dropdown.dart';
import 'package:sharp_cut/presentation/home/widgets/online_booking_shimmer_loading.dart';
import 'package:sharp_cut/presentation/home/widgets/online_booking_table_header.dart';
import 'package:sharp_cut/utils/app_colors.dart';
import 'package:sharp_cut/utils/helpers/app_scroll_behavior.dart';

class ScreenOnlineBookings extends StatefulWidget {
  const ScreenOnlineBookings({super.key});

  @override
  State<ScreenOnlineBookings> createState() => _ScreenOnlineBookingsState();
}

class _ScreenOnlineBookingsState extends State<ScreenOnlineBookings> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
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
    _horizontalScrollController.dispose();
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
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0.5,
        centerTitle: false,
        title: Text(
          "ONLINE BOOKINGS",
          style: GoogleFonts.rajdhani(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimaryLight,
          ),
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
            // Filter Bar: Phone Search & Date Filter Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.borderMediumLight,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _phoneSearchController,
                        builder: (context, value, child) {
                          return TextField(
                            controller: _phoneSearchController,
                            style: GoogleFonts.rajdhani(
                              color: AppColors.textPrimaryLight,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText:
                                  "Search Customer name or phone...",
                              hintStyle: GoogleFonts.rajdhani(
                                color: AppColors.textMutedLight,
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
                                        color: AppColors.textSecondaryLight,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        _phoneSearchController.clear();
                                        _onSearchChanged('');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Date Filter Dropdown (ALL DATES, TODAY, YESTERDAY, CUSTOM DATE)
                  BlocBuilder<OnlineBookingCubit, OnlineBookingState>(
                    builder: (context, state) {
                      return OnlineBookingDateFilterDropdown(
                        activeDateFilter:
                            context.read<OnlineBookingCubit>().currentDateFilter,
                        onDateFilterChanged: (newDateStr) {
                          if (newDateStr == null) {
                            context
                                .read<OnlineBookingCubit>()
                                .fetchOnlineBookings(
                                  isRefresh: true,
                                  phoneNumber: _phoneSearchController.text,
                                  clearDate: true,
                                );
                          } else {
                            context
                                .read<OnlineBookingCubit>()
                                .fetchOnlineBookings(
                                  isRefresh: true,
                                  phoneNumber: _phoneSearchController.text,
                                  date: newDateStr,
                                );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),

            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double tableWidth =
                      constraints.maxWidth < 1000 ? 1000 : constraints.maxWidth;

                  return ScrollConfiguration(
                    behavior: AppScrollBehavior(),
                    child: Scrollbar(
                      controller: _horizontalScrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      child: SingleChildScrollView(
                        controller: _horizontalScrollController,
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: tableWidth,
                          child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 4,
                            ),
                            child: OnlineBookingTableHeader(),
                          ),
                          const SizedBox(height: 4),

                          Expanded(
                            child: BlocBuilder<
                              OnlineBookingCubit,
                              OnlineBookingState
                            >(
                              builder: (context, state) {
                                if (state is OnlineBookingLoading) {
                                  return const OnlineBookingShimmerLoading();
                                }

                                if (state is OnlineBookingError) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                                  phoneNumber:
                                                      _phoneSearchController
                                                          .text,
                                                );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                                    color: AppColors
                                                        .textSecondaryLight,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              )
                                            : RefreshIndicator(
                                                color: AppColors.violetNormal,
                                                backgroundColor: AppColors
                                                    .surfaceLight,
                                                onRefresh: () async {
                                                  await context
                                                      .read<
                                                        OnlineBookingCubit
                                                      >()
                                                      .fetchOnlineBookings(
                                                        isRefresh: true,
                                                        phoneNumber:
                                                            _phoneSearchController
                                                                .text,
                                                      );
                                                },
                                                child: ListView.builder(
                                                  controller: _scrollController,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 4,
                                                      ),
                                                  itemCount:
                                                      state.bookings.length +
                                                      (state.hasMore ? 1 : 0),
                                                  itemBuilder: (
                                                    context,
                                                    index,
                                                  ) {
                                                    if (index >=
                                                        state.bookings.length) {
                                                      return const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                              bottom: 8,
                                                            ),
                                                        child:
                                                            OnlineBookingCardShimmer(),
                                                      );
                                                    }

                                                    final booking =
                                                        state.bookings[index];
                                                    return OnlineBookingCard(
                                                      booking: booking,
                                                    );
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
                  ),
                ),
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
