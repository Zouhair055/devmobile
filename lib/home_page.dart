import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart'; // Assurez-vous que ce chemin d'importation est correct pour votre page de connexion
import 'theme.dart';

class HomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showProfileDialog(BuildContext context) async {
    User? user = _auth.currentUser;

    if (user == null) {
      // Si l'utilisateur n'est pas connecté, retournez.
      return;
    }

    // Utiliser l'email pour récupérer le document de l'utilisateur
    String userEmail = user.email ?? '';
    
    // Récupérer les informations de l'utilisateur depuis Firestore
    QuerySnapshot userQuery = await _firestore.collection('users').where('email', isEqualTo: userEmail).get();

    if (userQuery.docs.isEmpty) {
      print("Le document de l'utilisateur n'existe pas.");
      return;
    }

    // Si le document existe, récupérer le nom
    DocumentSnapshot userDoc = userQuery.docs.first;
    String userName = userDoc['login'] ?? 'Nom inconnu';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Profil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nom : $userName'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await _auth.signOut(); // Déconnexion de l'utilisateur
                  Navigator.of(context).pop(); // Ferme la boîte de dialogue
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()), // Remplacez par le nom de votre page de connexion
                  );
                },
                child: Text('Déconnexion'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
              child: Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'VintedIA',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          BackgroundWithIcons(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Liste des vêtements disponibles',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('vetements').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Erreur de chargement des vêtements : ${snapshot.error}'));
                      }

                      final vetements = snapshot.data?.docs ?? [];

                      if (vetements.isEmpty) {
                        return Center(child: Text('Aucun vêtement disponible.'));
                      }

                      return ListView.builder(
                        itemCount: vetements.length,
                        itemBuilder: (context, index) {
                          final doc = vetements[index];
                          final nom = doc['nom'] ?? 'Nom inconnu';
                          final prix = doc['prix'] ?? 'N/A';
                          final description = doc['description'] ?? 'Pas de description';
                          final stock = doc['stock'] ?? 'Stock indisponible';
                          final taille = doc['taille'] ?? 'Taille inconnue';
                          final couleur = doc['couleur'] ?? 'Couleur inconnue';
                          final imageUrl = doc['imageUrl'];

                          return Card(
                            child: ListTile(
                              title: Text(nom),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        child: imageUrl != null
                                            ? Image.network(imageUrl, fit: BoxFit.cover)
                                            : Icon(Icons.image_not_supported),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Prix : $prix€'),
                                            Text('Description : $description'),
                                            Text('Taille : $taille'),
                                            Text('Stock : $stock'),
                                            Text('Couleur : $couleur'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Boutons en bas de la page
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Logique pour acheter
                    },
                    icon: Icon(Icons.attach_money),
                    label: Text('Acheter'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Logique pour le panier
                    },
                    icon: Icon(Icons.local_mall),
                    label: Text('Panier'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showProfileDialog(context); // Ouvre le dialogue de profil
                    },
                    icon: Icon(Icons.person),
                    label: Text('Profil'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
