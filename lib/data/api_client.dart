import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:sharp_cut/data/interceptors/auth_interceptor.dart';
import 'package:sharp_cut/data/local_storage/token_storage.dart';
import 'package:sharp_cut/data/local_storage/url_storage.dart';

class ApiClient {
  static String baseUrl = "https://saloon.softcart.io/";

  static final dio = Dio(BaseOptions(baseUrl: baseUrl))
    ..interceptors.add(AuthInterceptor(GetIt.instance<TokenStorage>()));

  static Future<void> init() async {
    final urlStorage = UrlStorage();
    final details = await urlStorage.getConnectionDetails();
    final ip = details['ip'];
    final port = details['port'];

    if (ip != null && ip.isNotEmpty && port != null && port.isNotEmpty) {
      baseUrl = "http://$ip:$port/";
    } else {
      baseUrl = "https://saloon.softcart.io/";
    }
    dio.options.baseUrl = baseUrl;
  }

  static Future<void> setConnectionDetails(String ip, String port) async {
    baseUrl = "http://$ip:$port/";
    dio.options.baseUrl = baseUrl;
    final urlStorage = UrlStorage();
    await urlStorage.saveConnectionDetails(ip, port);
  }

  static Future<void> resetToDefault() async {
    baseUrl = "http://165.232.178.223/saloon/";
    dio.options.baseUrl = baseUrl;
    final urlStorage = UrlStorage();
    await urlStorage.clearConnectionDetails();
  }

  //POST API ENDPOINTS
  static final loginApi = "api/login";
  static final logoutApi = "api/logout";
  static final userExpensePostApi = "api/users/expenses";
  static final bookingsPostApi = "api/bookings";
  static final transactionsPOSTapi = "api/transactions";
  static final transactionsSYNCPOSTapi = "api/transactions";
  static final resetUserPasswordapi = "api/reset-password";
  static final resetAdminPasswordapi = "api/reset-password";
  static final shopAdminLoginapi = "api/shop-admin-login";
  static final invoiceSettingsPOSTApi = "api/invoice-settings";
  static final slotBookingChairApi = "api/transactions/book-slot";
  static final cancelBookingApi = "api/transactions/cancel";
  static final validatePassword = "api/users/validate-password";
  static final validatePasswordAdminUser = "api/shop-admins/validate-password";
  static final saveBookingApi = "api/transactions/save-booking";
  static final settlePayment = "api/transactions/settle-payment";
  static final quickPayment = "api/transactions/quick-payment";
  static final reSettlementPayment = "api/transactions/payment";
  static final updatePaymentMode = "api/transactions/payment";

  // GET API ENDPOINTS
  static final userExpenseGETapi = "api/users/expenses";
  static final transactionsGETApi = "api/transactions";
  static final authentcatedUserApi = "api/shop";
  static final chairsApi = "api/chairs";
  static final serviceCategoriesApi = "api/service-categories";
  static final servicesApi = "api/services";
  static final invoiceSettingsApi = "api/invoice-settings";
  static final shopadminsApi = "api/shop-admins";
  static final serviceByCategorieId = "api/services";
  static final allUsers = "api/users";
  static final resetPasswordUsers = "api/reset-password/users";
  static final quickReportapi = '/api/transactions/report';
  static final cashRegisterCheckApi = "api/cash-registers/check";
  static final openCashRegisterApi = "api/cash-registers/open";
  static final closeCashRegisterApi = "api/cash-registers/close";
  static final getTotalSalesForCloseCashRegisterApi =
      "api/cash-registers/sales-total";
  static final printerSettingsApi = "api/settings";
  static final cashRegisterLastSalesApi =
      "api/cash-registers/print-last-report";
  static final printerListApi = "api/printers/list";
  static final printInvoiceApi = "api/print/invoice";
  static final printQuickReportApi = "api/print/transaction-report";
  static final printCashRegisterApi = "api/print/cash-register-report";
}
