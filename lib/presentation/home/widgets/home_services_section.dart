import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/cubit/home/service_cubit.dart';
import 'package:sharp_cut/cubit/home/service_cubit_state.dart';
import 'package:sharp_cut/presentation/expense/screens/screen_expense.dart';
import 'package:sharp_cut/presentation/home/screens/screen_search.dart';
import 'package:sharp_cut/presentation/home/widgets/action_button.dart';
import 'package:sharp_cut/presentation/home/widgets/added_item.dart';
import 'package:sharp_cut/presentation/home/widgets/cash_or_card.dart';
import 'package:sharp_cut/presentation/home/widgets/category_item.dart';
import 'package:sharp_cut/presentation/home/widgets/common_container.dart';
import 'package:sharp_cut/presentation/home/widgets/cutting_masters_dialog.dart';
import 'package:sharp_cut/presentation/home/widgets/features_bottons.dart';
import 'package:sharp_cut/presentation/home/widgets/menu_item.dart';
import 'package:sharp_cut/presentation/home/widgets/search_and_menu.dart';
import 'package:sharp_cut/presentation/home/widgets/service_item.dart';
import 'package:sharp_cut/presentation/printing/screens/screen_printing_settings.dart';
import 'package:sharp_cut/presentation/printing/widgets/print_count_dialog.dart';
import 'package:sharp_cut/presentation/printing/widgets/reset_password_dialog.dart';
import 'package:sharp_cut/utils/comon/password_showdialoge.dart';
import 'package:sharp_cut/utils/helpers/icon_helper.dart';

class HomeServicesSection extends StatefulWidget {
  const HomeServicesSection({super.key});

  @override
  State<HomeServicesSection> createState() => _HomeServicesSectionState();
}

class _HomeServicesSectionState extends State<HomeServicesSection> {
  final GlobalKey _menuKey = GlobalKey();
  final ValueNotifier<String> _selectedButtonNotifier = ValueNotifier(
    "BOOK A SLOT",
  );

  @override
  void initState() {
    super.initState();
    context.read<ServiceCubit>().getCategories();
  }

  @override
  void dispose() {
    _selectedButtonNotifier.dispose();
    super.dispose();
  }

  void _showMenu() async {
    final RenderBox renderBox =
        _menuKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    final selectedValue = await showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderBox.size.height + 10,
        offset.dx + renderBox.size.width,
        offset.dy + renderBox.size.height + 200,
      ),
      color: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white12),
      ),
      items: [
        PopupMenuItem(
          value: 1,
          child: MenuItem(
            icon: Icons.admin_panel_settings_outlined,
            text: "Reset Admin Password",
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: MenuItem(
            icon: Icons.badge_outlined,
            text: "Reset Staff Password",
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: MenuItem(icon: Icons.print_outlined, text: "Printer Settings"),
        ),
        PopupMenuItem(
          value: 4,
          child: MenuItem(icon: Icons.print, text: "Print Count"),
        ),
      ],
    );

    if (selectedValue != null && mounted) {
      switch (selectedValue) {
        case 1:
          ResetPasswordDialog.show(context, title: 'Reset Admin Password');
          break;
        case 2:
          ResetPasswordDialog.show(context, title: 'Reset Staff Password');
          break;
        case 3:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ScreenPrintingSettings(),
            ),
          );
          break;
        case 4:
          PrintCountDialog.show(context);
          break;
      }
    }
  }

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
            child: BlocBuilder<ServiceCubit, ServiceState>(
              builder: (context, state) {
                List<Widget> categories = [];

                if (state is ServiceStateSuccess) {
                  // Add "ALL" category
                  categories.add(
                    CategoryItem(
                      onTap: () {
                        context.read<ServiceCubit>().getServices(
                          categoryId: null,
                        );
                      },
                      title: "ALL",
                      icon: Icons.grid_view,
                      isSelected: state.selectedCategoryId == null,
                    ),
                  );
                  categories.add(const SizedBox(height: 12));

                  // Add dynamic categories
                  categories.addAll(
                    state.categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: CategoryItem(
                          onTap: () {
                            context.read<ServiceCubit>().getServices(
                              categoryId: category.id,
                            );
                          },
                          title: category.name ?? "Service",
                          icon: getIconForService(category.name),
                          isSelected: state.selectedCategoryId == category.id,
                        ),
                      );
                    }),
                  );
                } else if (state is ServiceStateLoading) {
                  categories.add(
                    const Center(child: CircularProgressIndicator()),
                  );
                }

                return ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: categories,
                );
              },
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
              child: BlocBuilder<ServiceCubit, ServiceState>(
                builder: (context, state) {
                  if (state is ServiceStateSuccess) {
                    if (state.isLoadingServices) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: state.services.length,
                      itemBuilder: (context, index) {
                        final service = state.services[index];
                        return InkWell(
                          onTap: () {
                            context.read<ServiceCubit>().addToCart(service);
                          },
                          child: ServiceItem(
                            title: service.name ?? "Service",
                            imagePath:
                                service.image ??
                                "lib/utils/images/hair_cut.png", // Placeholder image
                          ),
                        );
                      },
                    );
                  } else if (state is ServiceStateLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ServiceStateError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return const SizedBox();
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
                    child: BlocBuilder<ServiceCubit, ServiceState>(
                      builder: (context, state) {
                        if (state is ServiceStateSuccess) {
                          return ListView.separated(
                            padding: EdgeInsets.zero,
                            separatorBuilder: (context, index) {
                              return const SizedBox(height: 10);
                            },
                            itemCount: state.cartItems.length,
                            itemBuilder: (context, index) {
                              final item = state.cartItems[index];
                              return AddedItem(
                                item: item,
                                onIncrement: () {
                                  context.read<ServiceCubit>().updateQuantity(
                                    item,
                                    1,
                                  );
                                },
                                onDecrement: () {
                                  context.read<ServiceCubit>().updateQuantity(
                                    item,
                                    -1,
                                  );
                                },
                                onRemove: () {
                                  context.read<ServiceCubit>().removeFromCart(
                                    item,
                                  );
                                },
                              );
                            },
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),

                  // List would go here
                  const Divider(color: Colors.white24, height: 32),

                  // Totals
                  BlocBuilder<ServiceCubit, ServiceState>(
                    builder: (context, state) {
                      double subTotal = 0;
                      double vat = 0;
                      double total = 0;

                      if (state is ServiceStateSuccess) {
                        subTotal = state.subTotal;
                        vat = state.vat;
                        total = state.total;
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TotalItem(
                            label: "Sub Total",
                            value: subTotal.toStringAsFixed(2),
                          ),
                          TotalItem(label: "Discount", value: "0"),
                          TotalItem(
                            label: "Vat",
                            value: vat.toStringAsFixed(2),
                          ),
                          TotalItem(
                            label: "Total",
                            value: total.toStringAsFixed(2),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),

          // 4. Action Buttons Sidebar
          SizedBox(
            width: 200,
            child: ValueListenableBuilder<String>(
              valueListenable: _selectedButtonNotifier,
              builder: (context, selectedButton, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        SearchAndMenu(
                          icon: Icons.search,
                          onTap: () async {
                            await showPasswordDialoge(context);
                            if (true && context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ScreenSearch(),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        SearchAndMenu(
                          key: _menuKey,
                          icon: Icons.menu,
                          onTap: () {
                            _showMenu();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ActionButton(
                      label: "BOOK A SLOT",
                      isPrimary: selectedButton == "BOOK A SLOT",
                      onTap: () {
                        _selectedButtonNotifier.value = "BOOK A SLOT";
                        CuttingMastersDialog.show(context);
                      },
                    ),
                    const SizedBox(height: 12),
                    ActionButton(
                      label: "CLEAR",
                      isPrimary: selectedButton == "CLEAR",
                      onTap: () {
                        _selectedButtonNotifier.value = "CLEAR";
                      },
                    ),
                    const SizedBox(height: 12),
                    ActionButton(
                      label: "SAVE BOOKING",
                      isPrimary: selectedButton == "SAVE BOOKING",
                      onTap: () {
                        _selectedButtonNotifier.value = "SAVE BOOKING";
                      },
                    ),
                    const SizedBox(height: 12),
                    ActionButton(
                      key: quickPaymentKey,
                      label: "QUICK PAYMENT",
                      isPrimary: selectedButton == "QUICK PAYMENT",
                      onTap: () {
                        _selectedButtonNotifier.value = "QUICK PAYMENT";
                        showQuickPaymentPopup(context, () {}, () {});
                      },
                    ),
                    const SizedBox(height: 12),
                    ActionButton(
                      label: "SAVE & SETTLE BILL",
                      isPrimary: selectedButton == "SAVE & SETTLE BILL",
                      onTap: () {
                        _selectedButtonNotifier.value = "SAVE & SETTLE BILL";
                      },
                    ),
                    const SizedBox(height: 12),
                    ActionButton(
                      label: "ADD EXPENSE",
                      isPrimary: selectedButton == "ADD EXPENSE",
                      onTap: () async {
                        _selectedButtonNotifier.value = "ADD EXPENSE";
                        await showPasswordDialoge(context);
                        if (true && context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScreenExpense(),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    ActionButton(
                      label: "REPORT",
                      isPrimary: selectedButton == "REPORT",
                      onTap: () {
                        _selectedButtonNotifier.value = "REPORT";
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
