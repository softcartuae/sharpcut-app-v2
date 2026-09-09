import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/auth/auth_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_form_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_state.dart';
import 'package:sharp_cut/cubit/cash_registory/cash_registory_cubit.dart';
import 'package:sharp_cut/cubit/cash_registory/cash_registory_state.dart';
import 'package:sharp_cut/cubit/home/service_cubit.dart';
import 'package:sharp_cut/cubit/home/service_cubit_state.dart';
import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/domain/home/models/cart_item_model.dart';
import 'package:sharp_cut/presentation/cash_registory/screens/close_cash_register_dialog.dart';
import 'package:sharp_cut/presentation/cash_registory/screens/open_cash_registory_dialoge.dart';
import 'package:sharp_cut/presentation/expense/screens/screen_expense.dart';
import 'package:sharp_cut/presentation/expense/screens/screen_settlement.dart';
import 'package:sharp_cut/presentation/home/screens/screen_online_bookings.dart';
import 'package:sharp_cut/presentation/home/screens/screen_search.dart';
import 'package:sharp_cut/presentation/home/screens/screen_staff_wise_bookings.dart';
import 'package:sharp_cut/presentation/home/widgets/action_button.dart';
import 'package:sharp_cut/presentation/home/widgets/cancellation_dialog.dart';
import 'package:sharp_cut/presentation/home/widgets/cash_or_card.dart';
import 'package:sharp_cut/presentation/home/widgets/expandable_expense_button.dart';
import 'package:sharp_cut/presentation/home/widgets/expandable_online_booking_button.dart';
import 'package:sharp_cut/presentation/home/widgets/home_header_menu_handler.dart';
import 'package:sharp_cut/presentation/home/widgets/search_and_menu.dart';
import 'package:sharp_cut/presentation/quick_report/screens/screen_quick_report.dart';
import 'package:sharp_cut/presentation/shop_expense/screens/screen_shop_expense.dart';
import 'package:sharp_cut/utils/comon/validate_password.dart';
import 'package:sharp_cut/utils/helpers/booking_flow_helper.dart';
import 'package:sharp_cut/utils/helpers/check_no_chair.dart';
import 'package:sharp_cut/utils/helpers/enums.dart';
import 'package:sharp_cut/utils/helpers/payment_request_mapper.dart';
import 'package:sharp_cut/utils/helpers/toast_helper.dart';

class HomeActionSidebar extends StatefulWidget {
  final ValueNotifier<String> selectedButtonNotifier;
  final void Function({
    required int? chairId,
    required double balanceAmount,
    required SettlePaymentRequestModel request,
    required dynamic shopData,
    required List<CartItemModel> cartItems,
    required String? staffName,
    required String bookingTime,
  }) onPendingPrintSet;

  const HomeActionSidebar({
    super.key,
    required this.selectedButtonNotifier,
    required this.onPendingPrintSet,
  });

  @override
  State<HomeActionSidebar> createState() => _HomeActionSidebarState();
}

class _HomeActionSidebarState extends State<HomeActionSidebar> {
  final GlobalKey _menuKey = GlobalKey();

  void _settlePayment({
    required BuildContext context,
    required int? transactionId,
    required int? userId,
    required int? onlineBookingId,
    required ServiceStateSuccess serviceState,
    required BookingFormState bookingFormState,
    required String paymentMode,
    required String? staffName,
    required String? bookingTime,
    required double discount,
    required double finalTotal,
    required int? chairId,
  }) {
    if (discount > finalTotal) {
      ToastHelper.showError("Total amount cannot be greater than Final Total");
      return;
    }

    final SettlePaymentRequestModel request = PaymentRequestMapper.fromQuickPayment(
      transactionId: transactionId,
      onlineBookingId: onlineBookingId,
      customerName: bookingFormState.customerName,
      customerNumber: bookingFormState.customerNumber,
      subTotal: serviceState.subTotal,
      taxTotal: serviceState.vat,
      discount: discount,
      finalTotal: finalTotal,
      cartItems: serviceState.cartItems,
      userId: userId,
      paymentMode: paymentMode,
    );

    final shopData = context.read<AuthCubit>().currentShop;
    if (shopData != null) {
      final double balanceAmount = (paymentMode == PaymentMode.Unpaid.name) ? serviceState.total : 0.0;
      widget.onPendingPrintSet(
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
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: SingleChildScrollView(
        child: BlocBuilder<BookingCubit, BookingState>(
          builder: (context, bookingState) {
            final isBooked = bookingState is BookingSuccess;

            return ValueListenableBuilder<String>(
              valueListenable: widget.selectedButtonNotifier,
              builder: (context, selectedButton, child) {
                final shop = context.read<AuthCubit>().currentShop;
                final isShowUserExpenses = CheckNoChair.checkShowUserExpenses(shop);
                final isShowShopExpenses = CheckNoChair.checkShowShopExpenses(shop);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Search & Menu Bar
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
                                          builder: (context) => ScreenSearch(staff: staff),
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
                              : () => HomeHeaderMenuHandler.showHeaderMenu(context, menuKey: _menuKey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // BOOK A SLOT BUTTON
                    if (!isBooked)
                      BlocConsumer<CashRegistoryCubit, CashRegistoryState>(
                        listener: (context, state) {
                          if (state is CashRegistorOpen) {
                            BookingFlowHelper.handleBookingAction(context);
                          }
                          if (state is CashRegistorClosed) {
                            showCashRegistoryDialoge(context);
                          }
                        },
                        builder: (context, state) {
                          return Opacity(
                            opacity: isBooked ? 0.5 : 1.0,
                            child: ActionButton(
                              label: isBooked ? "SLOT BOOKED" : "BOOK A SLOT",
                              isPrimary: !isBooked && selectedButton == "BOOK A SLOT",
                              isLoading: state is CashRegistoryLoading && selectedButton == "BOOK A SLOT",
                              onTap: isBooked
                                  ? null
                                  : () {
                                      widget.selectedButtonNotifier.value = "BOOK A SLOT";
                                      context.read<CashRegistoryCubit>().checkCashRegisterStatus();
                                    },
                            ),
                          );
                        },
                      ),

                    // ONLINE BOOKINGS BUTTON
                    if (!isBooked) const SizedBox(height: 12),
                    if (!isBooked)
                      ExpandableOnlineBookingButton(
                        selectedButton: selectedButton,
                        onTapHistory: () {
                          widget.selectedButtonNotifier.value = "HISTORY";
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ScreenOnlineBookings()),
                          );
                        },
                        onTapStaffWise: () {
                          widget.selectedButtonNotifier.value = "STAFF WISE";
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ScreenStaffWiseBookings()),
                          );
                        },
                      ),

                    // CANCEL BOOKING BUTTON
                    if (isBooked)
                      Builder(
                        builder: (context) {
                          final isNoChair = CheckNoChair.checkIsThisAppNoChairOrNot(shop);
                          if (!isNoChair) return const SizedBox.shrink();

                          return Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: ActionButton(
                              label: "CANCEL BOOKING",
                              isPrimary: false,
                              onTap: () {
                                if (bookingState.bookingResponse.id != null) {
                                  CancellationDialog.show(context, bookingState.bookingResponse.id!);
                                }
                              },
                            ),
                          );
                        },
                      ),

                    if (isBooked) const SizedBox(height: 12),

                    // QUICK PAYMENT BUTTON
                    if (isBooked)
                      Opacity(
                        opacity: !isBooked ? 0.5 : 1.0,
                        child: ActionButton(
                          label: "QUICK PAYMENT",
                          isPrimary: isBooked && selectedButton == "QUICK PAYMENT",
                          onTap: !isBooked
                              ? null
                              : () {
                                  widget.selectedButtonNotifier.value = "QUICK PAYMENT";
                                  final serviceState = context.read<ServiceCubit>().state;
                                  if (serviceState is ServiceStateSuccess) {
                                    if (serviceState.cartItems.isEmpty) {
                                      ToastHelper.showError("You have to select the services");
                                      return;
                                    }

                                    final int? transactionId = bookingState.bookingResponse.id;
                                    final int? userId = bookingState.bookingResponse.userId;
                                    final int? onlineBookingId = bookingState.bookingResponse.onlineBookingId;
                                    final bookingFormState = context.read<BookingFormCubit>().state;
                                    final double? walletAmount = bookingState.bookingResponse.customer?.wallet;

                                    showQuickPaymentPopup(
                                      context,
                                      (discount) {
                                        _settlePayment(
                                          context: context,
                                          transactionId: transactionId,
                                          userId: userId,
                                          onlineBookingId: onlineBookingId,
                                          serviceState: serviceState,
                                          bookingFormState: bookingFormState,
                                          paymentMode: PaymentMode.Cash.name,
                                          staffName: bookingState.bookingResponse.staff?.name,
                                          bookingTime: bookingState.bookingResponse.transactionDate,
                                          discount: discount,
                                          finalTotal: serviceState.total,
                                          chairId: bookingState.bookingResponse.chairId,
                                        );
                                      },
                                      (discount) {
                                        _settlePayment(
                                          context: context,
                                          transactionId: transactionId,
                                          userId: userId,
                                          onlineBookingId: onlineBookingId,
                                          serviceState: serviceState,
                                          bookingFormState: bookingFormState,
                                          paymentMode: PaymentMode.Card.name,
                                          staffName: bookingState.bookingResponse.staff?.name,
                                          bookingTime: bookingState.bookingResponse.transactionDate,
                                          discount: discount,
                                          finalTotal: serviceState.total,
                                          chairId: bookingState.bookingResponse.chairId,
                                        );
                                      },
                                      (discount) {
                                        _settlePayment(
                                          context: context,
                                          transactionId: transactionId,
                                          userId: userId,
                                          onlineBookingId: onlineBookingId,
                                          serviceState: serviceState,
                                          bookingFormState: bookingFormState,
                                          paymentMode: PaymentMode.Unpaid.name,
                                          staffName: bookingState.bookingResponse.staff?.name,
                                          bookingTime: bookingState.bookingResponse.transactionDate,
                                          discount: discount,
                                          finalTotal: serviceState.total,
                                          chairId: bookingState.bookingResponse.chairId,
                                        );
                                      },
                                      total: serviceState.total,
                                      discount: bookingState.bookingResponse.calculateEffectiveDiscount(
                                        serviceState.subTotal,
                                      ),
                                      grandTotal: serviceState.subTotal,
                                      walletAmount: walletAmount,
                                      onWalletSelected: (discount) {
                                        _settlePayment(
                                          context: context,
                                          transactionId: transactionId,
                                          userId: userId,
                                          onlineBookingId: onlineBookingId,
                                          serviceState: serviceState,
                                          bookingFormState: bookingFormState,
                                          paymentMode: PaymentMode.Wallet.name,
                                          staffName: bookingState.bookingResponse.staff?.name,
                                          bookingTime: bookingState.bookingResponse.transactionDate,
                                          discount: discount,
                                          finalTotal: serviceState.total,
                                          chairId: bookingState.bookingResponse.chairId,
                                        );
                                      },
                                    );
                                  }
                                },
                        ),
                      ),

                    if (isBooked) const SizedBox(height: 12),

                    // SAVE & SETTLE BILL BUTTON
                    if (isBooked)
                      Opacity(
                        opacity: !isBooked ? 0.5 : 1.0,
                        child: ActionButton(
                          label: "SAVE & SETTLE BILL",
                          isPrimary: isBooked && selectedButton == "SAVE & SETTLE BILL",
                          onTap: !isBooked
                              ? null
                              : () {
                                  widget.selectedButtonNotifier.value = "SAVE & SETTLE BILL";
                                  final serviceState = context.read<ServiceCubit>().state;
                                  if (serviceState is ServiceStateSuccess) {
                                    if (serviceState.cartItems.isEmpty) {
                                      ToastHelper.showError("You have to select the services");
                                      return;
                                    }

                                    final int? transactionId = bookingState.bookingResponse.id;
                                    final int? userId = bookingState.bookingResponse.userId;
                                    final int? onlineBookingId = bookingState.bookingResponse.onlineBookingId;
                                    final bookingFormState = context.read<BookingFormCubit>().state;

                                    final SettlePaymentRequestModel request = PaymentRequestMapper.fromSaveAndSettle(
                                      transactionId: transactionId,
                                      onlineBookingId: onlineBookingId,
                                      customerName: bookingFormState.customerName,
                                      customerNumber: bookingFormState.customerNumber,
                                      subTotal: serviceState.subTotal,
                                      taxTotal: serviceState.vat,
                                      total: serviceState.total,
                                      cartItems: serviceState.cartItems,
                                      userId: userId,
                                    );

                                    showSettlementDialog(
                                      context,
                                      settlePayment: request,
                                      customer: bookingState.bookingResponse.customer,
                                      staffName: bookingState.bookingResponse.staff?.name,
                                      bookingTime: bookingState.bookingResponse.transactionDate,
                                      cartItems: serviceState.cartItems,
                                      chairId: bookingState.bookingResponse.chairId,
                                    );
                                  }
                                },
                        ),
                      ),

                    if (isBooked) const SizedBox(height: 12),

                    // BACK BUTTON
                    if (isBooked)
                      Builder(
                        builder: (context) {
                          final isNoChair = CheckNoChair.checkIsThisAppNoChairOrNot(shop);
                          if (isNoChair) return const SizedBox.shrink();

                          return Opacity(
                            opacity: isBooked ? 1.0 : 0.5,
                            child: ActionButton(
                              label: "BACK",
                              isPrimary: selectedButton == "BACK",
                              onTap: !isBooked
                                  ? null
                                  : () {
                                      widget.selectedButtonNotifier.value = "BACK";
                                      context.read<BookingCubit>().backToInitialState();
                                      context.read<ServiceCubit>().clearCart();
                                    },
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 12),

                    // REPORT BUTTON
                    if (!isBooked)
                      Opacity(
                        opacity: isBooked ? 0.5 : 1.0,
                        child: ActionButton(
                          label: "REPORT",
                          isPrimary: selectedButton == "REPORT",
                          onTap: isBooked
                              ? null
                              : () {
                                  widget.selectedButtonNotifier.value = "REPORT";
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ScreenQuickReport()),
                                  );
                                },
                        ),
                      ),

                    const SizedBox(height: 12),

                    // CLOSE REGISTER BUTTON
                    if (!isBooked)
                      BlocConsumer<CashRegistoryCubit, CashRegistoryState>(
                        listener: (context, state) {
                          if (state is CashRegistorySalesTotalLoaded) {
                            CloseCashRegisterDialog.show(context, state.closeRegisterModel);
                          } else if (state is CashRegistoryAddError) {
                            ToastHelper.showError(state.message);
                          }
                        },
                        builder: (context, state) {
                          return ActionButton(
                            isLoading: state is CashRegistoryLoading && selectedButton == "CLOSE REGISTER",
                            label: "CLOSE REGISTER",
                            isPrimary: selectedButton == "CLOSE REGISTER",
                            onTap: isBooked
                                ? null
                                : () {
                                    widget.selectedButtonNotifier.value = "CLOSE REGISTER";
                                    context.read<CashRegistoryCubit>().getSalesTotal();
                                  },
                          );
                        },
                      ),

                    if (!isBooked && (isShowShopExpenses || isShowUserExpenses))
                      const SizedBox(height: 12),

                    // EXPENSE BUTTONS
                    ExpandableExpenseButton(
                      isBooked: isBooked,
                      selectedButton: selectedButton,
                      isShowShopExpenses: isShowShopExpenses,
                      isShowUserExpenses: isShowUserExpenses,
                      onTapShop: () {
                        widget.selectedButtonNotifier.value = "SHOP EXPENSE";
                        showPasswordForValidation(
                          showAdminToo: false,
                          isAdminOnly: true,
                          context,
                          false,
                          onSuccessWithStaff: (staff) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ScreenShopExpense(staff: staff),
                              ),
                            );
                          },
                        );
                      },
                      onTapStaff: () {
                        widget.selectedButtonNotifier.value = "STAFF EXPENSE";
                        showPasswordForValidation(
                          context,
                          false,
                          onSuccessWithStaff: (staff) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ScreenExpense(staff: staff),
                              ),
                            );
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
    );
  }
}
