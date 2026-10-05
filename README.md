# KitchenFlow ⏱️🍳

> **Temporizador y Asistente de Cocina por Pasos (Recipe Timers)**  
> *Flujos de tiempo culinarios inteligentes, temporizadores encadenados y control manos libres para cocinar sin estrés ni pantallas manchadas.*

---

## 📖 Visión del Proyecto

### El Problema
Al cocinar platos elaborados con múltiples fases (por ejemplo: sofreír 5 min, añadir verduras otros 5 min, hervir 20 min removiendo cada 5 min), los temporizadores convencionales o alarmas individuales resultan caóticos, fáciles de confundir y requieren manipular constantemente el dispositivo con las manos sucias o mojadas.

### La Solución
**KitchenFlow** es un asistente interactivo y gestor de guiones de tiempo culinarios diseñado específicamente para el ecosistema Apple. Guía al usuario paso a paso a través de temporizadores secuenciales y anidados, alertas de acciones intermedias, presencia en la Dynamic Island / Pantalla de bloqueo y control directo desde el Apple Watch o mediante comandos de voz.

---

## 📱 Plataformas y Requisitos

- **Plataformas Soportadas**: iOS, iPadOS, watchOS
- **Deployment Targets**:
  - **iOS**: 17.0+
  - **iPadOS**: 17.0+
  - **watchOS**: 10.0+
- **Herramientas de Desarrollo**:
  - **Xcode**: 15.0+ (Recomendado Xcode 16+)
  - **Swift**: 5.9+ / Swift 6 Mode ready
  - **Gestor de Dependencias**: Swift Package Manager (SPM)

### 🏷️ Identificadores Oficiales de App Store
- **Nombre en App Store**: `KitchenFlow: Recipe Timers`
- **Nombre en Dispositivo (`CFBundleDisplayName`)**: `KitchenFlow`
- **Nombre de registro interno**: `KitchenFlowRecipes`
- **Bundle ID (App)**: `com.rmartinl1109.KitchenFlow`
- **Bundle ID (Widget)**: `com.rmartinl1109.KitchenFlow.KitchenFlowWidget`
- **Bundle ID (Watch)**: `com.rmartinl1109.KitchenFlow.watchkitapp`
- **Apple ID (App Store)**: `6819074326`
- **IAP Product ID**: `com.rmartinl1109.KitchenFlowPro` (KitchenFlow Pro Lifetime)
- **IAP Apple ID**: `6819074505`
- **Enlace Oficial**: [https://apps.apple.com/app/id6819074326](https://apps.apple.com/app/id6819074326)

---

## 🏛️ Arquitectura y Tecnologías

El proyecto sigue una arquitectura **Clean Architecture + MVVM** reactiva orientada a estados y modularizada para facilitar la compartición de lógica entre iOS y watchOS:

- **Interfaz de Usuario**: SwiftUI con diseño declarativo adaptativo y componentes nativos modernos.
- **Gestión de Estado y Concurrencia**: `@Observable` (Observation framework), Swift Concurrency (`async/await`, `Actors`).
- **Persistencia y Sincronización**: **SwiftData** con integración nativa en **CloudKit** (sincronización transparente de recetas y estado activo entre iPhone, iPad y Apple Watch).
- **Widgets y Pantalla en Vivo**: **ActivityKit** y **WidgetKit** para soporte de *Live Activities* y presencia continua en la *Dynamic Island*.
- **Integración con Apple Watch**: Companion app nativa para watchOS con **WatchConnectivity**, complicaciones modulares y patrones hápticos distintivos diseñados para entornos ruidosos de cocina.
- **Modo Manos Libres y Accesibilidad**: **Speech Framework** y **AVFoundation** para avance de pasos por comandos de voz básicos o detección de proximidad/gestos.
- **Monetización**: **StoreKit 2** (Suscripción / Compra única para KitchenFlow Pro).
- **Internacionalización**: **String Catalogs** (`.xcstrings`) con soporte nativo estricto para **6 idiomas oficiales**:
  - 🇬🇧 Inglés (`en`)
  - 🇪🇸 Español (`es`)
  - 🇫🇷 Francés (`fr`)
  - 🇩🇪 Alemán (`de`)
  - 🇵🇹 Portugués (`pt`)
  - 🇨🇳 Chino Simplificado (`zh-Hans`)

---

## 📁 Estructura del Proyecto

```text
KitchenFlow/
├── KitchenFlow/
│   ├── App/
│   │   ├── KitchenFlowApp.swift            # Punto de entrada de la aplicación
│   │   └── AppState.swift                  # Estado global y enrutamiento
│   ├── Core/
│   │   ├── Models/                         # Modelos SwiftData (Recipe, Step, TimerPhase)
│   │   ├── Engine/                         # Motor de ejecución de recetas y temporizadores
│   │   ├── Services/                       # CloudKit, Notificaciones, Haptics, Audio/Voice
│   │   └── StoreKit/                       # Gestor de suscripciones y compras Pro
│   ├── Features/
│   │   ├── RecipeList/                     # Explorador y gestor de recetas
│   │   ├── RecipeEditor/                   # Creación y edición de guiones de tiempo
│   │   ├── ActiveSession/                  # Pantalla de cocinado activo y temporizador guiado
│   │   ├── HandsFree/                      # Interfaz de voz y modo manos libres
│   │   └── Settings/                       # Preferencias, sonido, hápticos y paywall
│   ├── DesignSystem/
│   │   ├── Components/                     # Botones circulares, barras de progreso de fase
│   │   ├── Modifiers/                      # Estilos gastronómicos, animaciones de cuenta atrás
│   │   └── Theme/                          # Paletas de color dinámicas (Dark/Light mode)
│   └── Resources/
│       ├── Assets.xcassets                 # Colores, iconos y recursos gráficos
│       └── Localizable.xcstrings           # Catálogo centralizado de localización (6 idiomas)
├── KitchenFlowWatch/                       # Companion App para Apple Watch
│   ├── App/                                # Ciclo de vida watchOS
│   ├── Features/                           # Vistas compactas de temporizador y control háptico
│   └── Complications/                      # Complicaciones para esferas de reloj
├── KitchenFlowWidget/                      # Live Activities y Dynamic Island
│   ├── Attributes/                         # ActivityAttributes de la sesión de cocina
│   └── Views/                              # UI para Dynamic Island (Compact, Expanded) y Lock Screen
└── web/                                    # Landing Page y escaparate interactivo de la app
```

---

## 💡 Modelo de Monetización (Freemium)

| Característica | Versión Gratuita (Free) | KitchenFlow Pro (Premium) |
| :--- | :---: | :---: |
| **Recetas Guardadas / Activas** | **1 Receta** simultánea | **Ilimitadas** |
| **Temporizadores Secuenciales y Anidados** (intervalos, avisos de remover, etc.) | ✅ **Incluido** | ✅ **Incluido** |
| **Live Activities & Dynamic Island** | ✅ Básico | ✅ Completo con acciones interactivas |
| **Integración Completa con Apple Watch** | ❌ | ✅ Complicaciones y hápticos PRO |
| **Modo Manos Libres (Comandos de Voz)** | ❌ | ✅ Incluido |
| **Sincronización CloudKit Multidispositivo** | ❌ (Solo local) | ✅ iPhone, iPad y Apple Watch |

---

## 🗺️ Hoja de Ruta (Roadmap) y Plan de Proyecto

### Fase 1: Arquitectura Base y Motor de Temporizadores 🚀 *(Completada)*
- [x] Inicialización del repositorio y definición canónica del proyecto.
- [x] Configuración del catálogo de localización (`Localizable.xcstrings`) en los 6 idiomas oficiales (`en`, `es`, `fr`, `de`, `pt`, `zh-Hans`) sin cadenas hardcodeadas.
- [x] Modelado de datos en SwiftData: `Recipe`, `RecipeStep`, `StepIntervalAlert`.
- [x] Desarrollo del **CookingTimerEngine**:
  - Control de cuenta atrás precisa en segundo plano y transiciones de fase.
  - Encadenamiento secuencial automático y pausas interactivas esperando confirmación del usuario.
  - Temporizadores anidados y repetitivos para acciones intermedias (ej. remover sofrito).
  - Alertas hápticas y sonoras (`UIImpactFeedbackGenerator`, `AudioServicesPlaySystemSound`).
- [x] Creador y editor dinámico de recetas (`RecipeEditorView`) con configuración de pasos e intervalos anidados.
- [x] Pantalla principal (`RecipeListView`) con receta precargada de demostración (*Risotto de Setas*) y control de límite de 1 receta en modo gratuito.
- [x] Pantalla inmersiva de cocinado activo (`ActiveCookingView`) con anillo circular de progreso dinámico y banner de avisos de intervalo.
- [x] Actualización de la Landing Page interactiva en `/web` con simulador navegable de la app.

### Fase 2: Experiencia Visual, Dynamic Island y Live Activities ⏱️ *(Completada)*
- [x] Configuración de `NSSupportsLiveActivities` y módulo de widgets con `ActivityKit` y `WidgetKit`.
- [x] Modelado de `CookingActivityAttributes` y estado dinámico `ContentState`.
- [x] Gestor centralizado `LiveActivityManager` con control de ciclo de vida (inicio, sincronización de ticks, pausa y finalización).
- [x] Diseño completo de la interfaz de **Live Activities**:
  - Pantalla de bloqueo: progreso circular del paso actual, tiempo restante, avisos de intervalo anidados y preview del siguiente paso.
  - Dynamic Island (Compact Leading con emoji y paso, Compact Trailing con cuenta regresiva, Minimal y Expanded con vista detallada de la receta y recordatorios).
- [x] Sistema de notificaciones locales ricas (`NotificationService`) con categorías interactivas y avisos sonoros para finalización de fase y recordatorios de intervalo.

### Fase 3: Ecosistema Apple Watch & Experiencia Sensorial ⌚ *(Completada)*
- [x] Target nativo `KitchenFlowWatch` en watchOS 10+.
- [x] Sincronización en tiempo real y segundo plano mediante `WatchConnectivity` (`WCSession`).
- [x] Diseño de patrones hápticos distintivos (`WatchHapticsManager` con `WKInterfaceDevice`) para alertar al cocinero en entornos de ruido o extracción de humos.
- [x] Interfaz SwiftUI inmersiva (`WatchCookingView`) con anillo circular gastronómico, botón táctil grande y gestión de intervalos.
- [x] Complicaciones de esfera con `WidgetKit` (`accessoryCircular`, `accessoryCorner`, `accessoryRectangular`, `accessoryInline`).

### Fase 4: Modo Manos Libres y Accesibilidad de Cocina 🗣️
- [ ] Integración con `Speech` y comandos por voz sin contacto físico ("*Siguiente paso*", "*Pausar*", "*¿Cuánto falta?*").
- [ ] Soporte de gestos sin contacto utilizando el sensor de proximidad / cámara TrueDepth si aplica.
- [ ] Soporte completo para VoiceOver, Dynamic Type y alto contraste.

### Fase 5: Monetización (StoreKit 2), CloudKit y Pulido Final 💎
- [x] Integración de **StoreKit 2**: gestión de compra única de por vida (*Lifetime Non-Consumable Purchase*) a 4,99 $ / 4,99 € sin suscripciones ni cuotas recurrentes.
- [x] Pantalla nativa de Paywall gastronómico ([PaywallView.swift](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Features/Settings/PaywallView.swift)) con presentación de compra única, restauración de compras y enlaces legales.
- [x] Aplicación de reglas Freemium: límite de 1 receta propia en el plan gratuito con activación automática del Paywall.
- [x] Páginas públicas de cumplimiento normativo de Apple: [Política de Privacidad](file:///Users/roberto/Developer/KitchenFlow/web/privacy.html) y [Términos de Uso / EULA](file:///Users/roberto/Developer/KitchenFlow/web/terms.html) en `/web`.
- [x] Preparación y validación exhaustiva de metadatos ASO para App Store Connect en los **6 idiomas oficiales** (`en-US`, `es-ES`, `fr-FR`, `de-DE`, `pt-BR`, `zh-Hans`) según la skill `app-store-prep`.
- [ ] Sincronización multi-dispositivo con `NSPersistentCloudKitContainer` / SwiftData CloudKit.

---

## 🛠️ Compilación y Ejecución

1. Clonar el repositorio localmente:
   ```bash
   git clone https://github.com/rmartinl1109/KitchenFlow.git
   cd KitchenFlow
   ```
2. Abrir `KitchenFlow.xcodeproj` en **Xcode 15+** o superior.
3. Asegurarse de que el equipo de desarrollo (*Signing & Capabilities*) esté asignado.
4. Seleccionar el esquema correspondiente:
   - `KitchenFlow`: Aplicación principal iOS / iPadOS.
5. Seleccionar un simulador (ej. *iPhone 16 Pro*, *iPad Pro 13"*) o dispositivo físico y presionar `Cmd + R` para compilar y ejecutar.

---

## 🌐 Internacionalización y Localización

KitchenFlow cumple estrictamente la política de **cero cadenas hardcodeadas**. Todos los textos visibles por el usuario están registrados en el catálogo de cadenas oficial con soporte completo en:
- `en`: English
- `es`: Español
- `fr`: Français
- `de`: Deutsch
- `pt`: Português
- `zh-Hans`: 简体中文

---

## 📝 Historial de Actualizaciones Recientes

- **2026-10-04**:
  - **Configuración de Identificadores Oficiales de App Store Connect**:
    - **Bundle Identifier (App)**: `com.rmartinl1109.KitchenFlow` configurado en Debug y Release.
    - **Bundle Identifier (Widget)**: `com.rmartinl1109.KitchenFlow.KitchenFlowWidget` para la extensión de Dynamic Island y Live Activities.
    - **Apple ID (App Store)**: `6819074326` integrado en enlaces de valoración directa (`write-review`) y difusión (`ShareLink`).
    - **In-App Purchase (StoreKit 2)**:
      - Product ID: `com.rmartinl1109.KitchenFlowPro`
      - In-App Purchase Apple ID: `6819074505`
      - Configurado en [KitchenFlow.storekit](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Core/StoreKit/KitchenFlow.storekit) y [StoreKitManager.swift](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Core/StoreKit/StoreKitManager.swift).
    - **Landing Page en `/web`**: Botones de descarga y enlaces oficiales actualizados hacia la App Store (`https://apps.apple.com/app/id6819074326`).
    - Registro de identificadores centralizado en [AppStore/AppStoreIdentifiers.md](file:///Users/roberto/Developer/KitchenFlow/AppStore/AppStoreIdentifiers.md).
  - **Refactorización y Blindaje de Límites del Plan Gratuito**:
    - Corregida la condición en [RecipeListView.swift](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Features/RecipeList/RecipeListView.swift): el límite del plan Free es estrictamente **1 receta en total** (`recipes.count < 1`), evitando que la receta de muestra permita crear una segunda receta sin Pro.
    - Unificada la presentación modal con `activeSheet` (`newRecipe`, `editRecipe`, `paywall`, `settings`), eliminando conflictos de estados múltiples en SwiftUI.
    - Añadida salvaguarda a nivel de guardado en [RecipeEditorView.swift](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Features/RecipeEditor/RecipeEditorView.swift) y persistencia del sembrado inicial con `@AppStorage("hasSeededInitialSample")`.
  - **Pantalla Completa de Configuración y Ajustes del Sistema**:
    - Desarrollada e integrada la vista [SettingsView.swift](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Features/Settings/SettingsView.swift) accesible mediante un botón con icono de engranaje (`gearshape`) en la barra de herramientas principal.
    - **Selector de Apariencia Dinámico**: Soporte para Modo Sistema, Modo Claro y Modo Oscuro guardado en `@AppStorage("appAppearance")` y aplicado a nivel de raíz en [MyApp.swift](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/MyApp.swift) mediante `.preferredColorScheme`.
    - **Preferencias de Cocina Activa**:
      - Mantener pantalla encendida (`keepScreenAwake`) sincronizado con `UIApplication.shared.isIdleTimerDisabled` durante las sesiones de cocinado en [ActiveCookingView.swift](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Features/ActiveSession/ActiveCookingView.swift).
      - Toggles para vibración háptica y avisos acústicos.
    - **Soporte, Comunidad y Crecimiento**:
      - Valoración nativa en App Store (`requestReview`).
      - Envío de sugerencias y comentarios por correo con datos técnicos del dispositivo y versión del sistema preconfigurados.
      - Opción nativa de compartir la aplicación (`ShareLink`).
    - **Sección Legal y Acerca de**: Enlaces directos al sitio web oficial, [Política de Privacidad](file:///Users/roberto/Developer/KitchenFlow/web/privacy.html), [Términos de Uso](file:///Users/roberto/Developer/KitchenFlow/web/terms.html) y versión de compilación.
    - **Membresía Pro integrada**: Muestra el estado activo de KitchenFlow Pro o un botón destacado para abrir [PaywallView.swift](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Features/Settings/PaywallView.swift).
    - **Localización Completa**: Todos los textos localizados en los 6 idiomas oficiales (`en`, `es`, `fr`, `de`, `pt`, `zh-Hans`) en [Localizable.xcstrings](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Resources/Localizable.xcstrings).
  - **Fase 5 completada: Monetización con StoreKit 2, Paywall nativo y Preparación ASO para App Store**:
    - **Gestor nativo de compras StoreKit 2**: Creado [StoreKitManager.swift](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Core/StoreKit/StoreKitManager.swift) con arquitectura reactiva `@Observable`, concurrencia segura (Swift 6 ready), soporte para `Transaction.updates`, escucha de renovaciones y restauraciones automáticas, y archivo de configuración local [KitchenFlow.storekit](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Core/StoreKit/KitchenFlow.storekit).
    - **Paywall Culinario de Alto Nivel**: Creada la vista [PaywallView.swift](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Features/Settings/PaywallView.swift) que presenta las ventajas PRO (recetas ilimitadas, hápticos potentes para Apple Watch, control por voz manos libres y sincronización iCloud) y tarjetas interactivas de suscripción (Anual con prueba de 7 días, Mensual y Vitalicio).
    - **Integración del modelo Freemium en la interfaz**: En [RecipeListView.swift](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Features/RecipeList/RecipeListView.swift), añadida la insignia botón `👑 PRO` en la barra superior, banner dinámico con botón de actualización, y presentación automática del Paywall al intentar crear más recetas de las permitidas en la versión gratuita (1 receta propia).
    - **Páginas Legales para la App Store**: Creadas en `/web` las páginas con estética gastronómica premium: [privacy.html](file:///Users/roberto/Developer/KitchenFlow/web/privacy.html) (cumplimiento directrices Apple 5.1.1) y [terms.html](file:///Users/roberto/Developer/KitchenFlow/web/terms.html) (Términos de servicio y EULA estándar de Apple para suscripciones auto-renovables).
    - **Metadatos ASO en 6 idiomas oficiales (App Store Connect)**: Mediante la skill `app-store-prep`, generados y verificados estrictamente los metadatos en [AppStore/metadata/](file:///Users/roberto/Developer/KitchenFlow/AppStore/metadata/) para `en-US`, `es-ES`, `fr-FR`, `de-DE`, `pt-BR` y `zh-Hans`. Se validaron con un script los límites de caracteres (`name` <= 30, `subtitle` <= 30, `promotional_text` <= 170, `keywords` <= 100 sin espacios tras las comas, descripciones estructuradas y notas de versión).
    - **Validación del AppIcon**: Verificado con `sips` que el icono [AppIcon.png](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Assets.xcassets/AppIcon.appiconset/AppIcon.png) no contiene canal alfa (`hasAlpha: no`), cumpliendo el estándar estricto de Apple para evitar rechazos en el proceso de revisión.
    - **Compilación validada**: Proyecto compilado y ejecutado con éxito en el simulador mediante `xcodebuild` sin advertencias ni errores.
  - **Identidad visual y AppIcon oficial de alta definición**:
    - Diseñado y generado el icono oficial de la aplicación ([AppIcon.appiconset](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Assets.xcassets/AppIcon.appiconset)) en 1024x1024 px con estética moderna y tangible de Apple (olla/cazo de cocina satinado con dial de temporizador integrado, sutil vapor ascendente y fondo degradado azafrán/fuego cálido *edge-to-edge*).
    - Configurado `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;` en Xcode e instalado en el simulador.
  - **Widget Extension Target configurado (`KitchenFlowWidget`)**:
    - Creado e integrado el target nativo de extensión [KitchenFlowWidget](file:///Users/roberto/Developer/KitchenFlow/KitchenFlowWidget) con `WidgetBundle` y diccionario `NSExtension` oficial (`com.apple.widgetkit-extension`) embebido en `PlugIns/`, permitiendo a iOS renderizar la **Dynamic Island** y la tarjeta de **Live Activity** en la pantalla de bloqueo en tiempo real sin errores de instalación.
  - **Experiencia de navegación y edición perfeccionada**:
    - Implementada vista [RecipeDetailView.swift](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Features/RecipeDetail/RecipeDetailView.swift) que permite al usuario pulsar en cualquier tarjeta de receta para ver el desglose completo de fases, tiempos, instrucciones y avisos de intervalos anidados.
    - Corregida la presentación del editor: ahora se usa `.sheet(item: $recipeToEdit)` e inicialización inmediata de `@State` en [RecipeEditorView.swift](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Features/RecipeEditor/RecipeEditorView.swift), garantizando que al deslizar a la izquierda y dar a "Editar", se carguen todos los campos y pasos de la receta seleccionada en lugar de una plantilla vacía.
  - **Fase 2 completada con éxito**:
    - Integrado soporte de **Live Activities** y **Dynamic Island** mediante `ActivityKit` y `WidgetKit`.
    - Creado [CookingActivityAttributes.swift](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Core/Services/CookingActivityAttributes.swift) y orquestador [LiveActivityManager.swift](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Core/Services/LiveActivityManager.swift).
    - Diseñadas las vistas para pantalla de bloqueo y Dynamic Island (Compact, Minimal y Expanded) en [CookingLiveActivityView.swift](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Features/LiveActivities/CookingLiveActivityView.swift) y [CookingLiveActivityWidget.swift](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Features/LiveActivities/CookingLiveActivityWidget.swift).
    - Desarrollado [NotificationService.swift](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Core/Services/NotificationService.swift) para avisos sonoros y notificaciones interactivas de finalización de paso y alertas de intervalo repetitivo.
    - Sincronización continua de Live Activities en tiempo real dentro de [CookingTimerEngine.swift](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Core/Engine/CookingTimerEngine.swift).
    - Actualizado el catálogo [Localizable.xcstrings](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Resources/Localizable.xcstrings) con las nuevas cadenas en los 6 idiomas oficiales.
  - **Fase 1 completada con éxito**:
    - Implementado `CookingTimerEngine` con soporte de temporizadores secuenciales y alertas anidadas de intervalo (ej. remover cada X tiempo).
    - Modelos de datos en SwiftData: [RecipeModels.swift](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Core/Models/RecipeModels.swift) (`Recipe`, `RecipeStep`, `StepIntervalAlert`).
    - Configurado catálogo de cadenas oficial [Localizable.xcstrings](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Resources/Localizable.xcstrings) en los 6 idiomas obligatorios (cero cadenas hardcodeadas).
    - Implementadas las vistas principales: [RecipeListView.swift](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Features/RecipeList/RecipeListView.swift), [RecipeEditorView.swift](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Features/RecipeEditor/RecipeEditorView.swift) y [ActiveCookingView.swift](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Features/ActiveSession/ActiveCookingView.swift).
    - Creación de receta de muestra inicial demostrativa (*Risotto de Setas*) vía [SampleDataService.swift](file:///Users/roberto/Developer/KitchenFlow/KitchenFlow/Core/Services/SampleDataService.swift).
    - Actualización del escaparate web interactivo en `/web` ([index.html](file:///Users/roberto/Developer/KitchenFlow/web/index.html) y [app.js](file:///Users/roberto/Developer/KitchenFlow/web/app.js)) con simulador funcional de la app.
    - Compilación nativa validada con éxito en simuladores de iOS y iPadOS.
