import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/api_endpoints.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;

  SupabaseClient? _client;
  bool _isInitialized = false;

  SupabaseService._internal();

  bool get isReady => _isInitialized && _client != null;
  SupabaseClient? get client => _client;

  Future<void> initialize() async {
    // Check if valid URL has been configured
    if (ApiEndpoints.supabaseUrl.contains('your-project') ||
        ApiEndpoints.supabasePublishableKey == 'your-anon-key') {
      // Supabase is not yet configured with production keys; skipped gracefully
      _isInitialized = false;
      return;
    }

    try {
      await Supabase.initialize(
        url: ApiEndpoints.supabaseUrl,
        publishableKey: ApiEndpoints.supabasePublishableKey,
      );
      _client = Supabase.instance.client;
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
    }
  }
}
