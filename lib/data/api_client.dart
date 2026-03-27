import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:sharp_cut/data/interceptors/auth_interceptor.dart';
import 'package:sharp_cut/data/local_storage/token_storage.dart';
import 'package:sharp_cut/data/local_storage/url_storage.dart';

class ApiClient {
  static String productionBaseUrl = "https://app.sharpcutae.com/api/v2/";
  static String developmentBaseUrl = "https://saloon.softcart.io/api/v2/";
  static String baseUrl = productionBaseUrl;

  static final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: 10),
      sendTimeout: Duration(seconds: 10),
    ),
  )..interceptors.add(AuthInterceptor(GetIt.instance<TokenStorage>()));

  static Future<void> init() async {
    log("Base URL: $baseUrl");
    final urlStorage = UrlStorage();
    final details = await urlStorage.getConnectionDetails();
    final ip = details['ip'];
    final port = details['port'];

    if (ip != null && ip.isNotEmpty && port != null && port.isNotEmpty) {
      baseUrl = "http://$ip:$port/api/v2/";
    } else {
      baseUrl = productionBaseUrl;
    }
    dio.options.baseUrl = baseUrl;
  }

  static Future<void> setConnectionDetails(String ip, String port) async {
    baseUrl = "http://$ip:$port/api/v2/";
    dio.options.baseUrl = baseUrl;
    final urlStorage = UrlStorage();
    await urlStorage.saveConnectionDetails(ip, port);
  }

  static Future<void> resetToDefault() async {
    // reset to default
    baseUrl = productionBaseUrl;
    dio.options.baseUrl = baseUrl;
    final urlStorage = UrlStorage();
    await urlStorage.clearConnectionDetails();
  }

  //POST API ENDPOINTS
  static final loginApi = "login";
  static final logoutApi = "logout";
  static final userExpensePostApi = "users/expenses";
  static final bookingsPostApi = "bookings";
  static final transactionsPOSTapi = "transactions";
  static final updateCustomerDetailsApi = "transactions/update-customer";
  static final transactionsSYNCPOSTapi = "transactions";
  static final resetUserPasswordapi = "reset-password";
  static final resetAdminPasswordapi = "reset-password";
  static final shopAdminLoginapi = "shop-admin-login";
  static final invoiceSettingsPOSTApi = "invoice-settings";
  static final slotBookingChairApi = "transactions/book-slot";
  static final cancelBookingApi = "transactions/cancel";
  static final validatePassword = "users/validate-password";
  static final validatePasswordAdminUser = "shop-admins/validate-password";
  static final saveBookingApi = "transactions/save-booking";
  static final settlePayment = "transactions/settle-payment";
  static final quickPayment = "transactions/quick-payment";
  static final reSettlementPayment = "transactions/payment";
  static final updatePaymentMode = "transactions/payment";
  static final searchCustomerApi = "transactions/search-customer";

  // GET API ENDPOINTS
  static final userExpenseGETapi = "users/expenses";
  static final transactionsGETApi = "transactions";
  static final authentcatedUserApi = "shop";
  static final chairsApi = "chairs";
  static final serviceCategoriesApi = "service-categories";
  static final servicesApi = "services";
  static final invoiceSettingsApi = "invoice-settings";
  static final shopadminsApi = "shop-admins";
  static final serviceByCategorieId = "services";
  static final allUsers = "users";
  static final resetPasswordUsers = "reset-password/users";
  static final quickReportapi = 'transactions/report';
  static final cashRegisterCheckApi = "cash-registers/check";
  static final openCashRegisterApi = "cash-registers/open";
  static final closeCashRegisterApi = "cash-registers/close";
  static final searchinvoiceApi = 'transactions/search';
  static final getTotalSalesForCloseCashRegisterApi =
      "cash-registers/sales-total";
  static final printerSettingsApi = "settings";
  static final cashRegisterLastSalesApi = "cash-registers/print-last-report";
  static final printerListApi = "printers/list";
  static final printInvoiceApi = "print/invoice";
  static final printQuickReportApi = "print/transaction-report";
  static final printCashRegisterApi = "print/cash-register-report";
  static final versionApi = "version";
}
