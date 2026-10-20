import 'package:sharp_cut/domain/auth/models/branch_model.dart';

/// Centralised shop-configuration helpers.
///
/// Logic table (from backend spec):
/// ┌──────────┬───────────┬────────────┬────────────────┐
/// │ isChair  │ isCashier │ No-chair   │ Password       │
/// │          │           │ layout?    │ required?      │
/// ├──────────┼───────────┼────────────┼────────────────┤
/// │ false    │ false     │ YES        │ NO (anyone)    │
/// │ true     │ false     │ NO         │ YES (anyone)   │
/// │ true     │ true      │ NO         │ YES (admin only)│
/// │ false    │ true      │ — invalid  │ —              │
/// └──────────┴───────────┴────────────┴────────────────┘
class ShopConfigHelper {
  // ───────────────────────── Layout ─────────────────────────

  /// Returns true when the shop operates in no-chair layout
  /// (single chair is auto-selected, chair picker is hidden).
  static bool isNoChairMode(BranchModel? shop) {
    if (shop == null) return false;
    return shop.isChair == false;
  }

  // ───────────────────────── Password ────────────────────────

  /// Returns true when a password must be collected from the user.
  ///
  /// [isAdmin] – pass true when the user being validated is an admin.
  static bool isPasswordRequired({
    required BranchModel? shop,
    required bool isAdmin,
  }) {
    if (shop == null) return true;

    final isChair = shop.isChair ?? true;
    final isCashier = shop.isCashier ?? false;

    // No-chair mode → skip password for everyone (including admin).
    if (!isChair) return false;

    // Cashier mode → skip password for regular staff, require for admin.
    if (isCashier) return isAdmin;

    // Standard chair mode → password required for everyone.
    return true;
  }

  // ───────────────────────── Feature flags ───────────────────

  /// Returns true when the shop allows editing service / charge prices.
  static bool canEditServiceOrCharge(BranchModel? shop) {
    if (shop == null) return false;
    return shop.isChargeOrServiceCanEdit == true;
  }

  /// Returns true when shop expenses should be shown.
  static bool showShopExpenses(BranchModel? shop) {
    if (shop == null) return false;
    return shop.isShopExpenses == true;
  }

  /// Returns true when user expenses should be shown.
  static bool showUserExpenses(BranchModel? shop) {
    if (shop == null) return false;
    return shop.isUserExpenses == true;
  }
  
}
