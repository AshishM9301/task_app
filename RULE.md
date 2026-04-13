# Task App - Immutable Project Rules

## Project Vision

A task management app with social features where users create tasks, schedule them in a calendar, and share progress with friends. No subtasks feature.

---

## Architecture

### Stack
- **Frontend**: Flutter (mobile app)
- **Backend**: Node.js API
- **Auth**: Firebase Auth (email/password + Google)
- **State**: Provider pattern

### Data Flow
1. User creates tasks → saved to Node.js API
2. Tasks have start/end dates → status auto-calculated:
   - `pending` → created, before start date
   - `in_progress` → after start date, before completion
   - `completed` → user marks done
   - `failed` → end date passed without completion
3. Sharing requires login → guest users get login prompt when accessing social features
4. Task sync: Guest tasks saved with guest-key, user tasks saved with Firebase token

---

## Conventions

### File Structure
```
lib/
├── core/                    # Constants, firebase, theme, core widgets
├── data/models/             # Data models
├── data/utils/              # ApiService singleton
├── presentation/screens/   # One folder per feature
├── presentation/widgets/    # Reusable UI components
├── providers/               # State management (one file per provider)
└── main.dart               # Entry point, MultiProvider setup
```

### State Management
- Each provider extends `ChangeNotifier`
- `AuthProvider` → Firebase user state, login/logout
- `GuestProvider` → guest session, guest-key management
- ApiService is a singleton, uses `x-guest-key` and `Authorization: Bearer` headers

### Environment Variables
- All config via `.env` file
- Load with `flutter_dotenv`
- Keys: `API_BASE_URL`, `FIREBASE_*`

### Task Model Fields
- `title`, `description`, `startedAt`, `endedAt`, `status`
- `taskGroupId`, `projectTitle`, `projectId` (optional)
- No subtasks in current version

### Social Features
- Friends: search, request, accept/reject, list
- Task sharing: share with friend (read), view shared, revoke
- Sharing requires authenticated user

### Login/Auth Flow
1. App starts as guest
2. Full task features without login
3. Profile/social features → show LoginScreen
4. After login → Firebase token synced to API for authenticated requests

---

## This file is immutable

Do not add implementation status, todo items, or mutable information here.
