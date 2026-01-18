# GPay Clone - Flutter Payment App

A fully functional Google Pay clone built with Flutter and Node.js, featuring UPI payments, QR code scanning, transaction history, and biometric authentication.

## 🎯 Project Overview

This project is a complete payment application that mimics Google Pay's core functionality. It includes a Flutter mobile app frontend and a Node.js/PostgreSQL backend for handling user authentication, transactions, and payment processing.

## ✨ Features

### Frontend (Flutter)

- **User Authentication**
  - Login/Signup with email and password
  - Secure password storage with encryption
  - Session management

- **Payment Features**
  - QR code scanning for UPI payments
  - Generate personal QR code for receiving payments
  - Set custom amounts for payment requests
  - Share QR codes via WhatsApp/SMS
  - Real-time balance updates
  - Transaction confirmation screens

- **Security**
  - Biometric authentication (fingerprint/face)
  - Password fallback for payments
  - Card details protection with tap-to-reveal

- **Transaction History**
  - View sent and received payments
  - Color-coded transactions (red for sent, green for received)
  - Detailed transaction information

- **UI/UX**
  - Modern Material Design
  - Smooth animations and transitions
  - Responsive layout with scrollable content
  - People section with contact avatars
  - Virtual card display with secure reveal

### Backend (Node.js + PostgreSQL)

- **REST API Endpoints**
  - `/login` - User authentication
  - `/signup` - New user registration
  - `/pay` - Process payments between users
  - `/history` - Fetch transaction history

- **Database Management**
  - PostgreSQL with encrypted passwords (bcrypt)
  - Transaction tracking with sender/receiver details
  - User balance management
  - Automatic transaction recording

- **Features**
  - Input validation and sanitization
  - Error handling and rollback
  - Case-insensitive email matching
  - Automatic balance updates for both parties

## 🛠️ Tech Stack

### Mobile App

- **Framework**: Flutter 3.9.2
- **Language**: Dart
- **Key Packages**:
  - `mobile_scanner` - QR code scanning
  - `qr_flutter` - QR code generation
  - `local_auth` - Biometric authentication
  - `share_plus` - Share functionality
  - `http` - API communication

### Backend

- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: PostgreSQL 13+
- **Key Packages**:
  - `pg` - PostgreSQL client
  - `cors` - Cross-origin resource sharing
  - `express` - Web framework

## 📱 Installation & Setup

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Node.js (v16 or higher)
- PostgreSQL (v13 or higher)
- Android Studio / VS Code
- Physical Android device or emulator

### Backend Setup

1. **Install PostgreSQL**

   ```bash
   # Follow official PostgreSQL installation for your OS
   ```

2. **Create Database**

   ```sql
   CREATE DATABASE gpay_db;
   ```

3. **Create Tables**

   ```sql
   -- Users table
   CREATE TABLE users (
       id SERIAL PRIMARY KEY,
       name VARCHAR(255) NOT NULL,
       email VARCHAR(255) UNIQUE NOT NULL,
       password TEXT NOT NULL,
       balance DECIMAL(10, 2) DEFAULT 1000.00
   );

   -- Transactions table
   CREATE TABLE transactions (
       id SERIAL PRIMARY KEY,
       amount DECIMAL(10, 2) NOT NULL,
       receiver_name VARCHAR(255),
       upi_id VARCHAR(255),
       sender_email VARCHAR(255),
       receiver_email VARCHAR(255),
       status VARCHAR(50) DEFAULT 'Success',
       date TIMESTAMP DEFAULT NOW()
   );
   ```

4. **Install Dependencies**

   ```bash
   cd backend
   npm install express pg cors
   ```

5. **Configure Database**
   - Edit `server.js` and update PostgreSQL credentials:

   ```javascript
   const pool = new Pool({
     user: "postgres",
     host: "localhost",
     database: "gpay_db",
     password: "your_password",
     port: 5432,
   });
   ```

6. **Start Server**
   ```bash
   node server.js
   ```
   Server runs on `http://localhost:3000`

### Frontend Setup

1. **Clone Repository**

   ```bash
   cd gpay
   ```

2. **Install Dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure API URL**
   - Edit `lib/api_constants.dart`:

   ```dart
   class ApiConstants {
     static const String baseUrl = 'http://YOUR_IP:3000';
     // For emulator: use 10.0.2.2
     // For physical device: use your computer's local IP
   }
   ```

4. **Find Your IP Address**
   - Windows: `ipconfig` (look for IPv4 Address)
   - Mac/Linux: `ifconfig` or `ip addr`

5. **Run the App**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### Network Setup for Physical Devices

#### Option A: Using USB (Most Reliable)

```bash
# Connect phone via USB, then run:
adb reverse tcp:3000 tcp:3000

# Update api_constants.dart:
static const String baseUrl = 'http://localhost:3000';
```

#### Option B: Using WiFi

1. Ensure phone and laptop are on the same WiFi network
2. Get your computer's local IP address
3. Update `api_constants.dart` with your IP
4. Allow Node.js through firewall:
   - **Windows**: Settings → Firewall → Allow an app → Node.js
   - **Mac**: System Settings → Network → Firewall → Options

### Firewall Configuration

- **Port**: 3000
- **Protocol**: TCP
- **Access**: Allow incoming connections from local network

## 📖 Usage Guide

### Creating an Account

1. Open the app
2. Tap "Create an account"
3. Enter name, email, and password
4. Receive ₹1000 initial balance

### Sending Money

1. Tap "Scan QR" on home screen
2. Scan recipient's QR code
3. Enter payment amount
4. Authenticate with fingerprint/password
5. Confirm payment

### Receiving Money

1. Tap QR icon on balance card
2. Choose "Enter amount to receive" (optional)
3. Share QR via WhatsApp/SMS or show directly
4. Money added automatically when someone pays

### Viewing History

1. Tap "History" button
2. View all transactions
3. Red (-) for sent, Green (+) for received

## 🏗️ Project Structure

```
gpay-clone/
├── backend/
│   ├── server.js           # Express server & API routes
│   └── package.json        # Node.js dependencies
│
└── gpay/
    ├── lib/
    │   ├── main.dart              # App entry point
    │   ├── login_screen.dart      # Login UI
    │   ├── signup_screen.dart     # Registration UI
    │   ├── gpay_page.dart         # Main dashboard
    │   ├── qr_scanner_page.dart   # QR scanning
    │   ├── money_transfer_page.dart # Payment UI
    │   ├── history_screen.dart    # Transaction history
    │   ├── auth_service.dart      # Authentication logic
    │   └── api_constants.dart     # API configuration
    │
    ├── android/               # Android-specific config
    ├── pubspec.yaml          # Flutter dependencies
    └── README.md             # This file
```

## 🐛 Troubleshooting

### Connection Errors

**Error**: `Connection timed out (errno = 110)`

- **Cause**: Phone can't reach backend
- **Solution**:
  1. Check IP address hasn't changed
  2. Verify firewall allows port 3000
  3. Ensure devices are on same WiFi

**Error**: `Failed host lookup`

- **Solution**: Use IP address instead of hostname in `api_constants.dart`

### Authentication Issues

**Error**: "Authentication Failed"

- Verify correct password entered
- Check backend is running
- Ensure database connection is active

### QR Scanning Not Working

- Grant camera permissions in app settings
- Ensure good lighting when scanning
- Hold steady for 2-3 seconds

## 🔐 Security Considerations

### Implemented

- ✅ Password encryption (bcrypt)
- ✅ Biometric authentication
- ✅ SQL injection prevention (parameterized queries)
- ✅ Input validation
- ✅ Transaction rollback on errors

### Production Recommendations

- [ ] HTTPS/TLS encryption
- [ ] JWT tokens for authentication
- [ ] Rate limiting on API endpoints
- [ ] Two-factor authentication
- [ ] Password strength requirements
- [ ] Session timeout
- [ ] Audit logging

## 📊 Database Schema

### Users Table

| Column   | Type          | Constraints      |
| -------- | ------------- | ---------------- |
| id       | SERIAL        | PRIMARY KEY      |
| name     | VARCHAR(255)  | NOT NULL         |
| email    | VARCHAR(255)  | UNIQUE, NOT NULL |
| password | TEXT          | NOT NULL         |
| balance  | DECIMAL(10,2) | DEFAULT 1000.00  |

### Transactions Table

| Column         | Type          | Constraints       |
| -------------- | ------------- | ----------------- |
| id             | SERIAL        | PRIMARY KEY       |
| amount         | DECIMAL(10,2) | NOT NULL          |
| receiver_name  | VARCHAR(255)  | -                 |
| upi_id         | VARCHAR(255)  | -                 |
| sender_email   | VARCHAR(255)  | -                 |
| receiver_email | VARCHAR(255)  | -                 |
| status         | VARCHAR(50)   | DEFAULT 'Success' |
| date           | TIMESTAMP     | DEFAULT NOW()     |

## 🎨 UI Features

- **Material Design 3** components
- **Custom animations** for smooth transitions
- **Responsive layouts** that adapt to screen sizes
- **Dark/Light theme** support (planned)
- **Glassmorphism** effects on cards
- **Skeleton loaders** for async operations

## 🚀 Future Enhancements

- [ ] Bill splitting functionality
- [ ] Recurring payments
- [ ] Payment reminders
- [ ] Bank account linking
- [ ] Multiple currency support
- [ ] Expense categorization
- [ ] Budget tracking
- [ ] Dark mode
- [ ] Notifications for transactions
- [ ] Contact sync for easy payments

## 📝 License

This project is for educational purposes only. Not affiliated with Google or Google Pay.

## 👥 Credits

Developed as a learning project to understand:

- Flutter mobile development
- REST API integration
- PostgreSQL database management
- Payment flow implementation
- QR code technology
- Biometric authentication

## 📞 Support

For issues or questions:

1. Check the troubleshooting section
2. Verify your setup matches the installation guide
3. Ensure all dependencies are installed correctly

---

**Note**: This is a demonstration project. For production use, implement proper security measures, comply with financial regulations, and obtain necessary certifications.
