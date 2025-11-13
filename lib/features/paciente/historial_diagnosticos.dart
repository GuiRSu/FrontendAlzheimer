import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/diagnostico_provider.dart';
import '../../core/widgets/diagnostico_card.dart';
import 'detalle_diagnostico.dart';

class HistorialDiagnosticos extends StatefulWidget {
  const HistorialDiagnosticos({super.key});

  @override
  _HistorialDiagnosticosState createState() => _HistorialDiagnosticosState();
}

class _HistorialDiagnosticosState extends State<HistorialDiagnosticos> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _cargarHistorialInicial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _cargarHistorialInicial() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DiagnosticoProvider>(context, listen: false);
      provider.cargarHistorial();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final provider = Provider.of<DiagnosticoProvider>(context, listen: false);
      provider.cargarMasDiagnosticos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Diagnósticos'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: _testUrls,
            tooltip: 'Testear URLs',
          ),
        ],
      ),
      body: Consumer<DiagnosticoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingHistorial && provider.diagnosticos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage.isNotEmpty &&
              provider.diagnosticos.isEmpty) {
            return _buildErrorWidget(provider);
          }

          if (provider.diagnosticos.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => provider.cargarHistorial(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: provider.diagnosticos.length + 1,
              itemBuilder: (context, index) {
                if (index == provider.diagnosticos.length) {
                  return _buildLoadingMore(provider);
                }

                final diagnostico = provider.diagnosticos[index];
                return DiagnosticoCard(
                  diagnostico: diagnostico,
                  onTap: () => _verDetalleDiagnostico(context, diagnostico.id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(DiagnosticoProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error cargando historial',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            provider.errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => provider.cargarHistorial(),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No hay diagnósticos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Realiza tu primer análisis para ver el historial',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMore(DiagnosticoProvider provider) {
    if (!provider.hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'No hay más diagnósticos',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: provider.isLoadingHistorial
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () => provider.cargarMasDiagnosticos(),
                child: Text('Cargar más'),
              ),
      ),
    );
  }

  void _verDetalleDiagnostico(BuildContext context, int diagnosticoId) {
    final provider = Provider.of<DiagnosticoProvider>(context, listen: false);
    provider.limpiarDetalle(); // Limpiar detalle anterior

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalleDiagnostico(diagnosticoId: diagnosticoId),
      ),
    );
  }

  void _testUrls() {
    final provider = Provider.of<DiagnosticoProvider>(context, listen: false);

    if (provider.diagnosticos.isNotEmpty) {
      // Testear la primera imagen
      final primerDiagnostico = provider.diagnosticos.first;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Test URL Imagen'),
          content: FutureBuilder<Map<String, dynamic>>(
            future: provider.testUrlImagen(primerDiagnostico.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Testeando URL...'),
                  ],
                );
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              final result = snapshot.data!;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('URL: ${result['url']}'),
                  SizedBox(height: 10),
                  Text('Status: ${result['status_code']}'),
                  Text('Accesible: ${result['accessible']}'),
                  if (result['error'] != null)
                    Text('Error: ${result['error']}'),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar'),
            ),
            if (provider.diagnosticos.isNotEmpty)
              TextButton(
                onPressed: () {
                  // Abrir URL en navegador
                  final url = provider.diagnosticos.first.imagenOriginalUrl;
                  if (url != null && url.isNotEmpty) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('URL: $url')));
                  }
                },
                child: Text('Abrir URL'),
              ),
          ],
        ),
      );
    }
  }
}
