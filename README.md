# VolunteerConnect 🤝

A dynamic Flutter application designed to connect local volunteers with community events and charity initiatives. This app is powered by a live **Firebase** backend, allowing users to register, browse live events, and sign up for opportunities in real-time.

---

## ✨ Features

This is a feature-complete V1 application with a full "user journey":

* **Firebase Backend:** Connects to a live **Firestore Database** to fetch and store all app data.
* **User Authentication:** Full registration, login, and sign-out flow using **Firebase Authentication**.
* **Live Event Browsing:** Fetches a real-time list of volunteer opportunities from Firestore, complete with images loaded from **Firebase Storage**.
* **Event Filtering:** Users can filter the event list by category (e.g., "Environment", "Education").
* **Event Sign-Up:** A logged-in user can register for an event, which creates a `registrations` record in the database.
* **Personalized "My Events" Screen:** A dedicated screen that shows the user a list of only the events they have personally registered for.
* **Dynamic Profile Screen:** A profile page that displays the user's name (fetched from their Firestore `users` document) and a sign-out button.
* **Smart "How to Join" Screen:** A step-by-step guide that dynamically updates to show the "Sign Up" step as completed if the user is logged in.

---

## 🚀 Getting Started

This project is no longer static. To run it, you **must** connect it to your own Firebase project.

### 1. Firebase Project Setup

Before running the app, you need to set up the Firebase backend:

1.  **Create a Firebase Project:** Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project.
2.  **Enable Authentication:** Go to **Build > Authentication** > **Sign-in method** and enable the **Email/Password** provider.
3.  **Enable Firestore:** Go to **Build > Firestore Database** and create a database. Start in **test mode** for now.
    * Create a collection named `opportunities` and add a few documents (events) with fields like `name` (string), `location` (string), `description` (string), `category` (string), `date` (timestamp), and `imageUrl` (string).
    * The `users` and `registrations` collections will be created automatically by the app.
4.  **Enable Storage:** Go to **Build > Storage** and set it up. Upload your event images here and use their "Download URLs" for the `imageUrl` field in your Firestore documents.

### 2. Local Installation

Once your Firebase project is ready:

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/your-username/VolunteerConnect.git](https://github.com/Ved05Nara/VolunteerConnect.git)
    ```
2.  **Navigate to the project directory:**
    ```bash
    cd VolunteerConnect
    ```
3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Connect to Firebase:** Use the FlutterFire CLI to connect your app to the Firebase project you just created.
    ```bash
    flutterfire configure
    ```
    This will generate the `lib/firebase_options.dart` file.

5.  **Run the app:**
    ```bash
    flutter run
    ```

---

## 🛠️ Built With

* **Flutter:** The UI toolkit for building natively compiled applications.
* **Dart:** The programming language used by Flutter.
* **Firebase:** The complete backend-as-a-service (BaaS) platform.
    * **Firebase Authentication:** For user management.
    * **Cloud Firestore:** As the real-time NoSQL database.
    * **Firebase Storage:** For hosting event images.

---

## 🔮 Future Improvements

Now that the core V1 is complete, future enhancements could include:

* **Un-register from Events:** Allow users to remove themselves from an event they've signed up for.
* **Push Notifications:** Send users reminders for events they are registered for.
* **User Profile Editing:** Allow users to update their name or upload a profile picture.
* **Map View:** Show events on a map.
* **Admin Panel:** Create a separate web app for organizations to post and manage their own events.
