# Módulo de Citas - Frontend Alzheimer

## 📁 Estructura de Archivos

```
lib/
├── data/
│   ├── models/
│   │   └── cita_model.dart          # Modelos de datos para citas
│   └── providers/
│       └── citas_provider.dart      # Provider con lógica de negocio
├── features/
│   └── citas/
│       ├── gestion_citas.dart       # Vista principal - Lista de citas
│       ├── formulario_cita.dart     # Formulario crear/editar cita
│       └── detalle_cita.dart        # Vista detalle de cita
└── core/
    └── services/
        └── api_service.dart         # Métodos HTTP actualizados
```

## 🎯 Funcionalidades Implementadas

### 1. **Modelos de Datos** (`cita_model.dart`)

#### CitaModel
- Representa una cita completa con toda su información
- Propiedades: id, paciente_id, medico_id, fecha_hora, estado, motivo, notas, etc.
- Métodos helper: `pacienteNombreCompleto`, `medicoNombreCompleto`, `estadoFormatted`
- Métodos de serialización: `fromJson()`, `toJson()`

#### CitaCreateRequest
- Modelo para crear nuevas citas
- Validaciones: motivo (10-1000 chars), fecha futura

#### CitaUpdateRequest
- Modelo para actualizar citas existentes
- Solo permite actualizar: fecha_hora, hospital_id, motivo, notas

#### CitaCambiarEstadoRequest
- Modelo para cambiar el estado de una cita
- Estados: programada, completada, cancelada, reprogramada

#### MedicoModel
- Información del médico
- Propiedades: id, nombre, apellido, especialidad, cmp, hospital_afiliacion

#### DisponibilidadResponse & HorarioDisponible
- Modelos para consultar disponibilidad de médicos
- Horarios de 9:00 a 17:00

---

### 2. **Provider** (`citas_provider.dart`)

#### Estado Gestionado
```dart
List<CitaModel> _citas
List<MedicoModel> _medicos
DisponibilidadResponse? _disponibilidad
CitaModel? _citaSeleccionada
int _total, _totalPages
bool _isLoading
String _errorMessage
```

#### Métodos Disponibles

##### `cargarCitas()`
Obtiene lista de citas con filtros y paginación
```dart
await provider.cargarCitas(
  medicoId: 1,
  estado: 'programada',
  fechaDesde: '2025-11-20',
  page: 1,
  limit: 10,
);
```

##### `cargarMedicos()`
Obtiene lista de médicos disponibles
```dart
await provider.cargarMedicos(especialidad: 'Neurología');
```

##### `crearCita()`
Crea una nueva cita
```dart
final citaRequest = CitaCreateRequest(
  pacienteId: 1,
  medicoId: 2,
  fechaHora: DateTime.now().add(Duration(days: 1)),
  motivo: 'Consulta de control',
);
final resultado = await provider.crearCita(citaRequest);
```

##### `obtenerCita()`
Obtiene detalles de una cita específica
```dart
await provider.obtenerCita(citaId);
```

##### `actualizarCita()`
Actualiza una cita existente (solo si está programada)
```dart
final citaUpdate = CitaUpdateRequest(
  fechaHora: nuevaFecha,
  motivo: 'Nuevo motivo',
);
await provider.actualizarCita(citaId, citaUpdate);
```

##### `cambiarEstadoCita()`
Cambia el estado de una cita
```dart
final estadoData = CitaCambiarEstadoRequest(
  estado: 'completada',
  motivoCambio: 'Consulta realizada',
);
await provider.cambiarEstadoCita(citaId, estadoData);
```

##### `eliminarCita()`
Elimina una cita (solo si está programada)
```dart
await provider.eliminarCita(citaId);
```

##### `verificarDisponibilidad()`
Verifica horarios disponibles de un médico
```dart
await provider.verificarDisponibilidad(
  medicoId,
  '2025-11-20',
  hospitalId: 1,
);
```

---

### 3. **Vistas**

#### 📋 GestionCitas (`gestion_citas.dart`)
Vista principal con lista de citas

**Características:**
- ✅ Filtros avanzados (médico, estado, fecha)
- ✅ Paginación
- ✅ Cards visuales con colores por estado
- ✅ Búsqueda y limpieza de filtros
- ✅ Botón flotante para crear nueva cita
- ✅ Tap en card para ver detalle

**Estados de Cita:**
- 🔵 **Programada** - Azul
- 🟢 **Completada** - Verde
- 🔴 **Cancelada** - Rojo
- 🟠 **Reprogramada** - Naranja

---

#### ➕ FormularioCita (`formulario_cita.dart`)
Formulario para crear o editar citas

**Características:**
- ✅ Modo dual: crear nueva / editar existente
- ✅ Selector de médico con especialidad
- ✅ Selector de fecha (DatePicker)
- ✅ Verificación de disponibilidad en tiempo real
- ✅ Selector visual de horarios disponibles (chips)
- ✅ Campo de motivo (min 10 caracteres)
- ✅ Campo de notas opcionales
- ✅ Validación completa de formulario

**Flujo de Uso:**
1. Seleccionar médico
2. Seleccionar fecha
3. Sistema carga horarios disponibles
4. Usuario selecciona hora
5. Completar motivo y notas
6. Guardar

**Validaciones:**
- Médico requerido
- Fecha y hora requeridas
- Fecha debe ser futura
- Motivo: 10-1000 caracteres (opcional)
- Notas: máximo 2000 caracteres

---

#### 🔍 DetalleCita (`detalle_cita.dart`)
Vista detallada de una cita

**Características:**
- ✅ Información completa de la cita
- ✅ Indicador visual de estado
- ✅ Información de paciente, médico y hospital
- ✅ Botón editar (solo para citas programadas)
- ✅ Botón cambiar estado con diálogo de confirmación
- ✅ Botón eliminar (solo para citas programadas)
- ✅ Timestamps de creación y actualización

**Acciones Disponibles:**
- **Editar**: Solo citas programadas
- **Cambiar Estado**: Todas las citas
- **Eliminar**: Solo citas programadas

---

### 4. **API Service** (`api_service.dart`)

Métodos HTTP agregados:

```dart
// PUT - Actualizar recurso completo
static Future<http.Response> put(String endpoint, Map<String, dynamic> data)

// PATCH - Actualizar recurso parcialmente
static Future<http.Response> patch(String endpoint, Map<String, dynamic> data)

// DELETE - Eliminar recurso
static Future<http.Response> delete(String endpoint)
```

---

## 🔌 Integración con Backend

### Endpoints Utilizados

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/citas` | Lista de citas con filtros |
| POST | `/api/citas` | Crear nueva cita |
| GET | `/api/citas/{id}` | Obtener cita específica |
| PUT | `/api/citas/{id}` | Actualizar cita |
| PATCH | `/api/citas/{id}/estado` | Cambiar estado |
| DELETE | `/api/citas/{id}` | Eliminar cita |
| GET | `/api/citas/medico/{id}/disponibilidad` | Ver disponibilidad |
| GET | `/api/medicos` | Lista de médicos |

---

## 📱 Uso en la Aplicación

### 1. Registrar el Provider

```dart
// main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => CitasProvider()),
    // ... otros providers
  ],
  child: MyApp(),
)
```

### 2. Navegar a Gestión de Citas

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const GestionCitas()),
);
```

### 3. Crear Cita con Paciente Predeterminado

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => FormularioCita(
      pacienteIdPredeterminado: pacienteId,
    ),
  ),
);
```

---

## 🎨 Personalización de Estilos

Los colores de estado se pueden personalizar en `gestion_citas.dart`:

```dart
Color _getColorPorEstado(String estado) {
  switch (estado) {
    case 'programada': return Colors.blue;
    case 'completada': return Colors.green;
    case 'cancelada': return Colors.red;
    case 'reprogramada': return Colors.orange;
    default: return Colors.grey;
  }
}
```

---

## 🔐 Control de Acceso

El backend controla automáticamente:
- **Pacientes**: Solo ven sus propias citas
- **Médicos**: Solo ven citas asignadas a ellos
- **Administradores**: Ven todas las citas

---

## 🧪 Pruebas Recomendadas

### Casos de Prueba

1. **Crear Cita**
   - Con todos los campos
   - Solo campos requeridos
   - Validar fecha futura
   - Validar disponibilidad

2. **Editar Cita**
   - Cambiar fecha y hora
   - Actualizar motivo
   - Solo citas programadas

3. **Cambiar Estado**
   - Programada → Completada
   - Programada → Cancelada
   - Con y sin motivo

4. **Eliminar Cita**
   - Solo programadas
   - Confirmar diálogo

5. **Filtros**
   - Por médico
   - Por estado
   - Por fecha
   - Combinación de filtros

6. **Paginación**
   - Navegar páginas
   - Mantener filtros

---

## 🚀 Mejoras Futuras

### Sugerencias de Funcionalidades

1. **Notificaciones**
   - Recordatorios de citas próximas
   - Notificación de cambio de estado

2. **Calendario Visual**
   - Vista de calendario mensual
   - Vista de agenda semanal

3. **Historial de Cambios**
   - Registro de modificaciones
   - Auditoría de estados

4. **Exportación**
   - Exportar lista a PDF
   - Exportar a Excel

5. **Búsqueda Avanzada**
   - Búsqueda por texto
   - Filtro por rango de fechas

6. **Estadísticas**
   - Citas por médico
   - Tasa de asistencia
   - Gráficos de tendencias

---

## 📝 Notas Técnicas

### Validaciones Backend vs Frontend

| Validación | Backend | Frontend |
|------------|---------|----------|
| Fecha futura | ✅ | ✅ |
| Motivo 10+ chars | ✅ | ✅ |
| Duplicados | ✅ | ⚠️ Mensaje |
| Médico existe | ✅ | - |
| Paciente existe | ✅ | - |

### Manejo de Errores

Todos los métodos del provider:
- Capturan excepciones
- Establecen `_errorMessage`
- Retornan valores seguros (null/false)
- Notifican a listeners

---

## 🐛 Troubleshooting

### Problema: No se cargan las citas
**Solución**: Verificar token de autenticación y conexión con backend

### Problema: No aparecen horarios disponibles
**Solución**: Verificar que el médico y fecha estén seleccionados

### Problema: No se puede editar cita
**Solución**: Solo citas con estado "programada" se pueden editar

### Problema: Error al crear cita
**Solución**: Verificar que el horario no esté ocupado

---

## 📞 Soporte

Para problemas o preguntas sobre el módulo de citas, contactar al equipo de desarrollo.

**Versión**: 1.0.0  
**Última actualización**: 19 de Noviembre, 2025

