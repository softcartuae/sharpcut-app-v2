import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportFilterItem extends StatefulWidget {
  final String label;
  final String initialValue;
  final List<String> items;
  final IconData? icon;
  final ValueChanged<String>? onChanged;

  const ReportFilterItem({
    super.key,
    required this.label,
    required this.initialValue,
    required this.items,
    this.icon,
    this.onChanged,
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
  void didUpdateWidget(covariant ReportFilterItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        _selectedValue = widget.initialValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
            color: Colors.black,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: widget.items.contains(_selectedValue)
                  ? _selectedValue
                  : null,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 18,
              ),
              dropdownColor: Colors.black,
              style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 14),
              hint: Text(
                _selectedValue,
                style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 14),
              ),
              items: widget.items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      if (widget.icon != null && value == _selectedValue) ...[
                        Icon(widget.icon, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          value,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.rajdhani(color: Colors.white),
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
                  if (widget.onChanged != null) {
                    widget.onChanged!(newValue);
                  }
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
