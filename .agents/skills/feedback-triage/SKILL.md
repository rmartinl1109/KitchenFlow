---
name: feedback-triage
description: >-
  Procedimiento guiado para revisar iterativamente las incidencias y capturas en /feedback,
  aplicar correcciones, validar con el usuario y eliminar las capturas resueltas para mantener limpio el repositorio.
---

# Skill: Triaje y Resolución de Feedback (/feedback)

Este skill define un protocolo estándar y reutilizable para cualquier proyecto. Permite resolver sistemáticamente las incidencias, ajustes de UI/UX y mejoras registradas por el usuario en `feedback/FEEDBACK.md`, apoyándose en capturas de pantalla y garantizando una limpieza automática de los archivos multimedia una vez solventados y validados.

---

## 📋 Requisitos y Ubicación de Archivos
- **Archivo de seguimiento**: `feedback/FEEDBACK.md`
- **Carpeta de capturas**: `feedback/` (donde se ubican imágenes como `.png`, `.jpg`, `.jpeg`, `.webp`, etc.)
- **Reglas del proyecto**:
  - Respetar la arquitectura, convenciones de código y sistema de internacionalización/localización vigentes en el proyecto.
  - Asegurar compatibilidad con el entorno de ejecución objetivo (dispositivos, navegadores o plataformas según corresponda).

---

## 🚀 Flujo de Trabajo Paso a Paso

### Paso 1: Lectura y Triaje de Ítems Pendientes
1. Leer `feedback/FEEDBACK.md`.
2. Identificar las tareas que aún tienen casilla desmarcada `- [ ]`.
3. Para cada tarea con captura referenciada (ej. `error_layout.png` o `feedback/error_layout.png`):
   - Utilizar la herramienta `view_file` sobre la imagen para inspeccionar visualmente el defecto reportado.
   - Contrastar la captura con el código de la vista o componente correspondiente.

### Paso 2: Propuesta e Implementación de la Solución
1. Explicar brevemente al usuario la causa raíz detectada (tanto por la captura como por el código).
2. Aplicar la solución en los archivos correspondientes del proyecto.
3. Si se añade o modifica texto de interfaz, aplicar el sistema de traducción o internacionalización estándar del repositorio sin hardcodear cadenas.

### Paso 3: Validación con el Usuario
1. Indicar al usuario qué cambios se han efectuado y en qué componentes o vistas.
2. Solicitar al usuario que pruebe el cambio en su entorno (simulador, navegador o dispositivo).

### Paso 4: Cierre del Ítem y Limpieza de Capturas ("Dar el OK")
Una vez que el usuario confirma que el ítem está correcto o solucionado:
1. **Marcar casilla en Markdown**: Cambiar `- [ ]` a `- [x]` en `feedback/FEEDBACK.md` (opcionalmente añadir nota de resolución breve).
2. **Eliminar la captura asociada**: Ejecutar la eliminación del archivo de imagen (`rm feedback/<nombre_captura>`) para mantener el repositorio ligero y libre de binarios innecesarios.
3. Confirmar al usuario que la captura ha sido eliminada y el punto marcado como completado.

---

## ⚠️ Pautas y Buenas Prácticas
- **Nunca eliminar una captura sin confirmación**: Solo borrar la imagen cuando el usuario dé explícitamente su visto bueno ("OK", "funciona", "resuelto", etc.).
- **Si una captura aplica a varios puntos**: Mantenerla hasta que el último punto asociado reciba el OK.
- **Mantener el histórico**: Conservar el texto del ítem marcado como `[x]` en `FEEDBACK.md` para que siempre haya constancia de lo que se ha corregido durante la sesión.
