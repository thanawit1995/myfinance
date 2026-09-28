/// Supabase project configuration.
/// Keep the anon key here — it is safe to be public (RLS enforces data isolation).
class SupabaseConfig {
  static const String projectUrl = 'https://dohnijzypsvqdsjkqwli.supabase.co';

  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
      '.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRvaG5panp5cHN2cWRzamtxd2xpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA1MzgxNzIsImV4cCI6MjEwNjExNDE3Mn0'
      '.WdhISbA3gwyq5Y5wOOTpZ1sEtpRSN9mvE0iXTtOYGcg';

  // Google OAuth Client ID (Web)
  static const String googleWebClientId =
      '25761984668-bisj0948pdlu6k6s1hvlpvbmqi9bb2r3.apps.googleusercontent.com';
}
