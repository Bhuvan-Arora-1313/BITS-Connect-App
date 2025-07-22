# 📚 BITS Connect – Your Study & Events Companion at BITS Pilani

**BITS Connect** is a Flutter-based mobile app built for BITS Pilani students to help them easily find study buddies, join relevant academic groups, and never miss out on college interactions or events again.

## 🎯 Why this app?

> "I created this app because I used to find it hard to connect with like-minded people in my course who were interested in studying the same subjects. I also often missed important college interactions and events due to skipped emails. This app is my way of helping students like me — who want to collaborate, study, and stay informed — to have a better campus experience."

## 🔑 Core Features

- 🔍 **Discover Study Groups**: Search or join groups based on subject, topic, or interest (like silent study, PYQ practice, event coordination, etc.).
- 📅 **Create or Join Events**: Schedule sessions with your peers or participate in ongoing academic activities.
- 📨 **Smart Notifications**: Never miss out on interactions or important group updates again.
- 👥 **BITS-only Access**: Restricted to BITS Pilani students via domain-based Google sign-in.
- 👤 **Complete Profile System**: Users set up a detailed profile with enrolled courses, making group relevance stronger.

## 📱 Download BITS Connect App

[⬇️ Click here to download APK](https://github.com/Bhuvan-Arora-1313/BITS-Connect-App/raw/main/release-apk/BITSConnect-v1.0.apk)


## 📱 How to Use

### 🔧 Setup (for Developers)

1. Clone the repo:
   ```bash
   git clone https://github.com/Bhuvan-Arora-1313/BITS-Connect-App.git
   cd BITS-Connect-App
   ```

2. Run Flutter pub:
   ```bash
   flutter pub get
   ```

3. If you're a developer trying to build/run the app:
   - You'll need to set up a Firebase project and replace `android/app/google-services.json`.
   - Add a `key.properties` file if you're building release versions.

### 🧪 Build & Run (for Testing)

```bash
flutter run
```

To build a release:
```bash
flutter build apk --release
```

### 🤝 Firebase Setup (Required for Auth, Firestore & Notifications)

This app uses:
- Firebase Authentication (Google Sign-In)
- Cloud Firestore (for user profiles, groups, and messages)
- Firebase Cloud Messaging (for push notifications)

Ensure you've linked your Firebase project and uploaded the correct `google-services.json`.

## 📁 What's in the Repo?

- All frontend source code (`lib/`)
- Android build configurations and signing setup
- Firebase logic
- Some generated APK and bundle files for demo/testing

> ⚠️ Secret keys and sensitive files are excluded for safety.

## 👨‍💻 Contributing

This app is still under development. Feel free to explore the code, learn from it, or suggest improvements via Issues or Pull Requests.