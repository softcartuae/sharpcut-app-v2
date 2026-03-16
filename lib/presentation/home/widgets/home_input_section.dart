import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:sharp_cut/cubit/booking/booking_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_state.dart';
import 'package:sharp_cut/cubit/booking/booking_form_cubit.dart';
import 'package:sharp_cut/presentation/home/widgets/custom_text_field.dart';
import 'package:sharp_cut/domain/booking/models/customer_suggestion_model.dart';
import 'package:sharp_cut/cubit/booking/customer_search_cubit.dart';
import 'package:sharp_cut/cubit/booking/customer_search_state.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

class HomeInputSection extends StatefulWidget {
  const HomeInputSection({super.key});

  @override
  State<HomeInputSection> createState() => _HomeInputSectionState();
}

class _HomeInputSectionState extends State<HomeInputSection> {
  late TextEditingController _nameController;
  late TextEditingController _numberController;
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _numberFocusNode = FocusNode();
  bool _isSelectionInProgress = false;

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
    _nameFocusNode.dispose();
    _numberFocusNode.dispose();
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
                      child: RawAutocomplete<CustomerSuggestionModel>(
                        focusNode: _nameFocusNode,
                        textEditingController: _nameController,
                        optionsBuilder:
                            (TextEditingValue textEditingValue) async {
                              if (_isSelectionInProgress ||
                                  textEditingValue.text.length < 3) {
                                return const Iterable<
                                  CustomerSuggestionModel
                                >.empty();
                              }

                              // Debounce for 500ms
                              await Future.delayed(
                                const Duration(milliseconds: 500),
                              );
                              if (textEditingValue.text !=
                                      _nameController.text ||
                                  _isSelectionInProgress) {
                                return const Iterable<
                                  CustomerSuggestionModel
                                >.empty();
                              }

                              await context
                                  .read<CustomerSearchCubit>()
                                  .searchCustomer(name: textEditingValue.text);
                              final searchState = context
                                  .read<CustomerSearchCubit>()
                                  .state;
                              if (searchState is CustomerSearchSuccess) {
                                return searchState.suggestions;
                              }
                              return const Iterable<
                                CustomerSuggestionModel
                              >.empty();
                            },
                        onSelected: (CustomerSuggestionModel suggestion) {
                          setState(() {
                            _isSelectionInProgress = true;
                          });
                          _nameController.text = suggestion.customerName;
                          _numberController.text = suggestion.customerNumber;
                          context.read<BookingFormCubit>().setInitialData(
                            name: suggestion.customerName,
                            number: suggestion.customerNumber,
                          );
                          context.read<CustomerSearchCubit>().reset();

                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (mounted) {
                              setState(() {
                                _isSelectionInProgress = false;
                              });
                            }
                          });
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                              return CustomTextField(
                                controller: controller,
                                focusNode: focusNode,
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
                                  context.read<BookingFormCubit>().updateName(
                                    value,
                                  );
                                },
                              );
                            },
                        optionsViewBuilder: (context, onSelected, options) {
                          return _buildSuggestionsOverlay(options, onSelected);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: RawAutocomplete<CustomerSuggestionModel>(
                        focusNode: _numberFocusNode,
                        textEditingController: _numberController,
                        optionsBuilder:
                            (TextEditingValue textEditingValue) async {
                              if (_isSelectionInProgress ||
                                  textEditingValue.text.length < 3) {
                                return const Iterable<
                                  CustomerSuggestionModel
                                >.empty();
                              }

                              // Debounce for 500ms
                              await Future.delayed(
                                const Duration(milliseconds: 500),
                              );
                              if (textEditingValue.text !=
                                      _numberController.text ||
                                  _isSelectionInProgress) {
                                return const Iterable<
                                  CustomerSuggestionModel
                                >.empty();
                              }

                              await context
                                  .read<CustomerSearchCubit>()
                                  .searchCustomer(
                                    number: textEditingValue.text,
                                  );
                              final searchState = context
                                  .read<CustomerSearchCubit>()
                                  .state;
                              if (searchState is CustomerSearchSuccess) {
                                return searchState.suggestions;
                              }
                              return const Iterable<
                                CustomerSuggestionModel
                              >.empty();
                            },
                        onSelected: (CustomerSuggestionModel suggestion) {
                          setState(() {
                            _isSelectionInProgress = true;
                          });
                          _nameController.text = suggestion.customerName;
                          _numberController.text = suggestion.customerNumber;
                          context.read<BookingFormCubit>().setInitialData(
                            name: suggestion.customerName,
                            number: suggestion.customerNumber,
                          );
                          context.read<CustomerSearchCubit>().reset();

                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (mounted) {
                              setState(() {
                                _isSelectionInProgress = false;
                              });
                            }
                          });
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                              return CustomTextField(
                                controller: controller,
                                focusNode: focusNode,
                                readOnly: isBooked == true ? false : true,
                                label: "Customer Number",
                                hint: "Customer Number",
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(15),
                                ],
                                onChanged: (value) {
                                  context.read<BookingFormCubit>().updateNumber(
                                    value,
                                  );
                                },
                              );
                            },
                        optionsViewBuilder: (context, onSelected, options) {
                          return _buildSuggestionsOverlay(options, onSelected);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: "Sales Man",
                        hint: staffName,
                        icon: Icons.groups_outlined,
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

  Widget _buildSuggestionsOverlay(
    Iterable<CustomerSuggestionModel> options,
    AutocompleteOnSelected<CustomerSuggestionModel> onSelected,
  ) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 300,
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final CustomerSuggestionModel option = options.elementAt(
                    index,
                  );
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: index != options.length - 1
                            ? Border(
                                bottom: BorderSide(
                                  color: Colors.white.withOpacity(0.05),
                                ),
                              )
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.customerName,
                            style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            option.customerNumber,
                            style: GoogleFonts.rajdhani(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
