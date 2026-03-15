class SupabaseConfig {
  static const _defaultUrl = 'https://ugoqoapwzuxrhofzmyqq.supabase.co';
  static const _defaultAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
      'eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVnb3FvYXB3enV4cmhvZnpteXFxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM1NzExMjIsImV4cCI6MjA4OTE0NzEyMn0.'
      'DighTEKml0Tr5pISF5e1EL-du3bqJSseDaClGuMroIE';

  static const _envUrl = String.fromEnvironment('SUPABASE_URL');
  static const _envAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static final String url = _envUrl.isNotEmpty ? _envUrl : _defaultUrl;
  static final String anonKey = _envAnonKey.isNotEmpty
      ? _envAnonKey
      : _defaultAnonKey;

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
