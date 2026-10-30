class ApiConstants {
  static const String baseUrl = 'https://dummyjson.com';
  
  // Endpoints
  static const String login = '$baseUrl/auth/login';
  static const String userMe = '$baseUrl/auth/me';
  static const String products = '$baseUrl/products';

  // Default pagination parameters
  static const int defaultLimit = 15;
}
