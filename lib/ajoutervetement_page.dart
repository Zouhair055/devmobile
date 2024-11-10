import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert'; // Pour la conversion en base64
import 'theme.dart'; // Importez le fichier theme.dart
import 'package:http/http.dart' as http;


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
    final ImagePicker picker = ImagePicker();
    _image = await picker.pickImage(source: ImageSource.gallery);

    if (_image != null) {
      // Lecture des données de l'image directement en base64 pour Flutter Web
      final bytes = await _image!.readAsBytes();
      _imageBase64 = 'data:image/webp;base64,${base64Encode(bytes)}';

      // Détecter la catégorie
      await _detectCategory(_image!); // Appelez la méthode pour détecter la catégorie
      print("Image sélectionnée et convertie en base64");
    } else {
      print("Aucune image sélectionnée");
    }
  }

  Future<void> _detectCategory(XFile image) async {
  final uri = Uri.parse('http://127.0.0.1:5000/predict'); // Utiliser l'IP locale obtenue
  final imageBytes = await image.readAsBytes(); // Lire l'image en bytes

  // Préparer la requête avec l'image en tant que fichier
  final request = http.MultipartRequest('POST', uri);
  request.files.add(http.MultipartFile.fromBytes(
    'image', 
    imageBytes,
    filename: image.name,
  ));

  try {
    final response = await request.send(); // Envoyer la requête
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final output = jsonDecode(responseBody);
      setState(() {
        _categorie = output['category']; // Extraire la catégorie du JSON retourné
      });
      print('Catégorie détectée : $_categorie');
    } else {
      print('Erreur de détection de catégorie : ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Erreur lors de l\'appel API : $e');
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
      body: Stack(
        children: [
          BackgroundWithIcons(), // Application du fond d'écran avec les icônes
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _nomController,
                      decoration: InputDecoration(labelText: 'Nom'),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _tailleController,
                      decoration: InputDecoration(labelText: 'Taille'),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _marqueController,
                      decoration: InputDecoration(labelText: 'Marque'),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _prixController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Prix'),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Télécharger une Image'),
                  ),
                  if (_categorie != null) // Afficher seulement si la catégorie est définie
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'Catégorie détectée : $_categorie',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
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
        ],
      ),
    );
  }
}