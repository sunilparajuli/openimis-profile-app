# Google Wallet Integration Documentation

## Project Overview
- **App Name:** HIB Profile
- **Package Name:** `hib.np.com.tinker`
- **Issuer ID:** Obtain from [Google Pay & Wallet Console](https://pay.google.com/business/console/)

## Flutter Implementation
- **Plugin:** `flutter_google_wallet`
- **Trigger:** "Add to Google Wallet" button on `CardDetailPage`.
- **Logic:** Fetches a signed JSON Web Token (JWT) from the backend and passes it to the native SDK.
- **Backend Endpoint:** `GET ${env.API_HIB_REST_URL}insuree/google-pass/[chfId]`
- **Headers Sent:** `Insuree-Token`, `App-Version`.

## Backend Requirements (Django)
The backend must return a JSON response containing a signed JWT.

### Process:
1. Create a **Generic Object** or **Generic Class** in the Google Wallet Console.
2. Sign a JWT (ES256) using your **Service Account Key** (.json).
3. The JWT payload must follow the [Google Wallet API reference](https://developers.google.com/wallet/generic/rest/v1/GenericObject).

## Key Implementation Steps
1. Enable the **Google Wallet API** in the Google Cloud Console.
2. Create a **Service Account** and download the JSON key.
3. Register your **Issuer ID** in the Wallet Console.
4. Set the app to **Test Mode** or **Production Mode** in the console.
