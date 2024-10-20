import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart';

class DetailPage extends StatelessWidget {
  final String vetementId;

  DetailPage({required this.vetementId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du vêtement'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Bouton retour à la liste des vêtements
          },
        ),
      ),
      body: Stack(
        children: [
          BackgroundWithIcons(),  // Application du fond d'écran avec les icônes
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('vetements').doc(vetementId).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Erreur de chargement : ${snapshot.error}'));
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(child: Text('Vêtement introuvable.'));
              }

              final vetement = snapshot.data!;
              final nom = vetement['nom'] ?? 'Nom inconnu';
              final prix = vetement['prix'] ?? 'N/A';
              final taille = vetement['taille'] ?? 'Taille inconnue';
              final categorie = vetement['categorie'] ?? 'Catégorie inconnue';
              final marque = vetement['marque'] ?? 'Marque inconnue';
              final imageUrl = vetement['imageUrl'];
              final description = vetement['description'] ?? 'Pas de description';

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    imageUrl != null
                        ? Image.network(imageUrl, width: 200, height: 200, fit: BoxFit.cover)
                        : Icon(Icons.image_not_supported, size: 200),
                    SizedBox(height: 16),
                    Text(nom, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Catégorie : $categorie'),
                    SizedBox(height: 8),
                    Text('Marque : $marque'),
                    SizedBox(height: 8),
                    Text('Taille : $taille'),
                    SizedBox(height: 8),
                    Text('Prix : $prix€'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _ajouterAuPanier(context, vetementId);  // Fonction d'ajout au panier
                      },
                      child: Text('Ajouter au panier'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _ajouterAuPanier(BuildContext context, String vetementId) async {
    // Récupérer l'utilisateur connecté
    User? user = FirebaseAuth.instance.currentUser;

    // Vérifie si l'utilisateur est connecté
    if (user == null) {
      print('Aucun utilisateur connecté.');  // Log pour débogage
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vous devez être connecté pour ajouter au panier.')),
      );
      return;
    }

    print('Utilisateur connecté : ${user.uid}');  // Log pour débogage

  }
}