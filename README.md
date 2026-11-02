# 📱 ALLFIX Services Xpress — Flutter Android Mobile App

Official native Android mobile application for **ALLFIX Services Xpress (ALLFIX)** built with Flutter, Riverpod, and Dio.

> *"Bridging the trust deficit in everyday services across Nigeria & Africa."*  
> *"Not just selling you products and services, but selling you peace of mind."*

---

## 🏗️ Architecture & Stack

- **Framework**: Flutter 3 (Android API 21+)
- **State Management**: `flutter_riverpod` (v2.5.1)
- **Declarative Navigation**: `go_router` (v14.1.4) with `StatefulShellRoute`
- **Networking**: `dio` (v5.4.3) with timeout interceptors and explicit connection errors
- **Real-time & DB**: `supabase_flutter` (v2.5.6)
- **Secure Storage**: `flutter_secure_storage` (server-issued admin session token)
- **Typography & Design**: Google Fonts (`Plus Jakarta Sans` & `Inter`), custom design tokens
- **Communication & Deep Linking**: `url_launcher` with pre-filled WhatsApp dispatch messages

---

## 🎨 Brand Design Tokens

| Token | Hex | Flutter Token | Usage |
| :--- | :--- | :--- | :--- |
| **Brand Primary Green** | `#16883D` | `Color(0xFF16883D)` | Primary buttons, active tabs, verified checkmarks |
| **Brand Green Dark** | `#166534` | `Color(0xFF166534)` | Pressed states, dark contrast banners |
| **Brand Green Light** | `#DCFCE7` | `Color(0xFFDCFCE7)` | Badge backgrounds, highlighted cards |
| **Dark Neutral** | `#151B17` | `Color(0xFF151B17)` | Heading text, card headers |
| **Body Neutral** | `#4A5568` | `Color(0xFF4A5568)` | Subtitles, body descriptions |
| **Background Subtle** | `#F8FAF8` | `Color(0xFFF8FAF8)` | Scaffold background |
| **Card Border** | `#DCE4DD` | `Color(0xFFDCE4DD)` | Outlines, card borders |
| **High Urgency** | `#DC2626` | `Color(0xFFDC2626)` | Immediate dispatch badge |
| **Medium Urgency** | `#D97706` | `Color(0xFFD97706)` | Within 24–48 hours badge |
| **Low Urgency** | `#16883D` | `Color(0xFF16883D)` | Flexible schedule badge |

---

## 📱 Screen Map (4 Persistent Navigation Tabs)

1. **Tab 1: Home Dashboard (`/home`)**
   - Hero: *"A Smarter, Safer Way to Hire Artisans"*
   - Live platform stats from the backend; unavailable values are shown as unavailable
   - Category Grid (15 items with responsive icons & popular service tags)
   - Verified Real Estate Carousel
   - The ALLFIX Promise Banner with direct dispatch CTA
2. **Tab 2: Book Service Wizard (`/request`)**
   - Dynamic 4-branch form adapting to:
     1. *Property Sales & Rentals* (Bedrooms, types, budget, timeline)
     2. *Cars & Vehicles* (SUV/Sedan, EV toggle, model/year, issue)
     3. *Construction & Land* (Land size, land scouting status, CAD/scope)
     4. *General Artisan Services* (Task, description)
   - Urgency Selector: High / Medium / Low
   - Mandatory Client Terms (v1.0) compliance checkbox
   - Instant Confirmation View with generated Request ID (`REQ-XXXXXXXX`) and direct WhatsApp dispatch button
3. **Tab 3: Property Explorer (`/properties`)**
   - Current property listings returned by the backend, with empty and error states
   - Search by location (Guzape, Lugbe, Wuse, Katampe) & keyword
   - Category filter chips (Residential, Commercial, Land)
   - Property Details (`/properties/:id`): photo gallery, title document badge (C of O), specs, and "Book Physical Inspection via WhatsApp" button
   - Vehicle Explorer (`/vehicles`) and Artisan Work Gallery (`/work`) load current backend records and show honest empty/error states
4. **Tab 4: Join Artisan (`/vendor`)**
   - Artisan KYC registration form
   - Trade category & dynamic specialty tag manager
   - Experience years, operating areas, CAC / Trade ID / NIN
   - Vendor Terms (v1.0) compliance acceptance
5. **Asset Marketing (`/list-asset`)**
   - Owner submission for a property or vehicle, with branch specific fields and mandatory Marketing & Inspection Terms
   - Image upload is omitted until the backend provides a supported upload endpoint
6. **Dispatch HQ Portal (`/admin`, direct admin route)**
   - Server authentication with a secure stored session token
   - Incoming requests queue with urgency filters
   - Status updater (`pending_matching` → `contacted` → `matched` → `completed`)
   - Add/Manage Properties Modal with instant publishing & deletion
   - Live platform metrics and hotline escalation

---

## 💬 Direct WhatsApp Deep-Link Rule

ALLFIX operates with human dispatching support. Any WhatsApp action in the Flutter app launches:
* **Target Number**: `+234 705 809 9045` (`2347058099045`)
* **URL Format**: `https://wa.me/2347058099045?text=<URL_ENCODED_MESSAGE>`
* **Service Request Confirmation**:
  `"Hello ALLFIX Support, I just submitted request [REQ-ID] for [Category]. Can you connect me with a specialist?"`
* **Property Inquiry**:
  `"Hello ALLFIX Properties, I am inquiring about [Property Title] in [Location] (Ref: [PROP-ID]). Is it available for inspection?"`

---

## 🚀 Running the Project

### Prerequisites
1. Install the stable [Flutter SDK](https://docs.flutter.dev/install/manual) (Dart is included).
2. Install JDK 17 and the Android SDK using [Android Studio](https://developer.android.com/studio/) or its command-line tools.
3. Run `flutter doctor --android-licenses` and accept the Android SDK licenses, then confirm the Android toolchain is green with `flutter doctor -v`.
4. Install the Android SDK platform and build tools matching the `compileSdk` selected by the installed Flutter version.

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run on Android Emulator or Physical Device
```bash
flutter run
```

For a local backend (the checked-in server example uses port 3000), run:

```bash
flutter run --dart-define=ALLFIX_API_BASE_URL=http://10.0.2.2:3000
```

### 3. Build APK for Android
```bash
flutter build apk --release
```
The output APK is generated at: `build/app/outputs/flutter-apk/app-release.apk`.

---

## 🛡️ Launch Compliance Rules Followed

1. **NO Mock Data**: Listings and platform metrics come from the backend; empty or unavailable responses do not produce sample content.
2. **Zero Dummy Testimonials**: Genuine platform assurances and Abuja HQ contact details.
3. **Mandatory Terms Acceptance**: Every customer request and vendor application requires `termsAccepted: true` and `termsVersion: 'v1.0'`.
4. **Email Verification**: Service bookings require a one-time email code before submission. The code is generated and verified by the backend; Resend only delivers the message.

### Build configuration and release signing

The Android project reads its signing values from the ignored `android/key.properties` file. Copy `android/key.properties.example` to that name and fill it with a release keystore you control before creating a Play Store build. Keep the keystore and passwords backed up securely; do not commit them. Without a release keystore, debug builds remain available, but a release build is not signed for store distribution.

The Supabase URL and publishable key are public client values supplied at build time. For example:

```bash
flutter build appbundle --release \
  --dart-define=ALLFIX_API_BASE_URL=https://your-api.example.com \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=your-publishable-key
```

The Supabase service-role key, Resend API key, and OTP signing secret belong only in the backend deployment environment. Apply `ALIX/supabase-email-otp.sql` to the Supabase project before enabling live email verification. The app currently has safe placeholder Supabase client values and cannot send OTPs until the backend credentials, sender domain, and migration are configured.

### Email OTP backend setup

The separate ALLFIX Node.js API reads these server environment variables:

```text
RESEND_API_KEY=<server-side Resend API key>
RESEND_FROM_EMAIL=ALLFIX Xpress <verify@your-domain.com>
OTP_SESSION_SECRET=<random secret of at least 32 characters>
SUPABASE_SERVICE_ROLE_KEY=<server-side Supabase service-role key>
ADMIN_SESSION_SECRET=<random secret of at least 32 characters>
```

Verify your sending domain in Resend, set these values in the backend deployment environment (or local `.env`), and run `ALIX/supabase-email-otp.sql` in the Supabase SQL editor. Generate the signing secret with `node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"`. The Resend API key, Supabase service-role key, and signing secret are server-only; never put them in the Flutter app or commit them. Resend currently lists a free tier of 3,000 emails per month with a 100-per-day limit; its test sender is not for delivering OTPs to arbitrary users.
