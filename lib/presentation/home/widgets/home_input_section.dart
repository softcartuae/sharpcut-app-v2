import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:sharp_cut/cubit/booking/booking_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_state.dart';
import 'package:sharp_cut/cubit/booking/booking_form_cubit.dart';
import 'package:sharp_cut/presentation/home/widgets/custom_text_field.dart';

class HomeInputSection extends StatefulWidget {
  const HomeInputSection({super.key});

  @override
  State<HomeInputSection> createState() => _HomeInputSectionState();
}

class _HomeInputSectionState extends State<HomeInputSection> {
  late TextEditingController _nameController;
  late TextEditingController _numberController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _numberController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
          String bookingTime = "Booking Time";

          String staffName = "Sales Man";
          final isBooked = state is BookingSuccess;

          if (state is BookingSuccess) {
            final booking = state.bookingResponse;
            // Format created_at date
            if (booking.transactionDate != null) {
              bookingTime = booking.transactionDate!;
            }

            staffName = booking.staff?.name ?? "Sales Man";
          }

          return BlocListener<BookingCubit, BookingState>(
            listener: (context, state) {
              if (state is BookingSuccess) {
                final name = "";
                final number = state.bookingResponse.customerNumber ?? "";

                _nameController.text = name;
                _numberController.text = number;

                context.read<BookingFormCubit>().setInitialData(
                  name: name,
                  number: number,
                );
              } else if (state is! BookingSuccess) {
                _nameController.clear();
                _numberController.clear();
              }
            },
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: "Booking Time",
                        hint: bookingTime,
                        icon: Icons.history, // Or another suitable icon
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _nameController,
                        readOnly: isBooked == true ? false : true,
                        label: "Customer Name",
                        hint: "Customer Name",
                        icon: Icons.person_outline,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z\s]'),
                          ),
                          LengthLimitingTextInputFormatter(30),
                        ],
                        onChanged: (value) {
                          context.read<BookingFormCubit>().updateName(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _numberController,
                        label: "Customer Number",
                        hint: "Customer Number",
                        icon: Icons.phone_outlined, // Placeholder icon
                        readOnly: isBooked == true ? false : true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(15),
                        ],
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
