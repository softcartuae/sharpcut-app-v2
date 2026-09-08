import 'package:flutter/material.dart';
import 'package:sharp_cut/presentation/home/widgets/online_booking_card_shimmer.dart';

class OnlineBookingShimmerLoading extends StatelessWidget {
  const OnlineBookingShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: 8,
      itemBuilder: (context, index) {
        return const OnlineBookingCardShimmer();
      },
    );
  }
}
