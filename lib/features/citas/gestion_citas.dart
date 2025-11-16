import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/providers/citas_provider.dart';

class GestionCitas extends StatefulWidget {
  const GestionCitas({super.key});

  @override
  State<GestionCitas> createState() => _GestionCitasState();
}

class _GestionCitasState extends State<GestionCitas> {
  final TextEditingController _fechaController = TextEditingController();
  int? _medicoSeleccionado;
  String _filtroEstado = 'todos';
  int _currentPage = 1;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  void _cargarDatosIniciales() {
    final provider = Provider.of<CitasProvider>(context, listen: false);
    provider.cargarCitas(page: _currentPage, limit: _limit);
    provider.cargarMedicos();
  }

  void _aplicarFiltros() {
    _currentPage = 1;
    final provider = Provider.of<CitasProvider>(context, listen: false);
    provider.cargarCitas(
      medicoId: _medicoSeleccionado,
      estado: _filtroEstado == 'todos' ? null : _filtroEstado,
      fechaDesde: _fechaController.text.isEmpty ? null : _fechaController.text,
      page: _currentPage,
      limit: _limit,
    );
  }

  void _limpiarFiltros() {
    _medicoSeleccionado = null;
    _filtroEstado = 'todos';
    _fechaController.clear();
    _currentPage = 1;
    _cargarDatosIniciales();
  }

  @override
  Widget build(BuildContext context) {
    final citasProvider = Provider.of<CitasProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Citas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _mostrarDialogoCrearCita,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          _buildFiltros(citasProvider),
          const SizedBox(height: 8),

          // Lista de citas
          Expanded(child: _buildListaCitas(citasProvider)),
        ],
      ),
    );
  }

  Widget _buildFiltros(CitasProvider provider) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    value: _medicoSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Médico',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Todos los médicos'),
                      ),
                      ...provider.medicos.map((medico) {
                        return DropdownMenuItem(
                          value: medico['id'],
                          child: Text(
                            'Dr. ${medico['nombre']} ${medico['apellido']}',
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _medicoSeleccionado = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filtroEstado,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'todos', child: Text('Todos')),
                      DropdownMenuItem(
                        value: 'programada',
                        child: Text('Programada'),
                      ),
                      DropdownMenuItem(
                        value: 'completada',
                        child: Text('Completada'),
                      ),
                      DropdownMenuItem(
                        value: 'cancelada',
                        child: Text('Cancelada'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filtroEstado = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fechaController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha',
                      hintText: 'YYYY-MM-DD',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () => _seleccionarFecha(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _aplicarFiltros,
                          icon: const Icon(Icons.search),
                          label: const Text('Filtrar'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _limpiarFiltros,
                        icon: const Icon(Icons.clear),
                        label: const Text('Limpiar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaCitas(CitasProvider provider) {
    if (provider.isLoading && provider.citas.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.citas.isEmpty) {
      return const Center(child: Text('No se encontraron citas'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '${provider.citas.length} citas encontradas',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: provider.citas.length,
            itemBuilder: (context, index) {
              final cita = provider.citas[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getColorPorEstado(cita['estado']),
                    child: Icon(
                      _getIconPorEstado(cita['estado']),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    '${cita['paciente_nombre']} ${cita['paciente_apellido']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Médico: Dr. ${cita['medico_nombre']} ${cita['medico_apellido']}',
                      ),
                      Text(
                        'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(cita['fecha_hora']))}',
                      ),
                      Text('Estado: ${_capitalizar(cita['estado'])}'),
                      if (cita['motivo'] != null)
                        Text('Motivo: ${cita['motivo']}'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (accion) => _manejarAccionCita(accion, cita),
                    itemBuilder: (context) => _buildMenuCitas(cita['estado']),
                  ),
                ),
              );
            },
          ),
        ),

        // Paginación
        _buildPaginacion(provider),
      ],
    );
  }

  List<PopupMenuEntry<String>> _buildMenuCitas(String estado) {
    final menuItems = <PopupMenuEntry<String>>[];

    menuItems.add(
      const PopupMenuItem(
        value: 'detalle',
        child: ListTile(leading: Icon(Icons.info), title: Text('Ver Detalle')),
      ),
    );

    if (estado == 'programada') {
      menuItems.add(
        const PopupMenuItem(
          value: 'reprogramar',
          child: ListTile(
            leading: Icon(Icons.schedule),
            title: Text('Reprogramar'),
          ),
        ),
      );
      menuItems.add(
        const PopupMenuItem(
          value: 'cancelar',
          child: ListTile(leading: Icon(Icons.cancel), title: Text('Cancelar')),
        ),
      );
    }

    if (estado == 'programada' || estado == 'reprogramada') {
      menuItems.add(
        const PopupMenuItem(
          value: 'completar',
          child: ListTile(
            leading: Icon(Icons.check_circle),
            title: Text('Marcar Completada'),
          ),
        ),
      );
    }

    return menuItems;
  }

  void _manejarAccionCita(String accion, Map<String, dynamic> cita) {
    switch (accion) {
      case 'detalle':
        _mostrarDetalleCita(cita);
        break;
      case 'reprogramar':
        _mostrarDialogoReprogramarCita(cita);
        break;
      case 'cancelar':
        _cancelarCita(cita);
        break;
      case 'completar':
        _completarCita(cita);
        break;
    }
  }

  Widget _buildPaginacion(CitasProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _currentPage > 1
                ? () {
                    _currentPage--;
                    _aplicarFiltros();
                  }
                : null,
          ),
          Text('Página $_currentPage'),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: provider.citas.length == _limit
                ? () {
                    _currentPage++;
                    _aplicarFiltros();
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Color _getColorPorEstado(String estado) {
    switch (estado) {
      case 'programada':
        return Colors.blue;
      case 'completada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconPorEstado(String estado) {
    switch (estado) {
      case 'programada':
        return Icons.schedule;
      case 'completada':
        return Icons.check_circle;
      case 'cancelada':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1);
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      _fechaController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _mostrarDialogoCrearCita() {
    // Implementar diálogo para crear nueva cita
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Cita'),
        content: const Text('Funcionalidad en desarrollo...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDetalleCita(Map<String, dynamic> cita) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalle de Cita'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paciente: ${cita['paciente_nombre']} ${cita['paciente_apellido']}',
              ),
              Text(
                'Médico: Dr. ${cita['medico_nombre']} ${cita['medico_apellido']}',
              ),
              Text(
                'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(cita['fecha_hora']))}',
              ),
              Text('Estado: ${_capitalizar(cita['estado'])}'),
              if (cita['motivo'] != null) Text('Motivo: ${cita['motivo']}'),
              if (cita['notas'] != null) Text('Notas: ${cita['notas']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoReprogramarCita(Map<String, dynamic> cita) {
    // Implementar reprogramación de cita
  }

  void _cancelarCita(Map<String, dynamic> cita) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Cita'),
        content: const Text('¿Estás seguro de que quieres cancelar esta cita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              // Lógica para cancelar cita
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Cita cancelada')));
            },
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }

  void _completarCita(Map<String, dynamic> cita) {
    // Lógica para marcar cita como completada
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cita marcada como completada')),
    );
  }
}
