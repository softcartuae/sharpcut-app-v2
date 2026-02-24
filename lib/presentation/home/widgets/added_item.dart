import 'dart:ui';
import 'package:sharp_cut/domain/home/models/cart_item_model.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:sharp_cut/utils/app_colors.dart';

class AddedItem extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const AddedItem({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: GradientBoxBorder(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.violetLight.withOpacity(0.9), // highlight
                  AppColors.violetLight.withOpacity(0.6), // shadow
                ],
              ),
              width: 0.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item.service.name ?? "Service",
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    "${item.quantity}",
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (item.service.isTip != 1)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: onIncrement,
                          child: const Icon(
                            Icons.arrow_drop_up,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        InkWell(
                          onTap: onDecrement,
                          child: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(width: 32),
              Text(
                "\$${item.service.charge ?? "0"}",
                style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(width: 24),
              InkWell(
                onTap: onRemove,
                child: const Icon(
                  Icons.delete,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
