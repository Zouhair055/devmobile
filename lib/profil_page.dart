import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'ajoutervetement_page.dart'; // Assurez-vous que le chemin est correct
import 'theme.dart';
class ProfilPage extends StatefulWidget {
  final User user;

  ProfilPage({required this.user});

  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _anniversaireController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _codePostalController = TextEditingController();
  final TextEditingController _villeController = TextEditingController();

  String login = '';
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    String userLogin = widget.user.displayName ?? widget.user.email ?? '';

    try {
      QuerySnapshot userQueryByLogin = await FirebaseFirestore.instance
          .collection('users')
          .where('login', isEqualTo: userLogin)
          .get();

      if (userQueryByLogin.docs.isNotEmpty) {
        final data = userQueryByLogin.docs.first.data() as Map<String, dynamic>;

        setState(() {
          login = data['login'] ?? 'Pas de login';
          _anniversaireController.text = data['anniversaire'] ?? 'Pas d\'anniversaire';
          _adresseController.text = data['adresse'] ?? 'Pas d\'adresse';
          _codePostalController.text = data['codePostal']?.toString() ?? 'Pas de code postal';
          _villeController.text = data['ville'] ?? 'Pas de ville';
        });
      } else {
        QuerySnapshot userQueryByEmail = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: widget.user.email)
            .get();

        if (userQueryByEmail.docs.isNotEmpty) {
          final data = userQueryByEmail.docs.first.data() as Map<String, dynamic>;

          setState(() {
            login = data['login'] ?? 'Pas de login';
            _anniversaireController.text = data['anniversaire'] ?? 'Pas d\'anniversaire';
            _adresseController.text = data['adresse'] ?? 'Pas d\'adresse';
            _codePostalController.text = data['codePostal']?.toString() ?? 'Pas de code postal';
            _villeController.text = data['ville'] ?? 'Pas de ville';
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Utilisateur non trouvé')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération des données : $e')),
      );
    }
  }

  void _saveUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String? userEmail = currentUser.email; // Récupère l'email de l'utilisateur connecté

      // Chercher l'utilisateur dans Firestore en fonction de son email
      final usersCollection = FirebaseFirestore.instance.collection('users');
      final querySnapshot = await usersCollection.where('email', isEqualTo: userEmail).get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first.reference;

        try {
          // Mise à jour des informations de l'utilisateur dans Firestore
          await userDoc.update({
            'anniversaire': _anniversaireController.text,
            'adresse': _adresseController.text,
            'codePostal': _codePostalController.text,
            'ville': _villeController.text,
          });

          // Mise à jour du mot de passe si un nouveau mot de passe a été saisi
          if (_passwordController.text.isNotEmpty) {
            await currentUser.updatePassword(_passwordController.text);
            // Si vous souhaitez enregistrer le mot de passe dans Firestore (optionnel)
            await userDoc.update({'password': _passwordController.text}); // Ajouter ce champ si nécessaire
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Mot de passe mis à jour avec succès')),
            );
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Informations mises à jour avec succès')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de la sauvegarde : $e')),
          );
        }
      } else {
        print('Aucun document trouvé pour cet email: $userEmail');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Utilisateur introuvable')),
        );
      }
    } else {
      print('Aucun utilisateur connecté');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aucun utilisateur connecté')),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      print('Utilisateur déconnecté avec succès');

      // Redirection vers la page de connexion après la déconnexion
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('Erreur lors de la déconnexion : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la déconnexion : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundWithIcons(), // Application du fond d'écran avec les icônes
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Align(
                alignment: Alignment.topCenter, // Alignement en haut au centre
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8, // Limite la largeur pour centrer
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Alignement à gauche des détails
                    children: [
                      Text(
                        'Login : $login',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Mot de passe :',
                        style: TextStyle(fontWeight: FontWeight.bold), // Mettre le texte en gras
                      ),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(hintText: '********'),
                        enabled: isEditing,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Anniversaire :',
                        style: TextStyle(fontWeight: FontWeight.bold), // Mettre le texte en gras
                      ),
                      TextField(
                        controller: _anniversaireController,
                        decoration: InputDecoration(),
                        enabled: isEditing,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Adresse :',
                        style: TextStyle(fontWeight: FontWeight.bold), // Mettre le texte en gras
                      ),
                      TextField(
                        controller: _adresseController,
                        decoration: InputDecoration(),
                        enabled: isEditing,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Code postal :',
                        style: TextStyle(fontWeight: FontWeight.bold), // Mettre le texte en gras
                      ),
                      TextField(
                        controller: _codePostalController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(),
                        enabled: isEditing,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Ville :',
                        style: TextStyle(fontWeight: FontWeight.bold), // Mettre le texte en gras
                      ),
                      TextField(
                        controller: _villeController,
                        decoration: InputDecoration(),
                        enabled: isEditing,
                      ),
                      SizedBox(height: 16),
                      // Ajout d'une Row pour organiser les boutons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: isEditing ? _saveUserData : null,
                            child: Text('Valider'),
                          ),
                          ElevatedButton(
                            onPressed: () => _logout(context),
                            child: Text('Se déconnecter'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isEditing = !isEditing;
                              });
                            },
                            child: Text(isEditing ? 'Annuler' : 'Modifier'),
                          ),
                        ],
                      ),
                      SizedBox(height: 20), // Espacement avant le bouton Ajouter un Vêtement
                      Center( // Centre le bouton Ajouter un Vêtement
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => AjouterVetementPage()),
                            );
                          },
                          child: Text('Ajouter un Vêtement'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
