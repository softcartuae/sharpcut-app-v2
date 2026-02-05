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

  Future<Response> getServerPrinters() async {
    return await ApiClient.dio.get(ApiClient.printerListApi);
  }

  Future<Response> printInvoice({
    required int transactionId,
    required String printerName,
    required int size,
  }) async {
    return await ApiClient.dio.post(
      ApiClient.printInvoiceApi,
      data: {
        "transaction_id": transactionId,
        "printer": {"name": printerName, "size": size},
      },
    );
  }

  Future<Response> printQuickReport({
    required String dateRange,
    required int? userId,
    required String printerName,
    required int size,
  }) async {
    return await ApiClient.dio.post(
      ApiClient.printQuickReportApi,
      data: {
        "date_range": dateRange,
        "user_id": userId,
        "printer": {"name": printerName, "size": size},
      },
    );
  }

  Future<Response> printCashRegisterReport({
    required int cashRegisterId,
    required String printerName,
    required int size,
  }) async {
    return await ApiClient.dio.post(
      ApiClient.printCashRegisterApi,
      data: {
        "cash_register_id": cashRegisterId,
        "printer": {"name": printerName, "size": size},
      },
    );
  }
}
