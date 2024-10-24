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
      // Récupérez l'email associé au login depuis Firestore
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
      final userData = userDocument.data() as Map<String, dynamic>;
      if (!userData.containsKey('email')) {
        setState(() {
          _errorMessage = 'Le champ "email" n\'existe pas dans le document.';
        });
        return;
      }

      final email = userData['email'];
      final storedPassword = userData['password'];

      // Vérifiez si le mot de passe correspond
      if (storedPassword != password) {
        setState(() {
          _errorMessage = 'Mot de passe incorrect.';
        });
        return;
      }

      // Authentifiez l'utilisateur avec Firebase Authentication en utilisant l'email et le mot de passe
      UserCredential emailUserCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Utilisateur connecté avec succès : ${emailUserCredential.user?.uid}');

      // Redirection vers la page d'accueil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(user: emailUserCredential.user!)),
      );

    } catch (e) {
      setState(() {
        if (e is FirebaseAuthException) {
          _errorMessage = 'Erreur de connexion : ${e.message}';
        } else {
          _errorMessage = 'Erreur de connexion : $e';
        }
      });
      print('Erreur de connexion : $e'); // Affichez l'erreur dans la console pour le débogage
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'VintedIA-Miage',
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
                  onSubmitted: (value) => _login(context),
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
                  onSubmitted: (value) => _login(context),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => _login(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'Se connecter',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),
                if (_errorMessage != null)
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
