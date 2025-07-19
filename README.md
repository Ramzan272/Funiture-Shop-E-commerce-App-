
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


| 🏠 User Home 
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/0034260e-838f-496b-a103-073084d1c14c" />
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/619e1b57-5d64-47de-b877-942df9cd282d" />
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/85ed9909-0522-4902-9d8f-21dff557e5e5" />
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/e1a35920-7730-4e17-a52e-f7938e4a0ed9" />
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/7fe2b87f-36f1-4579-9193-2ec67b8fa0d3" />

 | 🧑‍💼 Admin Panel    
 <img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/b6c9b8d1-4009-4828-9fa2-cb16db9cd7d0" />
 <img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/f6ac30ba-22b5-4c58-a209-4cb9c9252275" />
 <img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/342260af-0dc0-4193-aff5-ecc228b77938" />

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

