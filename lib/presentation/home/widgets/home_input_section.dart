import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/booking/booking_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_state.dart';
import 'package:sharp_cut/cubit/booking/booking_form_cubit.dart';
import 'package:sharp_cut/presentation/home/widgets/custom_text_field.dart';

class HomeInputSection extends StatelessWidget {
  const HomeInputSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 100, vertical: 24),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("lib/utils/images/rectangle.png"),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            spreadRadius: 0,
            color: Colors.black.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          String invoiceNo = "Invoice no";
          String date = "Date";
          String bookingTime = "Booking Time";
          String customerName = "Customer Name";
          String staffName = "Sales Man";
          final isBooked = state is BookingSuccess || state is BookingRestored;

          if (state is BookingSuccess) {
            final booking = state.bookingResponse;
            invoiceNo = booking.invoiceNo ?? "N/A";
            // Format created_at date
            if (booking.createdAt != null) {
              try {
                final DateTime parsedDate = DateTime.parse(booking.createdAt!);
                // Format date as DD-MM-YYYY
                date =
                    "${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}";
                // Format time as HH:MM AM/PM
                final hour = parsedDate.hour > 12
                    ? parsedDate.hour - 12
                    : parsedDate.hour;
                final period = parsedDate.hour >= 12 ? "PM" : "AM";
                bookingTime =
                    "${hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')} $period";
              } catch (e) {
                // Fallback if parsing fails
              }
            }

            customerName = booking.customerName ?? "Customer Name";
            staffName = booking.staff?.name ?? "Sales Man";
          }

          return BlocListener<BookingCubit, BookingState>(
            listener: (context, state) {
              if (state is BookingSuccess) {
                context.read<BookingFormCubit>().setInitialData(
                  name: state.bookingResponse.customerName ?? "",
                  number: state.bookingResponse.customerNumber ?? "",
                );
              } else if (state is BookingRestored) {
                context.read<BookingFormCubit>().setInitialData(
                  name: state.bookingResponse.customerName ?? "",
                  number: state.bookingResponse.customerNumber ?? "",
                );
              }
            },
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: "Invoice no",
                        hint: invoiceNo,
                        icon: Icons.receipt_long_outlined,
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: "Date",
                        hint: date,
                        icon: Icons.calendar_today_outlined,
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: "Booking Time",
                        hint: bookingTime,
                        icon: Icons.history, // Or another suitable icon
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        readOnly: isBooked == true ? false : true,
                        label: "Customer Name",
                        hint: customerName,
                        icon: Icons.person_outline,
                        onChanged: (value) {
                          context.read<BookingFormCubit>().updateName(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: "Customer Number",
                        hint: "Customer Number",
                        icon: Icons.phone_outlined, // Placeholder icon
                        readOnly: isBooked == true ? false : true,
                        onChanged: (value) {
                          context.read<BookingFormCubit>().updateNumber(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: "Sales Man",
                        hint: staffName,
                        icon: Icons
                            .groups_outlined, // Or person_pin_circle_outlined
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
