# Project Documentation for AI Agents

## Project Overview
- **Name:** openimis_mobile_app
- **Platform:** Flutter
- **Target OS:** Android 17 (API 37), iOS
- **Architecture:** Modular UI with Logic Hooks and Centralized Utils.

## Key Configurations
- **Android SDK:** `compileSdk 37`, `targetSdk 37`, `minSdkVersion 24`.
- **Environment:** Uses `flutter_dotenv`. Actual secrets are in `.env` (ignored by git). Template is in `.env.example`.
- **Java Version:** 17.

## Important Directories & Files
- `lib/hooks/`: Contains page-specific business logic and data fetching (e.g., `home_page_hooks.dart`).
- `lib/utils/`: Global utility functions (e.g., `token_fetch.dart` for auth tokens).
- `lib/pages/home/widgets/`: Modular UI components for the homepage.
- `lib/common/env.dart`: Bridge between `.env` file and the application code.
- `lib/theme/`: Branding colors and custom theme definitions.

## Recent Major Changes
1. **Migration to Android 17:** Optimized for 64-bit hardware (Pixel 7+) with 16KB page alignment.
2. **Logic Extraction:** Moved procedural code from `home_page.dart` into `HomePageHooks` and reusable widgets.
3. **Null Safety & Robustness:** Updated data models (`insuree_info.dart`, `insuree_claims.dart`) to handle null values from the API safely.
4. **Session Isolation:** Implemented mandatory local storage wipe upon any new login attempt to prevent data leakage between users.
5. **Race Condition Fix:** Refactored `SplashScreen` to wait for `AuthBlock` initialization, preventing accidental redirection to login during slow device startups.
6. **Consistency:** Standardized icon colors and card styles to match the Brand Purple palette.

## Guidelines for Future Work
- Always use `ApiClient.postGraphQL` or `ApiClient.postRest` to ensure `Insuree-Token` and `App-Version` headers are sent.
- Add new page-specific logic to `lib/hooks/`.
- Maintain the Brand Purple theme for interactive elements.
- Keep UI components small and modular in their respective page subdirectories.
