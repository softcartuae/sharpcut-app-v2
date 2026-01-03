import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  const ReceiptWidget({
    super.key,
    required this.staffName,
    required this.invoiceNumber,
    required this.bookingTime,
    required this.shopData,
    required this.request,
    required this.cartItems,
    required this.balanceAmount,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:
          width ?? 370, // Target width for 58mm printer (approx 384 dots max)
      color: Colors.white,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo
          const Center(
            child: Icon(Icons.content_cut, size: 50, color: Colors.black),
          ),
          const SizedBox(height: 8),

          // Shop Name
          Text(
            shopData.name ?? 'Shop Name',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          // Address
          if (shopData.address != null)
            Text(
              shopData.address!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

          // TRN
          if (shopData.vatNo != null)
            Text(
              'TRN: ${shopData.vatNo}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

          const SizedBox(height: 4),
          const Text(
            'TAX INVOICE - فاتورة ضريبية',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const Divider(color: Colors.black, thickness: 1),

          // Bill Details
          _buildDetailRow(
            label1: 'Bill Date:',
            subLabel1: 'تاريخ الفاتورة',
            value1:
                bookingTime ?? 'Unknown', // Assuming current date for bill date
            label2: 'Invoice No:',
            subLabel2: 'رقم الفاتورة',
            value2: invoiceNumber ?? 'Unknown',
          ),
          const SizedBox(height: 4),
          _buildDetailRow(
            label1: 'Print Date:',
            subLabel1: 'تاريخ الطباعة',
            value1: _formatDate(DateTime.now()),
            label2: 'Order No:',
            subLabel2: 'رقم الطلب',
            value2: '-', // Placeholder
          ),
          const SizedBox(height: 4),
          _buildDetailRow(
            label1: 'Table No',
            subLabel1: 'رقم الطاولة',
            value1: 'COUNTER', // Placeholder or from request
            label2: 'Staff:',
            subLabel2: 'النادل',
            value2: staffName ?? 'Unknown', // Placeholder or from request
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Start time : ${_formatTime(shopData.startTime)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                'End time : ${_formatTime(shopData.endTime)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          const Divider(color: Colors.black, thickness: 1),

          // Items Header
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'اسم الصنف',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Item Name',
                      style: TextStyle(
                        fontSize: 14,
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
                  children: const [
                    Text(
                      'الكمية',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Qty',
                      style: TextStyle(
                        fontSize: 14,
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
                  children: const [
                    Text(
                      'السعر',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Price',
                      style: TextStyle(
                        fontSize: 14,
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
                  children: const [
                    Text(
                      'القيمة',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Colors.black, thickness: 1),

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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            if (item.service.nameArabic != null &&
                                item.service.nameArabic!.isNotEmpty)
                              Text(
                                item.service.nameArabic!,
                                style: const TextStyle(
                                  fontSize: 16,
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
                          style: const TextStyle(
                            fontSize: 16,
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
                          style: const TextStyle(
                            fontSize: 16,
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
                          style: const TextStyle(
                            fontSize: 16,
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
          const SizedBox(height: 8),

          // Totals
          _buildTotalRow(
            'المجموع قبل الضريبة - Before VAT',
            (request.grandTotal ?? 0).toStringAsFixed(2),
          ),
          _buildTotalRow(
            'المجموع شامل الضريبة - Incl VAT',
            (request.finalTotal ?? 0).toStringAsFixed(2),
          ), // Assuming final total is incl VAT
          if ((request.discount ?? 0) > 0)
            _buildTotalRow(
              'خصم - Discount',
              (request.discount ?? 0).toStringAsFixed(2),
            ),
          _buildTotalRow(
            'المجموع الفرعي - Sub Total',
            (request.subTotal?.fold(0.0, (p, c) => p + c) ?? 0).toStringAsFixed(
              2,
            ),
          ), // Need to check logic
          _buildTotalRow(
            'قيمة الضريبة - VAT Amount',
            (request.taxTotal ?? 0).toStringAsFixed(2),
          ),
          if (balanceAmount > 0)
            _buildTotalRow(
              'الباقي - Balance Amount',
              (balanceAmount.toStringAsFixed(2)),
            ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'المبلغ الصافي - Net Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                (request.finalTotal ?? 0).toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          // Payment Modes
          if (request.mode != null)
            ...List.generate(request.mode!.length, (index) {
              return _buildTotalRow(
                '${request.mode![index]} - نقدي',
                (request.amount?[index] ?? 0).toStringAsFixed(2),
              );
            }),

          const SizedBox(height: 8),
          const DashedLine(),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label1,
    required String subLabel1,
    required String value1,
    required String label2,
    required String subLabel2,
    required String value2,
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
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        subLabel1,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ': $value1',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        subLabel2,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ': $value2',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd-MM-yyyy').format(date);
  }

  String _formatTime(String? time) {
    if (time == null) return '';
    // Assuming time string is HH:mm:ss or similar
    return time;
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
