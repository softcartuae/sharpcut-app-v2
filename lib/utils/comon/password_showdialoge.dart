import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

void showPasswordDialoge(BuildContext context) {
  final TextEditingController passwordController = TextEditingController();
  String? selectedStaff;
  List<String> staffList = ["Staff 1", "Staff 2", "Staff 3"];

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              "Select Staff",
              style: GoogleFonts.rajdhani(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E1E1E),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Staff Name",
                  style: GoogleFonts.rajdhani(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedStaff,
                      hint: Text(
                        "Select Staff",
                        style: GoogleFonts.rajdhani(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      isExpanded: true,
                      items: staffList.map((String staff) {
                        return DropdownMenuItem<String>(
                          value: staff,
                          child: Text(
                            staff,
                            style: GoogleFonts.rajdhani(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedStaff = newValue;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Password",
                  style: GoogleFonts.rajdhani(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Password",
                      hintStyle: GoogleFonts.rajdhani(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    style: GoogleFonts.rajdhani(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancel",
                  style: GoogleFonts.rajdhani(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Handle submit logic here
                  Navigator.pop(context);
                  passwordController.clear();
                  setState(() {
                    selectedStaff = null;
                  });
                },
                child: Text(
                  "Submit",
                  style: GoogleFonts.rajdhani(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E2130),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
