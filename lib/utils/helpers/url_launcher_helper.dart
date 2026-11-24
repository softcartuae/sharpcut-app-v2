import 'package:flutter/foundation.dart';
import 'package:sharp_cut/utils/helpers/toast_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherHelper {
  UrlLauncherHelper._();

  static const String termsAndConditionsUrl = 'https://sharpcutae.com/terms/';
  static const String privacyPolicyUrl = 'https://sharpcutae.com/policy/';

  /// Returns true only on Android and iOS platforms
  static bool get isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Launch web URL inside the app using in-app browser view (Chrome Custom Tabs on Android / Safari View Controller on iOS)
  static Future<void> openUrl(String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) {
      ToastHelper.showError('Invalid URL.');
      return;
    }

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
      );
      if (!launched) {
        final bool fallback = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!fallback) {
          ToastHelper.showError('Could not open page.');
        }
      }
    } catch (_) {
      try {
        final bool fallback = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!fallback) {
          ToastHelper.showError('Could not open page.');
        }
      } catch (_) {
        ToastHelper.showError('Could not open page.');
      }
    }
  }

  /// Launch Privacy Policy page
  static Future<void> openPrivacyPolicy() async {
    await openUrl(privacyPolicyUrl);
  }

  /// Launch Terms and Conditions page
  static Future<void> openTermsAndConditions() async {
    await openUrl(termsAndConditionsUrl);
  }
}
