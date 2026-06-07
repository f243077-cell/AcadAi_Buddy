# 🎓 AcadAI Buddy

AcadAI Buddy is an AI-powered Flutter study app built for Pakistani university students. It offers real-time AI chat for subject help, automatic MCQ quiz generation, and smart note summarization from text or images. The app is built using Clean Architecture with Riverpod state management, Firebase for authentication and cloud storage, and OpenRouter API for AI model integration. It supports 40+ university subjects including all FAST NUCES core courses with a custom subject search feature and a dark academic themed UI.

---

## 📱 Features

- 🤖 **AI Chat** — Ask anything about your university subjects with real-time AI responses
- 📝 **Quiz Generator** — Auto-generate MCQ quizzes on any subject with instant scoring
- 📄 **Note Summarizer** — Paste text or upload image of notes for instant bullet-point summaries
- 🔐 **Authentication** — Secure login & signup with Firebase Auth
- 💾 **Cloud Storage** — Chat history saved with Firebase Firestore
- 🎨 **Dark Academic UI** — Beautiful deep navy & gold themed interface
- 🔍 **Subject Search** — Search from 40+ subjects or add your own custom subject

---

## 🏗️ Architecture

This project follows **Clean Architecture** with 4 layers:

```
lib/
├── presentation/     → UI Widgets, Pages, Screens
├── application/      → Riverpod Notifiers & States
├── domain/           → Entities & Abstract Repositories
└── infrastructure/   → Firebase & OpenRouter implementations
```

---

## 🛠️ Tech Stack

| Technology | Usage |
|------------|-------|
| **Flutter** | Cross-platform UI framework |
| **Riverpod 2.x** | State management |
| **Firebase Auth** | User authentication |
| **Cloud Firestore** | Real-time database |
| **OpenRouter API** | AI model integration |
| **Clean Architecture** | Project structure |
| **GoRouter** | Navigation |
| **Dartz** | Functional programming (Either) |

---

## 📚 Supported Subjects

- FAST NUCES Core (OOP, DSA, SDA, OS, DBMS...)
- Mathematics (Calculus, Linear Algebra, Discrete Math...)
- Programming (Python, Java, C++, Dart...)
- CS Theory (Automata, Algorithms, AI, ML...)
- Engineering (Physics, Digital Logic, Electronics...)
- Custom subject support ✅

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.x or higher)
- Dart SDK
- Firebase account
- OpenRouter API key

### Installation

**1. Clone the repo**
```bash
git clone https://github.com/f243077-cell/AcadAi_Buddy.git
cd AcadAi_Buddy
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Setup Firebase**
- Create project at [console.firebase.google.com](https://console.firebase.google.com)
- Add Android app
- Download `google-services.json`
- Place in `android/app/`

**4. Setup API Key**

Create `.env` file in project root:
```
OPENROUTER_API_KEY=your_openrouter_key_here
```

Add to `pubspec.yaml` assets:
```yaml
flutter:
  assets:
    - .env
```

**5. Run the app**
```bash
flutter run
```

---

## 📁 Project Structure

```
lib/
├── main.dart
├── presentation/
│   ├── core/
│   │   ├── app_widget.dart
│   │   └── theme.dart
│   └── pages/
│       ├── splash/
│       ├── sign_in/
│       ├── sign_up/
│       └── study/
│           ├── home/
│           ├── chat/
│           ├── quiz/
│           └── summarize/
├── application/
│   ├── auth/
│   ├── chat/
│   ├── quiz/
│   └── summarize/
├── domain/
│   ├── core/
│   ├── auth/
│   └── study/
├── infrastructure/
│   ├── core/
│   ├── auth/
│   └── study/
└── routes/
```

---

## 🔐 Environment Variables

| Variable | Description |
|----------|-------------|
| `OPENROUTER_API_KEY` | OpenRouter API key for AI models |

> ⚠️ Never commit `.env` file to GitHub!

---

## 🤝 Contributing

1. Fork the repo
2. Create your branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 👨‍💻 Developer

**Tanzeel** — FAST NUCES CFD Campus
- Batch: 2024-2028
- Student ID: 24F-3077

---

## 📄 License

Distributed under the MIT License.

---

## 🌟 Show Your Support

Give a ⭐ if this project helped you!

---

<p align="center">
  Made with ❤️ for Pakistani University Students
</p>