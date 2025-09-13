# Educational CMS - Setup Guide

This guide will help you set up and connect all components of the Educational Content Management System, including:

1. Flutter Frontend
2. Node.js Backend
3. MongoDB Database
4. Firebase Authentication
5. Google Drive Storage

## Prerequisites

- Flutter SDK (latest stable version)
- Node.js (v14 or higher)
- MongoDB (local or Atlas)
- Firebase account
- Google Cloud account

## 1. Backend Setup

### 1.1 Clone the Repository

```bash
git clone <repository-url>
cd educational-cms/backend
```

### 1.2 Install Dependencies

```bash
npm install
```

### 1.3 Configure Environment Variables

Create a `.env` file in the backend directory:

```
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb+srv://<username>:<password>@<cluster>.mongodb.net/education_cms
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRE=30d

# Firebase Configuration (optional)
USE_FIREBASE=true
FIREBASE_SERVICE_ACCOUNT={"type":"service_account",...}

# Google Drive API Configuration
GOOGLE_CREDENTIALS_CSE={"type":"service_account",...}
GOOGLE_CREDENTIALS_ECE={"type":"service_account",...}
# Add more departments as needed
```

### 1.4 Run Setup Script

```bash
npm run setup
```

### 1.5 Create Sample Data (Optional)

```bash
npm run seed
```

### 1.6 Start the Backend Server

```bash
npm run dev
```

## 2. MongoDB Setup

### 2.1 Local MongoDB

If you're using a local MongoDB instance:

```bash
# Start MongoDB service
sudo systemctl start mongod

# Verify MongoDB is running
sudo systemctl status mongod
```

### 2.2 MongoDB Atlas

1. Create a MongoDB Atlas account at [https://www.mongodb.com/cloud/atlas](https://www.mongodb.com/cloud/atlas)
2. Create a new cluster (the free M0 tier is sufficient)
3. Create a database user with read/write permissions
4. Whitelist your IP address
5. Get the connection string and update the `MONGODB_URI` in your `.env` file

## 3. Firebase Setup

### 3.1 Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable Authentication service
4. Add Email/Password sign-in method

### 3.2 Generate Firebase Admin SDK Credentials

1. Go to Project Settings > Service accounts
2. Click "Generate new private key"
3. Save the JSON file
4. Add the JSON content to your `.env` file as `FIREBASE_SERVICE_ACCOUNT`

### 3.3 Configure Firebase for Flutter

1. In Firebase Console, add a Flutter app to your project
2. Follow the setup instructions to download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
3. Place these files in the appropriate directories in your Flutter project

## 4. Google Drive API Setup

### 4.1 Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project

### 4.2 Enable Google Drive API

1. Go to APIs & Services > Library
2. Search for "Google Drive API" and enable it

### 4.3 Create Service Account

1. Go to APIs & Services > Credentials
2. Create a Service Account
3. Grant the Service Account the "Drive File" role
4. Create a key (JSON) for the Service Account
5. Save the JSON file

### 4.4 Configure Service Account for Each Department

For each department (CSE, ECE, etc.):

1. Create a separate Google account (e.g., cse.department@gmail.com)
2. Create a folder in Google Drive for that department
3. Share the folder with the Service Account email (with Editor permissions)
4. Add the Service Account JSON to your `.env` file as `GOOGLE_CREDENTIALS_<DEPARTMENT>`

## 5. Flutter Frontend Setup

### 5.1 Install Dependencies

```bash
cd ../frontend
flutter pub get
```

### 5.2 Configure API Base URL

Update the API base URL in `lib/config/app_config.dart`:

```dart
static const String apiBaseUrl = 'http://10.0.2.2:5000/api'; // For Android emulator
// static const String apiBaseUrl = 'http://localhost:5000/api'; // For iOS simulator
// static const String apiBaseUrl = 'https://your-production-api.com/api'; // For production
```

### 5.3 Configure Firebase for Flutter

1. Add Firebase configuration to your Flutter project:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure --project=your-firebase-project-id
```

2. Initialize Firebase in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

### 5.4 Run the Flutter App

```bash
flutter run
```

## 6. Integration Testing

### 6.1 Test Authentication Flow

1. Start the backend server
2. Run the Flutter app
3. Register a new user
4. Login with the created user
5. Verify that the token is stored and the user is redirected to the dashboard

### 6.2 Test API Endpoints

1. Test course creation and listing
2. Test subject creation and listing
3. Test module creation and listing
4. Test document upload and download
5. Test notice creation and listing

### 6.3 Test File Storage

1. Upload a document
2. Verify that the file is stored in Google Drive
3. Download the document
4. Verify that the file is accessible

## 7. Deployment

### 7.1 Backend Deployment

#### Render

1. Create a new Web Service on Render
2. Connect your GitHub repository
3. Set the build command: `npm install`
4. Set the start command: `npm start`
5. Add environment variables from your `.env` file

#### Railway

1. Create a new project on Railway
2. Connect your GitHub repository
3. Add environment variables from your `.env` file
4. Deploy the project

### 7.2 Flutter App Deployment

#### Android

1. Update the API base URL to point to your production backend
2. Build the APK:

```bash
flutter build apk --release
```

3. The APK will be available at `build/app/outputs/flutter-apk/app-release.apk`

#### iOS

1. Update the API base URL to point to your production backend
2. Build the iOS app:

```bash
flutter build ios --release
```

3. Open the Xcode project and archive the app for distribution

## 8. Troubleshooting

### 8.1 Backend Issues

- **MongoDB Connection Error**: Verify your MongoDB URI and ensure your IP is whitelisted
- **Firebase Authentication Error**: Check your Firebase service account credentials
- **Google Drive API Error**: Verify your Google Drive API credentials and permissions

### 8.2 Flutter Issues

- **API Connection Error**: Verify the API base URL and ensure the backend is running
- **Firebase Integration Error**: Check your Firebase configuration files
- **File Upload Error**: Verify that the backend has proper permissions to access Google Drive

## 9. Department-Based Storage Strategy

The system uses a department-based storage strategy to maximize free storage:

1. Each department has its own Google Drive account (15GB free storage per department)
2. Files are organized by department, course, semester, subject, and module
3. The backend dynamically selects the appropriate Google Drive client based on the department

This approach provides several benefits:

- Increased free storage (15GB per department)
- Data isolation between departments
- Simplified management for department administrators

## 10. Security Considerations

- JWT tokens are used for authentication
- Role-based access control (student, faculty, admin)
- Department-based access restrictions
- Password hashing with bcrypt
- HTTPS for production environments
- Firebase Authentication for enhanced security (optional)

## 11. Next Steps

- Implement additional features (e.g., assignments, grades, discussions)
- Add real-time notifications using Firebase Cloud Messaging
- Implement offline support using local database
- Add analytics to track user engagement
- Implement multi-language support

For more information, refer to the API documentation in the backend README.md file.