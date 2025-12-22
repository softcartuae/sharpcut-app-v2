import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:sharp_cut/data/interceptors/auth_interceptor.dart';
import 'package:sharp_cut/data/local_storage/token_storage.dart';

class ApiClient {
  static String baseUrl = "https://saloon-test2.greendomains.in/";
  static final dio = Dio(BaseOptions(baseUrl: baseUrl))
    ..interceptors.add(AuthInterceptor(GetIt.instance<TokenStorage>()));

  //POST API ENDPOINTS
  static final loginApi = "api/login";
  static final logoutApi = "api/logout";
  static final userExpensePostApi = "api/user-expenses";
  static final bookingsPostApi = "api/bookings";
  static final transactionsPOSTapi = "api/transactions";
  static final transactionsSYNCPOSTapi = "api/transactions";
  static final resetUserPasswordapi = "api/reset-password";
  static final resetAdminPasswordapi = "api/reset-password";
  static final shopAdminLoginapi = "api/shop-admin-login";
  static final invoiceSettingsPOSTApi = "api/invoice-settings";

  // GET API ENDPOINTS
  static final userExpenseGETapi = "api/user-expenses";
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
}
