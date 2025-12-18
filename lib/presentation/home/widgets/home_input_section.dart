import 'package:flutter/material.dart';
import 'package:sharp_cut/presentation/home/widgets/custom_text_field.dart';
import 'package:sharp_cut/utils/app_colors.dart';

class HomeInputSection extends StatelessWidget {
  const HomeInputSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 100, vertical: 24),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("lib/utils/images/rectangle.png"),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            spreadRadius: 0,
            color: Colors.black.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: "Invoice no",
                  hint: "Invoice no",
                  icon: Icons.receipt_long_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: "Date",
                  hint: "28-04-2024",
                  icon: Icons.calendar_today_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: "Booking Time",
                  hint: "Booking Time",
                  icon: Icons.history, // Or another suitable icon
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: "Custom",
                  hint: "Custom",
                  icon: Icons.receipt_long_outlined, // Placeholder icon
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: "Customer Name",
                  hint: "Customer Name",
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: "Custom",
                  hint: "Custom",
                  icon: Icons.receipt_long_outlined, // Placeholder icon
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: "Sales Man",
                  hint: "Sales Man",
                  icon: Icons.groups_outlined, // Or person_pin_circle_outlined
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: "Custom",
                  hint: "Custom",
                  icon: Icons.receipt_long_outlined, // Placeholder icon
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
