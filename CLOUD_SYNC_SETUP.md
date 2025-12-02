# Cloud Sync Setup Guide

This guide will help you set up cloud sync for GraphTodo using MongoDB Atlas and Auth0.

## ✅ What's Already Done

The following components are already implemented and configured:

- ✅ **Backend Infrastructure**: All services and providers are created
- ✅ **Environment Variables**: `.env` file with MongoDB credentials
- ✅ **Provider Integration**: AuthProvider and SyncProvider added to app
- ✅ **Security**: `.env` added to `.gitignore`, credentials protected
- ✅ **MongoDB Configured**: Your MongoDB Atlas connection string is set up

## 🔐 MongoDB Atlas - COMPLETE ✅

Your MongoDB is already configured with:
- **Connection String**: `mongodb+srv://telomelonia:...@graphtodo.lfhak6e.mongodb.net/`
- **Database Name**: `graphtodo`
- **Collections**: Will be auto-created on first sync (nodes, connections)

## 📝 Next Step: Auth0 Setup

You need to complete the Auth0 setup to enable user authentication:

### 1. Create Auth0 Account

1. Go to https://auth0.com
2. Click "Sign Up" and create a free account
3. Verify your email

### 2. Create Application

1. In Auth0 Dashboard, go to **Applications** → **Create Application**
2. Name: **GraphTodo**
3. Type: Choose **Native**
4. Click **Create**

### 3. Configure Application Settings

In your new application's Settings tab:

1. **Note these values** (you'll need them):
   - **Domain**: Something like `dev-xxxxx.us.auth0.com`
   - **Client ID**: A long alphanumeric string

2. **Scroll down to Application URIs** and add:
   - **Allowed Callback URLs**: `graphtodo://callback`
   - **Allowed Logout URLs**: `graphtodo://logout`

3. **Click "Save Changes"** at the bottom

### 4. Update .env File

Edit the `.env` file in your project root and replace these lines:

```env
AUTH0_DOMAIN=YOUR_AUTH0_DOMAIN_HERE
AUTH0_CLIENT_ID=YOUR_AUTH0_CLIENT_ID_HERE
```

With your actual values:

```env
AUTH0_DOMAIN=dev-xxxxx.us.auth0.com
AUTH0_CLIENT_ID=your_actual_client_id_here
```

**Example:**
```env
AUTH0_DOMAIN=dev-abc123.us.auth0.com
AUTH0_CLIENT_ID=xYz123AbC456DeF789GhI012
```

### 5. Platform Configuration

#### iOS Configuration

Add this to `ios/Runner/Info.plist` (inside the `<dict>` tag):

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>None</string>
    <key>CFBundleURLName</key>
    <string>auth0</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>graphtodo</string>
    </array>
  </dict>
</array>
```

#### Android Configuration

Add this to `android/app/src/main/AndroidManifest.xml` (inside the `<application>` tag):

```xml
<activity
  android:name="com.auth0.flutter.auth0_flutter.Auth0FlutterActivity"
  android:exported="true">
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
      android:scheme="graphtodo"
      android:host="callback" />
  </intent-filter>
</activity>
```

## 🧪 Testing Cloud Sync

Once Auth0 is configured:

1. **Run the app**:
   ```bash
   flutter run
   ```

2. **Open hamburger menu** (three lines icon)

3. **Click "Login"** button
   - Auth0 login page will open in browser
   - Sign up or login with email/password or social login

4. **Create some nodes** on the canvas

5. **Click the sync button** (refresh icon in hamburger menu)
   - You should see "Syncing..." then "Synced!"

6. **Test on another device**:
   - Install app on second device
   - Login with same Auth0 account
   - Click sync
   - Your nodes should appear!

## 🔍 Troubleshooting

### "Auth0 not configured" Error

Check that `.env` has real values (not placeholders):
```bash
cat .env
```

Should NOT contain:
- `YOUR_AUTH0_DOMAIN_HERE`
- `YOUR_AUTH0_CLIENT_ID_HERE`

### "Login failed" Error

1. Verify callback URLs in Auth0 dashboard match exactly:
   - `graphtodo://callback`
   - `graphtodo://logout`

2. Check platform configuration files (Info.plist, AndroidManifest.xml)

3. Rebuild the app after adding platform configurations:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### "MongoDB connection failed" Error

This shouldn't happen since it's already configured, but if it does:

1. Check MongoDB Atlas network access allows `0.0.0.0/0`
2. Verify connection string in `.env` is correct
3. Ensure MongoDB Atlas cluster is running

### App Won't Build

1. Clean and rebuild:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. Check Flutter doctor:
   ```bash
   flutter doctor
   ```

## 📚 Documentation

For more details, see:
- `CLAUDE.md` - Full project documentation with detailed setup
- `planDB.md` - Implementation plan and progress tracking
- `.env.example` - Environment variable template

## 🔒 Security Reminders

- ✅ `.env` is in `.gitignore` (never commit it!)
- ✅ Auth0 tokens stored securely using `flutter_secure_storage`
- ✅ Each user's data is isolated by their Auth0 user ID
- ✅ All connections use HTTPS/TLS encryption

## 🎉 What You'll Get

Once setup is complete, you'll have:

- 🔐 **Secure Authentication**: Login with email, Google, GitHub, etc.
- ☁️ **Cloud Backup**: All your nodes synced to MongoDB Atlas
- 📱 **Multi-Device**: Access your todos from phone, tablet, desktop
- 🔄 **Manual Sync**: Control when your data syncs with a button tap
- 📡 **Offline First**: App works fully offline, syncs when online
- 🔒 **Private**: Your data is isolated and encrypted

---

**Need Help?**

Check the troubleshooting section above or refer to the full setup guide in `CLAUDE.md`.
