import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/home/chair_cubit.dart';
import 'package:sharp_cut/cubit/home/chair_state.dart';
import 'package:sharp_cut/domain/home/models/chair_model.dart';
import 'package:sharp_cut/utils/comon/password_showdialoge.dart';
import 'package:sharp_cut/utils/helpers/enums.dart';

class CuttingMastersDialog extends StatelessWidget {
  const CuttingMastersDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
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
          'Cutting Masters',
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
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is ChairSuccess) {
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
      onTap: () {
        // Close the current dialog
        Navigator.of(context).pop();
        // Open the password dialog with the selected chair
        if (chair.liveState != LiveState.occupied.name) {
          showPasswordDialoge(context, chair);
        } else {
          //show Toes
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

        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: Image.asset(
                'lib/utils/images/chair.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF252630), // Slightly lighter footer
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
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
      ),
    );
  }
}
