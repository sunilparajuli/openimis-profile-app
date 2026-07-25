# Apple Wallet Integration Documentation

## Project Overview
- **App Name:** HIB Profile
- **Bundle ID:** `np.gov.hib.hibprofile`
- **Team ID:** `SH3Q8XAG6M`
- **Pass Type ID:** `pass.np.gov.hib.membership`

## Flutter Implementation
- **Plugin:** `apple_passkit`
- **Trigger:** "Add to Apple Wallet" button on `CardDetailPage`.
- **Logic:** Downloads a `.pkpass` file from the backend and presents the native "Add Pass" UI.
- **Backend Endpoint:** `GET ${env.API_HIB_REST_URL}insuree/pass/[chfId]`
- **Headers Sent:** `Insuree-Token`, `App-Version`.

## Backend Requirements (Django)
The backend must return a binary stream of a signed ZIP archive with the `.pkpass` extension.

### Structure of .pkpass ZIP:
1. `pass.json`: Contains the card data (names, IDs, colors).
2. `manifest.json`: SHA-1 hashes of all other files in the ZIP.
3. `signature`: A PKCS#7 detached signature of the manifest, signed with the Apple Pass Certificate.
4. Images: `icon.png` (29x29), `logo.png` (160x50), and their `@2x` versions.

## Native Configuration
- **Entitlements:** Added `com.apple.developer.pass_kit` to `ios/Runner/Runner.entitlements`.
- **Deployment Target:** iOS 14.0+.

## Key Commands for Certificates
- Extract Cert: `openssl pkcs12 -in cert.p12 -clcerts -nokeys -out certificate.pem`
- Extract Key: `openssl pkcs12 -in cert.p12 -nocerts -nodes -out key.pem`
- Convert WWDR: `openssl x509 -inform der -in AppleWWDRCAG3.cer -out wwdr.pem`
