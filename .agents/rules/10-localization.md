# Regla: Localización e Internacionalización Multi-idioma (i18n & l10n)

> **Propósito**: Garantizar que todo componente de interfaz visual de usuario (SwiftUI, UIKit y AppKit) sea accesible y esté traducido de forma rigurosa y completa en los 6 idiomas oficiales del proyecto en cualquier target de Xcode (iOS, macOS, iPadOS, watchOS, tvOS, visionOS), eliminando cualquier cadena de texto *hardcodeada*.

---

## 1. Directrices Obligatorias

### 1.1 Idiomas Requeridos
Toda clave creada en el proyecto debe tener traducción explícita y coherente en los siguientes 6 idiomas:
1. **Inglés (`en`)** — *Idioma principal / Base de desarrollo (Development Language)*
2. **Español (`es`)**
3. **Francés (`fr`)**
4. **Alemán (`de`)**
5. **Portugués (`pt` o `pt-BR` / `pt-PT`)**
6. **Chino Simplificado (`zh-Hans`)**

### 1.2 Regla de "Cero Hardcoding"
- **Prohibido** incluir cadenas de texto visibles al usuario directamente en el código de vistas, modelos de presentación o controladores (`Text("Guardar")`, `label.text = "Error"` o `button.title = "Aceptar"` están estrictamente prohibidos).
- Aplica a: etiquetas (`Text`, `UILabel`, `NSTextField`), botones (`Button`, `UIButton`, `NSButton`), barras de menús y comandos macOS (`NSMenuItem`, `Menu`), títulos de navegación o ventanas (`navigationTitle`, `window.title`), placeholders de campos de texto, mensajes de alerta o diálogo (`Alert`, `UIAlertController`, `NSAlert`), notificaciones del sistema y accesibilidad (`accessibilityLabel`, `accessibilityHint`).

### 1.3 Formato y Ubicación de Archivos
- **Estándar Principal (Xcode 15+)**: **String Catalogs (`Localizable.xcstrings`)**. Permite gestionar en un único archivo JSON estructurado todos los idiomas, comentarios y estados de traducción, compatible de forma nativa con todos los targets de Apple (iOS, macOS, iPadOS, watchOS, tvOS, visionOS).
- **Alternativa Clásica**: Carpetas `.lproj` con archivos `Localizable.strings` (`en.lproj/Localizable.strings`, `es.lproj/Localizable.strings`, etc.).

### 1.4 Convención de Claves Semánticas
Las claves deben ser estructuradas jerárquicamente en minúsculas separadas por puntos para evitar colisiones:
```
[módulo_o_pantalla].[elemento_o_seccion].[identificador]
```
*Ejemplos:*
- `auth.login.button_submit`
- `auth.login.placeholder_email`
- `settings.account.title`
- `menu.file.export_pdf`
- `common.actions.cancel`
- `common.errors.generic_network`

### 1.5 Interpolación y Parámetros Dinámicos
- En cadenas con variables dinámicas, usar siempre **especificadores posicionales** (ej. `%1$@`, `%2$d`) para que el orden de las palabras pueda cambiar según la gramática del idioma (especialmente relevante en Alemán y Chino).
- **Prohibida** la concatenación manual de cadenas con `+` o interpolación libre `\(valor)` para texto de interfaz.

---

## 2. Instrucciones Específicas para el Agente

Al generar, modificar o refactorizar cualquier vista o componente:
1. **Identificar textos nuevos**: Extraer todas las cadenas visibles que requiera la pantalla o ventana.
2. **Crear claves semánticas**: Nombrarlas siguiendo la convención de punto (`feature.view.element`).
3. **Actualizar simultáneamente los 6 idiomas**: Antes de dar por finalizada la respuesta o tarea, añadir las entradas correspondientes en `Localizable.xcstrings` (o los 6 `Localizable.strings`) para `en`, `es`, `fr`, `de`, `pt` y `zh-Hans`.
4. **Añadir comentarios de contexto (`comment`)**: Proveer contexto que aclare el significado a traductores o herramientas (ej. *"Título del botón de autenticación principal"*).

---

## 3. Ejemplos de Implementación

### ✅ SwiftUI (Universal: iOS, macOS, iPadOS, watchOS, tvOS, visionOS)
```swift
// Vista usando clave semántica nativa
struct LoginView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("auth.login.title", comment: "Título de la pantalla de inicio de sesión")
                .font(.largeTitle)

            Button("auth.login.button_submit", comment: "Botón para iniciar sesión") {
                // Acción
            }
        }
    }
}

// Cadenas interpoladas con parámetros posicionales
let welcomeText = String(
    localized: "home.welcome.user_greeting \(userName)",
    defaultValue: "Welcome, \(userName)!",
    comment: "Saludo de bienvenida al usuario"
)
```

### ✅ UIKit (iOS / iPadOS / tvOS / visionOS / Mac Catalyst)
```swift
// En UIViewController o UIView
titleLabel.text = NSLocalizedString(
    "auth.login.title",
    tableName: "Localizable",
    bundle: .main,
    value: "Welcome Back",
    comment: "Título de la pantalla de inicio de sesión"
)

// Cadena formateada con parámetros posicionales
let count = 5
statusLabel.text = String(
    format: NSLocalizedString("cart.items_count", comment: "Número de artículos en carrito"),
    count
)
```

### ✅ AppKit (macOS nativo)
```swift
// En NSViewController, NSWindowController o menús macOS
submitButton.title = NSLocalizedString(
    "auth.login.button_submit",
    tableName: "Localizable",
    bundle: .main,
    value: "Log In",
    comment: "Botón para iniciar sesión en macOS"
)

// Elemento de menú de barra superior en macOS
let exportMenuItem = NSMenuItem(
    title: NSLocalizedString("menu.file.export_pdf", comment: "Opción exportar a PDF en menú Archivo"),
    action: #selector(exportPDF),
    keyEquivalent: "E"
)
```

### ❌ Prácticas Prohibidas
```swift
// ❌ Texto hardcodeado directamente
Text("Iniciar Sesión")
Button("Aceptar") { ... }
submitButton.title = "Guardar"

// ❌ Concatenación manual sin soporte i18n
let mensaje = "Hola " + usuario.nombre + ", tienes " + String(items) + " mensajes."

// ❌ Traducir solo en inglés y español olvidando el resto de idiomas obligatorios
```

---

## 4. Estructura de Datos en String Catalog (`Localizable.xcstrings`)
```json
{
  "sourceLanguage" : "en",
  "strings" : {
    "auth.login.button_submit" : {
      "comment" : "Botón para iniciar sesión",
      "localizations" : {
        "en" : { "stringUnit" : { "state" : "translated", "value" : "Log In" } },
        "es" : { "stringUnit" : { "state" : "translated", "value" : "Iniciar sesión" } },
        "fr" : { "stringUnit" : { "state" : "translated", "value" : "Se connecter" } },
        "de" : { "stringUnit" : { "state" : "translated", "value" : "Anmelden" } },
        "pt" : { "stringUnit" : { "state" : "translated", "value" : "Entrar" } },
        "zh-Hans" : { "stringUnit" : { "state" : "translated", "value" : "登录" } }
      }
    }
  },
  "version" : "1.0"
}
```

---

## 5. Checklist de Verificación (Definición de Hecho / DoD)
- [ ] ¿Hay **cero** strings hardcodeados en el código Swift (SwiftUI, UIKit, AppKit)?
- [ ] ¿Las claves siguen el formato jerárquico `[módulo].[sección].[elemento]`?
- [ ] ¿Se han incluido traducciones para **todos los 6 idiomas** (`en`, `es`, `fr`, `de`, `pt`, `zh-Hans`)?
- [ ] ¿Las cadenas con formato usan especificadores posicionales (`%1$@`, `%2$d`) si tienen más de una variable?
- [ ] ¿Se incluye el atributo `comment` para aportar contexto semántico a la traducción?
