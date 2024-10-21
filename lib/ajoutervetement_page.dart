import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class AjouterVetementPage extends StatefulWidget {
  @override
  _AjouterVetementPageState createState() => _AjouterVetementPageState();
}

class _AjouterVetementPageState extends State<AjouterVetementPage> {
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _tailleController = TextEditingController();
  final TextEditingController _marqueController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  String? _categorie; // Catégorie qui sera définie lors du téléchargement de l'image
  XFile? _image; // Pour stocker l'image sélectionnée

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    // Afficher un sélecteur d'image et obtenir le fichier
    _image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      // Définir la catégorie en fonction de l'image téléchargée (ajustez ceci selon vos besoins)
      _categorie = 'Pantalon'; // Exemple statique ; à modifier selon la logique de votre application
    });
  }

  void _ajouterVetement() async {
    if (_titreController.text.isNotEmpty &&
        _tailleController.text.isNotEmpty &&
        _marqueController.text.isNotEmpty &&
        _prixController.text.isNotEmpty &&
        _categorie != null &&
        _image != null) {
      // Ajouter le vêtement à Firestore
      await FirebaseFirestore.instance.collection('vetements').add({
        'titre': _titreController.text,
        'categorie': _categorie, // Défini après le téléchargement de l'image
        'taille': _tailleController.text,
        'marque': _marqueController.text,
        'prix': double.tryParse(_prixController.text) ?? 0.0,
        // Ajouter d'autres champs nécessaires, par exemple pour l'image
        'imageURL': _image!.path, // Utilisez une méthode d'upload si nécessaire
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vêtement ajouté avec succès')),
      );

      Navigator.of(context).pop(); // Retour à la page de profil
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un Vêtement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titreController,
                decoration: InputDecoration(labelText: 'Titre'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _tailleController,
                decoration: InputDecoration(labelText: 'Taille'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _marqueController,
                decoration: InputDecoration(labelText: 'Marque'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _prixController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Prix'),
              ),
              SizedBox(height: 16),
              // Bouton pour uploader une image
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Télécharger une Image'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _ajouterVetement,
                child: Text('Valider'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
