import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/cubit/shop_expenses/shop_expense_cubit.dart';
import 'package:sharp_cut/cubit/shop_expenses/shop_expense_state.dart';
import 'package:sharp_cut/presentation/home/widgets/home_appbar.dart';
import 'package:sharp_cut/domain/home/models/staff_model.dart';
import 'package:sharp_cut/presentation/shop_expense/screens/screen_add_shop_expense.dart';
import 'package:sharp_cut/presentation/shop_expense/widgets/delete_shop_expense_dialog.dart';
import 'package:sharp_cut/presentation/shop_expense/widgets/edit_shop_expense_dialog.dart';
import 'package:sharp_cut/utils/helpers/toast_helper.dart' show ToastHelper;

class ScreenShopExpense extends StatefulWidget {
  final StaffModel staff;
  const ScreenShopExpense({super.key, required this.staff});

  @override
  State<ScreenShopExpense> createState() => _ScreenShopExpenseState();
}

class _ScreenShopExpenseState extends State<ScreenShopExpense> {
  @override
  void initState() {
    super.initState();
    context.read<ShopExpenseCubit>().getShopExpensesByStaff(
      staffId: widget.staff.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShopExpenseCubit, ShopExpenseState>(
      listener: (context, state) {
        if (state is ShopExpenseDeleted) {
          ToastHelper.showSuccess(state.message);
        } else if (state is ShopExpenseUpdated) {
          ToastHelper.showSuccess(state.message);
        } else if (state is ShopExpenseError) {
          ToastHelper.showError(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const HomeAppBar(),
              const SizedBox(height: 40),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "SHOP EXPENSE",
                              style: GoogleFonts.rajdhani(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E1E1E),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.black,
                              ),
                              style: IconButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFE0E0E0)),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "ADMIN NAME",
                              style: GoogleFonts.rajdhani(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E1E1E),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 24,
                                ),
                                color: const Color(0xFFF9F9F9),
                                child: Text(
                                  widget.staff.name,
                                  style: GoogleFonts.rajdhani(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ScreenAddShopExpense(
                                      staff: widget.staff,
                                    ),
                                  ),
                                );

                                if (result == true && context.mounted) {
                                  context
                                      .read<ShopExpenseCubit>()
                                      .getShopExpensesByStaff(
                                        staffId: widget.staff.id,
                                      );
                                }
                              },
                              child: Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E2130),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "Add Expense",
                                      style: GoogleFonts.rajdhani(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Date",
                                style: GoogleFonts.rajdhani(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: const Color(0xFF1E1E1E),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                "Items",
                                style: GoogleFonts.rajdhani(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: const Color(0xFF1E1E1E),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                "Amount",
                                style: GoogleFonts.rajdhani(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: const Color(0xFF1E1E1E),
                                ),
                              ),
                            ),
                            const SizedBox(width: 100),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: BlocBuilder<ShopExpenseCubit, ShopExpenseState>(
                          builder: (context, state) {
                            if (state is ShopExpenseLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (state is ShopExpenseError) {
                              return Center(
                                child: Text(
                                  state.message,
                                  style: GoogleFonts.rajdhani(
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            } else if (state is ShopExpenseLoaded) {
                              if (state.expenses.isEmpty) {
                                return Center(
                                  child: Text(
                                    "No expenses found",
                                    style: GoogleFonts.rajdhani(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                );
                              }
                              return ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                itemCount: state.expenses.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 5),
                                itemBuilder: (context, index) {
                                  final expense = state.expenses[index];
                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 24,
                                                  ),
                                              child: Text(
                                                expense.purchaseDate ?? "",
                                                style: GoogleFonts.rajdhani(
                                                  fontSize: 16,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 24,
                                                  ),
                                              child: Text(
                                                expense.itemName ?? "",
                                                style: GoogleFonts.rajdhani(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 24,
                                                  ),
                                              child: Text(
                                                expense.price ?? "",
                                                style: GoogleFonts.rajdhani(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          IconButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    EditShopExpenseDialog(
                                                      expense: expense,
                                                      staffId: widget.staff.id,
                                                    ),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                              size: 20,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    DeleteShopExpenseDialog(
                                                      expenseId: expense.id!,
                                                      staffId: widget.staff.id,
                                                    ),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      const Divider(
                                        height: 1,
                                        color: Color(0xFFE0E0E0),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
