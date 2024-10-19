import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';
import 'theme.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage; // Variable pour stocker le message d'erreur

  void _login(BuildContext context) async {
    final login = _loginController.text.trim();
    final password = _passwordController.text.trim();

    if (login.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Login et mot de passe ne peuvent pas être vides.';
      });
      return;
    }

    try {
      print('Recherche de l\'utilisateur dans Firestore...');
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('login', isEqualTo: login)
          .limit(1)
          .get();

      if (result.docs.isEmpty) {
        setState(() {
          _errorMessage = 'Login non trouvé.';
        });
        return;
      }

      final userDocument = result.docs.first;
      final email = userDocument['email'];
      print('Utilisateur trouvé avec email: $email');

      // Impression des détails de connexion
      print('Tentative de connexion avec email: $email et mot de passe: $password');

      // Connexion avec Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Utilisateur connecté avec succès : ${userCredential.user?.uid}');

      // Redirection vers la page d'accueil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      String errorMessage;

      if (e is FirebaseAuthException) {
        errorMessage = 'Erreur de connexion : ${e.code} - ${e.message}';
      } else {
        errorMessage = 'Erreur de connexion : $e';
      }

      // Mettez à jour le message d'erreur à afficher
      setState(() {
        _errorMessage = errorMessage;
      });

      print(errorMessage); // Affichez l'erreur dans la console pour le débogage
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'VintedIA',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          BackgroundWithIcons(), // Fond d'écran avec logos
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Bienvenue !',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                TextField(
                  controller: _loginController,
                  decoration: InputDecoration(
                    labelText: 'Login',
                    labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => _login(context),
                  child: Text(
                    'Se connecter',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
                SizedBox(height: 20),
                if (_errorMessage != null) // Affiche le message d'erreur si disponible
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}