# Eucalyptus Health – med_monitoring_app

Screens: **Sign In** (+ password reset flow) and **Home**. Flutter only, no extra packages, fully offline.

## Run
```
flutter pub get
flutter run            # Windows, Chrome, Android emulator...
flutter test
```

## Demo login
| Field                    | Value                      |
|--------------------------|----------------------------|
| Email                    | `elena.vance@wellness.med` |
| Patient ID (alternative) | `PT-20481`                 |
| Password                 | `Eucalyptus@1`             |
| Reset-password OTP       | `123456`                   |

Fields are pre-filled. Credentials live in `lib/core/auth.dart`.

## Structure
```
lib/
  main.dart
  core/       theme, models, auth (dummy), day_data (fake history), routes
  screens/    login_screen, forgot_password_screen, home_screen
  widgets/    common, app_field, home_widgets, sheets (all bottom sheets)
assets/fonts/ Plus Jakarta Sans (bundled)
```

## Not built yet (shown as "coming soon" sheets / placeholder tabs)
Metrics, Visits, Records screens; metric deep-dives; registration flow;
personal info / emergency contacts / insurance pages.
