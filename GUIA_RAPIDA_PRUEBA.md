# 🚀 GUÍA RÁPIDA DE PRUEBA - Dashboard Admin

## ✅ Cambios Realizados

Se han actualizado **TODOS** los modelos del frontend para que coincidan exactamente con los schemas del backend. Ahora el dashboard debería funcionar correctamente.

## 📋 Pre-requisitos

1. **✅ Vistas SQL creadas** - Ya las tienes en `bd v3.sql`
2. **✅ Backend corriendo** - Puerto 8000
3. **✅ Usuarios creados**:
   - Admin (✓)
   - Paciente (✓)
   - Médico (✓)

## 🔧 Pasos para Probar

### 1. Reiniciar la App
```bash
# Detener la app si está corriendo
flutter clean
flutter pub get
flutter run
```

### 2. Login como Admin
- Usuario: tu usuario admin
- Contraseña: tu contraseña

### 3. Verificar Logs en la Consola

Deberías ver logs como estos:

```
🔄 Cargando dashboard completo...
📡 Response status: 200
📦 Response body preview: {"estadisticas_generales":{"total_pacientes_activos":1,...
📊 Data decoded successfully
🔍 Keys in response: [estadisticas_generales, diagnosticos_clasificacion, citas_por_hospital, ...]
✅ Dashboard completo cargado exitosamente
👥 Total usuarios: 3
📋 Total diagnósticos: 0
📅 Total citas: 0
```

### 4. Ver el DEBUG INFO

En el dashboard verás una tarjeta amarilla con información de depuración:

```
DEBUG INFO
Total Usuarios: 3
Total Diagnósticos: 0
Total Citas: 0
Usuarios por tipo: {paciente: 1, medico: 1, admin: 1}
```

### 5. Verificar Tarjetas Principales

Deberías ver 4 tarjetas con números:
- **Usuarios Total**: 3 (o el número que tengas)
- **Diagnósticos**: 0 (hasta que hagas diagnósticos)
- **Citas Total**: 0 (hasta que crees citas)
- **Este Mes**: 0

## 🐛 Troubleshooting

### Problema 1: "No hay datos disponibles"

**Causa**: El endpoint no está devolviendo datos o hay un error de parsing

**Solución**:
1. Revisa los logs en la consola de Flutter
2. Busca el log `📡 Response status:` 
3. Si es 200, el problema es de parsing
4. Si es 500, el problema es del backend (vistas SQL)

**Verificar Backend**:
```bash
# En el navegador o Postman
GET http://localhost:8000/api/dashboard/
# Headers: Authorization: Bearer TU_TOKEN
```

### Problema 2: Error 500 Internal Server Error

**Causa**: Las vistas SQL no están creadas en la base de datos

**Solución**:
1. Abre pgAdmin o psql
2. Conecta a tu base de datos
3. Ejecuta el archivo `bd v3.sql` completo
4. Verifica que las vistas se crearon:
```sql
SELECT * FROM vista_estadisticas_generales;
```

### Problema 3: Error 401 Unauthorized

**Causa**: Token expirado o usuario no es admin

**Solución**:
1. Cierra sesión en la app
2. Vuelve a hacer login
3. Verifica que el usuario sea tipo "admin"

### Problema 4: Números en 0 pero tengo datos

**Causa**: Los usuarios/datos existen pero no están "activos" o no cumplen las condiciones de las vistas

**Solución**:
1. Verifica en la base de datos:
```sql
-- Verificar usuarios activos
SELECT tipo_usuario, estado, COUNT(*) 
FROM usuario 
GROUP BY tipo_usuario, estado;

-- Debería mostrar estado = true
```

2. Si `estado = false`, actualizar:
```sql
UPDATE usuario SET estado = true WHERE id = TU_ID;
```

## 🎯 Test Rápido de 2 Minutos

1. **Login** → ✅ / ❌
2. **Ver DEBUG INFO amarillo** → ✅ / ❌  
3. **Ver número en "Usuarios Total"** → ✅ / ❌
4. **Número coincide con usuarios creados** → ✅ / ❌

Si todos son ✅, **¡FUNCIONÓ!** 🎉

## 📊 Próximos Pasos

Una vez que veas los números básicos:

1. **Crear Diagnósticos**:
   - Login como paciente
   - Sube una imagen MRI
   - Vuelve como admin y verás los números actualizados

2. **Crear Citas**:
   - Crea una cita desde cualquier rol
   - Verás las estadísticas de citas

3. **Ver Estadísticas Detalladas**:
   - Click en el icono 📊 en el AppBar
   - Explora las 4 tabs

## 🔍 Campos Actualizados

Los siguientes campos del modelo ahora coinciden con el backend:

### EstadisticasGenerales
- ✅ `total_pacientes_activos`
- ✅ `total_medicos_activos`
- ✅ `total_admins_activos`
- ✅ `total_usuarios_activos`
- ✅ `citas_programadas`
- ✅ `citas_completadas`
- ✅ `citas_canceladas`
- ✅ `total_diagnosticos`
- ✅ `total_hospitales`
- ✅ `total_asignaciones`

### Otros Modelos
- ✅ DiagnosticoPorClasificacion
- ✅ CitasPorHospital  
- ✅ PacienteDetallado
- ✅ MedicoEstadisticas
- ✅ ActividadReciente
- ✅ DiagnosticosPorMes

## 📝 Notas Finales

- Los logs de depuración (🔄, 📡, ✅, ❌) te ayudarán a identificar problemas
- La tarjeta DEBUG INFO es temporal, se puede quitar después
- Si todo funciona, los números deberían actualizarse en tiempo real

---

**¿Necesitas ayuda?**
Envía los logs de la consola y te ayudaré a diagnosticar el problema.

