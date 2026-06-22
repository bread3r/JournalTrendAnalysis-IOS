# AI-assisted Code Review Notes

Tooling used: Codex review, `flutter analyze`, and `flutter test`.

## Findings and Fixes

1. The generated Flutter counter scaffold did not match the lab architecture.
   Fixed by replacing it with separated `models`, `services`, `state`,
   `screens`, `widgets`, and `utils` modules.

2. The Android manifest initially lacked explicit Internet permission. Fixed by
   adding `android.permission.INTERNET` so the app can call OpenAlex on a real
   Android device.

3. Chart code initially used an incompatible `ColorScheme` getter. Fixed by
   using `onInverseSurface`, then reran `flutter analyze` successfully.

4. API calls needed resilient loading and error states. Fixed with
   `ResearchController`, timeout handling, OpenAlex error parsing, retry, and
   loading indicators.

## Verification

- `dart format lib test`: passed.
- `flutter analyze`: passed with no issues.
- `flutter test`: passed.

Android APK build could not be completed on this machine because Flutter cannot
find an installed Android SDK. Configure Android SDK and JDK 17, then run
`flutter build apk --debug`.
