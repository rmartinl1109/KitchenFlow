# Reglas Generales del Espacio de Trabajo (Xcode / Ecosistema Apple)

> **Propósito**: Definir directrices transversales de calidad, seguridad y consistencia arquitectónica para cualquier proyecto desarrollado en Xcode sobre el ecosistema Apple (iOS, macOS, iPadOS, watchOS, tvOS, visionOS o Multiplataforma).

## 1. Convenciones y Compatibilidad en Xcode
- **Enfoque Multiplataforma**: Priorizar código universal reutilizable mediante SwiftUI. Cuando se requieran APIs específicas de plataforma, aislar mediante directivas de compilación condicional (`#if os(iOS)`, `#if os(macOS)`, `#if os(watchOS)`, etc.) o mediante protocolos y extensiones especializadas.
- **Respeto a los Deployment Targets**: Verificar siempre las versiones mínimas soportadas del proyecto (`iOS Deployment Target`, `macOS Deployment Target`, etc.) antes de emplear APIs recientemente introducidas en Xcode / Swift.
- **Gestión de Dependencias**: Utilizar **Swift Package Manager (SPM)** como estándar preferente de gestión de librerías, manteniendo un esquema de módulos limpio y desacoplado.
- **Concurrencia Segura**: Emplear Swift Concurrency moderno (`async/await`, `Actor`, `@MainActor`, `Sendable`) respetando los límites de hilos y evitando bloqueos de la UI en cualquier plataforma.
- **Comentarios y Documentación**: Documentar funciones públicas y tipos con Markdown docstrings estándar de Swift (`///`). Explicar el "por qué" de las decisiones arquitectónicas.

## 2. Manejo de Errores y Validaciones
- Manejar errores de forma explícita mediante tipos `Error` tipados o estándar, evitando desempacados forzados (`!`) o `try!` en código productivo.
- Todo script de automatización o modificación de estructura de proyecto (archivos `.pbxproj`, schemes) debe ejecutarse con extrema precaución para no corromper la configuración de Xcode.
- Solicitar confirmación antes de ejecutar comandos destructivos o de limpieza masiva de caché (`DerivedData`, restablecimiento de simuladores).

## 3. Enlaces a Archivos
- Al referenciar archivos existentes o nuevos en las respuestas, utilizar siempre enlaces markdown clicables con esquema `file://`.

