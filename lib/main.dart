import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'home_page.dart'; // Importez votre page d'accueil
import 'firebase_options.dart';
import 'profil_page.dart'; // Importez votre page de profil

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(MyApp());
  } catch (e) {
    print('Erreur lors de l\'initialisation de Firebase: $e');
  }
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    analytics.logEvent(name: 'app_started');
    return MaterialApp(
      title: 'VintedIA App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      initialRoute: '/', // Définit la route initiale
      routes: {
        '/': (context) => LoginPage(), // Page de connexion
        '/home': (context) => HomePage(user: FirebaseAuth.instance.currentUser!), // Page d'accueil
        '/profil': (context) => ProfilPage(user: FirebaseAuth.instance.currentUser!), // Page de profil
      },
    );
  }
}