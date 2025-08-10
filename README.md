# 🚍 Bus Fare App

A Flutter-based mobile application for real-time bus fare collection and monitoring, integrated with Firebase and IoT hardware (ESP32 + RFID) and GPS location services for boarding/exit mapping.

---

## 📱 What it does (brief)
- A passenger taps a card/read from the hardware (ESP32 + RFID).
- The system logs boarding location using the device/GPS coordinates.
- On exit (next tap), the system logs exit location and calculates fare based on route/logic.
- Fare is deducted from the passenger's balance in real time via Firebase.
- Passenger can view balance and transaction history in the app; admins can monitor transactions from the dashboard.

---

## 📱 Features
- GPS-based boarding & exit mapping (location-aware fare events)
- Real-time fare updates using Firebase Realtime Database
- Card-based passenger authentication (via ESP32 + RFID)
- Automatic fare deduction and balance update
- Admin dashboard to monitor transactions and history
- Mobile-friendly UI built with Flutter
- Firebase integration (secure placeholder configs included)

---

## 🛠 Tech Stack
- **Frontend:** Flutter (Dart)  
- **Backend:** Firebase Realtime Database / Firestore  
- **Hardware:** ESP32 + RFID  
- **Location:** GPS / device location services

---

## 📂 Highlights
- Developed end-to-end from UI design to backend integration
- GPS-enabled boarding/exit detection and mapping for accurate fare events
- Integrated secure Firebase authentication and data handling
- Hardware and software seamlessly connected for real-time operations
- Credentials removed from the codebase for security

---

## 🔒 Security
Sensitive Firebase credentials have been removed and replaced with example configuration files:
- `lib/firebase_options.example.dart`
- `android/app/google-services.example.json`

---

## 👤 Author
**Shiva Duwal [SHIDO]**  
Electronics & Communication Engineer | Aspiring Software Engineer  
[GitHub](https://github.com/duwalshiva) | [LinkedIn](https://linkedin.com/in/shiva-duwal-0255b7379)
