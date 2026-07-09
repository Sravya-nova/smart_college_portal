# Smart College Portal (BEC Bapatla)

A modern, high-fidelity Flutter application built for **Bapatla Engineering College (BEC)** students and faculty administrators. This application offers a unified portal featuring dynamic glassmorphic UI controls, dynamic department routines, a RAG-enabled campus AI chatbot, QR-based attendance verification, and comprehensive academic performance bento cards.

---

## 🌟 Core Features

### 1. Dynamic Glassmorphic Navigation Deck
- A custom, floating pill-shaped navigation deck with smooth glass blur (`ImageFilter.blur` of 16px).
- **Hover-Reveal Behavior**: Slides down and hides (`bottom: -100`) when the mouse is away, and slides up (`bottom: 16`) when the cursor approaches the bottom 70px detection area.
- Includes a bottom-center indicator pill handle for touch targets.

### 2. Retrieval-Augmented Generation (RAG) AI Chatbot
- Powered by the Google Gemini API (`google_generative_ai`) and a local knowledge base context retriever.
- Injects live student status (GPA, class schedules, subject attendance) and retrieved policies (R20/R24 regulations, hostel details, library books) directly into the model context.
- **Robust Offline Fallback**: Gracefully parses and processes queries offline when the Gemini API key is not configured.

### 3. Detailed Bento Popovers
- **View Grades**: Expansion tile list showing Semester 1 to Semester 5 GPA and letter grades.
- **Hostel Info**: Curfew times (9:30 PM), double-sharing room details, warden contact numbers, and mess timings.
- **Semester Courses**: Pulls subject titles, course codes, and live attendance metrics directly from the provider.
- **Library Card**: Shows card number, active borrow status, and due dates of current issues.

### 4. Notice Board Release System
- Exclusive posting privileges restricted to the Admin / Faculty role.
- Dynamic announcement feeds categorized by Academic, Events, Placement, and Administrative.

### 5. Camera QR Passcode Verification
- Integrates `mobile_scanner` to scan and match registration codes.
- Ensures the scanned ID matches the active session profile to prevent attendance fraud.

### 6. Interactive Dark Mode
- Universal theme controller supporting a sleek dark slate theme (`#0F172A`) and vivid light mode status color tags (Emerald green, Coral red, and Amber).

---

## 🛠️ Technology Stack
- **Framework**: Flutter (Dart SDK `^3.12.0`)
- **State Management**: Riverpod (`flutter_riverpod: ^2.5.1`)
- **AI Integrations**: Gemini (`google_generative_ai: ^0.4.0`)
- **Devices / Platforms**: Web, macOS, iOS, Android, Linux, Windows

---

## 🚀 Running the Project

### Prerequisites
Ensure you have the Flutter SDK installed on your system.

### Build & Run
1. Clone the repository and navigate to the directory:
   ```bash
   cd smart_college_portal
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the project:
   - **For Offline / Fallback Mode**:
     ```bash
     flutter run -d chrome
     ```
   - **For Gemini-backed RAG Mode**:
     ```bash
     flutter run -d chrome --dart-define=GEMINI_API_KEY=YOUR_GEMINI_API_KEY
     ```
