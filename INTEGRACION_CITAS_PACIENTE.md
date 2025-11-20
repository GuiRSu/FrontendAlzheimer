# Integración del Módulo de Citas en Dashboard Paciente

## 🎯 Cambios Realizados

### 1. **Sidebar (Custom Drawer)** ✅
**Archivo**: `lib/core/widgets/custom_drawer.dart`

Se agregó la opción **"Mis Citas"** en el menú lateral para pacientes:

```dart
_buildDrawerItem(
  icon: Icons.calendar_today,
  title: 'Mis Citas',
  onTap: () {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GestionCitas()),
    );
  },
),
```

**Ubicación en el menú:**
- 📤 Subir Imagen
- 📋 Historial de Diagnósticos
- 📅 **Mis Citas** ← NUEVO

---

### 2. **Dashboard Paciente** ✅
**Archivo**: `lib/features/paciente/dashboard_paciente.dart`

#### Cambios principales:

##### a) Convertido a StatefulWidget
- Ahora puede cargar datos dinámicamente
- Implementa `initState()` para cargar citas al inicio

##### b) Card "Mis Próximas Citas"
Nueva sección que muestra:
- ✅ Próximas 3 citas programadas
- ✅ Información del médico
- ✅ Fecha y hora formateadas
- ✅ Estado visual con colores
- ✅ Botón "Nueva Cita"
- ✅ Botón "Ver Todas"
- ✅ Botón refrescar
- ✅ Click en cita para ver detalle

##### c) Estados visuales
```
🔵 Programada  - Azul
🟢 Completada  - Verde
🔴 Cancelada   - Rojo
🟠 Reprogramada - Naranja
```

---

## 📱 Interfaz del Usuario

### Vista del Dashboard Paciente

```
┌────────────────────────────────────────┐
│ ☰ Panel Paciente              🔔      │
├────────────────────────────────────────┤
│                                         │
│ Hola, [Nombre del Paciente]           │
│ Bienvenido a tu panel de control      │
│                                         │
│ ┌──────────────────────────────────┐  │
│ │ 📅 Mis Próximas Citas        🔄  │  │
│ ├──────────────────────────────────┤  │
│ │                                   │  │
│ │ ┌─────────────────────────────┐  │  │
│ │ │ 👨‍⚕️ Dr. García               │  │  │
│ │ │ 📅 Lunes, 20 Nov 2025        │  │  │
│ │ │ ⏰ 10:00      🔵 Programada  │  │  │
│ │ └─────────────────────────────┘  │  │
│ │                                   │  │
│ │ ┌─────────────────────────────┐  │  │
│ │ │ 👨‍⚕️ Dra. López              │  │  │
│ │ │ 📅 Miércoles, 22 Nov 2025    │  │  │
│ │ │ ⏰ 14:30      🔵 Programada  │  │  │
│ │ └─────────────────────────────┘  │  │
│ │                                   │  │
│ │ [➕ Nueva Cita] [📋 Ver Todas]  │  │
│ └───────────────────────────────────┘  │
│                                         │
│ ┌──────────────────────────────────┐  │
│ │ 🔬 Nuevo Diagnóstico            │  │
│ │ Sube una imagen médica...       │  │
│ │ [📤 Subir Imagen]               │  │
│ └──────────────────────────────────┘  │
└────────────────────────────────────────┘
```

---

## 🔄 Flujos de Usuario

### 1. Agendar Nueva Cita
```
Dashboard → Botón "Nueva Cita" → FormularioCita
                                       ↓
                              Seleccionar médico
                                       ↓
                              Seleccionar fecha
                                       ↓
                         Ver horarios disponibles
                                       ↓
                            Seleccionar horario
                                       ↓
                           Llenar motivo/notas
                                       ↓
                                   Guardar
                                       ↓
                         Regresar al Dashboard ✅
```

### 2. Ver Detalle de Cita
```
Dashboard → Click en cita → DetalleCita
                                 ↓
                    Ver información completa
                                 ↓
              Opciones: Editar / Cambiar Estado / Eliminar
```

### 3. Ver Todas las Citas
```
Dashboard → Botón "Ver Todas" → GestionCitas
                                      ↓
                              Lista completa
                                      ↓
                    Filtrar por médico/estado/fecha
                                      ↓
                              Paginación
```

---

## 📋 Funcionalidades Implementadas

### En el Dashboard:
- ✅ Cargar automáticamente próximas citas al iniciar
- ✅ Mostrar hasta 3 citas próximas
- ✅ Indicadores visuales de estado
- ✅ Botón para crear nueva cita
- ✅ Botón para ver todas las citas
- ✅ Botón de actualizar
- ✅ Click en cita para ver detalle
- ✅ Mensaje cuando no hay citas
- ✅ Loading spinner mientras carga

### En el Sidebar:
- ✅ Acceso directo a "Mis Citas"
- ✅ Visible solo para pacientes
- ✅ Navegación completa al módulo de gestión

---

## 🎨 Diseño y Experiencia

### Colores de Estado
```dart
Programada:    Colors.blue
Completada:    Colors.green
Cancelada:     Colors.red
Reprogramada:  Colors.orange
```

### Formato de Fechas
- **Fecha completa**: "Lunes, 20 Noviembre 2025"
- **Hora**: "10:00"
- **Locale**: Español ('es')

---

## 🔧 Detalles Técnicos

### Provider Utilizado
```dart
CitasProvider
- cargarCitas(estado: 'programada', fechaDesde: hoy, limit: 3)
- Automático al iniciar el dashboard
- Recarga después de crear/editar/eliminar cita
```

### Navegación
```dart
// Crear cita
Navigator.push(context, MaterialPageRoute(
  builder: (_) => const FormularioCita()
));

// Ver todas
Navigator.push(context, MaterialPageRoute(
  builder: (_) => const GestionCitas()
));

// Ver detalle
Navigator.push(context, MaterialPageRoute(
  builder: (_) => DetalleCita(citaId: cita.id)
));
```

---

## 🧪 Pruebas Sugeridas

### Casos de Prueba:

1. **Dashboard sin citas**
   - ✅ Debe mostrar mensaje "No tienes citas programadas"
   - ✅ Debe mostrar botón "Agendar Nueva Cita"

2. **Dashboard con citas**
   - ✅ Debe mostrar máximo 3 citas
   - ✅ Debe ordenar por fecha más próxima
   - ✅ Colores según estado

3. **Botón Nueva Cita**
   - ✅ Abre formulario de cita
   - ✅ Después de crear, regresa y actualiza

4. **Botón Ver Todas**
   - ✅ Navega a GestionCitas
   - ✅ Muestra todas las citas del paciente

5. **Click en cita**
   - ✅ Abre detalle completo
   - ✅ Permite editar/cancelar

6. **Sidebar**
   - ✅ "Mis Citas" visible para pacientes
   - ✅ Navega correctamente
   - ✅ No visible para doctor/admin

---

## 📝 Notas Importantes

### Filtros Automáticos
El dashboard carga automáticamente:
- ✅ Solo citas con estado "programada"
- ✅ Solo citas desde hoy en adelante
- ✅ Limitado a 3 resultados
- ✅ Ordenadas por fecha más próxima

### Actualización Automática
El dashboard se actualiza automáticamente cuando:
- ✅ Se crea una nueva cita
- ✅ Se edita una cita existente
- ✅ Se elimina una cita
- ✅ Se cambia el estado de una cita
- ✅ Se presiona el botón refrescar

---

## 🚀 Próximas Mejoras Sugeridas

### Opcionales:
1. **Notificaciones**
   - Recordatorio 24h antes de la cita
   - Notificación cuando se crea/modifica cita

2. **Widget de Calendario**
   - Vista de calendario mensual
   - Indicadores visuales de días con citas

3. **Contador de Citas**
   - Badge con número de citas pendientes
   - En el ícono del sidebar

4. **Filtro Rápido**
   - Toggle para ver solo citas de hoy
   - Toggle para ver citas de esta semana

5. **Acciones Rápidas**
   - Botón de cancelación rápida
   - Botón de confirmación rápida

---

## ✅ Resumen de Archivos Modificados

```
✏️ lib/features/paciente/dashboard_paciente.dart
   - Convertido a StatefulWidget
   - Agregada carga de citas
   - Nuevo card de próximas citas
   - Métodos de navegación

✏️ lib/core/widgets/custom_drawer.dart
   - Agregada opción "Mis Citas" para pacientes
```

---

**Fecha de implementación**: 19 de Noviembre, 2025
**Estado**: ✅ Completado y Funcional
**Versión**: 1.0.0

