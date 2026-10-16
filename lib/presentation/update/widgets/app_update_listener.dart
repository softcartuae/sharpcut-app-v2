import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sharp_cut/cubit/update/app_update_cubit.dart';
import 'package:sharp_cut/utils/helpers/toast_helper.dart';

/// Listens for update state changes.
///
/// Google Play renders its own UI for both immediate and flexible updates,
/// so the only custom interaction needed is prompting the user and completing
/// the installation once a flexible background update finishes downloading.
class AppUpdateListener extends StatelessWidget {
  final Widget child;

  const AppUpdateListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppUpdateCubit, AppUpdateState>(
      listenWhen: (_, current) => current is AppUpdateDownloaded,
      listener: (context, state) {
        ToastHelper.showToast(
          msg: 'Update downloaded. Restarting to install…',
          toastLength: Toast.LENGTH_LONG,
        );
        context.read<AppUpdateCubit>().completeFlexibleUpdate();
      },
      child: child,
    );
  }
}
