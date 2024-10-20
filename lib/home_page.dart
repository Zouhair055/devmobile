import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart'; // Assurez-vous que ce chemin d'importation est correct pour votre page de connexion
import 'theme.dart';
import 'detail_page.dart'; // Créez cette nouvelle page pour les détails
import 'panier_page.dart'; // Assurez-vous que ce chemin d'importation est correct

class HomePage extends StatefulWidget {
  final User user;

  HomePage({required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Initialiser _pages dans initState
    _pages = [
      VetementsPage(user: widget.user), // Ajoutez l'utilisateur si nécessaire
      PanierPage(user: widget.user), // Page Panier
      ProfilPage(), // Page de profil temporaire
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showProfileDialog(BuildContext context) async {
    User? user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vous devez être connecté pour voir le profil.')),
      );
      return;
    }

    String userEmail = user.email ?? '';
    QuerySnapshot userQuery = await _firestore.collection('users').where('email', isEqualTo: userEmail).get();

    if (userQuery.docs.isEmpty) {
      print("Le document de l'utilisateur n'existe pas.");
      return;
    }

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
                  await _auth.signOut();
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text('Déconnexion'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
        title: Text('VintedIA'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          BackgroundWithIcons(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _pages[_selectedIndex], // Affiche la page correspondante
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Acheter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_mall),
            label: 'Panier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // Ajouter l'icône pour le profil
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ProfilPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Page de profil à venir !'),
    );
  }
}

// Widget pour afficher la liste des vêtements
class VetementsPage extends StatelessWidget {
  final User user;

  VetementsPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  final taille = doc['taille'] ?? 'Taille inconnue';
                  final imageUrl = doc['imageUrl'];

                  return Card(
                    child: ListTile(
                      leading: imageUrl != null
                          ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                          : Icon(Icons.image_not_supported),
                      title: Text(nom),
                      subtitle: Text('Taille: $taille, Prix: $prix€'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(vetementId: doc.id, user: user),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
