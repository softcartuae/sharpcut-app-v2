import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';

class PaymentDetailsDialog extends StatelessWidget {
  final BookingResponseModel booking;
  final VoidCallback onEdit;

  const PaymentDetailsDialog({
    super.key,
    required this.booking,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF2EFF8), // Light purple/grey background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 700,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Payment Details",
              style: GoogleFonts.rajdhani(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black87),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    color: Colors.grey[400],
                    child: Row(
                      children: [
                        _buildHeaderCell("Sl.No", flex: 1),
                        _buildHeaderCell("Date", flex: 3),
                        _buildHeaderCell("Mode", flex: 2),
                        _buildHeaderCell("Amount", flex: 2),
                        _buildHeaderCell(
                          "Edit",
                          flex: 1,
                          align: TextAlign.center,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  // List
                  if (booking.payments != null && booking.payments!.isNotEmpty)
                    ...booking.payments!.asMap().entries.map((entry) {
                      final index = entry.key;
                      final payment = entry.value;
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(color: Colors.black87),
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildCell("${index + 1}", flex: 1),
                            _buildCell(payment.date ?? "-", flex: 3),
                            _buildCell(payment.mode ?? "-", flex: 2),
                            _buildCell(
                              payment.amount?.toStringAsFixed(2) ?? "0.00",
                              flex: 2,
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 40, // Fixed height for consistency
                                decoration: const BoxDecoration(
                                  border: Border(
                                    left: BorderSide(color: Colors.black87),
                                  ),
                                ),
                                child: Center(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                      onEdit();
                                    },
                                    child: const Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    })
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20.0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(top: BorderSide(color: Colors.black87)),
                      ),
                      child: Center(
                        child: Text(
                          "No payment details found",
                          style: GoogleFonts.rajdhani(color: Colors.grey),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Close",
                  style: GoogleFonts.rajdhani(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(
    String text, {
    required int flex,
    TextAlign align = TextAlign.center,
    bool isLast = false,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(right: BorderSide(color: Colors.black87)),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: align,
          style: GoogleFonts.rajdhani(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCell(
    String text, {
    required int flex,
    TextAlign align = TextAlign.center,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 40,
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: Colors.black87)),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: align,
          style: GoogleFonts.rajdhani(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
