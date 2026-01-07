import 'package:dio/dio.dart';
import 'package:sharp_cut/data/api_client.dart';
import 'package:sharp_cut/domain/printing/model/printer_settings_model.dart';

class PrintingService {
  PrintingService();

  Future<Response> getPrinterSettings() async {
    return await ApiClient.dio.get(ApiClient.printerSettingsApi);
  }

  Future<Response> updatePrinterSettings(PrinterSettingsModel model) async {
    return await ApiClient.dio.post(
      ApiClient.printerSettingsApi,
      data: model.toJson(),
    );
  }
}
