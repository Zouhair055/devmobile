import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart';

class DetailPage extends StatelessWidget {
  final String vetementId;
  final User user;

  DetailPage({required this.vetementId, required this.user});

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
              final prix = double.tryParse(vetement['prix']?.toString() ?? '0') ?? 0.0; 
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
                        _ajouterAuPanier(context, vetementId, nom, taille, prix, imageUrl);
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

  void _ajouterAuPanier(BuildContext context, String vetementId, String nom, String taille, double prix, String? imageUrl) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('panier')
          .add({
        'vetementId': vetementId,
        'nom': nom,
        'taille': taille,
        'prix': prix,
        'imageUrl': imageUrl,
        'quantite': 1,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Article ajouté au panier')),
      );
    } catch (e) {
      print('Erreur lors de l\'ajout au panier : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout au panier')),
      );
    }
  }
}

