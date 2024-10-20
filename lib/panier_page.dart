import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme.dart';

class PanierPage extends StatefulWidget {
  final User user;

  PanierPage({required this.user});

  @override
  _PanierPageState createState() => _PanierPageState();
}

class _PanierPageState extends State<PanierPage> {
  double total = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon panier'),
      ),
      body: Stack(
        children: [
          BackgroundWithIcons(),  // Application du fond d'écran avec les icônes
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.user.uid)
                .collection('panier')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('Votre panier est vide.'));
              }

              final panierItems = snapshot.data!.docs;
              total = panierItems.fold(0, (sum, doc) {
                final vetement = doc.data() as Map<String, dynamic>;
                return sum + (vetement['prix'] ?? 0);
              });

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: panierItems.length,
                      itemBuilder: (context, index) {
                        final vetement = panierItems[index].data() as Map<String, dynamic>;
                        final vetementId = vetement['vetementId'];
                        final titre = vetement['nom'] ?? 'Titre inconnu';
                        final taille = vetement['taille'] ?? 'Taille inconnue';
                        final prix = vetement['prix'] ?? 0;
                        final imageUrl = vetement['imageUrl'];

                        return ListTile(
                          leading: imageUrl != null
                              ? Image.network(imageUrl, width: 50, height: 50)
                              : Icon(Icons.image_not_supported),
                          title: Text(titre),
                          subtitle: Text('Taille : $taille\nPrix : $prix€'),
                          trailing: IconButton(
                            icon: Icon(Icons.remove_circle_outline),
                            onPressed: () => _retirerDuPanier(context, vetementId),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Total : $total€',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _retirerDuPanier(BuildContext context, String vetementId) async {
    try {
      final panierRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .collection('panier');

      final snapshot = await panierRef.where('vetementId', isEqualTo: vetementId).get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.delete();
        setState(() {
          // On met à jour l'interface après avoir retiré l'article
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Produit retiré du panier')));
      }
    } catch (e) {
      print('Erreur lors du retrait du produit : $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors du retrait du produit')));
    }
  }
}
