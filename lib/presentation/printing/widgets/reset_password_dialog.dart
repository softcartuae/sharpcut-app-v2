import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/utils/app_colors.dart';
import 'package:sharp_cut/utils/helpers/toast_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/password/password_cubit.dart';
import 'package:sharp_cut/domain/password/models/password_model.dart';
import 'package:sharp_cut/cubit/home/chair_cubit.dart';
import 'package:sharp_cut/cubit/home/chair_state.dart';

class ResetPasswordDialog extends StatefulWidget {
  final String title;
  final List<String> userTypes;

  final bool isAdmin;

  const ResetPasswordDialog({
    super.key,
    required this.title,
    this.userTypes = const ['Main'],
    this.isAdmin = false,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    bool isAdmin = false,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ResetPasswordDialog(title: title, isAdmin: isAdmin),
    );
  }

  @override
  State<ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _selectedUserType;

  @override
  void initState() {
    super.initState();
    if (widget.userTypes.isNotEmpty) {
      _selectedUserType = widget.userTypes.first;
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PasswordCubit, PasswordState>(
      listener: (context, state) {
        if (state is PasswordSuccess) {
          ToastHelper.showSuccess(state.message);
          Navigator.of(context).pop();
        } else if (state is PasswordFailure) {
          ToastHelper.showError(state.error);
        }
      },
      builder: (context, state) {
        return Dialog(
          backgroundColor: const Color(0xFF1E1E2C), // Dark background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Dropdown
                _buildDropdown(),
                const SizedBox(height: 16),

                // Password Fields
                _buildPasswordField(
                  'Current Password',
                  _currentPasswordController,
                  _obscureCurrent,
                  () => setState(() => _obscureCurrent = !_obscureCurrent),
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  'New Password',
                  _newPasswordController,
                  _obscureNew,
                  () => setState(() => _obscureNew = !_obscureNew),
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  'Confirm Password',
                  _confirmPasswordController,
                  _obscureConfirm,
                  () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),

                const SizedBox(height: 32),

                // OK Button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [AppColors.violetNormal, AppColors.redNormal],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: state is PasswordLoading
                        ? null
                        : () {
                            final currentPassword =
                                _currentPasswordController.text;
                            final newPassword = _newPasswordController.text;
                            final confirmPassword =
                                _confirmPasswordController.text;

                            if (newPassword != confirmPassword) {
                              ToastHelper.showError("Passwords do not match");
                              return;
                            }

                            if (currentPassword.isEmpty ||
                                newPassword.isEmpty) {
                              ToastHelper.showError("Please fill all fields");
                              return;
                            }

                            final passwordModel = PasswordModel(
                              staffId: "5",
                              currentPassword: currentPassword,
                              newPassword: newPassword,
                              confirmPassword: confirmPassword,
                            );

                            context.read<PasswordCubit>().resetPassword(
                              passwordModel,
                              isAdmin: widget.isAdmin,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state is PasswordLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'OK',
                            style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdown() {
    return BlocBuilder<ChairCubit, ChairState>(
      builder: (context, state) {
        List<String> userTypes = widget.userTypes;
        if (state is ChairSuccess) {
          userTypes = state.staffs.map((e) => e.name).toList();
        }

        // Ensure selected value is in the list
        if (_selectedUserType != null &&
            !userTypes.contains(_selectedUserType)) {
          _selectedUserType = userTypes.isNotEmpty ? userTypes.first : null;
        } else if (_selectedUserType == null && userTypes.isNotEmpty) {
          _selectedUserType = userTypes.first;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedUserType,
              dropdownColor: const Color(0xFF1E1E2C),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              isExpanded: true,
              style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16),
              items: userTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Center(child: Text(value)),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedUserType = newValue;
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasswordField(
    String hint,
    TextEditingController controller,
    bool obscureText,
    VoidCallback onToggleVisibility,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.rajdhani(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.white.withOpacity(0.5),
              size: 20,
            ),
            onPressed: onToggleVisibility,
          ),
        ),
      ),
    );
  }
}
