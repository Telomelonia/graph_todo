import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration for Auth0 and MongoDB.
///
/// IMPORTANT: Before using cloud sync, you need to:
/// 1. Set up your MongoDB Atlas account (free tier)
/// 2. Set up your Auth0 account (free tier)
/// 3. Copy .env.example to .env and fill in your credentials
///
/// Credentials are loaded from .env file using flutter_dotenv for security.
/// Never commit .env to git (it's in .gitignore).
class AppConfig {
  // ==========================================================================
  // AUTH0 CONFIGURATION
  // ==========================================================================

  /// Your Auth0 domain (e.g., 'your-tenant.us.auth0.com')
  /// Get this from: https://manage.auth0.com/ > Applications > Your App > Settings
  static String get auth0Domain => dotenv.get('AUTH0_DOMAIN', fallback: 'YOUR_AUTH0_DOMAIN_HERE');

  /// Your Auth0 client ID
  /// Get this from: https://manage.auth0.com/ > Applications > Your App > Settings
  static String get auth0ClientId => dotenv.get('AUTH0_CLIENT_ID', fallback: 'YOUR_AUTH0_CLIENT_ID_HERE');

  /// Auth0 callback URL scheme for your app
  /// This should match the scheme in your Auth0 dashboard
  /// Format: 'your-app-scheme://callback'
  /// Example: 'graphtodo://callback'
  static String get auth0CallbackScheme => dotenv.get('AUTH0_CALLBACK_SCHEME', fallback: 'graphtodo');

  // ==========================================================================
  // MONGODB CONFIGURATION
  // ==========================================================================

  /// Your MongoDB Atlas connection string
  /// Get this from: https://cloud.mongodb.com > Database > Connect > Connect your application
  ///
  /// Format: 'mongodb+srv://<username>:<password>@<cluster>.mongodb.net/<database>?retryWrites=true&w=majority'
  static String get mongoDBConnectionString => dotenv.get('MONGODB_CONNECTION_STRING', fallback: 'YOUR_MONGODB_CONNECTION_STRING_HERE');

  /// MongoDB database name
  /// This should match the database name in your connection string
  static String get mongoDBDatabaseName => dotenv.get('MONGODB_DATABASE_NAME', fallback: 'graphtodo');

  // ==========================================================================
  // VALIDATION
  // ==========================================================================

  /// Check if Auth0 is configured
  static bool get isAuth0Configured {
    return auth0Domain != 'YOUR_AUTH0_DOMAIN_HERE' &&
        auth0ClientId != 'YOUR_AUTH0_CLIENT_ID_HERE';
  }

  /// Check if MongoDB is configured
  static bool get isMongoDBConfigured {
    return mongoDBConnectionString != 'YOUR_MONGODB_CONNECTION_STRING_HERE';
  }

  /// Check if cloud sync is fully configured
  static bool get isCloudSyncConfigured {
    return isAuth0Configured && isMongoDBConfigured;
  }

  // ==========================================================================
  // SETUP INSTRUCTIONS
  // ==========================================================================

  /// Instructions for setting up Auth0
  static const String auth0SetupInstructions = '''

  🔐 AUTH0 SETUP INSTRUCTIONS:

  1. Go to https://auth0.com and create a free account
  2. Create a new Application:
     - Click "Applications" > "Create Application"
     - Name it "GraphTodo"
     - Choose "Native" as the application type
  3. Configure Application Settings:
     - Copy your Domain and Client ID
     - Add callback URL: graphtodo://callback
     - Add logout URL: graphtodo://logout
     - Save changes
  4. Update lib/config/app_config.dart with your credentials

  ''';

  /// Instructions for setting up MongoDB
  static const String mongoDBSetupInstructions = '''

  ☁️ MONGODB ATLAS SETUP INSTRUCTIONS:

  1. Go to https://www.mongodb.com/cloud/atlas and create a free account
  2. Create a free cluster (M0 tier):
     - Choose a cloud provider and region
     - Name your cluster (e.g., "Cluster0")
  3. Create a database user:
     - Click "Database Access" > "Add New Database User"
     - Choose password authentication
     - Remember username and password
  4. Configure network access:
     - Click "Network Access" > "Add IP Address"
     - Add 0.0.0.0/0 (allows access from anywhere - needed for mobile)
     - Or add specific IP addresses for better security
  5. Get connection string:
     - Click "Database" > "Connect" > "Connect your application"
     - Copy the connection string
     - Replace <password> with your database user password
     - Replace <database> with "graphtodo"
  6. Update lib/config/app_config.dart with your connection string

  ''';

  /// Get setup status message
  static String getSetupStatus() {
    if (isCloudSyncConfigured) {
      return '✅ Cloud sync is fully configured and ready to use!';
    }

    final messages = <String>[];

    if (!isAuth0Configured) {
      messages.add('❌ Auth0 not configured');
      messages.add(auth0SetupInstructions);
    }

    if (!isMongoDBConfigured) {
      messages.add('❌ MongoDB not configured');
      messages.add(mongoDBSetupInstructions);
    }

    return messages.join('\n');
  }
}
