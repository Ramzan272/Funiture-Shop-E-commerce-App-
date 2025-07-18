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

bash
flutterfire configure


#### 4️⃣ Run the App

bash
flutter run

## 📸 Screenshots

🏠 User Home

<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/cc0e0568-1a19-4d2f-9594-f0ac5e189b2f" />  
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/78f2d081-0d8a-42f5-8e8d-fcc170b38ec0" />
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/13e9d9ad-39e4-4a81-8dae-f8b2c9e4254c" />
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/053e6fd6-8e64-4a99-a61d-308f38807701" />
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/cbcdd6f9-8485-479f-82bf-365fe02bbb6f" 

| 🧑‍💼 Admin Panel

<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/a4ea6a2a-a5e1-4c23-a31f-b9e462fe8757" />
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/861b3eb5-327e-43fe-9eae-07185418d403" />
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/339a9825-e421-4ff9-ae6c-c15aea85e03f" />

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


