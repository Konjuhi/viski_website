import 'package:supabase/supabase.dart';

import '../core/config/supabase_config.dart';

class SupabaseService {
  static SupabaseClient? _client;

  static SupabaseClient get client {
    _client ??= SupabaseClient(SupabaseConfig.url, SupabaseConfig.anonKey);
    return _client!;
  }
}
