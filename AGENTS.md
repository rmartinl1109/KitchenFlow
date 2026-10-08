# Instrucciones y Reglas del Proyecto (Workspace Rules)

Este archivo define las directrices generales que el agente debe seguir en este repositorio. Sirve de plantilla base para cualquier proyecto de Xcode en el ecosistema Apple (iOS, macOS, iPadOS, watchOS, tvOS, visionOS o proyectos universales multiplataforma).

## 📌 Principios Generales
- **Idioma**: Responder preferentemente en español, manteniendo términos técnicos en su estándar habitual.
- **Claridad y Concisión**: Explicaciones directas, paso a paso, orientadas a resolución práctica y segura.
- **Seguridad y Precaución**: En desarrollos y refactorizaciones para cualquier plataforma Apple, asegurar compatibilidad con la versión mínima de despliegue (*Deployment Target*) de cada plataforma objetivo (iOS, macOS, iPadOS, watchOS, tvOS, visionOS), consistencia arquitectónica y ausencia de cadenas hardcodeadas.
- **Estructura de Reglas y Skills**:
  - Las reglas modulares se encuentran en [`.agents/rules/`](.agents/rules/).
    - [00-general.md](.agents/rules/00-general.md): Buenas prácticas generales, dependencias y compatibilidad en Xcode.
    - [10-localization.md](.agents/rules/10-localization.md): Localización obligatoria en 6 idiomas (cero hardcoding) para SwiftUI, UIKit y AppKit.
    - [20-auto-update-readme.md](.agents/rules/20-auto-update-readme.md): Sincronización continua y automática del README.md raíz adaptado al target Xcode activo.
    - [30-web-showcase.md](.agents/rules/30-web-showcase.md): Mantenimiento del escaparate web interactivo en `/web` para cualquier plataforma.
  - Los skills con procedimientos paso a paso se encuentran en [`.agents/skills/`](.agents/skills/).
    - [update-web-showcase](.agents/skills/update-web-showcase/SKILL.md): Procedimiento guiado para sincronizar funcionalidades de la aplicación en `/web`.
    - [app-store-prep](.agents/skills/app-store-prep/SKILL.md): Preparación y validación de metadatos ASO (6 idiomas), AppIcon y screenshots para App Store Connect.
    - [pre-release-qa](.agents/skills/pre-release-qa/SKILL.md): Control de calidad integral, testing automatizado y despliegue beta en TestFlight o dispositivos físicos.
    - [feedback-triage](.agents/skills/feedback-triage/SKILL.md): Triaje, resolución iterativa de feedback con capturas y limpieza de imágenes tras validación.

