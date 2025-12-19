
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/presentation/expense/screens/screen_settlement.dart';
import 'package:sharp_cut/presentation/home/widgets/action_button.dart';
import 'package:sharp_cut/presentation/home/widgets/added_item.dart';
import 'package:sharp_cut/presentation/home/widgets/category_item.dart';
import 'package:sharp_cut/presentation/home/widgets/common_container.dart';
import 'package:sharp_cut/presentation/home/widgets/features_bottons.dart';
import 'package:sharp_cut/presentation/home/widgets/search_and_menu.dart';
import 'package:sharp_cut/presentation/home/widgets/service_item.dart';

class HomeServicesSection extends StatelessWidget {
  const HomeServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600, // Fixed height for now, can be flexible later
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Category Sidebar
          SizedBox(
            width: 200,
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                CategoryItem(
                  title: "ALL",
                  icon: Icons.grid_view,
                  isSelected: true,
                ),
                const SizedBox(height: 12),
                CategoryItem(title: "Hair Cutting", icon: Icons.content_cut),
                const SizedBox(height: 12),
                CategoryItem(title: "Shaving", icon: Icons.face),
                const SizedBox(height: 12),
                CategoryItem(title: "Facial", icon: Icons.person_outline),
                const SizedBox(height: 12),
                CategoryItem(title: "Hair Cutting", icon: Icons.content_cut),
                const SizedBox(height: 12),
                CategoryItem(title: "Shaving", icon: Icons.face),
                const SizedBox(height: 12),
                CategoryItem(title: "Facial", icon: Icons.person_outline),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // 2. Services Grid
          Expanded(
            flex: 3,
            child: CommonContainer(
              borderRadius: BorderRadius.circular(15),
              backgroundImageUrl: "lib/utils/images/Card.png",
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  return ServiceItem(
                    title: "Service $index",
                    imagePath: "lib/utils/images/hair_cut.png",
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 24),

          // 3. Order Summary Panel
          Expanded(
            flex: 3,
            child: CommonContainer(
              borderRadius: BorderRadius.circular(15),
              backgroundImageUrl: "lib/utils/images/Card.png",
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Item Name",
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Quantity",
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Amount",
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 32),

                  Expanded(
                    child: ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return AddedItem();
                      },
                    ),
                  ),

                  // List would go here
                  const Divider(color: Colors.white24, height: 32),

                  // Totals
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TotalItem(label: "Sub Total", value: "0"),
                      TotalItem(label: "Discount", value: "0"),
                      TotalItem(label: "Vat", value: "0"),
                      TotalItem(label: "Total", value: "0"),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),

          // 4. Action Buttons Sidebar
          SizedBox(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    SearchAndMenu(icon: Icons.search, onTap: () {}),
                    const SizedBox(width: 12),
                    SearchAndMenu(icon: Icons.menu, onTap: () {}),
                  ],
                ),
                const SizedBox(height: 12),
                ActionButton(
                  label: "BOOK A SLOT",
                  isPrimary: true,
                  onTap: () {
                    // calling cutting_master_dialoge
                    showSettlementDialog(context);
                  },
                ),
                const SizedBox(height: 12),
                ActionButton(label: "CLEAR"),
                const SizedBox(height: 12),
                ActionButton(label: "SAVE BOOKING"),
                const SizedBox(height: 12),
                ActionButton(label: "QUICK PAYMENT"),
                const SizedBox(height: 12),
                ActionButton(label: "SAVE & SETTLE BILL"),
                const SizedBox(height: 12),
                ActionButton(label: "ADD EXPENSE"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


