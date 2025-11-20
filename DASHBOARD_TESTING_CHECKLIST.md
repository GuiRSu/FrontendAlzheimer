/// TEST CHECKLIST - Dashboard Admin
/// 
/// Ejecuta estos tests manualmente para verificar la implementación

# ✅ CHECKLIST DE VERIFICACIÓN

## 1. Configuración Inicial
- [ ] Verificar que el backend esté corriendo (puerto 8000)
- [ ] Comprobar la URL del backend en api_service.dart
- [ ] Asegurar que hay un usuario admin creado
- [ ] Login con credenciales de admin

## 2. Dashboard Principal (dashboard_admin.dart)

### Visualización Inicial
- [ ] Las tarjetas de estadísticas se cargan correctamente
- [ ] Se muestran 4 tarjetas: Usuarios, Diagnósticos, Citas, Este Mes
- [ ] Los números en las tarjetas son correctos
- [ ] La distribución de usuarios muestra barras de progreso

### Secciones de Datos
- [ ] **Diagnósticos por Clasificación**: Se muestra lista con colores
- [ ] **Citas por Hospital**: ExpansionTiles funcionan correctamente
- [ ] **Actividad Reciente**: Se muestra timeline con iconos
- [ ] **Pacientes Destacados**: Lista con información correcta
- [ ] **Médicos Activos**: Se muestran estadísticas de médicos

### Interacciones
- [ ] Pull-to-refresh actualiza los datos
- [ ] Botón refresh en AppBar funciona
- [ ] Navegación al historial completo funciona
- [ ] Navegación a estadísticas detalladas funciona

### Estados
- [ ] Loading spinner se muestra mientras carga
- [ ] Error screen aparece si hay problemas de conexión
- [ ] Botón "Reintentar" funciona en error screen
- [ ] Estados vacíos se muestran cuando no hay datos

## 3. Estadísticas Detalladas (estadisticas_detalladas.dart)

### Navegación entre Tabs
- [ ] Tab 1 (Diagnósticos) se carga correctamente
- [ ] Tab 2 (Hospitales) muestra datos de hospitales
- [ ] Tab 3 (Tendencias) muestra gráfico de barras
- [ ] Tab 4 (Actividad) muestra timeline completo
- [ ] Cambiar entre tabs es fluido

### Tab Diagnósticos
- [ ] Barras de progreso muestran porcentajes correctos
- [ ] Colores diferentes por clasificación
- [ ] Confianza promedio se muestra
- [ ] Pacientes únicos se muestran

### Tab Hospitales
- [ ] Cards de hospitales con información completa
- [ ] Estadísticas de citas (programadas, completadas, canceladas)
- [ ] Barra de progreso horizontal por estado
- [ ] Colores correctos (azul, verde, rojo)

### Tab Tendencias
- [ ] Últimos 12 meses se muestran
- [ ] Barras proporcionales al valor máximo
- [ ] Mes formateado correctamente (ej: "Noviembre 2025")
- [ ] Pacientes únicos y confianza se muestran

### Tab Actividad
- [ ] Lista de actividades reciente
- [ ] Iconos correctos por tipo de actividad
- [ ] Timestamps relativos (ej: "Hace 5 min")
- [ ] Badges de tipo de actividad
- [ ] Scroll funciona correctamente

## 4. Historial Completo (historial_completo.dart)

### Filtros
- [ ] Campo ID Paciente acepta números
- [ ] Campo Resultado acepta texto
- [ ] Selector de fecha funciona
- [ ] Botón "Aplicar Filtros" ejecuta búsqueda
- [ ] Botón "Limpiar Filtros" resetea campos

### Resultados
- [ ] Lista de diagnósticos se muestra
- [ ] Información del paciente está incluida
- [ ] Imágenes se cargan (si disponibles)
- [ ] Paginación funciona correctamente
- [ ] Botones siguiente/anterior funcionan

## 5. Provider (admin_provider.dart)

### Métodos de Carga
- [ ] `cargarDashboardCompleto()` funciona
- [ ] `cargarEstadisticasGeneralesDashboard()` funciona
- [ ] `cargarDiagnosticosPorClasificacion()` funciona
- [ ] `cargarCitasPorHospital()` funciona
- [ ] `cargarPacientesDestacados()` funciona
- [ ] `cargarMedicosEstadisticas()` funciona
- [ ] `cargarActividadReciente()` funciona
- [ ] `cargarTendenciasMensuales()` funciona

### Estado del Provider
- [ ] `isLoading` cambia correctamente
- [ ] `errorMessage` se muestra cuando hay errores
- [ ] `notifyListeners()` actualiza la UI
- [ ] Datos se almacenan correctamente en variables privadas
- [ ] Getters devuelven datos correctos

## 6. Modelos (dashboard_models.dart)

### Parsing JSON
- [ ] `EstadisticasGenerales.fromJson()` funciona
- [ ] `DiagnosticoPorClasificacion.fromJson()` funciona
- [ ] `CitasPorHospital.fromJson()` funciona
- [ ] `PacienteDetallado.fromJson()` funciona
- [ ] `MedicoEstadisticas.fromJson()` funciona
- [ ] `ActividadReciente.fromJson()` funciona
- [ ] `DiagnosticosPorMes.fromJson()` funciona
- [ ] `DashboardCompleto.fromJson()` funciona

### Null Safety
- [ ] Valores nulos se manejan correctamente
- [ ] Valores por defecto funcionan
- [ ] No hay errores de null pointer

## 7. Conectividad Backend

### Endpoints Respondiendo
- [ ] `GET /api/dashboard/` retorna 200
- [ ] `GET /api/dashboard/estadisticas-generales` retorna 200
- [ ] `GET /api/dashboard/diagnosticos-clasificacion` retorna 200
- [ ] `GET /api/dashboard/citas-hospital` retorna 200
- [ ] `GET /api/dashboard/pacientes` retorna 200
- [ ] `GET /api/dashboard/medicos` retorna 200
- [ ] `GET /api/dashboard/actividad-reciente` retorna 200
- [ ] `GET /api/dashboard/tendencias-mensuales` retorna 200
- [ ] `GET /api/admin/historial-completo` retorna 200

### Autenticación
- [ ] Token JWT se envía en headers
- [ ] Peticiones sin token son rechazadas (401)
- [ ] Token expirado redirige a login

## 8. Rendimiento

### Tiempos de Carga
- [ ] Dashboard completo carga en < 3 segundos
- [ ] Estadísticas detalladas cargan en < 2 segundos
- [ ] Historial completo carga en < 2 segundos
- [ ] Cambio entre tabs es instantáneo

### Memoria
- [ ] No hay fugas de memoria
- [ ] ScrollView no causa lag
- [ ] Imágenes se liberan correctamente

## 9. Responsividad

### Orientación
- [ ] Portrait mode funciona correctamente
- [ ] Landscape mode funciona correctamente
- [ ] Rotación no causa errores

### Tamaños de Pantalla
- [ ] Funciona en pantallas pequeñas (< 5")
- [ ] Funciona en pantallas medianas (5-6")
- [ ] Funciona en pantallas grandes (> 6")
- [ ] Funciona en tablets

## 10. Logs y Debugging

### Consola
- [ ] Logs informativos se imprimen (✅)
- [ ] Logs de error se imprimen (❌)
- [ ] URLs de requests se imprimen
- [ ] Respuestas se logean en desarrollo

### Error Handling
- [ ] Errores de red se capturan
- [ ] Errores de parsing JSON se capturan
- [ ] Mensajes de error son descriptivos
- [ ] Usuario puede reintentar después de error

---

## 🎯 PRUEBA RÁPIDA (5 minutos)

1. **Login como Admin**
2. **Dashboard carga** → ✅ / ❌
3. **Click en icono gráfico** → Estadísticas Detalladas se abre → ✅ / ❌
4. **Navegar entre tabs** → Todos cargan datos → ✅ / ❌
5. **Volver y click en historial** → Se abre historial → ✅ / ❌
6. **Aplicar filtro** → Resultados filtrados → ✅ / ❌
7. **Pull to refresh** → Datos se actualizan → ✅ / ❌

### Resultado: ____ / 7

---

## 📝 NOTAS DE PRUEBA

```
Fecha: ____________________
Tester: ___________________
Backend URL: ______________
Versión App: ______________

Observaciones:
_________________________________
_________________________________
_________________________________
_________________________________

Bugs Encontrados:
_________________________________
_________________________________
_________________________________
_________________________________
```

---

## 🐛 TROUBLESHOOTING

### Problema: Dashboard no carga datos
**Solución**: 
- Verificar que backend esté corriendo
- Comprobar URL en api_service.dart
- Ver logs en consola para el error específico

### Problema: Error 401 Unauthorized
**Solución**:
- Token expiró, hacer logout y login nuevamente
- Verificar que el usuario sea tipo "admin"

### Problema: Error 500 Internal Server Error
**Solución**:
- Revisar logs del backend
- Verificar que la base de datos tenga datos
- Comprobar que las vistas SQL estén creadas

### Problema: Datos vacíos pero sin errores
**Solución**:
- Verificar que haya datos en la base de datos
- Ejecutar scripts de seed si es necesario
- Revisar que los endpoints retornen datos

### Problema: App se congela al cargar
**Solución**:
- Verificar cantidad de datos en backend
- Reducir límites en queries
- Implementar paginación más agresiva

---

**Última actualización**: Noviembre 2025

