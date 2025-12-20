import 'package:dio/dio.dart';

class ApiClient {
  static String baseUrl = "https://api.example.com";
  static final dio = Dio(BaseOptions(baseUrl: baseUrl));
  
}