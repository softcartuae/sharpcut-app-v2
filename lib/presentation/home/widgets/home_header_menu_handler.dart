import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart' show BuildContext, GlobalKey, RenderBox, Offset, RelativeRect, Colors, RoundedRectangleBorder, BorderSide, Icons, AlertDialog, Text, TextButton, Navigator, MaterialPageRoute, showDialog;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/auth/auth_cubit.dart';
import 'package:sharp_cut/cubit/cash_registory/cash_registory_cubit.dart';
import 'package:sharp_cut/cubit/home/chair_cubit.dart';
import 'package:sharp_cut/presentation/home/widgets/menu_item.dart';
import 'package:sharp_cut/presentation/printing/cubit/printing_cubit.dart';
import 'package:sharp_cut/presentation/printing/screens/screen_printing_settings.dart';
import 'package:sharp_cut/presentation/printing/widgets/print_count_dialog.dart';
import 'package:sharp_cut/presentation/printing/widgets/reset_password_dialog.dart';

abstract class HomeHeaderMenuHandler {
  static Future<void> showHeaderMenu(
    BuildContext context, {
    required GlobalKey menuKey,
  }) async {
    final RenderBox? renderBox = menuKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);

    final selectedValue = await material.showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderBox.size.height + 10,
        offset.dx + renderBox.size.width,
        offset.dy + renderBox.size.height + 200,
      ),
      color: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: material.BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white12),
      ),
      items: const [
        material.PopupMenuItem(
          value: 1,
          child: MenuItem(
            icon: Icons.admin_panel_settings_outlined,
            text: "Reset Admin Password",
          ),
        ),
        material.PopupMenuItem(
          value: 2,
          child: MenuItem(
            icon: Icons.badge_outlined,
            text: "Reset Staff Password",
          ),
        ),
        material.PopupMenuItem(
          value: 3,
          child: MenuItem(icon: Icons.print_outlined, text: "Printer Settings"),
        ),
        material.PopupMenuItem(
          value: 4,
          child: MenuItem(icon: Icons.print, text: "Print Count"),
        ),
        material.PopupMenuItem(
          value: 5,
          child: MenuItem(icon: Icons.logout, text: "Logout"),
        ),
        material.PopupMenuItem(
          value: 6,
          child: MenuItem(
            icon: Icons.receipt_long,
            text: "Print Register Report",
          ),
        ),
        material.PopupMenuItem(
          value: 7,
          child: MenuItem(
            icon: Icons.point_of_sale_outlined,
            text: "Open Drawer",
          ),
        ),
      ],
    );

    if (selectedValue != null && context.mounted) {
      switch (selectedValue) {
        case 1:
          ResetPasswordDialog.show(
            context,
            title: 'Reset Admin Password',
            isAdmin: true,
          );
          break;
        case 2:
          ResetPasswordDialog.show(
            context,
            title: 'Reset Staff Password',
            isAdmin: false,
          );
          break;
        case 3:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ScreenPrintingSettings(),
            ),
          );
          break;
        case 4:
          PrintCountDialog.show(context);
          break;
        case 5:
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              title: const Text("Logout"),
              content: const Text("Are you sure you want to logout?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    if (context.mounted) {
                      context.read<ChairCubit>().reset();
                      context.read<AuthCubit>().logout();
                    }
                  },
                  child: const Text("Logout"),
                ),
              ],
            ),
          );
          break;
        case 6:
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              title: const Text("Print Last Report"),
              content: const Text(
                "Are you sure you want to print the last close register report?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    if (context.mounted) {
                      context.read<CashRegistoryCubit>().getLastCloseRegisterReport();
                    }
                  },
                  child: const Text("Print"),
                ),
              ],
            ),
          );
          break;
        case 7:
          if (context.mounted) {
            context.read<PrintingCubit>().openDrawer();
          }
          break;
      }
    }
  }
}
