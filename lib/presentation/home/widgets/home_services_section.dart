import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/auth/auth_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_state.dart';
import 'package:sharp_cut/cubit/cash_registory/cash_registory_cubit.dart';
import 'package:sharp_cut/cubit/cash_registory/cash_registory_state.dart';
import 'package:sharp_cut/cubit/home/chair_cubit.dart';
import 'package:sharp_cut/cubit/home/chair_state.dart';
import 'package:sharp_cut/cubit/home/service_cubit.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/domain/home/models/cart_item_model.dart';
import 'package:sharp_cut/domain/home/models/service_model.dart';
import 'package:sharp_cut/presentation/home/widgets/home_action_sidebar.dart';
import 'package:sharp_cut/presentation/home/widgets/home_cart_summary_panel.dart';
import 'package:sharp_cut/presentation/home/widgets/home_category_sidebar.dart';
import 'package:sharp_cut/presentation/home/widgets/home_services_grid.dart';
import 'package:sharp_cut/presentation/printing/cubit/printing_cubit.dart';
import 'package:sharp_cut/utils/helpers/check_no_chair.dart';
import 'package:sharp_cut/utils/helpers/enums.dart';
import 'package:sharp_cut/utils/helpers/toast_helper.dart';

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
  final ValueNotifier<String> _selectedButtonNotifier = ValueNotifier("BOOK A SLOT");
  _PendingPrintData? _pendingPrintData;

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

  @override
  Widget build(BuildContext context) {
    final isWindows = Theme.of(context).platform == TargetPlatform.windows;
    return MultiBlocListener(
      listeners: [
        BlocListener<ChairCubit, ChairState>(
          listener: (context, state) {
            final shop = context.read<AuthCubit>().currentShop;
            final isNoChair = CheckNoChair.checkIsThisAppNoChairOrNot(shop);
            final bookingState = context.read<BookingCubit>().state;

            if (isNoChair && state is ChairSuccess && state.chairs.isNotEmpty) {
              final chair = state.chairs.first;
              if (chair.liveState == LiveState.occupied.name &&
                  chair.transaction != null &&
                  bookingState is! BookingSuccess) {
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
            } else if (state is BookingError) {
              ToastHelper.showError(state.message);
              if (state.message == "This chair is already booked") {
                context.read<ChairCubit>().getChairsAndStaffs(forceRefresh: true);
              }
            } else if (state is BookingPaymentSettled) {
              if (_pendingPrintData != null) {
                final printCubit = context.read<PrintingCubit>();
                final SettlePaymentRequestModel updatedData = _pendingPrintData!.request.copyWith(
                  finalTotal: state.response.bookingResponse?.finalTotal,
                  discount: state.response.bookingResponse?.discount,
                  subTotalValue: state.response.bookingResponse?.subtotal,
                  taxTotal: state.response.bookingResponse?.taxTotal,
                  paymentStatus: state.response.bookingResponse?.paymentStatus,
                  finalTotalbefore: state.response.bookingResponse?.finalTotalbefore,
                );

                printCubit.printInvoice(
                  chairId: _pendingPrintData!.chairId,
                  printCount: printCubit.state.settings?.printCount.quickPayment.toInt(),
                  balanceAmount: _pendingPrintData!.balanceAmount,
                  request: updatedData,
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
            } else if (state is BookingSuccess) {
              context.read<ChairCubit>().getChairsAndStaffs(forceRefresh: true);
              final customerBookingServices = state.bookingResponse.customerBookingServices;
              log("customerBookingServices: ${customerBookingServices?.length}");
              if (customerBookingServices != null && customerBookingServices.isNotEmpty) {
                final restoredCartItems = customerBookingServices.map((service) {
                  return CartItemModel(
                    service: ServiceModel(
                      beforeVat: service.beforeVat,
                      unitTax: service.unitTax,
                      taxPercentage: service.taxPercentage,
                      name: service.name,
                      id: service.serviceId,
                      charge: service.rate,
                    ),
                    quantity: service.quantity ?? 1,
                  );
                }).toList();
                context.read<ServiceCubit>().setCart(restoredCartItems);
              } else {
                context.read<ServiceCubit>().clearCart();
              }
            }
          },
        ),
        BlocListener<CashRegistoryCubit, CashRegistoryState>(
          listener: (context, state) {
            if (state is CashRegistoryReportLoaded) {
              final shop = context.read<AuthCubit>().currentShop;
              if (shop != null) {
                final printCubit = context.read<PrintingCubit>();
                printCubit.printCloseRegisterReport(
                  report: state.report,
                  shop: shop,
                  printCount: printCubit.state.settings?.printCount.report.toInt(),
                );
              } else {
                ToastHelper.showError("Shop data not found");
              }
            } else if (state is CashRegistoryAddError) {
              ToastHelper.showError(state.message);
            }
          },
        ),
      ],
      child: SizedBox(
        height: isWindows ? null : 450,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Category Sidebar
            const HomeCategorySidebar(),
            const SizedBox(width: 8),

            // 2. Services Grid
            const HomeServicesGrid(),
            const SizedBox(width: 10),

            // 3. Order Summary Panel
            const HomeCartSummaryPanel(),
            const SizedBox(width: 10),

            // 4. Action Buttons Sidebar
            HomeActionSidebar(
              selectedButtonNotifier: _selectedButtonNotifier,
              onPendingPrintSet: ({
                required int? chairId,
                required double balanceAmount,
                required SettlePaymentRequestModel request,
                required dynamic shopData,
                required List<CartItemModel> cartItems,
                required String? staffName,
                required String bookingTime,
              }) {
                _pendingPrintData = _PendingPrintData(
                  chairId: chairId,
                  balanceAmount: balanceAmount,
                  request: request,
                  shopData: shopData,
                  cartItems: cartItems,
                  staffName: staffName,
                  bookingTime: bookingTime,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
