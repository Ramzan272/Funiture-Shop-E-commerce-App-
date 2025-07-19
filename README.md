## ✨ Overview (Furniture Shop App)
A full-featured furniture e-commerce app developed using Flutter. This application includes user and admin functionalities, supporting login/signup, product listing, cart/wishlist management, order tracking, and real-time chat – all integrated with Firebase services.

## 📱 Key Features

### 👤 User Side:
- 🔐 Sign Up / Login (Firebase Authentication)
- 🪑 Browse furniture items by category
- 🛒 Add to Cart & Wishlist
- 🧾 Place orders and track status
- 📜 View order history
- 💬 Live chat with admin

### 🛠 Admin Side:
- ➕ Add new products
- ✏️ Edit / 🗑 Delete existing items
- 📦 View & manage orders
- 💬 Real-time customer support chat
- 🚚 Update delivery status

## 🧠 Architecture

The app follows **MVVM (Model-View-ViewModel)** architecture for scalability, testability, and clean separation of concerns.

lib/
├── main.dart
├── firebase\_options.dart
├── models/               # Data Models
│   ├── product.dart
│   ├── cart\_item.dart
│   └── order.dart
├── data/                 # Firebase Repositories
│   ├── auth\_repository.dart
│   ├── product\_repository.dart
│   └── order\_repository.dart
├── viewmodels/           # Business Logic
│   ├── auth\_viewmodel.dart
│   ├── product\_viewmodel.dart
│   └── order\_viewmodel.dart
├── ui/                   # UI Layer
│   ├── common/
│   ├── user/
│   │   ├── home/
│   │   ├── cart/
│   │   ├── wishlist/
│   │   └── profile/
│   └── admin/
│       ├── dashboard/
│       ├── product\_manager/
│       └── order\_manager/


## 🧰 Tech Stack

| Layer             | Technology                           |
|------------------|---------------------------------------|
| 🖼 UI Framework    | [Flutter](https://flutter.dev)        |
| ☁️ Backend         | [Firebase](https://firebase.google.com) |
| 🗃️ Database        | Firestore (NoSQL Realtime DB)         |
| 🖼 State Mgmt      | Provider / ChangeNotifier             |
| 🔐 Auth            | Firebase Authentication               |
| 📦 Storage         | Firebase Cloud Storage (for images)   |
| 📐 Architecture    | MVVM                                  |
| 💬 Messaging       | Firestore Live Chat                   |

## 🚀 Getting Started

### 🔧 Prerequisites

- Flutter SDK (3.x or later)
- Firebase CLI (`npm install -g firebase-tools`)
- Android Studio or VS Code

### 🛠 Setup Guide

#### 1️⃣ Clone the Repository
bash
git clone https://github.com/your-username/furniture-shop-app.git
cd furniture-shop-app

#### 2️⃣ Install Dependencies

bash
flutter pub get


#### 3️⃣ Firebase Setup

* Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
* Enable:

  * Firebase Authentication (Email/Password)
  * Firestore Database
  * Firebase Storage
* Download:

  * `google-services.json` → place in `android/app/`
  * `GoogleService-Info.plist` → place in `ios/Runner/`
* Run Firebase CLI setup:

`bash
flutterfire configure

#### 4️⃣ Run the App

bash
flutter run

## 📸 Screenshots

🏠 User Home
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/d0f82b4f-f0c3-4563-9294-26593c71fe76" />
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/23ecaee4-2c4f-4335-8205-b372c0f176d4" />
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/9dd52dab-e68f-4135-9f85-caa885cc3cb1" />
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/29bfa12c-1b36-47f9-a9c7-bfb6652a7e0f" />

  | 🧑‍💼 Admin Panel
  <img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/dc6debc4-b2fd-4206-8345-d2187f97090f" />
  <img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/2094263b-9c25-46aa-ba7c-70729e1a8bf7" />
  <img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/4e0cd368-fede-43a5-b670-f16fed812ba8" />
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/841baeff-b918-474e-84da-a27b4f7a474d" />

## 🔮 Future Enhancements

* 💳 Payment Gateway Integration (Stripe, Razorpay)
* 🔔 Push Notifications via FCM
* 🌐 Multi-language Localization (English / Urdu)
* 📊 Analytics Dashboard for Admin
* 🌈 Theme Customization Support

## 🙌 Contribution Guidelines

We welcome contributions to improve this app!
To contribute:

1. Fork the repo
2. Create a new branch `feature/your-feature`
3. Commit your changes
4. Open a Pull Request 🚀

## 👨‍💻 Developed By

**Ramzan Mustafa**
Flutter Developer | Firebase Enthusiast

* 🐙 GitHub: [https://github.com/Ramzan272)
* 💼 LinkedIn: [https://www.linkedin.com/feed/)
* ✉️ Email: [ramzanmustafa865@gmail.com)

