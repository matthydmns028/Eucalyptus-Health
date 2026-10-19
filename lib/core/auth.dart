import 'models.dart';

/// Local-only authentication used for demos. No network calls.
///
/// Demo account:
///   Email      : elena.vance@wellness.med   (or Patient ID: PT-20481)
///   Password   : Eucalyptus@1
class AuthService {
  static const demoEmail = 'elena.vance@wellness.med';
  static const demoPatientId = 'PT-20481';
  static const defaultPassword = 'Eucalyptus@1';
  static const resetOtp = '123456';

  static String _password = defaultPassword;
  static String get demoPassword => _password;

  /// Called by the forgot-password flow (in-memory only).
  static void setPassword(String value) => _password = value;

  static bool matchesIdentity(String id) {
    final key = id.trim().toLowerCase();
    return key == demoEmail || key == demoPatientId.toLowerCase();
  }

  static const demoPatient = Patient(
    firstName: 'Elena',
    lastName: 'Vance',
    email: demoEmail,
    patientId: demoPatientId,
  );

  static Future<Patient?> signIn(String id, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final key = id.trim().toLowerCase();
    final idOk = key == demoEmail || key == demoPatientId.toLowerCase();
    if (idOk && password == _password) return demoPatient;
    return null;
  }

  static Future<Patient> signInWithFace() async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    return demoPatient;
  }
}
