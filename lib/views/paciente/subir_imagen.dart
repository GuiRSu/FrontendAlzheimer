import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'diagnostico.dart';

class SubirImagen extends StatefulWidget {
  @override
  _SubirImagenState createState() => _SubirImagenState();
}

class _SubirImagenState extends State<SubirImagen> {
  File? _imagen;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imagen = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Subir Imagen Médica")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _imagen == null
                        ? Column(
                            children: [
                              Icon(Icons.image, size: 120, color: Colors.grey),
                              Text(
                                "Selecciona una imagen MRI o CT scan para análisis",
                              ),
                            ],
                          )
                        : Image.file(_imagen!, height: 200),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: Icon(Icons.photo),
                      label: Text("Galería"),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: Icon(Icons.camera_alt),
                      label: Text("Cámara"),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _imagen != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PantallaResultadoDiagnostico(
                                    imagen: _imagen!,
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: Text("Analizar"),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Recomendaciones",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "• Asegúrate de que la imagen sea clara y de alta resolución",
                    ),
                    Text("• Los formatos compatibles: JPEG, PNG, DICOM"),
                    Text("• El análisis puede tomar 2-5 minutos"),
                    Text("• Los resultados serán validados por un médico"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
