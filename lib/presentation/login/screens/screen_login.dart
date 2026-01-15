import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sharp_cut/cubit/auth/auth_cubit.dart';
import 'package:sharp_cut/presentation/home/screens/screen_home.dart';
import 'package:sharp_cut/data/api_client.dart';
import 'package:sharp_cut/data/local_storage/url_storage.dart';
import 'package:sharp_cut/utils/app_colors.dart';
import 'package:sharp_cut/utils/helpers/toast_helper.dart';

class ScreenLogin extends StatefulWidget {
  const ScreenLogin({super.key});

  @override
  State<ScreenLogin> createState() => _ScreenLoginState();
}

class _ScreenLoginState extends State<ScreenLogin> {
  bool _isPasswordVisible = false;
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadConnectionDetails();
  }

  Future<void> _loadConnectionDetails() async {
    final urlStorage = UrlStorage();
    final details = await urlStorage.getConnectionDetails();
    final ip = details['ip'];
    final port = details['port'];

    if (ip != null && ip.isNotEmpty && port != null && port.isNotEmpty) {
      _ipController.text = ip;
      _portController.text = port;
    }
  }

  @override
  void dispose() {
    _licenseController.dispose();
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthCubitState>(
        listener: (context, state) {
          if (state is AuthLoginSuccess || state is AuthAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const ScreenHome()),
            );
          } else if (state is AuthError) {
            ToastHelper.showError(state.message);
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 65,
                          width: 361,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                "lib/utils/images/sharp_cut.png",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),

                    // Login Card
                    Container(
                      width: 400, // Fixed width for tablet
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.violetDarker, // Dark purple/black
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            spreadRadius: 0,
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 4,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'Welcome Back!',
                              style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Center(
                            child: Text(
                              'welcome back we missed you',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Licence Key',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _licenseController,
                            obscureText: !_isPasswordVisible,
                            style: const TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'License key cannot be empty';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              hintStyle: TextStyle(
                                color: Colors.grey.withValues(alpha: 0.5),
                              ),
                              prefixIcon: const Icon(
                                Icons.vpn_key_outlined,
                                color: Colors.grey,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.violetNormal,
                                ),
                              ),
                              errorStyle: const TextStyle(
                                color: AppColors.redNormal,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'IP Address',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _ipController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9.]'),
                                        ),
                                      ],
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '192.168.1.5',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white.withValues(
                                          alpha: 0.05,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.white.withValues(
                                              alpha: 0.1,
                                            ),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: AppColors.violetNormal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Port',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _portController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '8001',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white.withValues(
                                          alpha: 0.05,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.white.withValues(
                                              alpha: 0.1,
                                            ),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: AppColors.violetNormal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Sign In Button
                          Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.violetNormal, // Purple
                                  AppColors.redNormal, // Pinkish/Red
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: state is AuthLoading
                                  ? null
                                  : () async {
                                      final ip = _ipController.text.trim();
                                      final port = _portController.text.trim();

                                      // Validation: Either both empty or both filled
                                      if ((ip.isEmpty && port.isNotEmpty) ||
                                          (ip.isNotEmpty && port.isEmpty)) {
                                        ToastHelper.showError(
                                          "Please provide both IP and Port, or leave both empty to use default.",
                                        );
                                        return;
                                      }

                                      if (_formKey.currentState!.validate()) {
                                        if (ip.isNotEmpty && port.isNotEmpty) {
                                          await ApiClient.setConnectionDetails(
                                            ip,
                                            port,
                                          );
                                        } else {
                                          await ApiClient.resetToDefault();
                                        }

                                        if (context.mounted) {
                                          context.read<AuthCubit>().login(
                                            _licenseController.text.trim(),
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: state is AuthLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Sign in',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
