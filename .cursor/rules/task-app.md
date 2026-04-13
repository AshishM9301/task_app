# Task App - Cursor Agent Rules

## Project Vision

A task management Flutter app with Node.js backend. Users create tasks with start/end dates, view calendar, share with friends. No subtasks.

---

## Tech Stack

- Flutter mobile app
- Node.js API (backend)
- Firebase Auth (email/password + Google)
- Provider for state management

---

## Architecture Rules

### File Organization
```
lib/
├── core/                    # Constants, firebase, theme
├── data/models/             # Data models
├── data/utils/              # ApiService singleton
├── presentation/screens/   # Screen per feature folder
├── presentation/widgets/    # Reusable UI components
├── providers/                # State management providers
└── main.dart               # Entry + MultiProvider
```

### State Management
- Providers extend `ChangeNotifier`
- `AuthProvider` → Firebase auth state
- `GuestProvider` → guest session & API key
- `ApiService` singleton → HTTP calls with headers

### API Communication
- Base URL from `.env` (`API_BASE_URL`)
- Guest mode: `x-guest-key` header
- Auth mode: `Authorization: Bearer <firebase_token>` header

### Environment Variables
- Use `.env` file with `flutter_dotenv`
- Required: `API_BASE_URL`, `FIREBASE_APP_ID`, `FIREBASE_API_KEY`, `FIREBASE_PROJECT_ID`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_AUTH_DOMAIN`

---

## Task Feature Rules

### Task Lifecycle
- Create with: `title`, `description`, `startedAt`, `endedAt`, `taskGroupId`, `projectTitle`
- Status auto-calculated:
  - `pending` → before start date
  - `in_progress` → after start date, before completion
  - `completed` → user marks done
  - `failed` → end date passed

### No Subtasks
- Current version has NO subtask feature
- Do not add subtask logic

---

## Auth Flow Rules

1. App launches as guest (no login required for tasks)
2. Tasks work fully without authentication
3. Social features (friends, sharing) require login
4. When accessing profile → show LoginScreen if not authenticated
5. After login → Firebase token sent to backend API

---

## Social Features Rules

### Friends System
- Search users by query
- Send/receive friend requests
- Accept/reject requests
- List friends

### Task Sharing
- Share task with friend (read permission)
- View tasks shared by friends
- Revoke sharing access

### Sharing Access Control
- Only authenticated users can share
- Show login prompt when guest tries to share

---

## This file is immutable

Do not modify this file with status updates, todo lists, or implementation notes.
