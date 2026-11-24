import 'package:flutter/material.dart';
import 'package:sharp_cut/utils/app_colors.dart';
import 'package:sharp_cut/utils/helpers/url_launcher_helper.dart';

class LoginLegalLinks extends StatelessWidget {
  const LoginLegalLinks({super.key});

  @override
  Widget build(BuildContext context) {
    if (!UrlLauncherHelper.isMobile) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => UrlLauncherHelper.openTermsAndConditions(),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text(
              'Terms & Conditions',
              style: TextStyle(
                color: AppColors.violetLightActive,
                fontSize: 12,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.violetLightActive,
              ),
            ),
          ),
        ),
        const Text(
          '•',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 12,
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => UrlLauncherHelper.openPrivacyPolicy(),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text(
              'Privacy Policy',
              style: TextStyle(
                color: AppColors.violetLightActive,
                fontSize: 12,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.violetLightActive,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
