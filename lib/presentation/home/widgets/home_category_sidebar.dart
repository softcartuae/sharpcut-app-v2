import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/home/service_cubit.dart';
import 'package:sharp_cut/cubit/home/service_cubit_state.dart';
import 'package:sharp_cut/presentation/home/widgets/category_item.dart';
import 'package:sharp_cut/utils/helpers/icon_helper.dart';

class HomeCategorySidebar extends StatelessWidget {
  const HomeCategorySidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: SingleChildScrollView(
        child: BlocBuilder<ServiceCubit, ServiceState>(
          buildWhen: (previous, current) {
            if (previous is ServiceStateSuccess && current is ServiceStateSuccess) {
              return previous.categories != current.categories ||
                  previous.selectedCategoryId != current.selectedCategoryId;
            }
            return true;
          },
          builder: (context, state) {
            List<Widget> categories = [];
            if (state is ServiceStateSuccess) {
              // Add "ALL" category
              categories.add(
                CategoryItem(
                  onTap: () {
                    context.read<ServiceCubit>().getServices(categoryId: null);
                  },
                  title: "ALL",
                  icon: Icons.grid_view,
                  isSelected: state.selectedCategoryId == null,
                ),
              );
              categories.add(const SizedBox(height: 12));

              // Add dynamic categories
              categories.addAll(
                state.categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: CategoryItem(
                      onTap: () {
                        context.read<ServiceCubit>().getServices(
                              categoryId: category.id,
                            );
                      },
                      title: category.name ?? "Service",
                      icon: getIconForService(category.name),
                      isSelected: state.selectedCategoryId == category.id,
                    ),
                  );
                }),
              );
            } else if (state is ServiceStateLoading) {
              categories.add(
                const Center(child: CircularProgressIndicator()),
              );
            }

            return ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: categories,
            );
          },
        ),
      ),
    );
  }
}
