import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert'; // Pour la conversion en base64
import 'dart:html' as html; // Import spécifique pour Flutter Web

class AjouterVetementPage extends StatefulWidget {
  @override
  _AjouterVetementPageState createState() => _AjouterVetementPageState();
}

class _AjouterVetementPageState extends State<AjouterVetementPage> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _tailleController = TextEditingController();
  final TextEditingController _marqueController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _categorie;
  XFile? _image;
  String? _imageBase64;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    _image = await _picker.pickImage(source: ImageSource.gallery);

    if (_image != null) {
      // Lecture des données de l'image directement en base64 pour Flutter Web
      final bytes = await _image!.readAsBytes();
      _imageBase64 = 'data:image/webp;base64,' + base64Encode(bytes);

      setState(() {
        _categorie = 'Pantalon';
        print("Image sélectionnée et convertie en base64");
      });
    } else {
      print("Aucune image sélectionnée");
    }
  }

  void _ajouterVetement() async {
    // Définir la description à une chaîne vide
    _descriptionController.text = '';

    if (_nomController.text.isNotEmpty &&
        _tailleController.text.isNotEmpty &&
        _marqueController.text.isNotEmpty &&
        _prixController.text.isNotEmpty &&
        _categorie != null &&
        _imageBase64 != null) {
      await FirebaseFirestore.instance.collection('vetements').add({
        'nom': _nomController.text,
        'description': _descriptionController.text, // Ajouter la description vide
        'categorie': _categorie,
        'taille': _tailleController.text,
        'marque': _marqueController.text,
        'prix': double.tryParse(_prixController.text) ?? 0.0,
        'imageUrl': _imageBase64,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vêtement ajouté avec succès')),
      );
      Navigator.of(context).pop();
    } else {
      print('Champs manquants ou image non sélectionnée');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs et ajouter une image')),
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
                controller: _nomController,
                decoration: InputDecoration(labelText: 'Nom'),
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