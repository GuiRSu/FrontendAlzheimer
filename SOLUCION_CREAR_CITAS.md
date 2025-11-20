# 🔧 Solución al Problema de Creación de Citas

## 🎯 Problema Identificado

Al intentar crear una cita, no pasaba nada porque el frontend no estaba enviando el `paciente_id` requerido por el backend.

## ✅ Cambios Realizados

### 1. **BACKEND** (C:\Users\Lenovo\Desktop\BackendAlzheimer\app)

#### a) Actualizado `schemas/usuario.py`
Agregados campos para IDs de perfil:
```python
class UsuarioResponse(UsuarioBase):
    # ...campos existentes...
    
    # IDs de perfil específico
    paciente_id: Optional[int] = None
    medico_id: Optional[int] = None
    admin_id: Optional[int] = None
```

#### b) Actualizado `routers/auth.py`
Endpoint `/api/auth/me` ahora retorna los IDs de perfil:
```python
@router.get("/me", response_model=UsuarioResponse)
async def read_users_me(...):
    paciente_id = None
    medico_id = None
    admin_id = None
    
    if current_user.tipo_usuario == "paciente":
        paciente_id = current_user.paciente.id
        # ...
    
    return UsuarioResponse(
        # ...campos existentes...
        paciente_id=paciente_id,
        medico_id=medico_id,
        admin_id=admin_id
    )
```

---

### 2. **FRONTEND** (C:\Users\Lenovo\StudioProjects\FrontendAlzheimer)

#### a) Actualizado `lib/data/models/auth_model.dart`
Agregados campos al modelo UserResponse:
```dart
class UserResponse {
  // ...campos existentes...
  final int? pacienteId;
  final int? medicoId;
  final int? adminId;
}
```

#### b) Actualizado `lib/data/providers/auth_provider.dart`
El AuthProvider ahora guarda y carga los IDs de perfil:
```dart
class AuthProvider with ChangeNotifier {
  int? _pacienteId;
  int? _medicoId;
  int? _adminId;
  
  int? get pacienteId => _pacienteId;
  int? get medicoId => _medicoId;
  int? get adminId => _adminId;
}
```

#### c) Actualizado `lib/features/citas/formulario_cita.dart`
Ahora obtiene el pacienteId del AuthProvider:
```dart
void _inicializarPacienteId() {
  if (_pacienteId == null && widget.cita == null) {
    Future.microtask(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.pacienteId != null) {
        setState(() {
          _pacienteId = authProvider.pacienteId;
        });
      }
    });
  }
}
```

---

## 🚀 PASOS PARA APLICAR LA SOLUCIÓN

### **PASO 1: Reiniciar el Backend**

Abre una terminal en `C:\Users\Lenovo\Desktop\BackendAlzheimer` y ejecuta:

```bash
# Detener el servidor si está corriendo (Ctrl+C)

# Reiniciar el servidor
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

O si usas un script de inicio, simplemente reinicia el servidor.

---

### **PASO 2: Cerrar Sesión y Volver a Iniciar**

En la aplicación Flutter:

1. **Cerrar sesión** del usuario actual
2. **Volver a iniciar sesión**

Esto es CRUCIAL porque:
- El nuevo endpoint `/api/auth/me` ahora retorna `paciente_id`
- El AuthProvider necesita cargar este nuevo dato
- Los datos antiguos en SharedPreferences no tienen el `paciente_id`

---

### **PASO 3: Probar Crear una Cita**

1. Ir al **Dashboard del Paciente**
2. Click en **"Nueva Cita"** o **"Agendar Nueva Cita"**
3. Seleccionar un médico
4. Seleccionar una fecha
5. Seleccionar un horario disponible
6. (Opcional) Agregar motivo y notas
7. Click en **"Crear Cita"**

---

## 🔍 DEBUGGING

Si aún no funciona, revisa los logs en la consola:

### Logs del Frontend (Flutter):
```
🔍 DEBUG: Iniciando _guardarCita
🔍 DEBUG: _pacienteId = 1          ← DEBE tener un valor
🔍 DEBUG: _medicoId = 2
🔍 DEBUG: _fechaSeleccionada = ...
🔍 DEBUG: _horaSeleccionada = 10:00
✅ DEBUG: CitaRequest creado:
   - pacienteId: 1
   - medicoId: 2
   - fechaHora: ...
📤 DEBUG: Enviando solicitud al backend...
📥 DEBUG: Respuesta recibida: Éxito
   - Cita ID: 5
```

### Si `_pacienteId` es NULL:
Significa que no se cargó correctamente desde el AuthProvider.

**Solución:**
1. Cerrar sesión
2. Volver a iniciar sesión (esto llamará al nuevo endpoint `/api/auth/me`)
3. Intentar crear cita nuevamente

---

## 📋 VERIFICACIÓN RÁPIDA

### Backend está actualizado si:
```bash
# Verificar endpoint /api/auth/me
curl -H "Authorization: Bearer TU_TOKEN" http://localhost:8000/api/auth/me
```

Debe retornar:
```json
{
  "id": 1,
  "username": "paciente1",
  "tipo_usuario": "paciente",
  "paciente_id": 5,    ← NUEVO
  "medico_id": null,
  "admin_id": null,
  "nombre": "Juan",
  ...
}
```

### Frontend está actualizado si:
Al hacer login, el AuthProvider debe imprimir:
```
Datos guardados:
- pacienteId: 5  ← NUEVO
```

---

## ❌ POSIBLES ERRORES

### Error 1: "No se pudo obtener el ID del paciente"
**Causa:** El usuario inició sesión antes de los cambios
**Solución:** Cerrar sesión y volver a iniciar

### Error 2: Backend retorna 400 "Paciente no encontrado"
**Causa:** El pacienteId no existe en la base de datos
**Solución:** Verificar que el usuario tenga un registro en la tabla `paciente`

### Error 3: Backend retorna 500 Internal Server Error
**Causa:** Error en el código del backend
**Solución:** Revisar logs del backend, puede ser que el modelo `Usuario` no tenga la relación `paciente` cargada

---

## 🎉 RESULTADO ESPERADO

Al crear una cita exitosamente, deberías ver:

1. **Snackbar verde:** "Cita creada exitosamente"
2. **Navegación:** Regresa al dashboard
3. **Dashboard actualizado:** La nueva cita aparece en "Mis Próximas Citas"
4. **En la base de datos:** Nueva fila en la tabla `cita` con:
   - `paciente_id` = ID del paciente actual
   - `medico_id` = ID del médico seleccionado
   - `fecha_hora` = Fecha y hora seleccionadas
   - `estado` = "programada"

---

## 📞 SI SIGUE SIN FUNCIONAR

1. **Revisa los logs del backend** para ver si llega la petición
2. **Revisa los logs del frontend** para ver qué valor tiene `_pacienteId`
3. **Verifica que el backend se reinició** después de los cambios
4. **Asegúrate de haber cerrado sesión y vuelto a iniciar** después de los cambios
5. **Verifica la conexión** entre frontend y backend (que esté usando la URL correcta)

---

**Fecha de implementación:** 19 de Noviembre, 2025
**Estado:** ✅ Cambios completados, requiere reinicio de backend y re-login

