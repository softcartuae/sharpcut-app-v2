import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:sharp_cut/core/database/database_helper.dart';
import 'package:sharp_cut/data/api_client.dart';
import 'package:sharp_cut/domain/pusher/pusher_repo.dart';

class PusherRepoImpl implements PusherRepo {
  final DatabaseHelper _dbHelper;

  PusherRepoImpl({required DatabaseHelper dbHelper}) : _dbHelper = dbHelper;

  @override
  Future<void> notifyChairUpdate() async {
    try {
      log("PusherRepo: Triggering chair update notification...");
      // 2. Fetch all chairs with status
      final chairsData = await _dbHelper.getChairsWithStatus();

      // 3. Build the metadata list
      final List<Map<String, dynamic>> metadata = chairsData.map((row) {
        final String? bookingTime = row['booking_time'];
        String? formattedTime;
        String? normalizedBookingTime;

        if (bookingTime != null) {
          final String? bookingTime = row['booking_time'];

          if (bookingTime != null) {
            try {
              DateTime dt;

              if (bookingTime.contains('/')) {
                // Input: 27/03/2026 03:58 PM
                dt = DateFormat('dd/MM/yyyy hh:mm a').parse(bookingTime);
              } else {
                // Input: 2026-03-27 14:25:00
                dt = DateFormat('yyyy-MM-dd HH:mm:ss').parse(bookingTime);
              }

              // ✅ Convert to desired formats
              formattedTime = DateFormat('hh:mm a').format(dt);
              normalizedBookingTime = DateFormat(
                'yyyy-MM-dd HH:mm:ss',
              ).format(dt);
            } catch (e) {
              log("Error formatting time: $e");
              formattedTime = null;
              normalizedBookingTime = bookingTime; // fallback
            }
          }
        }

        return {
          "chair": row['chair'],
          "status": row['transaction_status'] == 'Pending' ? "booked" : "free",
          "user_id": row['user_id'],
          "chair_id": row['chair_id'],
          "user_name": row['user_name'],
          "user_photo": row['user_photo'],
          "booking_time": normalizedBookingTime,
          "date_time_formatted": formattedTime,
        };
      }).toList();

      // 4. Build the full body
      final Map<String, dynamic> body = {"metadata": metadata};

      // 5. Send to API
      log(
        "PusherRepo: Sending notification to ${ApiClient.pusherNotifyApi}...",
      );
      final response = await ApiClient.dio.post(
        ApiClient.pusherNotifyApi,
        data: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("PusherRepo: Notification sent successfully.");
      } else {
        log(
          "PusherRepo: Failed to send notification. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      log("PusherRepo: Error in notifyChairUpdate: $e");
    }
  }
}
