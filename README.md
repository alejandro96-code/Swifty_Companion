# Swifty Companion

Swifty Companion is a cross-platform app built with Flutter to query
user profiles from 42 using the official Intra API.

The application allows you to search for a login, open the user's profile, and display
useful information clearly and adapted to different screen sizes.

## What it does

- Search users by login
- Display the profile card of the selected user
- Show basic information such as login, email, location, wallet, evaluations,
  campus, join date, and level
- Display user skills with their level and percentage
- Show completed projects, separated between C Piscine and Cursus
- Handle network errors, non-existent login, missing credentials, and API failures
- Use responsive design for web and Android

## Technologies used

- Flutter
- Dart
- Docker
- Official 42 API

## How to start

- Clone your proyecto
- Create a app in for connect 42 API
- Follow terminal steps


## What is Flutter?

**Flutter** is a Google framework for developing mobile, web, and desktop applications from a single codebase (Dart). The main idea is: **"Write once, run anywhere"**.

### Main features of Flutter:
- **Single codebase** for Android, iOS, and web
- **Hot Reload**: Real-time changes without recompiling
- **Native performance**: Compiles directly to native code
- **Material Design**: Modern and consistent interface
- **Active community**: Thousands of available packages

---

## Key Flutter Concepts

### 1. **Widgets (Building blocks)**
A widget is any visual element in Flutter. Everything is a widget:
- Buttons, text, images, layouts, screens

**Widget types:**
```
Widgets
├── StatelessWidget (stateless, immutable)
└── StatefulWidget (stateful, mutable)
```

**Example StatelessWidget:**
```dart
class MyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      child: Text('Click me'),
    );
  }
}
```

**Example StatefulWidget:**
```dart
class Counter extends StatefulWidget {
  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$count'),
        ElevatedButton(
          onPressed: () => setState(() => count++),
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

### 2. **State**
The information that can change in a widget. When you change the state, you call `setState()` and Flutter automatically redraws.

### 3. **BuildContext**
Represents the location of a widget in the widget tree. Used for navigation, theme access, etc.

### 4. **Navigation**
To move from one screen to another:
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => TargetScreen()),
);
```

---

## Swifty Companion Project Structure

```
app/
├── lib/                          # Main source code
│   ├── main.dart                 # App entry point
│   └── core/
│       ├── pages/                # Full screens
│       │   ├── login_screen.dart
│       │   └── info_screen.dart
│       ├── components/           # Reusable components
│       │   ├── user_data.dart
│       │   ├── user_projects.dart
│       │   └── user_skills.dart
│       ├── services/             # API communication logic
│       │   └── forty_two_api.dart
│       └── utils/                # Helper functions
│           └── forty_two_user_utils.dart
├── pubspec.yaml                  # Project dependencies
└── android/                       # Android-specific configuration
```



## Authentication

The app uses OAuth2 with `client_credentials` to obtain an access token from
42 Intra.

Credentials are loaded from a local `.env` file:

- `CLIENT_ID`
- `CLIENT_SECRET`

The token is reused while valid and renewed when it expires.

## Overall structure

- `app/lib/main.dart`: app startup
- `app/lib/core/pages/login_screen.dart`: user search screen
- `app/lib/core/pages/info_screen.dart`: profile screen
- `app/lib/core/components/user_data.dart`: user basic data
- `app/lib/core/components/user_skills.dart`: skills list
- `app/lib/core/components/user_projects.dart`: projects list
- `app/lib/core/services/forty_two_api.dart`: 42 API client
- `app/lib/core/utils/forty_two_user_utils.dart`: profile helper functions

## Requirements

- Docker, if you want to run the recommended version for evaluation
- or Flutter installed locally, if you want to run the app outside of Docker
- valid 42 Intra credentials

## Recommended execution with Docker

This is the most convenient way for evaluation and local testing:

```bash
git clone https://github.com/alejandro96-code/Swifty_Companion.git
cd Swifty_Companion
make docker-up
```

The command will ask for `CLIENT_ID` and `CLIENT_SECRET`, create the necessary
`.env` files, and start Flutter Web on `http://localhost:8080`.

To stop it:

```bash
make docker-down
```

## Local execution with Flutter

If you prefer to run the app without Docker, you'll need to install Flutter in a session and run:

```bash
cd Swifty_Companion/app
cp .env.example .env
flutter pub get
flutter run
```

In Android Studio, open the `app/` folder and run the application from there.

## Environment variables

Example `.env` file:

```env
CLIENT_ID=your_42_client_id
CLIENT_SECRET=your_42_client_secret
```

## Resources

### Official Documentation
- [Flutter API Reference](https://api.flutter.dev/flutter/painting/BorderRadius/bottomLeft.html) - Flutter components reference
- [Dart Effective Documentation](https://dart.dev/effective-dart/documentation) - Dart best practices
- [Creating a New Flutter App](https://docs.flutter.dev/reference/create-new-app) - Official project creation guide
- [Flutter Navigation & Routing](https://docs.flutter.dev/ui/navigation) - Navigation between screens

### Tutorials and Articles
- [Descubriendo el Widget Scaffold](https://www.ricardogottheil.com/descubriendo-el-widget-scaffold-de-flutter/) - Screen basic structure
- [Clase Scaffold en Flutter](https://medium.com/comunidad-flutter/clase-scaffold-en-flutter-28b2789eae10) - Advanced layout structure

### Acknowledgments
- AI usage for structuring the project and components