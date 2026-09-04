import 'package:flutter/material.dart';
import 'package:sharp_cut/presentation/home/widgets/action_button.dart';

class ExpandableOnlineBookingButton extends StatefulWidget {
  final String selectedButton;
  final VoidCallback onTapHistory;
  final VoidCallback? onTapStaffWise;

  const ExpandableOnlineBookingButton({
    super.key,
    required this.selectedButton,
    required this.onTapHistory,
    this.onTapStaffWise,
  });

  @override
  State<ExpandableOnlineBookingButton> createState() =>
      _ExpandableOnlineBookingButtonState();
}

class _ExpandableOnlineBookingButtonState
    extends State<ExpandableOnlineBookingButton> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final bool isAnyOnlineBookingSelected =
        widget.selectedButton == "ONLINE BOOKINGS" ||
        widget.selectedButton == "HISTORY" ||
        widget.selectedButton == "STAFF WISE";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ActionButton(
          label: _isExpanded ? "CLOSE ONLINE BOOKINGS" : "ONLINE BOOKINGS",
          isPrimary: isAnyOnlineBookingSelected,
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SizeTransition(
              sizeFactor: animation,
              alignment: Alignment.topCenter,
              child: child,
            );
          },
          child: _isExpanded
              ? Padding(
                  key: const ValueKey('expanded'),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      ActionButton(
                        label: "HISTORY",
                        isPrimary: widget.selectedButton == "HISTORY",
                        onTap: widget.onTapHistory,
                      ),
                      const SizedBox(height: 12),
                      ActionButton(
                        label: "STAFF WISE",
                        isPrimary: widget.selectedButton == "STAFF WISE",
                        onTap: widget.onTapStaffWise,
                      ),
                    ],
                  ),
                )
              : const SizedBox(
                  key: ValueKey('collapsed'),
                  width: double.infinity,
                ),
        ),
      ],
    );
  }
}
