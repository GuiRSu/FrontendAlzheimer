import 'dart:io';
import 'package:flutter/material.dart';

class PantallaResultadoDiagnostico extends StatelessWidget {
  final File imagen;

  PantallaResultadoDiagnostico({required this.imagen});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Resultados del Diagnóstico")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          "Análisis Completado",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Riesgo Bajo",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("Confianza: 85%"),
                    SizedBox(height: 20),
                    _progressRow("Probabilidad de Alzheimer", 0.15),
                    _progressRow("Deterioro Cognitivo Leve", 0.08),
                    _progressRow("Estado Normal", 0.77),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              child: Column(
                children: [
                  ListTile(title: Text("Imagen Analizada")),
                  Image.file(imagen, height: 200),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.remove_red_eye),
                        label: Text("Ver Original"),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.analytics),
                        label: Text("Segmentación"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressRow(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label ${(value * 100).toStringAsFixed(0)}%"),
        LinearProgressIndicator(value: value),
        SizedBox(height: 10),
      ],
    );
  }
}
