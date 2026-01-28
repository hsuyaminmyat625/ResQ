# 🚨 ResQ – Location-based Disaster Alert App

ResQ is a mobile application that helps users **receive disaster alerts and manage safe locations based on their current position**.  
The app is designed especially for **foreign residents and travelers in Japan**, providing clear, location-based alerts and evacuation support.

---

## 📱 Features

- 📍 **Location Management**
  - Get current location using Apple Maps / CoreLocation
  - Save multiple user-defined locations
  - Set alert radius per location

- 🗺 **Interactive Map**
  - View saved locations on Apple Maps
  - Primary location highlighted
  - Reverse geocoding (coordinate → address)

- 🚨 **Disaster Alerts**
  - Earthquake, weather, flood alerts
  - Severity levels (low / medium / high / critical)
  - Color & icon based alert UI

- 👤 **User Profile**
  - Login / Register
  - Notification preferences
  - Language settings (EN / JP planned)

---

## 🛠 Tech Stack

### iOS (Frontend)
- Swift / SwiftUI
- MapKit
- CoreLocation
- Combine
- MVVM Architecture

### Backend (API)
- FastAPI (Python)
- REST API
- JSON-based communication

### Others
- Git / GitHub
- Apple Simulator / Xcode

---

## 🧱 Architecture

ResQ
├── Models
│ ├── User
│ ├── Alert
│ └── Location
├── Views
│ ├── LocationView
│ ├── AlertsView
│ ├── ProfileView
│ └── AddLocationSheet
├── ViewModels
│ ├── LocationViewModel
│ └── AlertViewModel
├── Services
│ ├── APIService
│ ├── LocationManager
│ └── AuthManager


---

## 📸 Screenshots
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 Pro - 2026-01-21 at 02 05 34" src="https://github.com/user-attachments/assets/c9172a58-3fc2-4caa-a4f7-3ef880caf7ac" />
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 Pro - 2026-01-21 at 02 05 29" src="https://github.com/user-attachments/assets/69d0b3bc-6567-4908-a643-6055ce16a339" />
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 Pro - 2026-01-21 at 02 05 19" src="https://github.com/user-attachments/assets/3c701b56-9ae7-4dba-b224-bf1b2e540edd" />

- My Locations (Map)
- Add Location Sheet
- Alert List
- User Profile

---

## 🚀 Getting Started

### Requirements
- macOS
- Xcode 15+
- iOS Simulator or real device
- Backend API running locally or remotely

### Setup
```bash
git clone https://github.com/hsuyaminmyat625/ResQ.git
cd ResQ
open ResQ.xcodeproj
