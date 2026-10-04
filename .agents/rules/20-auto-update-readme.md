# Regla: Actualización Continua del README.md (Xcode / Ecosistema Apple)

> **Propósito**: Asegurar que el archivo `README.md` en la raíz del repositorio refleje fielmente y en todo momento el estado funcional, arquitectónico y operativo del proyecto, sirviendo como la fuente única de verdad para desarrolladores y colaboradores en cualquier proyecto Xcode (iOS, macOS, iPadOS, watchOS, tvOS, visionOS o Multiplataforma).

---

## 1. Directrices Obligatorias

### 1.1 Fuente Única de Verdad (`README.md` en la raíz)
- El archivo `README.md` situado en la raíz del proyecto es el documento de entrada principal y debe mantenerse siempre sincronizado.
- Toda nueva característica, cambio arquitectónico relevante, nueva dependencia (SPM), adición de targets de plataforma o requisito de compilación debe quedar reflejado de inmediato.

### 1.2 Estructura Canónica Obligatoria
El `README.md` debe respetar las siguientes secciones estructuradas:
1. **Encabezado y Descripción del Proyecto**: Propósito de la aplicación o librería, público objetivo, plataformas Apple soportadas y propuesta de valor.
2. **Requisitos de Plataforma y Entorno**: Versiones mínimas de despliegue según los targets configurados (ej. *iOS 17.0+*, *macOS 14.0+*, *iPadOS 17.0+*, *watchOS 10.0+*, *tvOS 17.0+*, *visionOS 1.0+*), versión de Xcode recomendada, versión de Swift y dependencias de entorno.
3. **Stack Tecnológico y Arquitectura**: Patrón arquitectónico (ej. MVVM, Clean Architecture, TCA), frameworks de UI (SwiftUI universal, UIKit, AppKit), concurrencia (`async/await`, Swift Concurrency) y persistencia (SwiftData, CoreData, etc.).
4. **Estructura del Proyecto**: Árbol descriptivo de carpetas, esquemas o módulos principales.
5. **Funcionalidades Principales (Features)**: Lista viva de capacidades implementadas con estado (✅ Implementado / 🟡 En progreso).
6. **Compilación y Ejecución**: Pasos exactos para clonar, resolver dependencias en Xcode, seleccionar el Scheme y ejecutar en el destino adecuado (Mac nativo, simulador de iPhone/iPad, simulador Apple Watch/TV/Vision Pro, o dispositivo físico).
7. **Internacionalización**: Mención expresa a los 6 idiomas soportados según la regla de localización.
8. **Historial de Actualizaciones Recientes (Recent Updates)**: Resumen conciso de los últimos hitos, refactorizaciones o funcionalidades incorporadas.

### 1.3 Criterios de Actualización (¿Cuándo actualizar?)
El agente debe actualizar el `README.md` cuando:
- Se implemente una **nueva pantalla, vista o flujo de usuario** en cualquiera de las plataformas.
- Se integre un **nuevo paquete o dependencia** externa vía SPM.
- Se modifique la **estructura de directorios, módulos o targets del proyecto Xcode**.
- Se altere la **configuración del proyecto o requisitos de compilación** (ej. bumping de Deployment Targets, adición de target macOS/iPadOS).
- Se realice una **refactorización estructural** o cambio de arquitectura.

---

## 2. Instrucciones para el Agente

Al finalizar cualquier tarea que impacte el código o funcionalidad:
1. **Evaluar el impacto**: Comprobar si los cambios alteran funcionalidades, dependencias, estructura, plataformas soportadas o requisitos.
2. **Edición quirúrgica y preservación**: No sobrescribir arbitrariamente secciones estables existentes. Modificar o añadir de forma incremental en las secciones correspondientes.
3. **Actualizar el checklist de Features**: Marcar con ✅ las nuevas capacidades completadas.
4. **Añadir entrada en Actualizaciones Recientes**: Registrar brevemente la fecha/versión, qué se añadió o refactorizó y qué archivos clave se vieron involucrados.
5. **Validar enlaces**: Garantizar que los enlaces internos o rutas relativas referenciadas sigan existiendo.

---

## 3. Plantilla Base para el README.md

```markdown
# [Nombre del Proyecto Xcode]

Breve descripción del propósito, propuesta de valor y plataformas objetivo de la app o librería Apple.

## 📱 Plataformas y Requisitos
- **Plataformas Soportadas**: [iOS / macOS / iPadOS / watchOS / tvOS / visionOS / Multiplataforma]
- **Deployment Targets**:
  - iOS: 17.0+
  - macOS: 14.0+ (si aplica)
  - iPadOS: 17.0+ (si aplica)
- **Xcode**: 15.0+
- **Swift**: 5.9+

## 🏛️ Arquitectura y Tecnologías
- **UI**: SwiftUI (universal) / UIKit / AppKit
- **Patrón**: MVVM / Clean Architecture / TCA
- **Concurrencia**: Swift Concurrency (async/await, Actors)
- **Persistencia**: SwiftData / CoreData / Ninguna
- **Internacionalización**: 6 idiomas oficiales (en, es, fr, de, pt, zh-Hans) con String Catalogs (`Localizable.xcstrings`)

## 📁 Estructura del Proyecto
\`\`\`text
Proyecto/
├── App/                # Ciclo de vida y puntos de entrada de la aplicación
├── Features/           # Módulos funcionales (Views, ViewModels)
├── Core/               # Lógica de dominio, networking y servicios
├── DesignSystem/       # Componentes visuales, temas y estilos
└── Resources/          # Assets y Localizable.xcstrings
\`\`\`

## 🚀 Funcionalidades
- [x] Autenticación y Onboarding
- [x] Localización multi-idioma (6 idiomas)
- [ ] Perfil de usuario (en desarrollo)

## 🛠️ Compilación y Ejecución
1. Abrir `Proyecto.xcodeproj` o `Proyecto.xcworkspace` en Xcode.
2. Seleccionar el esquema de compilación correspondiente (*Scheme*).
3. Elegir el dispositivo o simulador de destino (ej. *My Mac*, *iPhone 15 Pro*, *iPad Pro*, etc.) y pulsar `Cmd + R`.

## 📝 Actualizaciones Recientes
- **[YYYY-MM-DD]**: Implementación inicial del sistema base multi-idioma y arquitectura.
```

---

## 4. Checklist de Verificación (Definición de Hecho / DoD)
- [ ] ¿El `README.md` refleja la última funcionalidad o refactor implementado?
- [ ] ¿Las plataformas objetivo y sus deployment targets están especificadas correctamente?
- [ ] ¿La lista de funcionalidades (`Features`) tiene los estados actualizados?
- [ ] ¿La sección de requisitos o dependencias está al día?
- [ ] ¿Se ha registrado la actualización en la sección de historial reciente?
- [ ] ¿Los formatos y rutas de archivo son válidos?
