import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportTableRow extends StatelessWidget {
  final int index;

  const ReportTableRow({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.white : Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          _buildDataCell(
            "",
            width: 50,
            isCheckbox: true,
            isChecked: index == 0,
          ),
          _buildDataCell("${index + 1}", width: 50),
          _buildDataCell("-", width: 60),
          _buildDataCell("07-Jun-24\n04:45PM", width: 100),
          _buildDataCell("A10068", width: 80),
          _buildDataCell("07-Jun-24\n04:45PM", width: 100),
          _buildDataCell("PICKUP", width: 80),
          _buildDataCell("0000000000", width: 100),
          _buildDataCell("Name", width: 100),
          _buildDataCell("Cash Customer\nAdderss", width: 150),
          _buildDataCell("-", width: 80),
          _buildDataCell("0.00", width: 80),
          _buildDataCell("0.00", width: 80),
          _buildDataCell("0.00", width: 80),
          _buildDataCell("ASHRAF", width: 100),
          _buildActionCell(Icons.print, width: 60, onTap: () {}),
          _buildActionCell(Icons.visibility, width: 60, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildDataCell(
    String text, {
    required double width,
    bool isCheckbox = false,
    bool isChecked = false,
  }) {
    return SizedBox(
      width: width,
      child: isCheckbox
          ? Center(
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: isChecked ? Colors.blue : Colors.transparent,
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isChecked
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                text,
                style: GoogleFonts.rajdhani(
                  color: Colors.grey[800],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
    );
  }

  Widget _buildActionCell(
    IconData icon, {
    required double width,
    void Function()? onTap,
  }) {
    return SizedBox(
      width: width,
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Icon(icon, size: 20, color: Colors.black),
        ),
      ),
    );
  }
}
