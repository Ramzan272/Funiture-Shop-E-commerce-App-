🪑 E-Commerce App (Flutter + Firebase)
A full-featured furniture e-commerce app developed using Flutter. This application includes user and admin functionalities, supporting login/signup, product listing, cart/wishlist management, order tracking, and real-time chat – all integrated with Firebase services.

📱 Features
👥 User
Sign up / Login (Firebase Auth)
Browse products by category
Add items to Cart and Wishlist
Place orders
Chat with Admin
View order history
Tracks own orders
🛠️ Admin
Add/Edit/Delete Products
View and manage orders
Respond to customer chats
Tells users about their orders
🧱 Architecture
Follows the MVVM (Model-View-ViewModel) architecture for clean separation of concerns:

Model: Defines data structures (cart_item.dart, product.dart, etc.)
Repository: Handles Firebase/database interactions
ViewModel: Business logic and state management
UI: Widgets and screen implementations
