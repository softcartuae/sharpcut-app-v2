import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/domain/auth/models/shop_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/domain/home/models/cart_item_model.dart';
import 'dart:ui' as ui;

class ReceiptWidget extends StatelessWidget {
  final ShopModel shopData;
  final SettlePaymentRequestModel request;
  final List<CartItemModel> cartItems;
  final String? staffName;
  final String? invoiceNumber;
  final String? bookingTime;
  final double? width;
  final double balanceAmount;
  final String? invoiceDate;
  final int? chairId;
  final String? endTime;

  const ReceiptWidget({
    super.key,
    required this.staffName,
    required this.invoiceNumber,
    required this.bookingTime,
    required this.shopData,
    required this.request,
    required this.cartItems,
    required this.balanceAmount,
    required this.invoiceDate,
    required this.chairId,
    this.endTime,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:
          width ?? 384, // Target width for 58mm printer (approx 384 dots max)
      color: Colors.white,
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo
            const Center(
              child: Icon(Icons.content_cut, size: 65, color: Colors.black),
            ),
            const SizedBox(height: 8),

            // Shop Name
            Text(
              shopData.name ?? 'Shop Name',
              textAlign: TextAlign.center,
              style: GoogleFonts.marcellus(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            // Address
            if (shopData.address != null)
              Text(
                shopData.address!,
                textAlign: TextAlign.center,
                style: GoogleFonts.marcellus(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

            // TRN
            if (shopData.vatNo != null)
              Text(
                'TRN: ${shopData.vatNo}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

            const SizedBox(height: 4),

            Text(
              'TAX INVOICE - فاتورة ضريبية',
              textAlign: TextAlign.center,
              style: GoogleFonts.marcellus(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            Container(height: 1.5, color: Colors.black),

            // Bill Details
            _buildDetailRow(
              label1: 'Bill Date',
              subLabel1: 'تاريخ الفاتورة',
              value1:
                  invoiceDate ??
                  'Unknown', // Assuming current date for bill date
              label2: 'Invoice No',
              subLabel2: 'رقم الفاتورة',
              value2: invoiceNumber ?? 'Unknown',
            ),
            const SizedBox(height: 4),
            _buildDetailRow(
              label1: 'Print Date',
              subLabel1: 'تاريخ الطباعة',
              value1: _formatDate(DateTime.now()),
              label2: 'Customer',
              subLabel2: 'اسم العميل',
              value2: request.customerName ?? 'Cash Customer',
            ),
            const SizedBox(height: 4),
            _buildDetailRow(
              label1: 'Chair No',
              subLabel1: 'رقم الكرسي',
              value1: chairId?.toString() ?? '', // Placeholder or from request
              label2: 'Staff',
              subLabel2: 'النادل',
              value2: staffName ?? 'Unknown', // Placeholder or from request
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (bookingTime == null) {
                        return Text(
                          'Start time : Unknown',
                          style: GoogleFonts.marcellus(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        );
                      }

                      DateTime? dateTime;
                      try {
                        dateTime = DateFormat(
                          'dd/MM/yyyy hh:mm a',
                        ).parse(bookingTime!);
                      } catch (e) {
                        log("issue in parsing booking time");
                        dateTime = DateTime.tryParse(bookingTime!);
                      }

                      final timeString = dateTime != null
                          ? DateFormat('hh:mm a').format(dateTime)
                          : bookingTime!;

                      return Text(
                        'Start time: $timeString',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      );
                    },
                  ),
                ),

                Expanded(
                  child: Text(
                    'End time: ${endTime ?? DateFormat('hh:mm a').format(DateTime.now())}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 3),
            const DashedLine(),
            const DashedLine(),
            const DashedLine(),
            const DashedLine(),
            SizedBox(height: 3),

            // Items Header
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اسم الصنف',
                        style: GoogleFonts.marcellus(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Item Name',
                        style: GoogleFonts.marcellus(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'الكمية',
                        style: GoogleFonts.marcellus(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Qty',
                        style: GoogleFonts.marcellus(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'السعر',
                        style: GoogleFonts.marcellus(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Price',
                        style: GoogleFonts.marcellus(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'القيمة',
                        style: GoogleFonts.marcellus(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Total',
                        style: GoogleFonts.marcellus(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            const DashedLine(),
            const DashedLine(),
            const DashedLine(),
            const DashedLine(),
            SizedBox(height: 5),

            // Items List
            ...cartItems.map((item) {
              final price = item.service.price ?? 0.0;
              final total = price * item.quantity;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.service.name ?? '',
                                style: GoogleFonts.marcellus(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              if (item.service.nameArabic != null &&
                                  item.service.nameArabic!.isNotEmpty)
                                Text(
                                  item.service.nameArabic!,
                                  style: GoogleFonts.marcellus(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textDirection: ui.TextDirection.rtl,
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            item.quantity.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            price.toStringAsFixed(2),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            total.toStringAsFixed(2),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 8),
            const DashedLine(),
            const DashedLine(),
            const DashedLine(),
            const DashedLine(), const DashedLine(),
            const DashedLine(),
            const SizedBox(height: 8),

            // Totals
            _buildTotalRow(
              'Sub Total - المجموع الفرعي',
              (request.finalTotalbefore ?? 0).toStringAsFixed(2),
            ),
            _buildTotalRow(
              'Discount - الخصم',
              (request.discount ?? 0).toStringAsFixed(2),
            ),

            _buildTotalRow(
              'Before VAT - المجموع قبل الضريبة',
              (request.subTotalValue ?? 0).toStringAsFixed(2),
            ),

         
            _buildTotalRow(
              'VAT (5%) Amount - قيمة الضريبة',
              (request.taxTotal ?? 0).toStringAsFixed(2),
            ),

            _buildTotalRow(
              increesFontSize: true,
              'Net Amount - المبلغ الصافي',
              (request.finalTotal ?? 0).toStringAsFixed(2),
            ),
            SizedBox(height: 3),
            const DashedLine(),
            const DashedLine(),
            const DashedLine(),
            const DashedLine(),

            // Payment Modes
            if (request.mode != null)
              ...List.generate(request.mode!.length, (index) {
                return _buildTotalRow(
                  balanceANdCard: true,
                  increesFontSize: true,
                  '${request.mode![index]} - نقدي',
                  (request.amount?[index] ?? 0).toStringAsFixed(2),
                );
              }),
            _buildTotalRow(
              balanceANdCard: true,
              increesFontSize: true,
              'Balance Amount - الباقي',
              (balanceAmount.toStringAsFixed(2)),
            ),
            const SizedBox(height: 8),
            const DashedLine(),
            const DashedLine(),
            const DashedLine(),
            const DashedLine(),
            Text(
              request.paymentStatus == "full"
                  ? "PAID"
                  : request.paymentStatus?.toUpperCase() ?? "UNKNOWN",
              textAlign: TextAlign.center,
              style: GoogleFonts.marcellus(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label1,
    required String subLabel1,
    required String value1,
    String? label2,
    String? subLabel2,
    String? value2,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label1,
                        style: GoogleFonts.marcellus(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        subLabel1,
                        style: GoogleFonts.marcellus(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  Text(
                    ': $value1',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (label2 != null)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label2,
                          style: GoogleFonts.marcellus(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          subLabel2 ?? '',
                          style: GoogleFonts.marcellus(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ': ${value2 ?? ''}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        else
          const Spacer(),
      ],
    );
  }

  Widget _buildTotalRow(
    String label,
    String value, {
    bool increesFontSize = false,
    bool balanceANdCard = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: GoogleFonts.marcellus(
                fontSize: increesFontSize ? 27 : 23,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: balanceANdCard
                    ? 28
                    : increesFontSize
                    ? 25
                    : 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }
}

class DashedLine extends StatelessWidget {
  final Color color;
  const DashedLine({super.key, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        final dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            );
          }),
        );
      },
    );
  }
}
