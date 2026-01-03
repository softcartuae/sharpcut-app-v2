import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:sharp_cut/data/interceptors/auth_interceptor.dart';
import 'package:sharp_cut/data/local_storage/token_storage.dart';

class ApiClient {
  // static String baseUrl = "https://saloon-test2.greendomains.in/";
  static String baseUrl = "http://165.232.178.223/saloon/";
  static final dio = Dio(BaseOptions(baseUrl: baseUrl))
    ..interceptors.add(AuthInterceptor(GetIt.instance<TokenStorage>()));

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
  static final getTotalSalesForCloseCashRegisterApi = "api/cash-registers/sales-total";

  
}
