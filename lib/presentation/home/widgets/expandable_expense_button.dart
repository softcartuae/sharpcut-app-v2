import 'package:flutter/material.dart';
import 'package:sharp_cut/presentation/home/widgets/action_button.dart';

class ExpandableExpenseButton extends StatefulWidget {
  final bool isBooked;
  final String selectedButton;
  final bool isShowShopExpenses;
  final bool isShowUserExpenses;
  final VoidCallback onTapShop;
  final VoidCallback onTapStaff;

  const ExpandableExpenseButton({
    super.key,
    required this.isBooked,
    required this.selectedButton,
    required this.isShowShopExpenses,
    required this.isShowUserExpenses,
    required this.onTapShop,
    required this.onTapStaff,
  });

  @override
  State<ExpandableExpenseButton> createState() =>
      _ExpandableExpenseButtonState();
}

class _ExpandableExpenseButtonState extends State<ExpandableExpenseButton> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isBooked ||
        (!widget.isShowShopExpenses && !widget.isShowUserExpenses)) {
      return const SizedBox.shrink();
    }

    final bool isAnyExpenseSelected =
        widget.selectedButton == "SHOP EXPENSE" ||
        widget.selectedButton == "STAFF EXPENSE";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ActionButton(
          label: _isExpanded ? "CLOSE EXPENSES" : "EXPENSES",
          isPrimary: isAnyExpenseSelected,
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
              axisAlignment: -1.0,
              child: child,
            );
          },
          child: _isExpanded
              ? Padding(
                  key: const ValueKey('expanded'),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      if (widget.isShowShopExpenses) ...[
                        const SizedBox(height: 12),
                        ActionButton(
                          label: "SHOP EXPENSE",
                          isPrimary: widget.selectedButton == "SHOP EXPENSE",
                          onTap: widget.onTapShop,
                        ),
                      ],
                      if (widget.isShowUserExpenses) ...[
                        const SizedBox(height: 12),
                        ActionButton(
                          label: "STAFF EXPENSE",
                          isPrimary: widget.selectedButton == "STAFF EXPENSE",
                          onTap: widget.onTapStaff,
                        ),
                      ],
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
