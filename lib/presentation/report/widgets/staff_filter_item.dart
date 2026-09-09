import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/domain/home/models/staff_model.dart';

class StaffFilterItem extends StatefulWidget {
  final String label;
  final List<StaffModel> items;
  final ValueChanged<int?>? onChanged;
  final int? initialValue;
  final bool enabled;

  const StaffFilterItem({
    super.key,
    required this.label,
    required this.items,
    this.onChanged,
    this.initialValue,
    this.enabled = true,
  });

  @override
  State<StaffFilterItem> createState() => _StaffFilterItemState();
}

class _StaffFilterItemState extends State<StaffFilterItem> {
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialValue;
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
            child: DropdownButton<int>(
              value: _selectedId,
              isExpanded: true,
              hint: Text(
                "Select",
                style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 14),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 18,
              ),
              dropdownColor: Colors.black,
              style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 14),
              items: [
                const DropdownMenuItem<int>(value: null, child: Text("Select")),
                ...widget.items.map((StaffModel staff) {
                  return DropdownMenuItem<int>(
                    value: staff.id,
                    child: Text(
                      staff.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
              ],
              onChanged: widget.enabled
                  ? (int? newValue) {
                      setState(() {
                        _selectedId = newValue;
                      });
                      if (widget.onChanged != null) {
                        widget.onChanged!(newValue);
                      }
                    }
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
