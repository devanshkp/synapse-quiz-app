# Synapse

A modern, feature-rich quiz application built with Flutter and Firebase, offering a comprehensive quiz experience with friend leaderboards, custom generated hints, progress tracking, and more.

<img src="flutter_application/assets/icons/logos/app_banner.png" alt="Synapse Logo" width="500">

## ✨ Features

### User Authentication & Profile Management

- Secure email/password authentication
- Customizable user profiles with avatars
- User statistics tracking

### Quiz Experience

- Diverse question categories from Computer Science
- Real-time question delivery and progress tracking
- Multiple question formats (multiple choice, true/false)
- Dynamic hint system powered by Gemini AI
- Score tracking and performance analytics (user streaks, accuracy, etc.)
- **Question Tracking**:
  - Users' encountered questions are tracked to ensure no repeated questions are shown (can be reset)
  - Ability to review previously encountered questions for revision

### Social Features

- Friend system with user discovery
- Real-time leaderboards

### UI/UX

- Modern, intuitive interface with smooth animations
- Dark mode design with gradient accents
- Responsive layout for various device sizes

## 🛠️ Technologies Used

- **Frontend**: Flutter
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **State Management**: Provider
- **Architecture**: Service-based architecture
- **Data Scraping**: Python, Selenium, bs4
- **Data Sourcing**: Questions from [https://sanfoundry.com/](https://sanfoundry.com/)
- **AI Integration**: Google's Gemini API for intelligent hints

## 📱 Screenshots

<div align="center">
  <img src="flutter_application/assets/screenshots/Home.png" alt="Home Screen" width="250">
  <img src="flutter_application/assets/screenshots/Search.png" alt="Topicst Screen" width="250">
  <img src="flutter_application/assets/screenshots/Trivia.png" alt="Trivia Screen" width="250">
  <img src="flutter_application/assets/screenshots/Profile.png" alt="Profile Screen" width="250">
  <img src="flutter_application/assets/screenshots/Leaderboard.png" alt="Leaderboard Screen" width="250">
  <img src="flutter_application/assets/screenshots/Recents.png" alt="Recent Questions Screen" width="250">
</div>

## 🎬 Demo Video

* Mobile View: [https://youtube.com/shorts/kAqLwVWDZAs?feature=share](https://youtube.com/shorts/kAqLwVWDZAs?feature=share)
* Tablet View: [https://youtu.be/JBgfspfbi3A](https://youtu.be/JBgfspfbi3A)

## 📲 Download

**Android:**

* **Google Play Store (Closed Testing), Join Group:** [https://groups.google.com/u/1/g/synapse-testers](https://groups.google.com/u/1/g/synapse-testers)
* **Direct APK:** [APKs/](APKs/) (arm64 For most modern Android devices)

**iOS:**

Coming soon!

## 🏗️ Project Structure

```
lib/
├── constants.dart             # App-wide constants
├── main.dart                  # Entry point
├── models/                    # Data models
├── pages/                     # App screens
│   ├── auth/                  # Authentication screens
│   ├── main/                  # Main app screens (on navbar)
│   ├── secondary/             # Other app screens
│   ├── landing.dart           # Landing Page
│   ├── splash_screen.dart     # Splash Screen
├── providers/                 # State management
├── services/                  # API and backend services
├── utils/                     # Utility functions/classes
└── widgets/                   # Reusable UI components
    ├── auth/                  # Auth screens widgets
    ├── home/                  # Home screen widgets
    ├── profile/               # Profile screen widgets
    ├── trivia/                  # Trivia screen widgets
    └── shared_widgets.dart    # Common widgets used across the app
```

## 📊 Architecture

The application follows a service-based architecture with Provider for state management:

- **Services**: Handle API calls and data processing
- **Providers**: Manage application state and business logic
- **Pages**: Define the application's screens and navigation
- **Widgets**: Encapsulate UI components for reusability

## 🤝 Contributing

Contributions are welcome, feel free to reach out to start collaborating!

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Contact

Devansh Kapoor - [LinkedIn](https://linkedin.com/in/devansh-kapoor) - devansh.kp@outlook.com
