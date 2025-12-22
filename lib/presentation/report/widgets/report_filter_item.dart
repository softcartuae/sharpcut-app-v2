import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportFilterItem extends StatefulWidget {
  final String label;
  final String initialValue;
  final List<String> items;
  final int flex;
  final IconData? icon;

  const ReportFilterItem({
    super.key,
    required this.label,
    required this.initialValue,
    required this.items,
    this.flex = 1,
    this.icon,
  });

  @override
  State<ReportFilterItem> createState() => _ReportFilterItemState();
}

class _ReportFilterItemState extends State<ReportFilterItem> {
  late String _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    // Ensure initial value is in the list
    if (!widget.items.contains(_selectedValue)) {
      if (widget.items.isNotEmpty) {
        _selectedValue = widget.items.first;
      } else {
        // Fallback if list is empty, though ideally shouldn't happen with dummy data
        _selectedValue = widget.initialValue;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we should use dark style (based on original logic: Select, MAIN, or Date range)
    // Note: Date range logic is a bit specific, but we'll keep the style consistent with the request.
    // If the selected value is "Select" or "MAIN" or contains "AM" (date), use black background.
    bool isDarkStyle =
        _selectedValue == "Select" ||
        _selectedValue == "MAIN" ||
        _selectedValue.contains("AM");

    return Expanded(
      flex: widget.flex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(4),
              color: isDarkStyle ? Colors.black : Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: widget.items.contains(_selectedValue)
                    ? _selectedValue
                    : null,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: isDarkStyle ? Colors.white : Colors.black,
                  size: 18,
                ),
                dropdownColor: isDarkStyle ? Colors.black : Colors.white,
                style: GoogleFonts.rajdhani(
                  color: isDarkStyle ? Colors.white : Colors.black,
                  fontSize: 14,
                ),
                items: widget.items.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        if (widget.icon != null && value == _selectedValue) ...[
                          Icon(
                            widget.icon,
                            color: isDarkStyle ? Colors.white : Colors.black,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            value,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.rajdhani(
                              color: isDarkStyle ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedValue = newValue;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
