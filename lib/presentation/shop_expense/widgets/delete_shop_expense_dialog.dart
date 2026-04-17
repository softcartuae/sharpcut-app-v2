import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/cubit/shop_expenses/shop_expense_cubit.dart';

class DeleteShopExpenseDialog extends StatelessWidget {
  final int expenseId;
  final int staffId;

  const DeleteShopExpenseDialog({
    super.key,
    required this.expenseId,
    required this.staffId,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E2C),
      title: Text(
        "Delete Shop Expense",
        style: GoogleFonts.rajdhani(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        "Are you sure you want to delete this shop expense?",
        style: GoogleFonts.rajdhani(color: Colors.white),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: GoogleFonts.rajdhani(color: Colors.white),
          ),
        ),
        TextButton(
          onPressed: () {
            context.read<ShopExpenseCubit>().deleteShopExpense(
              id: expenseId,
              staffId: staffId,
            );
            Navigator.pop(context);
          },
          child: Text("Delete", style: GoogleFonts.rajdhani(color: Colors.red)),
        ),
      ],
    );
  }
}
