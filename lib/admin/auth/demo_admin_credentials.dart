/// DEMO admin credentials only — never real production secrets.
///
/// Overridable at build time via `--dart-define=ADMIN_DEMO_USERNAME=...`
/// and `--dart-define=ADMIN_DEMO_PASSWORD=...` (see `.env.example`), so
/// nothing sensitive needs to be committed even for this demo.
class DemoAdminCredentials {
  const DemoAdminCredentials._();

  static const String username = String.fromEnvironment(
    'ADMIN_DEMO_USERNAME',
    defaultValue: 'admin',
  );
  static const String password = String.fromEnvironment(
    'ADMIN_DEMO_PASSWORD',
    defaultValue: 'Rakshak@Demo123',
  );
}
