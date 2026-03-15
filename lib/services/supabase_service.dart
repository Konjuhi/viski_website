import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  if (!SupabaseConfig.isConfigured) {
    throw StateError(
      'Supabase is not configured. Provide SUPABASE_URL and SUPABASE_ANON_KEY.',
    );
  }

  return Supabase.instance.client;
});
