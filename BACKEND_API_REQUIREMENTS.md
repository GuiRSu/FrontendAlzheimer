# 📋 Especificaciones del Backend - AlzheCare

Este documento detalla TODOS los endpoints y estructuras de datos que el backend debe implementar para funcionar correctamente con el frontend Flutter.

---

## 🔐 AUTENTICACIÓN

### 1. POST `/api/auth/login`
**Descripción:** Autenticar usuario y obtener token JWT

**Request Body:**
```json
{
  "username": "string",
  "password": "string"
}
```

**Response (200 OK):**
```json
{
  "access_token": "string (JWT token)",
  "token_type": "Bearer"
}
```

**Errores:**
- 401: Credenciales inválidas
- 400: Datos faltantes

---

### 2. GET `/api/auth/me`
**Descripción:** Obtener datos del usuario autenticado

**Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "username": "string",
  "tipo_usuario": "paciente|medico|admin|cuidador",
  "nombre": "string",
  "apellido": "string",
  "email": "string|null",
  "telefono": "string|null",
  "foto_perfil_url": "string|null",
  "estado": true,
  "created_at": "2024-01-01T00:00:00"
}
```

**⚠️ IMPORTANTE:** El campo `tipo_usuario` debe ser exactamente: `"paciente"`, `"medico"`, `"admin"` o `"cuidador"` (en minúsculas). El frontend lo mapea a roles con mayúscula inicial.

---

### 3. POST `/api/auth/register`
**Descripción:** Registrar nuevo usuario

**Request Body:**
```json
{
  "username": "string (requerido)",
  "password": "string (requerido)",
  "tipo_usuario": "string (requerido: paciente|medico|admin|cuidador)",
  "nombre": "string (requerido)",
  "apellido": "string (requerido)",
  "email": "string (opcional)",
  "telefono": "string (opcional)",
  "fecha_nacimiento": "string (opcional, formato: YYYY-MM-DD)",
  "genero": "string (opcional)",
  "numero_identidad": "string (opcional)",
  "direccion": "string (opcional)",
  "ciudad": "string (opcional)",
  
  // Campos específicos por tipo de usuario:
  
  // Para paciente:
  "estado_alzheimer": "string (opcional)",
  
  // Para cuidador:
  "relacion_paciente": "string (opcional)",
  
  // Para médico:
  "cmp": "string (opcional)",
  "especialidad": "string (opcional)",
  "hospital_afiliacion": "string (opcional)",
  
  // Para admin:
  "nivel_acceso": "string (opcional)",
  "permisos": "string (opcional)"
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "username": "string",
  "tipo_usuario": "string",
  "mensaje": "Usuario registrado exitosamente"
}
```

**Errores:**
- 400: Usuario ya existe o datos inválidos
- 422: Validación fallida

---

## 🧠 DIAGNÓSTICOS (Paciente)

### 4. POST `/api/diagnosticos/analizar`
**Descripción:** Analizar imagen de resonancia magnética cerebral usando IA

**Headers:**
```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Request Body (multipart/form-data):**
- `file`: archivo de imagen (JPG, PNG)

**Response (200 OK):**
```json
{
  "resultado": "Alzheimer Leve|Alzheimer Moderado|Alzheimer Severo|Normal",
  "confianza": "85.5%",
  "diagnostico_id": 123,
  "datos_roboflow": {
    // Datos adicionales del modelo de IA (opcional)
  }
}
```

**Errores:**
- 400: Archivo no válido
- 401: No autenticado
- 500: Error en el análisis

---

### 5. GET `/api/diagnosticos/historial`
**Descripción:** Obtener historial de diagnósticos del paciente autenticado

**Headers:**
```
Authorization: Bearer {token}
```

**Query Parameters (opcionales):**
- `page`: número de página (default: 1)
- `per_page`: registros por página (default: 10)

**Response (200 OK):**
```json
{
  "diagnosticos": [
    {
      "id": 1,
      "paciente_id": 1,
      "resultado": "Alzheimer Leve",
      "confianza": 0.855,
      "clase_original": "mild_demented",
      "imagen_original_url": "http://backend.com/uploads/diagnosticos/1/original.jpg",
      "imagen_procesada_url": "http://backend.com/uploads/diagnosticos/1/procesada.jpg",
      "datos_roboflow": {},
      "estado": "completado",
      "created_at": "2024-01-01T10:30:00"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 10,
    "total": 25,
    "total_pages": 3,
    "has_next": true,
    "has_prev": false
  }
}
```

**⚠️ IMPORTANTE:** 
- Las URLs de imágenes deben ser **absolutas y accesibles** desde el frontend
- El estado puede ser: `"completado"`, `"procesando"`, `"error"`

---

### 6. GET `/api/diagnosticos/detalle/{diagnostico_id}`
**Descripción:** Obtener detalle completo de un diagnóstico específico

**Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "fecha_analisis": "2024-01-01T10:30:00",
  "resultado": "Alzheimer Leve",
  "confianza": 0.855,
  "clase_original": "mild_demented",
  "imagen_original_url": "http://backend.com/uploads/diagnosticos/1/original.jpg",
  "imagen_procesada_url": "http://backend.com/uploads/diagnosticos/1/procesada.jpg",
  "estado": "completado",
  "datos_detallados": {
    "predicciones": [
      {
        "clase": "Alzheimer Leve",
        "confianza": 0.855,
        "clase_id": 1,
        "bbox": {
          "x": 100,
          "y": 100,
          "width": 200,
          "height": 200
        }
      }
    ],
    "metadatos_imagen": {
      "ancho": 512,
      "alto": 512,
      "formato": "jpg"
    },
    "estadisticas": {
      "tiempo_procesamiento": "2.5s",
      "modelo_version": "v1.0"
    }
  }
}
```

**Errores:**
- 404: Diagnóstico no encontrado
- 403: No tiene permiso para ver este diagnóstico

---

### 7. GET `/api/diagnosticos/test-url/{diagnostico_id}`
**Descripción:** Endpoint de prueba para verificar URLs de imágenes (desarrollo)

**Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "diagnostico_id": 1,
  "imagen_original_url": "string",
  "imagen_procesada_url": "string",
  "urls_accesibles": true
}
```

---

## 👨‍⚕️ MÉDICOS

### 8. GET `/api/medicos`
**Descripción:** Listar médicos disponibles (para agendar citas)

**Headers:**
```
Authorization: Bearer {token}
```

**Query Parameters (opcionales):**
- `especialidad`: filtrar por especialidad

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "nombre": "Dr. Juan Pérez",
    "especialidad": "Neurología",
    "cmp": "12345",
    "hospital_afiliacion": "Hospital Central",
    "foto_perfil_url": "string|null"
  }
]
```

---

### 9. GET `/api/medicos/mis-pacientes`
**Descripción:** Obtener lista de pacientes asignados al médico autenticado

**Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "nombre": "Juan Pérez",
    "apellido": "García",
    "email": "juan@example.com",
    "estado_alzheimer": "Leve",
    "ultimo_diagnostico": "2024-01-01T10:00:00"
  }
]
```

---

### 10. GET `/api/medico/historial-pacientes`
**Descripción:** Obtener historial de diagnósticos de los pacientes del médico

**Headers:**
```
Authorization: Bearer {token}
```

**Query Parameters (opcionales):**
- `paciente_id`: filtrar por paciente específico
- `fecha_desde`: formato YYYY-MM-DD
- `fecha_hasta`: formato YYYY-MM-DD
- `page`: número de página
- `per_page`: registros por página

**Response (200 OK):**
```json
{
  "diagnosticos": [
    {
      "id": 1,
      "paciente_id": 1,
      "paciente_nombre": "Juan Pérez",
      "resultado": "Alzheimer Leve",
      "confianza": 0.85,
      "created_at": "2024-01-01T10:00:00"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 10,
    "total": 50,
    "total_pages": 5,
    "has_next": true,
    "has_prev": false
  }
}
```

---

### 11. GET `/api/medicos/perfil`
**Descripción:** Obtener perfil completo del médico autenticado

**Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "nombre": "Dr. Juan Pérez",
  "especialidad": "Neurología",
  "cmp": "12345",
  "hospital_afiliacion": "Hospital Central",
  "total_pacientes": 25,
  "total_diagnosticos": 150
}
```

---

## 📅 CITAS

### 12. GET `/api/citas`
**Descripción:** Obtener lista de citas

**Headers:**
```
Authorization: Bearer {token}
```

**Query Parameters (opcionales):**
- `paciente_id`: filtrar por paciente
- `medico_id`: filtrar por médico
- `hospital_id`: filtrar por hospital
- `estado`: pendiente|confirmada|cancelada|completada
- `fecha_desde`: formato YYYY-MM-DD
- `fecha_hasta`: formato YYYY-MM-DD
- `page`: número de página
- `limit`: registros por página

**Response (200 OK):**
```json
{
  "citas": [
    {
      "id": 1,
      "paciente_id": 1,
      "paciente_nombre": "Juan Pérez",
      "medico_id": 2,
      "medico_nombre": "Dr. María López",
      "fecha_hora": "2024-01-15T10:00:00",
      "estado": "confirmada",
      "motivo": "Consulta de seguimiento",
      "hospital_id": 1,
      "hospital_nombre": "Hospital Central"
    }
  ],
  "total": 10,
  "page": 1,
  "limit": 10
}
```

---

### 13. POST `/api/citas`
**Descripción:** Crear nueva cita

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "medico_id": 1,
  "fecha_hora": "2024-01-15T10:00:00",
  "motivo": "Consulta inicial",
  "hospital_id": 1
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "paciente_id": 1,
  "medico_id": 1,
  "fecha_hora": "2024-01-15T10:00:00",
  "estado": "pendiente",
  "motivo": "Consulta inicial",
  "created_at": "2024-01-01T12:00:00"
}
```

**Errores:**
- 400: Datos inválidos o horario no disponible
- 409: Conflicto de horario

---

### 14. GET `/api/citas/medico/{medico_id}/disponibilidad`
**Descripción:** Verificar disponibilidad de horarios de un médico

**Headers:**
```
Authorization: Bearer {token}
```

**Query Parameters:**
- `fecha`: fecha a consultar (formato YYYY-MM-DD) **REQUERIDO**
- `hospital_id`: hospital específico (opcional)

**Response (200 OK):**
```json
{
  "medico_id": 1,
  "fecha": "2024-01-15",
  "horarios_disponibles": [
    "09:00",
    "10:00",
    "11:00",
    "14:00",
    "15:00"
  ],
  "horarios_ocupados": [
    "16:00",
    "17:00"
  ]
}
```

---

## 👑 ADMIN

### 15. GET `/api/admin/historial-completo`
**Descripción:** Obtener historial completo de todos los diagnósticos (solo admin)

**Headers:**
```
Authorization: Bearer {token}
```

**Query Parameters (opcionales):**
- `paciente_id`: filtrar por paciente
- `fecha_desde`: formato YYYY-MM-DD
- `fecha_hasta`: formato YYYY-MM-DD
- `resultado`: filtrar por resultado específico
- `page`: número de página
- `per_page`: registros por página

**Response (200 OK):**
```json
{
  "diagnosticos": [
    {
      "id": 1,
      "paciente_id": 1,
      "paciente_nombre": "Juan Pérez",
      "resultado": "Alzheimer Leve",
      "confianza": 0.85,
      "created_at": "2024-01-01T10:00:00",
      "estado": "completado"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 10,
    "total": 500,
    "total_pages": 50,
    "has_next": true,
    "has_prev": false
  }
}
```

---

### 16. GET `/api/admin/estadisticas-globales`
**Descripción:** Obtener estadísticas generales del sistema (solo admin)

**Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "total_usuarios": 150,
  "total_pacientes": 100,
  "total_medicos": 25,
  "total_diagnosticos": 500,
  "diagnosticos_por_resultado": {
    "Normal": 200,
    "Alzheimer Leve": 150,
    "Alzheimer Moderado": 100,
    "Alzheimer Severo": 50
  },
  "diagnosticos_ultimo_mes": 45,
  "usuarios_activos": 120,
  "promedio_confianza": 0.82
}
```

---

## 🔒 SEGURIDAD Y MIDDLEWARE

### Autenticación JWT
- Todos los endpoints (excepto `/api/auth/login` y `/api/auth/register`) requieren token JWT
- El token debe enviarse en el header: `Authorization: Bearer {token}`
- El token debe contener: `user_id`, `username`, `tipo_usuario`
- Expiración recomendada: 24 horas

### Autorización por Roles
- **Paciente**: puede acceder solo a sus propios diagnósticos y citas
- **Médico**: puede ver sus pacientes asignados y sus diagnósticos
- **Admin**: acceso completo al sistema
- **Cuidador**: puede ver diagnósticos del paciente asociado

### CORS
- Debe permitir origen: `http://localhost:*` (desarrollo)
- Headers permitidos: `Content-Type`, `Authorization`
- Métodos permitidos: `GET`, `POST`, `PUT`, `DELETE`, `OPTIONS`

---

## 📁 ARCHIVOS ESTÁTICOS

### Servir Imágenes
Las URLs de imágenes deben ser accesibles públicamente (o con autenticación):

**Ejemplo de estructura:**
```
/uploads/diagnosticos/{diagnostico_id}/original.jpg
/uploads/diagnosticos/{diagnostico_id}/procesada.jpg
/uploads/perfiles/{user_id}/foto.jpg
```

**URLs deben ser absolutas:**
```
http://localhost:8000/uploads/diagnosticos/1/original.jpg
http://192.168.18.8:8000/uploads/diagnosticos/1/original.jpg
https://backendalzheimer.onrender.com/uploads/diagnosticos/1/original.jpg
```

---

## 📊 CÓDIGOS DE ESTADO HTTP

### Exitosos
- `200 OK`: Operación exitosa
- `201 Created`: Recurso creado exitosamente

### Errores del Cliente
- `400 Bad Request`: Datos inválidos
- `401 Unauthorized`: No autenticado
- `403 Forbidden`: Sin permisos
- `404 Not Found`: Recurso no encontrado
- `409 Conflict`: Conflicto (ej: horario ocupado)
- `422 Unprocessable Entity`: Validación fallida

### Errores del Servidor
- `500 Internal Server Error`: Error del servidor
- `503 Service Unavailable`: Servicio no disponible

### Formato de Errores
```json
{
  "detail": "Mensaje de error descriptivo",
  "code": "ERROR_CODE" // opcional
}
```

---

## ✅ CHECKLIST DE IMPLEMENTACIÓN

### Prioridad ALTA (Funcionalidad Básica)
- [ ] POST `/api/auth/login` - Autenticación
- [ ] GET `/api/auth/me` - Usuario actual
- [ ] POST `/api/auth/register` - Registro
- [ ] POST `/api/diagnosticos/analizar` - Análisis de imagen
- [ ] GET `/api/diagnosticos/historial` - Historial paciente
- [ ] GET `/api/diagnosticos/detalle/{id}` - Detalle diagnóstico
- [ ] Middleware JWT autenticación
- [ ] CORS configurado
- [ ] Servir archivos estáticos (imágenes)

### Prioridad MEDIA (Funcionalidad Extendida)
- [ ] GET `/api/medicos` - Listar médicos
- [ ] GET `/api/medicos/mis-pacientes` - Pacientes del médico
- [ ] GET `/api/medico/historial-pacientes` - Historial médico
- [ ] GET `/api/medicos/perfil` - Perfil médico
- [ ] GET `/api/citas` - Listar citas
- [ ] POST `/api/citas` - Crear cita
- [ ] GET `/api/citas/medico/{id}/disponibilidad` - Disponibilidad

### Prioridad BAJA (Administración)
- [ ] GET `/api/admin/historial-completo` - Historial completo
- [ ] GET `/api/admin/estadisticas-globales` - Estadísticas
- [ ] Middleware de autorización por roles

---

## 🧪 PRUEBAS RECOMENDADAS

### Con cURL (Windows PowerShell):

```powershell
# 1. Login
$response = Invoke-RestMethod -Uri "http://localhost:8000/api/auth/login" -Method POST -Body '{"username":"test","password":"test"}' -ContentType "application/json"
$token = $response.access_token

# 2. Usuario actual
Invoke-RestMethod -Uri "http://localhost:8000/api/auth/me" -Method GET -Headers @{"Authorization"="Bearer $token"}

# 3. Historial
Invoke-RestMethod -Uri "http://localhost:8000/api/diagnosticos/historial" -Method GET -Headers @{"Authorization"="Bearer $token"}
```

---

## 📝 NOTAS IMPORTANTES

1. **URLs Base del Frontend:**
   - Local: `http://localhost:8000`
   - Físico: `http://192.168.18.8:8000`
   - Producción: `https://backendalzheimer.onrender.com`

2. **Campos críticos:**
   - `tipo_usuario` debe ser minúsculas: `paciente`, `medico`, `admin`, `cuidador`
   - URLs de imágenes deben ser absolutas y accesibles
   - Fechas formato ISO 8601: `YYYY-MM-DDTHH:mm:ss`

3. **Paginación:**
   - El frontend espera objetos `pagination` con: `page`, `per_page`, `total`, `total_pages`, `has_next`, `has_prev`

4. **Nombres de archivos multipart:**
   - Campo esperado: `file` (no `image`, no `foto`)

---

**Generado para proyecto:** AlzheCare Frontend Flutter
**Fecha:** 2025-01-19
**Base URL actual:** http://192.168.18.8:8000

