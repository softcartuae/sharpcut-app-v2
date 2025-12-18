import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/presentation/home/widgets/home_appbar.dart';

class ScreenExpense extends StatelessWidget {
  const ScreenExpense({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const HomeAppBar(),
            const SizedBox(height: 40),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        "ADD EXPENSE",
                        style: GoogleFonts.rajdhani(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E1E1E),
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE0E0E0)),

                    // Form Section
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "STAFF NAME",
                            style: GoogleFonts.rajdhani(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E1E1E),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                              color: const Color(0xFFF9F9F9),
                              child: Text(
                                "Name",
                                style: GoogleFonts.rajdhani(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E2130),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "Add",
                                  style: GoogleFonts.rajdhani(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E2130),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "Submit",
                                  style: GoogleFonts.rajdhani(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Table Header
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              "Date",
                              style: GoogleFonts.rajdhani(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: const Color(0xFF1E1E1E),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              "Items",
                              style: GoogleFonts.rajdhani(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: const Color(0xFF1E1E1E),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              "Amount",
                              style: GoogleFonts.rajdhani(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: const Color(0xFF1E1E1E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Table Row (Example)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                  color: const Color(0xFFF9F9F9),
                                  child: Text(
                                    "16/06/2024",
                                    style: GoogleFonts.rajdhani(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(),
                                  color: const Color(0xFFF9F9F9),
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Name",
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
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(),
                                  color: const Color(0xFFF9F9F9),
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Amount",
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
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: Color(0xFFE0E0E0)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
