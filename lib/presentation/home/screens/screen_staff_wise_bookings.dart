import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/cubit/booking/booking_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_state.dart';
import 'package:sharp_cut/cubit/staff_wise_booking/staff_wise_booking_cubit.dart';
import 'package:sharp_cut/cubit/staff_wise_booking/staff_wise_booking_state.dart';
import 'package:sharp_cut/presentation/home/widgets/online_booking_card_shimmer.dart';
import 'package:sharp_cut/presentation/home/widgets/online_booking_date_filter_dropdown.dart';
import 'package:sharp_cut/presentation/home/widgets/online_booking_shimmer_loading.dart';
import 'package:sharp_cut/presentation/home/widgets/online_booking_status_filter_dropdown.dart';
import 'package:sharp_cut/presentation/home/widgets/staff_wise_card.dart';
import 'package:sharp_cut/utils/app_colors.dart';
import 'package:sharp_cut/utils/helpers/app_scroll_behavior.dart';

class ScreenStaffWiseBookings extends StatefulWidget {
  const ScreenStaffWiseBookings({super.key});

  @override
  State<ScreenStaffWiseBookings> createState() =>
      _ScreenStaffWiseBookingsState();
}

class _ScreenStaffWiseBookingsState extends State<ScreenStaffWiseBookings> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<StaffWiseBookingCubit>()
          .fetchStaffWiseBookings(isRefresh: true);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<StaffWiseBookingCubit>().loadMoreStaffWiseBookings();
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<StaffWiseBookingCubit>().fetchStaffWiseBookings(
          isRefresh: true,
          search: query,
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
          "STAFF'S ONLINE BOOKINGS",
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
              context.read<StaffWiseBookingCubit>().fetchStaffWiseBookings(
                isRefresh: true,
                search: _searchController.text,
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: BlocListener<BookingCubit, BookingState>(
        listener: (context, bookingState) {
          if (bookingState is BookingInitial) {
            context.read<StaffWiseBookingCubit>().fetchStaffWiseBookings(
                  isRefresh: true,
                  search: _searchController.text,
                );
          }
        },
        child: Column(
          children: [
          // Filter Bar: Search, Date Filter & Status Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                // Search Input Field
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
                      valueListenable: _searchController,
                      builder: (context, value, child) {
                        return TextField(
                          controller: _searchController,
                          style: GoogleFonts.rajdhani(
                            color: AppColors.textPrimaryLight,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: "Search staff name or phone...",
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
                                      _searchController.clear();
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
                const SizedBox(width: 10),

                // Date Filter Dropdown
                BlocBuilder<StaffWiseBookingCubit, StaffWiseBookingState>(
                  builder: (context, state) {
                    return OnlineBookingDateFilterDropdown(
                      activeDateFilter: context
                          .read<StaffWiseBookingCubit>()
                          .currentDateFilter,
                      onDateFilterChanged: (newDateStr) {
                        if (newDateStr == null) {
                          context
                              .read<StaffWiseBookingCubit>()
                              .fetchStaffWiseBookings(
                                isRefresh: true,
                                search: _searchController.text,
                                clearDate: true,
                              );
                        } else {
                          context
                              .read<StaffWiseBookingCubit>()
                              .fetchStaffWiseBookings(
                                isRefresh: true,
                                search: _searchController.text,
                                date: newDateStr,
                              );
                        }
                      },
                    );
                  },
                ),
                const SizedBox(width: 10),

                // Status Filter Dropdown
                BlocBuilder<StaffWiseBookingCubit, StaffWiseBookingState>(
                  builder: (context, state) {
                    return OnlineBookingStatusFilterDropdown(
                      activeStatus: context
                          .read<StaffWiseBookingCubit>()
                          .currentStatusFilter,
                      onStatusChanged: (newStatus) {
                        if (newStatus == null) {
                          context
                              .read<StaffWiseBookingCubit>()
                              .fetchStaffWiseBookings(
                                isRefresh: true,
                                search: _searchController.text,
                                clearStatus: true,
                              );
                        } else {
                          context
                              .read<StaffWiseBookingCubit>()
                              .fetchStaffWiseBookings(
                                isRefresh: true,
                                search: _searchController.text,
                                status: newStatus,
                              );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          // Total Summary Banner
          BlocBuilder<StaffWiseBookingCubit, StaffWiseBookingState>(
            builder: (context, state) {
              if (state is StaffWiseBookingLoaded) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.headerLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 18,
                          color: AppColors.violetNormal,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Total Staff: ",
                          style: GoogleFonts.rajdhani(
                            color: AppColors.textSecondaryLight,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "${state.totalStaff}",
                          style: GoogleFonts.rajdhani(
                            color: AppColors.textPrimaryLight,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 24),
                        const Icon(
                          Icons.event_note_outlined,
                          size: 18,
                          color: AppColors.redNormal,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Total Online Bookings: ",
                          style: GoogleFonts.rajdhani(
                            color: AppColors.textSecondaryLight,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "${state.totalBookings}",
                          style: GoogleFonts.rajdhani(
                            color: AppColors.textPrimaryLight,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 8),

          // Main Staff Bookings Content
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
                        child: BlocBuilder<StaffWiseBookingCubit,
                            StaffWiseBookingState>(
                          builder: (context, state) {
                            if (state is StaffWiseBookingLoading) {
                              return const OnlineBookingShimmerLoading();
                            }

                            if (state is StaffWiseBookingError) {
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
                                            .read<StaffWiseBookingCubit>()
                                            .fetchStaffWiseBookings(
                                              isRefresh: true,
                                              search: _searchController.text,
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

                            if (state is StaffWiseBookingLoaded) {
                              return Column(
                                children: [
                                  if (state.isRefreshing)
                                    const LinearProgressIndicator(
                                      minHeight: 2,
                                      color: AppColors.violetNormal,
                                      backgroundColor: Colors.transparent,
                                    ),
                                  Expanded(
                                    child: state.staffWiseBookings.isEmpty
                                        ? Center(
                                            child: Text(
                                              "No Staff Wise Bookings Found",
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
                                            backgroundColor:
                                                AppColors.surfaceLight,
                                            onRefresh: () async {
                                              await context
                                                  .read<
                                                      StaffWiseBookingCubit>()
                                                  .fetchStaffWiseBookings(
                                                    isRefresh: true,
                                                    search:
                                                        _searchController.text,
                                                  );
                                            },
                                            child: ListView.builder(
                                              controller: _scrollController,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 8,
                                              ),
                                              itemCount:
                                                  state.staffWiseBookings.length +
                                                      (state.hasMore ? 1 : 0),
                                              itemBuilder: (context, index) {
                                                if (index >=
                                                    state.staffWiseBookings
                                                        .length) {
                                                  return const Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 16),
                                                    child:
                                                        OnlineBookingCardShimmer(),
                                                  );
                                                }

                                                final staffBooking = state
                                                    .staffWiseBookings[index];
                                                return StaffWiseCard(
                                                  staffBooking: staffBooking,
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
