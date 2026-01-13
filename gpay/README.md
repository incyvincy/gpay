# GPay Clone - UPI Payment System

A full-stack payment application recreating Google Pay's core functionality with QR-based payments, transaction history, and secure payment processing.

## 🎯 Project Overview

This project is an AI-assisted implementation of a UPI payment system featuring:

- **QR-based payments** with scan & pay functionality
- **Transaction management** with comprehensive history and filtering
- **Secure authentication** with JWT-based session management
- **Real-time payment processing** with multiple payment states
- **Receipt generation** and transaction tracking

Built as part of the KUBBERA Technical Assessment to demonstrate AI-assisted full-stack development capabilities.

## 🏗️ Architecture

### Frontend (Flutter)

- **Framework**: Flutter 3.x
- **State Management**: Provider/Riverpod
- **QR Scanner**: `mobile_scanner` package
- **Image Picker**: `image_picker` for gallery QR import
- **HTTP Client**: `http` or `dio` for API calls
- **Local Storage**: `shared_preferences` for session management

### Backend (Node.js + Express)

- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Database**: PostgreSQL with encryption/decryption
- **Authentication**: JWT tokens
- **Security**: bcrypt for password hashing, crypto for data encryption
- **CORS**: Enabled for cross-origin requests

### Key Features Implemented

#### 🔍 QR-Based Payments

- Camera permission flow with error handling
- Real-time QR scanner with flashlight toggle
- Gallery import for saved QR codes
- Parse merchant/UPI QR codes
- Display confirmation sheet with:
  - Receiver name and UPI ID
  - Bank logo and verified badge
  - Amount entry with presets (₹100, ₹500, ₹1000)
  - Notes/remarks field
  - Account selection
  - Available balance display

#### 💳 Payment Processing

- Multi-step payment flow
- Dynamic status handling (success, pending, failed)
- Transaction receipt generation
- Share and download receipt options
- "Pay again" functionality

#### 📊 Transaction History

- Comprehensive transaction logs
- Filter by: All, Received, Sent, Pending, Refunds
- Search functionality:
  - Name, UPI ID, phone number
  - Transaction notes/remarks
- Transaction details view:
  - Masked VPA/bank details
  - Status, timestamp, reference number
  - Downloadable receipt
  - Dispute/report issue button
  - Quick action shortcuts

#### 🔐 Authentication

- Login/Signup screens with validation
- JWT-based session management
- Secure password storage
- Client-side field validation

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.0.0 or higher
- **Dart SDK**: 2.17.0 or higher
- **Node.js**: 18.x or higher
- **PostgreSQL**: 14.x or higher
- **Android Studio** / **Xcode** (for mobile development)

### Backend Setup

1. **Navigate to backend directory**

   ```bash
   cd backend
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Configure environment variables**
   Create a `.env` file in the `backend` directory:

   ```env
   PORT=3000
   DATABASE_URL=postgresql://username:password@localhost:5432/gpay_db
   JWT_SECRET=your-secret-key-here
   ENCRYPTION_KEY=32-byte-encryption-key
   NODE_ENV=development
   ```

4. **Setup PostgreSQL database**

   ```bash
   # Create database
   createdb gpay_db

   # Run migrations (if available)
   npm run migrate

   # Seed initial data
   npm run seed
   ```

5. **Start the backend server**

   ```bash
   npm start
   # or for development with auto-reload
   npm run dev
   ```

   Backend will run on `http://localhost:3000`

### Frontend Setup

1. **Navigate to Flutter project**

   ```bash
   cd gpay
   ```

2. **Install Flutter dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**
   Create a `lib/config/app_config.dart` file:

   ```dart
   class AppConfig {
     static const String baseUrl = 'http://localhost:3000/api';
     static const String apiVersion = 'v1';
   }
   ```

4. **Run the app**

   ```bash
   # For Android
   flutter run

   # For iOS
   flutter run -d ios

   # For Web
   flutter run -d chrome
   ```

## 🤖 AI Tools Usage

This project extensively utilized AI assistance throughout development:

### Frontend Development

**Tool Used**: GitHub Copilot, Claude AI, Cursor

**Examples**:

1. **QR Scanner Integration**

   - _Prompt_: "Create a Flutter QR scanner page with camera permissions, flashlight toggle, and gallery import"
   - _AI Output_: Generated `qr_scanner_page.dart` with complete camera handling
   - _Refinement_: Added error states, improved UX, integrated with payment flow

2. **Transaction History UI**

   - _Prompt_: "Build a transaction history list with filters, search, and pull-to-refresh"
   - _AI Output_: Created reusable transaction card widget with filtering logic
   - _Refinement_: Added animations, optimized list rendering, implemented search debouncing

3. **Payment Flow State Management**
   - _Prompt_: "Implement multi-step payment flow with amount entry, confirmation, and status screens"
   - _AI Output_: Generated state management logic and navigation flow
   - _Refinement_: Added validation, error recovery, and success animations

### Backend Development

**Tool Used**: GitHub Copilot, Cursor, ChatGPT

**Examples**:

1. **PostgreSQL Encryption Layer**

   - _Prompt_: "Create PostgreSQL functions for encrypting and decrypting sensitive payment data"
   - _AI Output_: Generated SQL functions and Node.js service layer
   - _Refinement_: Added key rotation support, improved error handling

2. **JWT Authentication Middleware**

   - _Prompt_: "Build Express middleware for JWT authentication with refresh token support"
   - _AI Output_: Created auth middleware and token management utilities
   - _Refinement_: Added token blacklisting, improved security headers

3. **Transaction API Endpoints**
   - _Prompt_: "Create REST APIs for transactions: create, list with pagination, filter, search"
   - _AI Output_: Generated routes, controllers, and validation schemas
   - _Refinement_: Added transaction locking, optimized queries, improved error responses

### Database Schema Design

**Tool Used**: ChatGPT, Claude AI

- AI helped design normalized schema for users, transactions, accounts, and UPI data
- Generated migration scripts and seed data
- Suggested indexes for query optimization

## 📁 Project Structure

```
gpay-clone/
├── backend/
│   ├── src/
│   │   ├── controllers/     # Request handlers
│   │   ├── models/          # Database models
│   │   ├── routes/          # API routes
│   │   ├── middleware/      # Auth, validation, error handling
│   │   ├── services/        # Business logic
│   │   ├── utils/           # Helper functions
│   │   └── config/          # Configuration files
│   ├── migrations/          # Database migrations
│   ├── seeds/               # Seed data
│   ├── .env.example         # Environment template
│   └── package.json
│
├── gpay/
│   ├── lib/
│   │   ├── screens/         # UI screens
│   │   ├── widgets/         # Reusable components
│   │   ├── services/        # API services
│   │   ├── models/          # Data models
│   │   ├── providers/       # State management
│   │   ├── utils/           # Utilities
│   │   └── config/          # App configuration
│   ├── assets/              # Images, fonts
│   ├── pubspec.yaml         # Flutter dependencies
│   └── README.md
│
└── AI_NOTES.md              # Detailed AI usage documentation
```

## 🔒 Security Features

- **Password Hashing**: bcrypt with salt rounds
- **Data Encryption**: AES-256 encryption for sensitive data in PostgreSQL
- **JWT Tokens**: Secure authentication with expiration
- **Input Validation**: Server-side validation for all inputs
- **SQL Injection Protection**: Parameterized queries
- **CORS Configuration**: Restricted origin policy

## 🧪 Testing

```bash
# Backend tests
cd backend
npm test

# Flutter tests
cd gpay
flutter test

# Integration tests
flutter test integration_test/
```

## 📸 Screenshots

_(Add screenshots of your running application here)_

1. Login/Signup Screen
2. QR Scanner Interface
3. Payment Confirmation
4. Transaction History
5. Transaction Details

## 🚧 Future Enhancements

- [ ] Biometric authentication
- [ ] Multi-language support
- [ ] UPI Lite wallet integration
- [ ] Bill payments and recharge
- [ ] Split payments
- [ ] Merchant dashboard
- [ ] Analytics and spending insights

## 📝 License

This project is created for educational purposes as part of the KUBBERA Technical Assessment.

## 👥 Contact

For questions or feedback regarding this assessment submission, please reach out through the designated submission channel.

---

**Development Time**: ~140 hours (6 days)  
**AI Assistance Level**: High - Used throughout frontend, backend, and database design  
**Code Quality**: Production-ready with proper error handling, validation, and security measures
