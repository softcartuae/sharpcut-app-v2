import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/home/chair_cubit.dart';
import 'package:sharp_cut/cubit/home/chair_state.dart';
import 'package:sharp_cut/domain/home/models/chair_model.dart';

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
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
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
              return _buildChairItem(state.chairs[index]);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildChairItem(ChairModel chair) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B25), // Dark background from image
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
    );
  }
}
