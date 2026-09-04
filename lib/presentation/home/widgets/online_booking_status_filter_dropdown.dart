import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/utils/app_colors.dart';
import 'package:sharp_cut/utils/helpers/enums.dart';

class OnlineBookingStatusFilterDropdown extends StatelessWidget {
  final String? activeStatus;
  final ValueChanged<String?> onStatusChanged;

  const OnlineBookingStatusFilterDropdown({
    super.key,
    required this.activeStatus,
    required this.onStatusChanged,
  });

  String get _displayLabel {
    if (activeStatus == null || activeStatus!.isEmpty) {
      return "ALL STATUS";
    }
    final statusEnum = OnlineBookingStatus.fromString(activeStatus);
    return statusEnum?.label ?? activeStatus!.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasFilter = activeStatus != null && activeStatus!.isNotEmpty;

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasFilter
              ? AppColors.violetNormal.withValues(alpha: 0.4)
              : AppColors.borderMediumLight,
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
      child: PopupMenuButton<String?>(
        tooltip: "Filter by Status",
        offset: const Offset(0, 50),
        color: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.borderLight),
        ),
        onSelected: onStatusChanged,
        itemBuilder: (context) => [
          PopupMenuItem<String?>(
            value: null,
            child: Text(
              "ALL STATUS",
              style: GoogleFonts.rajdhani(
                color: activeStatus == null
                    ? AppColors.violetNormal
                    : AppColors.textPrimaryLight,
                fontWeight:
                    activeStatus == null ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          ...OnlineBookingStatus.values.map((statusEnum) {
            final isSelected = activeStatus == statusEnum.apiKey;
            return PopupMenuItem<String?>(
              value: statusEnum.apiKey,
              child: Text(
                statusEnum.label,
                style: GoogleFonts.rajdhani(
                  color: isSelected
                      ? AppColors.violetNormal
                      : AppColors.textPrimaryLight,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            );
          }),
        ],
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sell_outlined,
              color: hasFilter
                  ? AppColors.violetNormal
                  : AppColors.textSecondaryLight,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              _displayLabel,
              style: GoogleFonts.rajdhani(
                color: hasFilter
                    ? AppColors.violetDark
                    : AppColors.textBodyLight,
                fontSize: 14,
                fontWeight: hasFilter ? FontWeight.bold : FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_drop_down,
              color: AppColors.textSecondaryLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
