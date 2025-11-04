# VolunteerConnect 🤝

VolunteerConnect is a mobile application built with Flutter and Firebase, designed to bridge the gap between non-profit organizations and volunteers. The platform provides two distinct user roles (Volunteer and Organization), each with a tailored experience.

---

## ✨ Features

### 🧑‍🤝‍🧑 For Volunteers
* **🔍 Browse Opportunities:** Discover local and remote volunteering events.
* **✅ Easy Sign-up:** Register for events with a single tap.
* **📅 My Events:** Track all upcoming events you've registered for and cancel if needed.
* **👤 Profile Management:** Update your personal information and profile picture.

### 🏛️ For Organizations
* **➕ Post Events:** Easily create, edit, and manage new volunteer opportunities.
* **📊 Dashboard:** View key statistics, like total events created and total volunteer sign-ups.
* **📋 View Volunteers:** See a list of all volunteers registered for each of your events.
* **👤 Profile Management:** Manage your organization's public profile.

---

## 🛠️ Tech Stack

* **Framework:** Flutter
* **Backend:** Firebase
    * **Authentication:** Firebase Auth (Email/Password, Role-based)
    * **Database:** Cloud Firestore
    * **Storage:** Firebase Storage (for profile pictures and event images)
* **Key Packages:**
    * `cloud_firestore`
    * `firebase_auth`
    * `firebase_storage`
    * `image_picker`

---

## 🚀 Getting Started

**1. Clone the repository:**
```bash
git clone [https://github.com/YourUsername/YourRepoName.git](https://github.com/YourUsername/YourRepoName.git)
cd YourRepoName
````

**2. Install dependencies:**

```bash
flutter pub get
```

**3. Set up Firebase:**

  * Create a new project on the [Firebase Console](https://console.firebase.google.com/).
  * Add an Android, iOS, and/or Web app to your Firebase project.
  * Follow the setup instructions to add the `firebase_options.dart` file to your `lib/` folder (using `flutterfire configure` is the easiest way).
  * In **Firestore**, create a `users` collection to store user data (e.g., `fullName`, `email`, `role`).
  * In **Firebase Storage**, enable the service to allow image uploads.

**4. Run the app:**

```bash
flutter run
```

