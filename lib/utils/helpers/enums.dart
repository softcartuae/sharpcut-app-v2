import 'package:flutter/material.dart';
import 'package:sharp_cut/utils/app_colors.dart';

enum LiveState {
  available,
  occupied,
}

enum Role {
  staff,
  admin,
}

enum PaymentMode {
  // ignore: constant_identifier_names
  Cash,
  // ignore: constant_identifier_names
  Card,
  // ignore: constant_identifier_names
  Unpaid,
  // ignore: constant_identifier_names
  Wallet,
}

enum OnlineBookingStatus {
  pending,
  confirmed,
  completed,
  cancelled,
  rescheduled,
  inProgress;

  static OnlineBookingStatus? fromString(String? status) {
    if (status == null ||
        status.trim().isEmpty ||
        status.trim().toLowerCase() == 'all') {
      return null;
    }
    switch (status.trim().toLowerCase()) {
      case 'pending':
        return OnlineBookingStatus.pending;
      case 'confirmed':
        return OnlineBookingStatus.confirmed;
      case 'completed':
        return OnlineBookingStatus.completed;
      case 'cancelled':
        return OnlineBookingStatus.cancelled;
      case 'rescheduled':
        return OnlineBookingStatus.rescheduled;
      case 'in_progress':
      case 'in progress':
        return OnlineBookingStatus.inProgress;
      default:
        return null;
    }
  }

  String get apiKey {
    switch (this) {
      case OnlineBookingStatus.pending:
        return 'pending';
      case OnlineBookingStatus.confirmed:
        return 'confirmed';
      case OnlineBookingStatus.completed:
        return 'completed';
      case OnlineBookingStatus.cancelled:
        return 'cancelled';
      case OnlineBookingStatus.rescheduled:
        return 'rescheduled';
      case OnlineBookingStatus.inProgress:
        return 'in_progress';
    }
  }

  String get label {
    switch (this) {
      case OnlineBookingStatus.pending:
        return 'PENDING';
      case OnlineBookingStatus.confirmed:
        return 'CONFIRMED';
      case OnlineBookingStatus.completed:
        return 'COMPLETED';
      case OnlineBookingStatus.cancelled:
        return 'CANCELLED';
      case OnlineBookingStatus.rescheduled:
        return 'RESCHEDULED';
      case OnlineBookingStatus.inProgress:
        return 'IN PROGRESS';
    }
  }

  Color get bgColor {
    switch (this) {
      case OnlineBookingStatus.confirmed:
      case OnlineBookingStatus.completed:
        return AppColors.statusConfirmedBg;
      case OnlineBookingStatus.cancelled:
        return AppColors.statusCancelledBg;
      case OnlineBookingStatus.rescheduled:
        return AppColors.statusRescheduledBg;
      case OnlineBookingStatus.pending:
      case OnlineBookingStatus.inProgress:
        return AppColors.statusPendingBg;
    }
  }

  Color get borderColor {
    switch (this) {
      case OnlineBookingStatus.confirmed:
      case OnlineBookingStatus.completed:
        return AppColors.statusConfirmedBorder;
      case OnlineBookingStatus.cancelled:
        return AppColors.statusCancelledBorder;
      case OnlineBookingStatus.rescheduled:
        return AppColors.statusRescheduledBorder;
      case OnlineBookingStatus.pending:
      case OnlineBookingStatus.inProgress:
        return AppColors.statusPendingBorder;
    }
  }

  Color get textColor {
    switch (this) {
      case OnlineBookingStatus.confirmed:
      case OnlineBookingStatus.completed:
        return AppColors.statusConfirmedText;
      case OnlineBookingStatus.cancelled:
        return AppColors.statusCancelledText;
      case OnlineBookingStatus.rescheduled:
        return AppColors.statusRescheduledText;
      case OnlineBookingStatus.pending:
      case OnlineBookingStatus.inProgress:
        return AppColors.statusPendingText;
    }
  }
}
