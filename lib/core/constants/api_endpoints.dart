class ApiEndpoints {
  ApiEndpoints._();

  // Environment URLs
  static const String devBaseUrl = 'http://10.0.2.2:3000';
  static const String prodBaseUrl = 'https://allfixservicexpress.com.ng';

  // Override with --dart-define=ALLFIX_API_BASE_URL=... for local or staging API.
  static String activeBaseUrl = const String.fromEnvironment(
    'ALLFIX_API_BASE_URL',
    defaultValue: prodBaseUrl,
  );

  // REST Endpoints
  static String get requests => '$activeBaseUrl/api/requests';
  static String get otpRequest => '$activeBaseUrl/api/otp/request';
  static String get otpVerify => '$activeBaseUrl/api/otp/verify';
  static String get vendors => '$activeBaseUrl/api/vendors';
  static String get properties => '$activeBaseUrl/api/properties';
  static String get vehicles => '$activeBaseUrl/api/vehicles';
  static String get vendorWorks => '$activeBaseUrl/api/vendor-works';
  static String get marketingRequests =>
      '$activeBaseUrl/api/marketing-requests';
  static String get stats => '$activeBaseUrl/api/stats';
  static String get adminLogin => '$activeBaseUrl/api/admin/login';
  static String get adminAuthCheck => '$activeBaseUrl/api/admin/auth-check';
  static String get adminLogout => '$activeBaseUrl/api/admin/logout';

  // Public client configuration is injected at build time. Keep service-role
  // credentials in the API server only.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );
  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'your-anon-key',
  );
}
