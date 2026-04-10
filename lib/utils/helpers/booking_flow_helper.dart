import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/auth/auth_cubit.dart';
import 'package:sharp_cut/cubit/home/chair_cubit.dart';
import 'package:sharp_cut/cubit/home/chair_state.dart';
import 'package:sharp_cut/presentation/home/widgets/cutting_masters_dialog.dart';
import 'package:sharp_cut/utils/comon/staff_selection_dialog.dart';
import 'package:sharp_cut/utils/helpers/check_no_chair.dart';
import 'package:sharp_cut/utils/helpers/toast_helper.dart';

class BookingFlowHelper {
  static Future<void> handleBookingAction(BuildContext context) async {
    final shop = context.read<AuthCubit>().currentShop;
    final isNoChair = CheckNoChair.checkIsThisAppNoChairOrNot(shop);

    if (isNoChair) {
      final chairCubit = context.read<ChairCubit>();

      // Ensure we have data
      if (chairCubit.state is! ChairSuccess) {
        await chairCubit.getChairsAndStaffs();
      }

      final chairState = chairCubit.state;
      if (chairState is ChairSuccess && chairState.chairs.isNotEmpty) {
        // In No Chair mode, we take the first chair
        final chair = chairState.chairs.first;
        showStaffSelectionDialog(context, chair);
      } else {
        ToastHelper.showError("No chairs available for booking");
      }
    } else {
      // Standard flow
      CuttingMastersDialog.show(context);
    }
  }
}
