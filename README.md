🪑 E-Commerce App (Flutter + Firebase)
A full-featured furniture e-commerce app developed using Flutter. This application includes user and admin functionalities, supporting login/signup, product listing, cart/wishlist management, order tracking, and real-time chat – all integrated with Firebase services.

📱 Features

👥 User:

Sign up / Login (Firebase Auth)
Browse products by category
Add items to Cart and Wishlist
Place orders
Chat with Admin
View order history
Tracks own orders

🛠️ Admin:

Add/Edit/Delete Products
View and manage orders
Respond to customer chats
Tells users about their orders

🧱 Architecture:

Follows the MVVM (Model-View-ViewModel) architecture for clean separation of concerns:

Model: Defines data structures (cart_item.dart, product.dart, etc.)
Repository: Handles Firebase/database interactions
ViewModel: Business logic and state management
UI: Widgets and screen implementations

🛠️ Tech Stack:
Flutter
Firebase (Auth, Firestore, Storage)
MVVM Architecture
Provider (or any state management library used)
Dart

📂 Project Structure
lib/
├── main.dart
├── firebase_options.dart
├── data/
│   └── AuthRepository.dart, media_repository.dart, ...
├── models/
│   └── product.dart, cart_item.dart, wishlist_item.dart, ...
├── ui/
│   ├── admin/
│   │   └── product/, orders/, chats/, ...
│   └── user/
│       └── home/, cart/, wishlist/, profile/, ...

🚀 Getting Started
1. Clone the Repository
git clone https://github.com/your-username/furniture-app.git
cd furniture-app
2. Install Dependencies
flutter pub get
3. Setup Firebase
Download google-services.json (Android) and GoogleService-Info.plist (iOS) from Firebase Console
Replace in the respective platform folders
Update Firebase settings in firebase_options.dart if needed

5. Run the App
   flutter run
   



