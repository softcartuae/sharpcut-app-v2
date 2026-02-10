import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sharp_cut/cubit/booking/booking_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_state.dart';
import 'package:sharp_cut/cubit/cash_registory/cash_registory_cubit.dart';
import 'package:sharp_cut/cubit/cash_registory/cash_registory_state.dart';
import 'package:sharp_cut/cubit/home/chair_cubit.dart';
import 'package:sharp_cut/cubit/home/service_cubit.dart';
import 'package:sharp_cut/cubit/home/service_cubit_state.dart';
import 'package:sharp_cut/domain/booking/models/save_booking_request_model.dart';
import 'package:sharp_cut/domain/home/models/cart_item_model.dart';
import 'package:sharp_cut/cubit/home/chair_state.dart';
import 'package:sharp_cut/presentation/cash_registory/screens/open_cash_registory_dialoge.dart';
import 'package:sharp_cut/presentation/cash_registory/screens/close_cash_register_dialog.dart';
import 'package:sharp_cut/presentation/expense/screens/screen_expense.dart';
import 'package:sharp_cut/presentation/expense/screens/screen_settlement.dart';
import 'package:sharp_cut/presentation/home/screens/screen_search.dart';
import 'package:sharp_cut/presentation/home/widgets/action_button.dart';
import 'package:sharp_cut/presentation/home/widgets/added_item.dart';
import 'package:sharp_cut/presentation/home/widgets/cash_or_card.dart';
import 'package:sharp_cut/presentation/home/widgets/category_item.dart';
import 'package:sharp_cut/presentation/home/widgets/common_container.dart';
import 'package:sharp_cut/presentation/home/widgets/features_bottons.dart';
import 'package:sharp_cut/presentation/home/widgets/menu_item.dart';
import 'package:sharp_cut/presentation/home/widgets/search_and_menu.dart';
import 'package:sharp_cut/presentation/home/widgets/service_item.dart';
import 'package:sharp_cut/presentation/printing/cubit/printing_cubit.dart';
import 'package:sharp_cut/presentation/printing/screens/screen_printing_settings.dart';
import 'package:sharp_cut/presentation/printing/widgets/print_count_dialog.dart';
import 'package:sharp_cut/presentation/printing/widgets/reset_password_dialog.dart';
import 'package:sharp_cut/presentation/quick_report/screens/screen_quick_report.dart';
import 'package:sharp_cut/presentation/home/widgets/tip_dialoge.dart';
import 'package:sharp_cut/utils/helpers/enums.dart';
import 'package:sharp_cut/utils/helpers/toast_helper.dart';

import 'package:sharp_cut/utils/helpers/icon_helper.dart';
import 'package:sharp_cut/utils/comon/validate_password.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/utils/helpers/check_no_chair.dart';
import 'package:sharp_cut/utils/helpers/booking_flow_helper.dart';
import 'package:sharp_cut/presentation/home/widgets/cancellation_dialog.dart';
import 'package:sharp_cut/cubit/booking/booking_form_cubit.dart';
import 'package:sharp_cut/cubit/auth/auth_cubit.dart';
import 'package:sharp_cut/data/sync/sync_to_server.dart';
import 'package:sharp_cut/presentation/sync/cubit/sync_cubit.dart';

class HomeServicesSection extends StatefulWidget {
  const HomeServicesSection({super.key});

  @override
  State<HomeServicesSection> createState() => _HomeServicesSectionState();
}

class _PendingPrintData {
  final int? chairId;
  final double balanceAmount;
  final SettlePaymentRequestModel request;
  final dynamic shopData;
  final List<CartItemModel> cartItems;
  final String? staffName;

  final String bookingTime;

  _PendingPrintData({
    required this.chairId,
    required this.balanceAmount,
    required this.request,
    required this.shopData,
    required this.cartItems,
    required this.staffName,
    required this.bookingTime,
  });
}

class _HomeServicesSectionState extends State<HomeServicesSection> {
  final GlobalKey _menuKey = GlobalKey();
  final ValueNotifier<String> _selectedButtonNotifier = ValueNotifier(
    "BOOK A SLOT",
  );
  _PendingPrintData? _pendingPrintData;

  @override
  void initState() {
    super.initState();
    context.read<ServiceCubit>().getCategories();
  }

  void _settlePayment(
    BuildContext context,
    int? transactionId,
    int? userId,
    ServiceStateSuccess serviceState,
    BookingFormState bookingFormState,
    String paymentMode,
    String? staffName,
    String? bookingTime,
    double discount,
    double finalTotal,
    int? chairId,
  ) {
    if ((discount) > finalTotal) {
      ToastHelper.showError("Total amount cannot be greater than Final Total");
      return;
    }
    // calculate the amount after discount
    double amount = serviceState.total - discount;
    double balanceAmount = 0.0;

    // if user click unpaid then make the amount zero and the payment methord zero;
    if (paymentMode == PaymentMode.Unpaid.name) {
      log("unpaid is selected");
      balanceAmount = serviceState.total;
      amount = 0.0;
    } else {}

    log("amount: $amount");
    log("discount: $discount");
    log("finalTotal: $finalTotal");
    log("serviceState.total: ${serviceState.total}");

    final request = SettlePaymentRequestModel(
      paymentStatus: paymentMode == PaymentMode.Unpaid.name ? "unpaid" : "full",
      transactionId: transactionId,
      customerName: bookingFormState.customerName,
      customerNumber: bookingFormState.customerNumber,
      subTotalValue: serviceState.subTotal,
      taxTotal: serviceState.vat,
      discount: discount,
      roundOff: 0.0,
      finalTotal: finalTotal,
      finalTotalbefore: finalTotal + discount,
      serviceId: serviceState.cartItems.map((e) => e.service.id!).toList(),
      quantity: serviceState.cartItems.map((e) => e.quantity).toList(),
      rate: serviceState.cartItems.map((e) => e.service.price ?? 0.0).toList(),
      taxAmount: serviceState.cartItems
          .map((e) => e.service.unitTax ?? 0)
          .toList(), // Placeholder
      currency: serviceState.cartItems.map((e) => "AED").toList(),
      amountTotal: serviceState.cartItems
          .map((e) => (e.service.price ?? 0.0) * e.quantity)
          .toList(),
      tax: serviceState.cartItems
          .map((e) => (e.service.unitTax ?? 0.0) * e.quantity)
          .toList(), // Placeholder
      subTotalList: serviceState.cartItems.map((e) {
        final price = e.service.price ?? 0.0;
        final tax = e.service.unitTax ?? 0.0;
        return (price + tax) * e.quantity;
      }).toList(),
      isTip: serviceState.cartItems.map((e) => e.service.isTip ?? 0).toList(),
      collectedUserId: [userId!], // Placeholder
      mode: [paymentMode == PaymentMode.Unpaid.name ? "Cash" : paymentMode],
      amount: [amount],
      tenderCash: [0.0],
      change: [0.0],
    );

    final shopData = context.read<AuthCubit>().currentUser;
    if (shopData != null) {
      _pendingPrintData = _PendingPrintData(
        chairId: chairId,
        balanceAmount: balanceAmount,
        request: request,
        shopData: shopData,
        cartItems: serviceState.cartItems,
        staffName: staffName,
        bookingTime: bookingTime ?? "--:--",
      );
    }
    context.read<BookingCubit>().quickPayment(request: request);
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
        PopupMenuItem(
          value: 5,
          child: MenuItem(icon: Icons.logout, text: "Logout"),
        ),
        PopupMenuItem(
          value: 6,
          child: MenuItem(
            icon: Icons.receipt_long,
            text: "Print Register Report",
          ),
        ),
      ],
    );

    if (selectedValue != null && mounted) {
      switch (selectedValue) {
        case 1:
          ResetPasswordDialog.show(
            context,
            title: 'Reset Admin Password',
            isAdmin: true,
          );
          break;
        case 2:
          ResetPasswordDialog.show(
            context,
            title: 'Reset Staff Password',
            isAdmin: false,
          );
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
        case 5:
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text("Logout"),
              content: const Text("Are you sure you want to logout?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<AuthCubit>().logout();
                  },
                  child: const Text("Logout"),
                ),
              ],
            ),
          );
          break;
        case 6:
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text("Print Last Report"),
              content: const Text(
                "Are you sure you want to print the last close register report?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context
                        .read<CashRegistoryCubit>()
                        .getLastCloseRegisterReport();
                  },
                  child: const Text("Print"),
                ),
              ],
            ),
          );
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ChairCubit, ChairState>(
          listener: (context, state) {
            final shop = context.read<AuthCubit>().currentUser;
            final isNoChair = CheckNoChair.checkIsThisAppNoChairOrNot(shop);
            final bookingState = context.read<BookingCubit>().state;

            if (isNoChair && state is ChairSuccess && state.chairs.isNotEmpty) {
              final chair = state.chairs.first;
              if (chair.liveState == LiveState.occupied.name &&
                  chair.transaction != null &&
                  bookingState is! BookingSuccess) {
                // Auto restore
                context.read<BookingCubit>().restoreBooking(
                  bookingResponse: chair.transaction!,
                );
              }
            }
          },
        ),
        BlocListener<BookingCubit, BookingState>(
          listener: (context, state) {
            if (state is BookingSaved) {
              ToastHelper.showSuccess(state.message);
              // Optionally clear cart or reset state
            } else if (state is BookingError) {
              ToastHelper.showError(state.message);
              if (state.message == "This chair is already booked") {
                context.read<ChairCubit>().getChairsAndStaffs(
                  forceRefresh: true,
                );
              }
            } else if (state is BookingPaymentSettled) {
              if (_pendingPrintData != null) {
                final printCubit = context.read<PrintingCubit>();
                printCubit.printInvoice(
                  chairId: _pendingPrintData!.chairId,
                  printCount: printCubit.state.settings?.printCount.quickPayment
                      .toInt(),
                  balanceAmount: _pendingPrintData!.balanceAmount,
                  request: _pendingPrintData!.request,
                  shopData: _pendingPrintData!.shopData,
                  cartItems: _pendingPrintData!.cartItems,
                  staffName: _pendingPrintData!.staffName,
                  invoiceNumber: state.response.bookingResponse?.invoiceNo,
                  bookingTime: _pendingPrintData!.bookingTime,
                  invoiceDate: state.response.bookingResponse?.invoiceDate,
                );
                _pendingPrintData = null;
              }
              ToastHelper.showSuccess(state.message);
              context.read<ServiceCubit>().clearCart();
              context.read<ChairCubit>().getChairsAndStaffs(forceRefresh: true);
              // Optionally clear cart or reset state
            } else if (state is BookingSuccess) {
              context.read<ChairCubit>().getChairsAndStaffs(forceRefresh: true);
            }
          },
        ),
        BlocListener<CashRegistoryCubit, CashRegistoryState>(
          listener: (context, state) {
            if (state is CashRegistoryReportLoaded) {
              final shop = context.read<AuthCubit>().currentUser;
              if (shop != null) {
                final printCubit = context.read<PrintingCubit>();
                printCubit.printCloseRegisterReport(
                  report: state.report,
                  shop: shop,
                  printCount: printCubit.state.settings?.printCount.report
                      .toInt(),
                );
              } else {
                ToastHelper.showError("Shop data not found");
              }
            } else if (state is CashRegistoryAddError) {
              ToastHelper.showError(state.message);
            }
          },
        ),
        BlocListener<SyncCubit, SyncState>(
          listener: (context, state) {
            if (state is SyncSuccess) {
              ToastHelper.showSuccess(state.message);
              if (_selectedButtonNotifier.value == "REPORT") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScreenQuickReport()),
                );
              }
            } else if (state is SyncError) {
              ToastHelper.showError(state.message);
            }
          },
        ),
      ],
      child: SizedBox(
        height: 450, // Fixed height for now, can be flexible later
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Category Sidebar
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: BlocBuilder<ServiceCubit, ServiceState>(
                  buildWhen: (p, c) {
                    if (p is ServiceStateSuccess && c is ServiceStateSuccess) {
                      return p.categories != c.categories ||
                          p.selectedCategoryId != c.selectedCategoryId;
                    }
                    return true;
                  },
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
                              isSelected:
                                  state.selectedCategoryId == category.id,
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
            ),
            const SizedBox(width: 8),

            // 2. Services Grid
            Expanded(
              flex: 6,
              child: BlocBuilder<BookingCubit, BookingState>(
                builder: (context, bookingState) {
                  final isBooked = bookingState is BookingSuccess;
                  return Opacity(
                    opacity: isBooked ? 1.0 : 0.5,
                    child: RepaintBoundary(
                      child: CommonContainer(
                        height: MediaQuery.of(context).size.height,
                        borderRadius: BorderRadius.circular(15),
                        backgroundImageUrl: "lib/utils/images/Card.png",
                        padding: const EdgeInsets.all(16),
                        child: BlocBuilder<ServiceCubit, ServiceState>(
                          buildWhen: (previous, current) {
                            if (previous is ServiceStateSuccess &&
                                current is ServiceStateSuccess) {
                              return previous.services != current.services ||
                                  previous.isLoadingServices !=
                                      current.isLoadingServices;
                            }
                            return true;
                          },
                          builder: (context, state) {
                            if (state is ServiceStateSuccess) {
                              if (state.isLoadingServices) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
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
                                      if (!isBooked) {
                                        ToastHelper.showError(
                                          "You have to book first",
                                        );
                                        return;
                                      }
                                      if (service.isTip == 1) {
                                        // if it tip then we need to find the before wat and unit tax ok

                                        showDialog(
                                          context: context,
                                          builder: (context) => TipDialog(
                                            onTipSelected: (amount) {
                                              final taxPercentage =
                                                  service.taxPercentage ?? 0;

                                              final beforeTax = double.parse(
                                                (amount *
                                                        100 /
                                                        (100 + taxPercentage))
                                                    .toStringAsFixed(2),
                                              );

                                              final taxAmount = double.parse(
                                                (amount - beforeTax)
                                                    .toStringAsFixed(2),
                                              );

                                              context
                                                  .read<ServiceCubit>()
                                                  .addToCart(
                                                    service.copyWith(
                                                      unitTax: taxAmount,
                                                      charge: amount,
                                                      beforeVat: beforeTax,
                                                    ),
                                                  );
                                            },
                                          ),
                                        );
                                      } else {
                                        context.read<ServiceCubit>().addToCart(
                                          service,
                                        );
                                      }
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
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (state is ServiceStateError) {
                              return Center(
                                child: Text(
                                  "Something went wrong",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),

            // 3. Order Summary Panel
            Expanded(
              flex: 6,
              child: CommonContainer(
                height: MediaQuery.of(context).size.height,
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
                          "Name",
                          style: GoogleFonts.rajdhani(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Qty",
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
                          log("vat is $vat");
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
            const SizedBox(width: 10),

            // 4. Action Buttons Sidebar
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: BlocBuilder<BookingCubit, BookingState>(
                  builder: (context, bookingState) {
                    final isBooked = bookingState is BookingSuccess;
                    return ValueListenableBuilder<String>(
                      valueListenable: _selectedButtonNotifier,
                      builder: (context, selectedButton, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                SearchAndMenu(
                                  icon: Icons.search,
                                  onTap: isBooked
                                      ? null
                                      : () async {
                                          showPasswordForValidation(
                                            showAdminToo: true,
                                            context,
                                            false,
                                            onSuccessWithStaff: (staff) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ScreenSearch(
                                                        staff: staff,
                                                      ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                ),
                                const SizedBox(width: 12),
                                SearchAndMenu(
                                  key: _menuKey,
                                  icon: Icons.menu,
                                  onTap: isBooked
                                      ? null
                                      : () {
                                          _showMenu();
                                        },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // BOOK A SLOT - Disabled if already booked
                            if (!isBooked)
                              BlocConsumer<
                                CashRegistoryCubit,
                                CashRegistoryState
                              >(
                                listener: (context, state) {
                                  if (state is CashRegistorOpen) {
                                    BookingFlowHelper.handleBookingAction(
                                      context,
                                    );
                                  }

                                  if (state is CashRegistorClosed) {
                                    showCashRegistoryDialoge(context);
                                  }
                                },
                                builder: (context, state) {
                                  return Opacity(
                                    opacity: isBooked ? 0.5 : 1.0,
                                    child: ActionButton(
                                      label: isBooked
                                          ? "SLOT BOOKED"
                                          : "BOOK A SLOT",
                                      isPrimary:
                                          !isBooked &&
                                          selectedButton == "BOOK A SLOT",
                                      isLoading:
                                          state is CashRegistoryLoading &&
                                          selectedButton == "BOOK A SLOT",
                                      onTap: isBooked
                                          ? null
                                          : () {
                                              _selectedButtonNotifier.value =
                                                  "BOOK A SLOT";
                                              context
                                                  .read<CashRegistoryCubit>()
                                                  .checkCashRegisterStatus();
                                            },
                                    ),
                                  );
                                },
                              ),

                            // CANCEL BOOKING - Visible only if Booked and No Chair
                            if (isBooked)
                              Builder(
                                builder: (context) {
                                  final shop = context
                                      .read<AuthCubit>()
                                      .currentUser;
                                  final isNoChair =
                                      CheckNoChair.checkIsThisAppNoChairOrNot(
                                        shop,
                                      );
                                  if (!isNoChair) {
                                    return const SizedBox.shrink();
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: ActionButton(
                                      label: "CANCEL BOOKING",
                                      isPrimary:
                                          false, // Or make it red/distinguishable
                                      onTap: () {
                                        final bookingState = context
                                            .read<BookingCubit>()
                                            .state;
                                        if (bookingState is BookingSuccess &&
                                            bookingState.bookingResponse.id !=
                                                null) {
                                          CancellationDialog.show(
                                            context,
                                            bookingState.bookingResponse.id!,
                                          );
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),

                            if (isBooked) const SizedBox(height: 12),
                            // QUICK PAYMENT - Disabled if NOT booked
                            if (isBooked)
                              Opacity(
                                opacity: !isBooked ? 0.5 : 1.0,
                                child: ActionButton(
                                  label: "QUICK PAYMENT",
                                  isPrimary:
                                      isBooked &&
                                      selectedButton == "QUICK PAYMENT",
                                  onTap: !isBooked
                                      ? null
                                      : () {
                                          _selectedButtonNotifier.value =
                                              "QUICK PAYMENT";

                                          final serviceState = context
                                              .read<ServiceCubit>()
                                              .state;
                                          if (serviceState
                                              is ServiceStateSuccess) {
                                            if (serviceState
                                                .cartItems
                                                .isEmpty) {
                                              ToastHelper.showError(
                                                "You have to select the services",
                                              );
                                              return;
                                            }

                                            int? transactionId;
                                            int? userId;
                                            if (bookingState
                                                is BookingSuccess) {
                                              transactionId = bookingState
                                                  .bookingResponse
                                                  .id;
                                              userId = bookingState
                                                  .bookingResponse
                                                  .userId;
                                            }

                                            final bookingFormState = context
                                                .read<BookingFormCubit>()
                                                .state;

                                            if (bookingFormState
                                                .customerName
                                                .isEmpty) {
                                              ToastHelper.showError(
                                                "Customer name is required",
                                              );
                                              return;
                                            }

                                            if (bookingFormState
                                                .customerNumber
                                                .isEmpty) {
                                              ToastHelper.showError(
                                                "Customer number is required",
                                              );
                                              return;
                                            }

                                            showQuickPaymentPopup(
                                              context,
                                              (discount) {
                                                // Cash Selected
                                                _settlePayment(
                                                  context,
                                                  transactionId,
                                                  userId,
                                                  serviceState,
                                                  bookingFormState,
                                                  PaymentMode.Cash.name,

                                                  bookingState
                                                      .bookingResponse
                                                      .staff
                                                      ?.name,
                                                  bookingState
                                                      .bookingResponse
                                                      .transactionDate,
                                                  discount,
                                                  serviceState.total,
                                                  bookingState
                                                      .bookingResponse
                                                      .chairId,
                                                );
                                              },
                                              (discount) {
                                                // Card Selected
                                                _settlePayment(
                                                  context,
                                                  transactionId,
                                                  userId,
                                                  serviceState,
                                                  bookingFormState,
                                                  PaymentMode.Card.name,

                                                  bookingState
                                                      .bookingResponse
                                                      .staff
                                                      ?.name,
                                                  bookingState
                                                      .bookingResponse
                                                      .transactionDate,

                                                  discount,
                                                  serviceState.total,
                                                  bookingState
                                                      .bookingResponse
                                                      .chairId,
                                                );
                                              },
                                              (discount) {
                                                _settlePayment(
                                                  context,
                                                  transactionId,
                                                  userId,
                                                  serviceState,
                                                  bookingFormState,
                                                  PaymentMode.Unpaid.name,

                                                  bookingState
                                                      .bookingResponse
                                                      .staff
                                                      ?.name,
                                                  bookingState
                                                      .bookingResponse
                                                      .transactionDate,

                                                  discount,
                                                  serviceState.total,
                                                  bookingState
                                                      .bookingResponse
                                                      .chairId,
                                                );
                                              },
                                              total: serviceState.total,
                                              discount: 0.0,
                                              grandTotal: serviceState.subTotal,
                                            );
                                          }
                                        },
                                ),
                              ),
                            if (isBooked) const SizedBox(height: 12),
                            // SAVE & SETTLE BILL - Disabled if NOT booked
                            if (isBooked)
                              Opacity(
                                opacity: !isBooked ? 0.5 : 1.0,
                                child: ActionButton(
                                  label: "SAVE & SETTLE BILL",
                                  isPrimary:
                                      isBooked &&
                                      selectedButton == "SAVE & SETTLE BILL",
                                  onTap: !isBooked
                                      ? null
                                      : () {
                                          _selectedButtonNotifier.value =
                                              "SAVE & SETTLE BILL";

                                          final serviceState = context
                                              .read<ServiceCubit>()
                                              .state;
                                          if (serviceState
                                              is ServiceStateSuccess) {
                                            if (serviceState
                                                .cartItems
                                                .isEmpty) {
                                              ToastHelper.showError(
                                                "You have to select the services",
                                              );
                                              return;
                                            }

                                            int? transactionId;
                                            int? userId;
                                            if (bookingState
                                                is BookingSuccess) {
                                              transactionId = bookingState
                                                  .bookingResponse
                                                  .id;
                                              userId = bookingState
                                                  .bookingResponse
                                                  .userId;
                                            }

                                            final bookingFormState = context
                                                .read<BookingFormCubit>()
                                                .state;

                                            SettlePaymentRequestModel
                                            request = SettlePaymentRequestModel(
                                              finalTotalbefore:
                                                  serviceState.total + 0,
                                              transactionId: transactionId,
                                              customerName:
                                                  bookingFormState.customerName,
                                              customerNumber: bookingFormState
                                                  .customerNumber,
                                              subTotalValue:
                                                  serviceState.subTotal,
                                              taxTotal: serviceState.vat,
                                              discount: 0.0,
                                              roundOff: 0.0,
                                              finalTotal: serviceState.total,
                                              serviceId: serviceState.cartItems
                                                  .map((e) => e.service.id!)
                                                  .toList(),
                                              quantity: serviceState.cartItems
                                                  .map((e) => e.quantity)
                                                  .toList(),
                                              rate: serviceState.cartItems
                                                  .map(
                                                    (e) =>
                                                        e.service.price ?? 0.0,
                                                  )
                                                  .toList(),
                                              taxAmount: serviceState.cartItems
                                                  .map(
                                                    (e) =>
                                                        e.service.unitTax ?? 0,
                                                  )
                                                  .toList(), // Placeholder
                                              currency: serviceState.cartItems
                                                  .map((e) => "AED")
                                                  .toList(),
                                              amountTotal: serviceState
                                                  .cartItems
                                                  .map(
                                                    (e) =>
                                                        (e.service.price ??
                                                            0.0) *
                                                        e.quantity,
                                                  )
                                                  .toList(),
                                              tax: serviceState.cartItems
                                                  .map(
                                                    (e) =>
                                                        (e.service.unitTax ??
                                                            0.0) *
                                                        e.quantity,
                                                  )
                                                  .toList(),
                                              subTotalList: serviceState
                                                  .cartItems
                                                  .map((e) {
                                                    final price =
                                                        e.service.price ?? 0.0;
                                                    final tax =
                                                        e.service.unitTax ??
                                                        0.0;
                                                    return (price + tax) *
                                                        e.quantity;
                                                  })
                                                  .toList(),
                                              isTip: serviceState.cartItems
                                                  .map(
                                                    (e) => e.service.isTip ?? 0,
                                                  )
                                                  .toList(),
                                              collectedUserId: [
                                                userId!,
                                              ], // Placeholder
                                              mode: [],
                                              amount: [serviceState.total],
                                              tenderCash: [0.0],
                                              change: [0.0],
                                            );

                                            showSettlementDialog(
                                              context,
                                              settlePayment: request,
                                              staffName: bookingState
                                                  .bookingResponse
                                                  .staff
                                                  ?.name,
                                              bookingTime: bookingState
                                                  .bookingResponse
                                                  .transactionDate,

                                              cartItems: serviceState.cartItems,
                                              chairId: bookingState
                                                  .bookingResponse
                                                  .chairId,
                                            );
                                          }
                                        },
                                ),
                              ),
                            if (!isBooked) const SizedBox(height: 12),
                            if (!isBooked)
                              Opacity(
                                opacity: isBooked ? 0.5 : 1.0,
                                child: ActionButton(
                                  label: "STAFF EXPENSE",
                                  isPrimary: selectedButton == "STAFF EXPENSE",
                                  onTap: isBooked
                                      ? null
                                      : () {
                                          _selectedButtonNotifier.value =
                                              "STAFF EXPENSE";
                                          showPasswordForValidation(
                                            context,
                                            false,
                                            onSuccessWithStaff: (staff) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ScreenExpense(
                                                        staff: staff,
                                                      ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                ),
                              ),
                            if (isBooked) const SizedBox(height: 12),
                            if (isBooked)
                              Builder(
                                builder: (context) {
                                  final shop = context
                                      .read<AuthCubit>()
                                      .currentUser;
                                  final isNoChair =
                                      CheckNoChair.checkIsThisAppNoChairOrNot(
                                        shop,
                                      );

                                  if (isNoChair) {
                                    return const SizedBox.shrink();
                                  }

                                  return Opacity(
                                    opacity: isBooked ? 1.0 : 0.5,
                                    child: ActionButton(
                                      label: "BACK",
                                      isPrimary: selectedButton == "BACK",
                                      onTap: !isBooked
                                          ? null
                                          : () {
                                              _selectedButtonNotifier.value =
                                                  "BACK";
                                              context
                                                  .read<BookingCubit>()
                                                  .backToInitialState();
                                              context
                                                  .read<ServiceCubit>()
                                                  .clearCart();
                                            },
                                    ),
                                  );
                                },
                              ),
                            const SizedBox(height: 12),
                            if (!isBooked)
                              BlocBuilder<SyncCubit, SyncState>(
                                builder: (context, state) {
                                  return ActionButton(
                                    label: "REPORT",
                                    isPrimary: selectedButton == "REPORT",
                                    isLoading:
                                        state is SyncLoading &&
                                        selectedButton == "REPORT",
                                    onTap: isBooked
                                        ? null
                                        : () async {
                                            _selectedButtonNotifier.value =
                                                "REPORT";
                                            final isSynced =
                                                await SyncToServer()
                                                    .isFullySynced();
                                            isSynced.fold(
                                              (l) => ToastHelper.showError(
                                                "You can navigate only after sync",
                                              ),
                                              (r) {
                                                if (r) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ScreenQuickReport(),
                                                    ),
                                                  );
                                                } else {
                                                  ToastHelper.showToast(
                                                    msg:
                                                        "Syncing data first...",
                                                    backgroundColor:
                                                        Colors.orange,
                                                  );
                                                  context
                                                      .read<SyncCubit>()
                                                      .syncTransactions();
                                                }
                                              },
                                            );
                                          },
                                  );
                                },
                              ),
                            const SizedBox(height: 12),
                            if (!isBooked)
                              BlocConsumer<
                                CashRegistoryCubit,
                                CashRegistoryState
                              >(
                                listener: (context, state) {
                                  if (state is CashRegistorySalesTotalLoaded) {
                                    CloseCashRegisterDialog.show(
                                      context,
                                      state.closeRegisterModel,
                                    );
                                  } else if (state is CashRegistoryAddError) {
                                    ToastHelper.showError(state.message);
                                  }
                                },
                                builder: (context, state) {
                                  return ActionButton(
                                    isLoading:
                                        state is CashRegistoryLoading &&
                                        selectedButton == "CLOSE REGISTER",
                                    label: "CLOSE REGISTER",
                                    isPrimary:
                                        selectedButton == "CLOSE REGISTER",
                                    onTap: isBooked
                                        ? null
                                        : () async {
                                            _selectedButtonNotifier.value =
                                                "CLOSE REGISTER";
                                            final isSynced =
                                                await SyncToServer()
                                                    .isFullySynced();
                                            isSynced.fold(
                                              (l) => ToastHelper.showError(
                                                "You can close register only after sync",
                                              ),
                                              (r) {
                                                if (r) {
                                                  context
                                                      .read<
                                                        CashRegistoryCubit
                                                      >()
                                                      .getSalesTotal();
                                                } else {
                                                  ToastHelper.showError(
                                                    "You can close register only after sync",
                                                  );
                                                }
                                              },
                                            );
                                          },
                                  );
                                },
                              ),
                            const SizedBox(height: 12),
                            if (!isBooked)
                              BlocBuilder<SyncCubit, SyncState>(
                                builder: (context, state) {
                                  return ActionButton(
                                    isLoading:
                                        selectedButton == "SYNC" &&
                                        state is SyncLoading,
                                    label: "SYNC",
                                    isPrimary: selectedButton == "SYNC",
                                    onTap: isBooked
                                        ? null
                                        : () {
                                            _selectedButtonNotifier.value =
                                                "SYNC";
                                            context
                                                .read<SyncCubit>()
                                                .syncTransactions();
                                          },
                                  );
                                },
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
