# 🌱 Beanstalk Mobile

**Financial literacy for teens — Flutter app (iOS & Android)**

Beanstalk helps teenagers aged 13–18 build real money skills through
bite-sized lessons, quizzes, challenges, and a rewards system that makes
learning about finance actually fun.

## Features
- **Lessons** — structured financial literacy courses (budgeting, saving, investing, credit, taxes)
- **Quizzes** — test knowledge after each lesson with instant feedback
- **Challenges** — weekly money challenges to build habits
- **Rewards** — earn XP and badges for completing lessons and streaks
- **Progress tracking** — visual dashboard showing skill growth over time
- **Mentor chat** — real-time chat with financial educators
- **Course library** — browse and enroll in topic-based course tracks

## Tech stack
- Flutter 3.x / Dart 3
- BLoC pattern (RxDart)
- Socket.io for real-time chat
- OneSignal push notifications
- REST API (see `beanstalk-api`)

## Getting started

```bash
# Install dependencies
flutter pub get

# Copy and configure environment
cp .env.example .env
# Fill in BEANSTALK_ONESIGNAL_APP_ID and API_BASE_URL

# Run
flutter run
```

## Environment variables
See `.env.example` for all required variables. Never commit `.env`.

## Project structure
```
lib/
  main.dart                 # App entry point
  src/
    blocs/                  # BLoC state management
    models/                 # Data models
      topic_model.dart      # Financial topic/subject
      course_model.dart     # Course definition
      lesson_session_model.dart
      quiz_result_model.dart
      reward_model.dart
      badge_model.dart
      score_model.dart
      challenge_model.dart
      skill_model.dart
    pages/
      onboarding/           # Sign up, sign in, profile setup
      dashboard/            # Home screen
      lessons/              # Lesson player
      quizzes/              # Quiz screens
      courses/              # Course browse & detail
      mentors/              # Mentor profiles
      rewards/              # Rewards & badges
      history/              # Progress & history
      chatting/             # Real-time chat
    services/               # API service layer
    ui/
      app_skin.dart         # Brand colors & theme
    widgets/                # Reusable UI components
```
