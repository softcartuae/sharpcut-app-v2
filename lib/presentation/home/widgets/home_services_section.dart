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
import 'package:sharp_cut/presentation/home/widgets/cutting_masters_dialog.dart';
import 'package:sharp_cut/presentation/home/widgets/features_bottons.dart';
import 'package:sharp_cut/presentation/home/widgets/menu_item.dart';
import 'package:sharp_cut/presentation/home/widgets/search_and_menu.dart';
import 'package:sharp_cut/presentation/home/widgets/service_item.dart';
import 'package:sharp_cut/presentation/printing/cubit/printing_cubit.dart';
import 'package:sharp_cut/presentation/printing/screens/screen_printing_settings.dart';
import 'package:sharp_cut/presentation/printing/widgets/print_count_dialog.dart';
import 'package:sharp_cut/presentation/printing/widgets/reset_password_dialog.dart';
import 'package:sharp_cut/presentation/quick_report/screens/screen_quick_report.dart';
import 'package:sharp_cut/utils/helpers/enums.dart';
import 'package:sharp_cut/utils/helpers/toast_helper.dart';

import 'package:sharp_cut/utils/helpers/icon_helper.dart';
import 'package:sharp_cut/utils/comon/validate_password.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/cubit/booking/booking_form_cubit.dart';
import 'package:sharp_cut/cubit/auth/auth_cubit.dart';

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

  void _settlePayment(
    BuildContext context,
    int? transactionId,
    int? userId,
    ServiceStateSuccess serviceState,
    BookingFormState bookingFormState,
    String paymentMode,
    String? invoiceNumber,
    String? staffName,
    String? bookingTime,
    double discount,
    double finalTotal,
  ) {
    double amount = serviceState.total;
    // if user click unpaid then make the amount zero and the payment methord zero;
    if (paymentMode == PaymentMode.Unpaid.name) {
      log("unpaid is selected");
      paymentMode = PaymentMode.Cash.name;
      amount = 0.0;
    }

    final request = SettlePaymentRequestModel(
      transactionId: transactionId,
      customerName: bookingFormState.customerName,
      customerNumber: bookingFormState.customerNumber,
      subTotalValue: serviceState.subTotal,
      taxTotal: serviceState.vat,
      discount: discount,
      roundOff: 0.0,
      finalTotal: finalTotal,
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
      isTip: serviceState.cartItems.map((e) => 0).toList(),
      collectedUserId: [userId!], // Placeholder
      mode: [paymentMode],
      amount: [amount],
      tenderCash: [0.0],
      change: [0.0],
    );

    final shopData = context.read<AuthCubit>().currentUser;
    if (shopData != null) {
      final printCubit = context.read<PrintingCubit>();
      printCubit.printInvoice(
        printCount: printCubit.state.settings?.printCount.quickPayment.toInt(),
        balanceAmount: 0.0,
        request: request,
        shopData: shopData,
        cartItems: serviceState.cartItems,
        staffName: staffName,
        invoiceNumber: invoiceNumber,
        bookingTime: bookingTime != null
            ? DateFormat('HH:mm').format(DateTime.parse(bookingTime))
            : "--:--",
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
          context.read<AuthCubit>().logout();
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
            final bookingState = context.read<BookingCubit>().state;
            if (state is ChairSuccess && bookingState is BookingSuccess) {
              for (var chair in state.chairs) {
                if (chair.transaction != null &&
                    chair.transaction!.details != null &&
                    chair.transaction!.details!.isNotEmpty) {
                  final cartItems = chair.transaction!.details!
                      .where((detail) => detail.service != null)
                      .map(
                        (detail) => CartItemModel(
                          service: detail.service!,
                          quantity: 1,
                        ),
                      )
                      .toList();
                  if (cartItems.isNotEmpty) {
                    context.read<ServiceCubit>().setCart(cartItems);
                    break;
                  }
                }
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
              ToastHelper.showSuccess(state.message);
              context.read<ServiceCubit>().clearCart();
              context.read<ChairCubit>().getChairsAndStaffs(forceRefresh: true);
              // Optionally clear cart or reset state
            } else if (state is BookingSuccess) {
              context.read<ChairCubit>().getChairsAndStaffs(forceRefresh: true);
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
            SingleChildScrollView(
              child: SizedBox(
                width: 180,
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
            const SizedBox(width: 10),

            // 2. Services Grid
            Expanded(
              flex: 3,
              child: BlocBuilder<BookingCubit, BookingState>(
                builder: (context, bookingState) {
                  final isBooked = bookingState is BookingSuccess;

                  return Opacity(
                    opacity: isBooked ? 1.0 : 0.5,
                    child: RepaintBoundary(
                      child: CommonContainer(
                        borderRadius: BorderRadius.circular(15),
                        backgroundImageUrl: "lib/utils/images/Card.png",
                        padding: const EdgeInsets.all(16),
                        child: BlocBuilder<ServiceCubit, ServiceState>(
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
                                      context.read<ServiceCubit>().addToCart(
                                        service,
                                      );
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
                  );
                },
              ),
            ),
            const SizedBox(width: 15),

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
            const SizedBox(width: 15),

            // 4. Action Buttons Sidebar
            SingleChildScrollView(
              child: SizedBox(
                width: 200,
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
                                    CuttingMastersDialog.show(context);
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
                            // if (isBooked) const SizedBox(height: 12),
                            // if (isBooked)
                            //   Opacity(
                            //     opacity: isBooked ? 1.0 : 0.5,
                            //     child: ActionButton(
                            //       label: "CANCEL",
                            //       isPrimary: selectedButton == "CANCEL",
                            //       onTap: !isBooked
                            //           ? null
                            //           : () {
                            //               _selectedButtonNotifier.value =
                            //                   "CANCEL";
                            //               int? transactionId;
                            //               if (bookingState is BookingSuccess) {
                            //                 transactionId =
                            //                     bookingState.bookingResponse.id;
                            //               }

                            //               if (transactionId != null) {
                            //                 CancellationDialog.show(
                            //                   context,
                            //                   transactionId,
                            //                 );
                            //               } else {
                            //                 ToastHelper.showError(
                            //                   "Invalid booking details",
                            //                 );
                            //               }
                            //             },
                            //     ),
                            //   ),
                            if (isBooked) const SizedBox(height: 12),
                            // SAVE BOOKING - Disabled if NOT booked
                            if (isBooked)
                              Opacity(
                                opacity: !isBooked ? 0.5 : 1.0,
                                child: ActionButton(
                                  label: "SAVE BOOKING",
                                  isPrimary:
                                      isBooked &&
                                      selectedButton == "SAVE BOOKING",
                                  onTap: !isBooked
                                      ? null
                                      : () {
                                          _selectedButtonNotifier.value =
                                              "SAVE BOOKING";
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
                                            if (bookingState
                                                is BookingSuccess) {
                                              transactionId = bookingState
                                                  .bookingResponse
                                                  .id;
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

                                            final request =
                                                SaveBookingRequestModel(
                                                  transactionId: transactionId,
                                                  customerName: bookingFormState
                                                      .customerName,
                                                  customerNumber:
                                                      bookingFormState
                                                          .customerNumber,
                                                  grandTotal:
                                                      serviceState.subTotal,
                                                  taxTotal: serviceState.vat,
                                                  discount: 0.0,
                                                  roundOff: 0.0,
                                                  finalTotal:
                                                      serviceState.total,
                                                  serviceId: serviceState
                                                      .cartItems
                                                      .map((e) => e.service.id!)
                                                      .toList(),
                                                  quantity: serviceState
                                                      .cartItems
                                                      .map((e) => e.quantity)
                                                      .toList(),
                                                  rate: serviceState.cartItems
                                                      .map(
                                                        (e) =>
                                                            e.service.price ??
                                                            0.0,
                                                      )
                                                      .toList(),
                                                  taxAmount: serviceState
                                                      .cartItems
                                                      .map(
                                                        (e) =>
                                                            e.service.unitTax ??
                                                            0,
                                                      ) // Placeholder
                                                      .toList(),
                                                  currency: serviceState
                                                      .cartItems
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
                                                            (e
                                                                    .service
                                                                    .unitTax ??
                                                                0.0) *
                                                            e.quantity,
                                                      )
                                                      .toList(),
                                                  subTotal: serviceState
                                                      .cartItems
                                                      .map((e) {
                                                        final price =
                                                            e.service.price ??
                                                            0.0;
                                                        final tax =
                                                            e.service.unitTax ??
                                                            0.0;
                                                        return (price + tax) *
                                                            e.quantity;
                                                      })
                                                      .toList(),
                                                  isTip: serviceState.cartItems
                                                      .map((e) => 0)
                                                      .toList(),
                                                );

                                            context
                                                .read<BookingCubit>()
                                                .saveBooking(request: request);
                                          }
                                        },
                                ),
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
                                                      .invoiceNo,
                                                  bookingState
                                                      .bookingResponse
                                                      .staff
                                                      ?.name,
                                                  bookingState
                                                      .bookingResponse
                                                      .createdAt,
                                                  discount,
                                                  serviceState.total,
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
                                                      .invoiceNo,
                                                  bookingState
                                                      .bookingResponse
                                                      .staff
                                                      ?.name,
                                                  bookingState
                                                      .bookingResponse
                                                      .createdAt,
                                                  discount,
                                                  serviceState.total,
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
                                                      .invoiceNo,
                                                  bookingState
                                                      .bookingResponse
                                                      .staff
                                                      ?.name,
                                                  bookingState
                                                      .bookingResponse
                                                      .createdAt,
                                                  discount,
                                                  serviceState.total,
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
                                                  .map((e) => 0)
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
                                                  .createdAt,
                                              invoiceNumber: bookingState
                                                  .bookingResponse
                                                  .invoiceNo,
                                              cartItems: serviceState.cartItems,
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
                                  label: "ADD EXPENSE",
                                  isPrimary: selectedButton == "ADD EXPENSE",
                                  onTap: isBooked
                                      ? null
                                      : () {
                                          _selectedButtonNotifier.value =
                                              "ADD EXPENSE";
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
                              Opacity(
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
                              ),
                            const SizedBox(height: 12),
                            if (!isBooked)
                              Opacity(
                                opacity: isBooked ? 0.5 : 1.0,
                                child: ActionButton(
                                  label: "REPORT",
                                  isPrimary: selectedButton == "REPORT",
                                  onTap: isBooked
                                      ? null
                                      : () {
                                          _selectedButtonNotifier.value =
                                              "REPORT";
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ScreenQuickReport(),
                                            ),
                                          );
                                        },
                                ),
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
                                        : () {
                                            _selectedButtonNotifier.value =
                                                "CLOSE REGISTER";
                                            context
                                                .read<CashRegistoryCubit>()
                                                .getSalesTotal();
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
