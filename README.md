# Project Title

A brief description of what this project does and who it's for

# Synapse

A modern, feature-rich quiz application built with Flutter and Firebase, offering a comprehensive quiz experience with friend leaderboards, personalized hints, and progress tracking.

![alt text](https://github.com/devanshkp/synapse-quiz-app/blob/[branch]/image.jpg?raw=true)

<div align="center">
  <img src="assets/images/logo.png" alt="QuizCraft Logo" width="150">
</div>

## ✨ Features

### 🔐 User Authentication & Profile Management

- Secure email/password authentication
- Customizable user profiles with avatars
- User statistics tracking

### 🧩 Quiz Experience

- Diverse question categories from Computer Science
- Real-time question delivery and progress tracking
- Multiple question formats (multiple choice, true/false)
- Dynamic hint system powered by Gemini AI
- Score tracking and performance analytics (user streaks, accuracy, etc.)

### 👥 Social Features

- Friend system with user discovery
- Real-time leaderboards
- Compete with friends

### 🎨 UI/UX

- Modern, intuitive interface with smooth animations
- Dark mode design with gradient accents
- Responsive layout for various device sizes

## 🛠️ Technologies Used

- **Frontend**: Flutter
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **State Management**: Provider
- **Architecture**: Service-based architecture
- **AI Integration**: Google's Gemini API for intelligent hints
- **Data Sourcing**: Scraped questions from https://sanfoundry.com/

## 📱 Screenshots

<div align="center">
  <img src="screenshots/login.png" alt="Login Screen" width="200">
  <img src="screenshots/quiz.png" alt="Quiz Screen" width="200">
  <img src="screenshots/profile.png" alt="Profile Screen" width="200">
  <img src="screenshots/leaderboard.png" alt="Leaderboard Screen" width="200">
</div>

## 📋 Prerequisites

- Flutter SDK (2.10.0 or higher)
- Dart SDK (2.16.0 or higher)
- Firebase account
- Gemini API key (for hint generation)

## 🚀 Getting Started

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/quiz-app.git
   cd quiz-app
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Firebase**

   - Create a new Firebase project
   - Add an Android/iOS app in the Firebase console
   - Download and add the `google-services.json`/`GoogleService-Info.plist` to the appropriate directory
   - Enable Authentication, Firestore, and Storage in the Firebase console

4. **Set up Gemini API**

   - Obtain an API key from Google's Gemini platform
   - Add your API key to the appropriate configuration file

5. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Project Structure

```
lib/
├── constants.dart             # App-wide constants
├── main.dart                  # Entry point
├── models/                    # Data models
├── pages/                     # App screens
│   ├── auth/                  # Authentication screens
│   ├── main/                  # Main app screens (on navbar)
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

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📬 Contact

Your Name - [LinkedIn](https://linkedin.com/in/devansh-kapoor) - devansh.kp@outlook.com

---

Built with ❤️ by Devansh Kapoor
