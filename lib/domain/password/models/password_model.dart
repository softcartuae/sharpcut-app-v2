class PasswordModel {
  final String staffId;
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  PasswordModel({
    required this.staffId,
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': staffId,
      'current_password': currentPassword,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    };
  }
}
