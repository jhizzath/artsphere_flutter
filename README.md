# 🎨 ArtSphere - Final Year Project

ArtSphere is a cross-platform Flutter application that connects artists and customers, allowing artists to showcase and sell their artworks, while customers can explore, purchase, and follow their favorite artists.  
The backend is powered by **Django** with **MySQL** as the database.

---

## 📌 Features

### **Artist Module**
- Artist registration & login
- Manage profile (update info, change profile picture, categories, and subcategories)
- Upload artworks (multiple images )
- Upload & manage videos (like Instagram Reels)
- View sales reports & analytics


### **Customer Module**
- Customer registration & login
- Browse artworks by category & subcategory
- Purchase artworks (checkout with address handling)
- Add to cart & checkout
- Receive order confirmation
- Add & view Feedback
- Make payments


---

## 🛠️ Tech Stack

**Frontend:** Flutter (Dart)  
**Backend:** Django (Python)  
**Database:** MySQL  
**State Management:** GetX (Flutter)  
**Version Control:** Git & GitHub  

---

## 📂 Project Structure


artsphere_flutter/
│
├── lib/ # Flutter app source code
│ ├── controllers/ # GetX controllers
│ ├── models/ # Data models
│ ├── screens/ # UI screens
| ├── utils/ # managing utils
│ └── services/ # services for artwork
│  
├── assets/ # Images, videos, and other assets
│
├── pubspec.yaml # Flutter dependencies
└── README.md # Project documentation


---

## 🚀 Getting Started

### **Prerequisites**
- Flutter SDK installed → [Install Guide](https://docs.flutter.dev/get-started/install)
- Python & Django installed (for backend)
- MySQL database running

### **Steps to Run the Flutter App**
```bash
# Clone the repository
git clone https://github.com/jhizzath/artsphere_flutter.git

# Go into the project directory
cd artsphere_flutter

# Install dependencies
flutter pub get

# Run the app
flutter run
```
📷 Screenshots


| Artist Home | Customer Home |
|-------------|---------------|
| ![Artist Home](https://github.com/user-attachments/assets/f75baa1c-af6e-4be2-bad2-4ad76e283c10) | ![Customer Home](https://github.com/user-attachments/assets/cfef206b-f300-44f2-9525-87f74bca3ca1) |



📜 License

This project is for academic and internship purposes only.
All rights reserved © 2025 Jahanara Hizzath.


---


