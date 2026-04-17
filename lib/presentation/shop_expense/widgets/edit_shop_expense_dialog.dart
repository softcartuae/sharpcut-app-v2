import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/cubit/shop_expenses/shop_expense_cubit.dart';
import 'package:sharp_cut/domain/expenses/models/expense_model.dart';

class EditShopExpenseDialog extends StatefulWidget {
  final ExpenseModel expense;
  final int staffId;

  const EditShopExpenseDialog({
    super.key,
    required this.expense,
    required this.staffId,
  });

  @override
  State<EditShopExpenseDialog> createState() => _EditShopExpenseDialogState();
}

class _EditShopExpenseDialogState extends State<EditShopExpenseDialog> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.expense.itemName);
    _amountController = TextEditingController(text: widget.expense.price);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E2C),
      title: Text(
        "Edit Shop Expense",
        style: GoogleFonts.rajdhani(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              style: GoogleFonts.rajdhani(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Item Name",
                labelStyle: GoogleFonts.rajdhani(color: Colors.grey),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? "Required" : null,
            ),
            TextFormField(
              controller: _amountController,
              style: GoogleFonts.rajdhani(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Amount",
                labelStyle: GoogleFonts.rajdhani(color: Colors.grey),
              ),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value == null || value.isEmpty ? "Required" : null,
            ),
          ],
        ),
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
            if (_formKey.currentState!.validate()) {
              context.read<ShopExpenseCubit>().updateShopExpense(
                id: widget.expense.id!,
                staffId: widget.staffId,
                data: {
                  "item_name": _nameController.text,
                  "price": double.parse(_amountController.text),
                  "purchase_date": widget.expense.purchaseDate,
                },
              );
              Navigator.pop(context);
            }
          },
          child: Text(
            "Update",
            style: GoogleFonts.rajdhani(color: Colors.blue),
          ),
        ),
      ],
    );
  }
}
