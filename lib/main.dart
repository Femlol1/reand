// Importing necessary packages and dependencies.
import 'dart:io';
import 'dart:isolate';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in_dartio/google_sign_in_dartio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'database/db.dart';
import 'firebase_options.dart';
import 'services/theme_services.dart';
import 'views/pages/home_page.dart';
import 'views/pages/login_page.dart';
import 'views/theme.dart';

bool shouldUseFirebaseEmulator = false;

// Declaring global variables for Firebase and user management.
late final FirebaseApp app;
late final FirebaseAuth auth;
late User user;

Future<void> main() async {
  // Ensuring that widget binding is initialized before runApp.
  WidgetsFlutterBinding.ensureInitialized();
  // Initializing time zones for the app.
  tz.initializeTimeZones();
  // Platform-specific code for Windows.
  if (Platform.isWindows) {
    // Initialize SQLite for Flutter on Windows using FFI (Foreign Function Interface).
    sqfliteFfiInit();

    // Registering Google Sign-In for Dart on Windows with a specific client ID.
    await GoogleSignInDart.register(
      clientId:
          '342116535427-q4nc25faid32abb99ufit8t0qnv72irt.apps.googleusercontent.com',
    );
  }
  // Setting the database factory to the FFI implementation.
  databaseFactory = databaseFactoryFfi;

  // Setting up isolate communication.
  RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
  Isolate.spawn(_isolateMain, rootIsolateToken);

  databaseFactory = databaseFactoryFfi;
  if (shouldUseFirebaseEmulator) {
    await auth.useAuthEmulator('localhost', 9099);
  }
// Initializing the database helper and storage.
  await DBHelper.initDb();
  await GetStorage.init();
// Initializing Firebase and obtaining an instance for the app.
  try {
    app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    auth = FirebaseAuth.instanceFor(app: app);
    runApp(const MyApp());
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
    // Handle the error or set a flag to show an error message in the UI
  }
}

// MyApp class, defining the root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of my application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: ThemeServices().theme,
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                Visibility(
                  visible: constraints.maxWidth >= 1200,
                  child: Expanded(
                    child: Container(
                      height: double.infinity,
                      color: Theme.of(context).colorScheme.primary,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Task Manager',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Container for the main content of the app.
                SizedBox(
                  width: constraints.maxWidth >= 1200
                      ? constraints.maxWidth / 2
                      : constraints.maxWidth,
                  child: StreamBuilder<User?>(
                    // ignore: unnecessary_null_comparison, prefer_null_aware_operators
                    stream: auth != null ? auth.authStateChanges() : null,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return const HomePage();
                      }
                      return const AuthGate();
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Function to handle background isolate logic.
void _isolateMain(RootIsolateToken rootIsolateToken) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  print(sharedPreferences.getBool('isDebug'));
}
