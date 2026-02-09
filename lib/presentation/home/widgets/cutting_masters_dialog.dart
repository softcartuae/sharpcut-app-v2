import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/home/chair_cubit.dart';
import 'package:sharp_cut/cubit/home/chair_state.dart';
import 'package:sharp_cut/cubit/booking/booking_cubit.dart';
import 'package:sharp_cut/domain/home/models/chair_model.dart';
import 'package:sharp_cut/utils/comon/staff_selection_dialog.dart';
import 'package:sharp_cut/utils/comon/validate_password.dart';
import 'package:sharp_cut/utils/helpers/enums.dart';
import 'package:sharp_cut/presentation/home/widgets/cancellation_dialog.dart';
import 'package:sharp_cut/presentation/home/widgets/services_or_cancel_dialog.dart';

class CuttingMastersDialog extends StatelessWidget {
  const CuttingMastersDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CuttingMastersDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1, color: Colors.grey),
            const SizedBox(height: 24),
            Expanded(child: _buildChairList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Select Chair',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: Colors.black),
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChairList() {
    return BlocBuilder<ChairCubit, ChairState>(
      builder: (context, state) {
        if (state is ChairLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ChairError) {
          return Center(child: Text('Something went wrong'));
        } else if (state is ChairSuccess) {
          if (state.chairs.isEmpty) {
            return const Center(
              child: Text(
                'No chairs available',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            );
          }
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: state.chairs.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return _buildChairItem(context, state.chairs[index]);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildChairItem(BuildContext context, ChairModel chair) {
    return GestureDetector(
      onTap: () async {
        if (chair.liveState != LiveState.occupied.name) {
          showStaffSelectionDialog(context, chair);
        } else {
          final result = await ServicesOrCancelDialog.show(context);
          if (!context.mounted) return;

          if (result == true) {
            // Services selected
            if (chair.transaction != null) {
              showPasswordForValidation(
                context,
                false,
                preSelectedStaff: chair.transaction!.staff,
                onSuccess: () {
                  context.read<BookingCubit>().restoreBooking(
                    bookingResponse: chair.transaction!,
                  );
                  Navigator.of(context).pop();
                },
              );
            } else {
              Navigator.of(context).pop();
              showPasswordForValidation(context, false);
            }
          } else if (result == false) {
            // Cancel selected
            if (chair.transaction != null) {
              CancellationDialog.show(context, chair.transaction!.id!);
            }
          }
        }
      },
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: chair.liveState == LiveState.available.name
                ? Colors.green
                : chair.liveState == LiveState.occupied.name
                ? Colors.red
                : Colors.grey, // fallback
          ),
          color: const Color(0xFF1A1B25),
          borderRadius: BorderRadius.circular(8),
        ),

        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 16),
                Expanded(
                  child: Image.asset(
                    chair.liveState == LiveState.occupied.name
                        ? 'lib/utils/images/chair.png'
                        : "lib/utils/images/chair-green.png",
                    fit: BoxFit.contain,
                  ),
                ),

                // const SizedBox(height: 10),
                if (chair.liveState == LiveState.occupied.name)
                  Text(
                    chair.transaction?.transactionDate ?? 'Unknown',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF252630), // Slightly lighter footer
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    chair.name ?? 'Unknown',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (chair.liveState == LiveState.occupied.name &&
                chair.transaction?.staff?.photo != null)
              Positioned(
                top: 8,
                right: 8,
                child: Column(
                  children: [
                    Container(
                      width: 40, // Adjust size as needed
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: chair.transaction!.staff!.photo!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.person,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chair.transaction!.staff!.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
