import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/booking/booking_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_state.dart';
import 'package:sharp_cut/cubit/home/service_cubit.dart';
import 'package:sharp_cut/cubit/home/service_cubit_state.dart';
import 'package:sharp_cut/presentation/home/widgets/common_container.dart';
import 'package:sharp_cut/presentation/home/widgets/service_item.dart';
import 'package:sharp_cut/presentation/home/widgets/tip_dialoge.dart';
import 'package:sharp_cut/utils/helpers/toast_helper.dart';

class HomeServicesGrid extends StatelessWidget {
  const HomeServicesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
                    if (previous is ServiceStateSuccess && current is ServiceStateSuccess) {
                      return previous.services != current.services ||
                          previous.isLoadingServices != current.isLoadingServices;
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

                      if (state.services.isEmpty) {
                        return const Center(
                          child: Text(
                            "No services found ,You Have to add services in Dashboard",
                          ),
                        );
                      }
                      return GridView.builder(
                        padding: EdgeInsets.zero,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                ToastHelper.showError("You have to book first");
                                return;
                              }
                              if (service.isTip == 1) {
                                showDialog(
                                  context: context,
                                  builder: (context) => TipDialog(
                                    onTipSelected: (amount) {
                                      final taxPercentage = service.taxPercentage ?? 0;
                                      final beforeTax = double.parse(
                                        (amount * 100 / (100 + taxPercentage)).toStringAsFixed(2),
                                      );
                                      final taxAmount = double.parse(
                                        (amount - beforeTax).toStringAsFixed(2),
                                      );
                                      context.read<ServiceCubit>().addToCart(
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
                                context.read<ServiceCubit>().addToCart(service);
                              }
                            },
                            child: ServiceItem(
                              title: service.name ?? "Service",
                              imagePath: service.image ?? "lib/utils/images/hair_cut.png",
                            ),
                          );
                        },
                      );
                    } else if (state is ServiceStateLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (state is ServiceStateError) {
                      return const Center(
                        child: Text(
                          "Something went wrong",
                          style: TextStyle(color: Colors.white),
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
    );
  }
}
