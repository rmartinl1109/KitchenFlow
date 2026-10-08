---
name: pre-release-qa
description: >-
  Procedimiento integral de control de calidad, auditoría estricta pre-lanzamiento, ejecución de tests automatizados y despliegue beta en TestFlight o dispositivos físicos (iOS, watchOS, iPadOS, macOS).
---

# Skill: Control de Calidad y Despliegue Beta Pre-Lanzamiento (`pre-release-qa`)

Este procedimiento guía al agente y al desarrollador en la auditoría exhaustiva, validación técnica, ejecución de pruebas automatizadas y despliegue previo a la publicación en **App Store Connect** para cualquier plataforma Apple (iOS, watchOS, iPadOS, macOS).

---

## 📋 Entorno y Prerrequisitos
- **Xcode 15+** instalado con herramientas de línea de comandos activas (`xcode-select -p`).
- Simuladores instalados para las plataformas objetivo (ej. iPhone con iOS 17+, Apple Watch con watchOS 10+).
- Dispositivo físico con **Modo Desarrollador** activado (para pruebas directas).
- Cuenta activa en **Apple Developer Program** (para subida a TestFlight y App Store Connect).

---

## 🚀 Procedimiento Paso a Paso

### Paso 1: Compilación Estricta y Detección de Warnings
Realizar una compilación limpia analizando la salida en busca de advertencias, deprecaciones de API o violaciones de concurrencia:

```bash
# Limpiar y compilar el target principal de iOS
xcodebuild clean build \
  -scheme "KitchenFlow" \
  -destination "generic/platform=iOS" \
  -configuration Release \
  CODE_SIGNING_ALLOWED=NO

# Si el proyecto cuenta con companion app para watchOS:
xcodebuild clean build \
  -scheme "KitchenFlowWatch" \
  -destination "generic/platform=watchOS" \
  -configuration Release \
  CODE_SIGNING_ALLOWED=NO
```

**Criterio de aprobación**: 0 errores de compilación y 0 warnings críticos. Resolver cualquier mensaje de deprecación o advertencia de Swift Concurrency antes de continuar.

---

### Paso 2: Ejecución de Tests Automatizados (Unit & UI Tests)
Ejecutar la suite completa de pruebas unitarias y de integración para validar la lógica de negocio y persistencia:

```bash
# Ejecutar tests en un simulador de iPhone
xcodebuild test \
  -scheme "KitchenFlow" \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=latest"
```

**Verificaciones clave**:
1. Motores de temporización y cuentas atrás (`CookingTimerEngine`): transiciones correctas de fase y disparadores de intervalo.
2. Modelos de datos y SwiftData: creación, edición, borrado y persistencia de recetas y pasos.
3. Reglas de negocio Freemium: bloqueo riguroso al intentar superar la cuota gratuita (1 receta propia).

---

### Paso 3: Auditoría Estricta de Localización (6 Idiomas)
Cumpliendo la regla del repositorio de **cero cadenas hardcodeadas**, auditar que todo texto de la interfaz provenga de los catálogos `.xcstrings`:

1. **Búsqueda de cadenas hardcodeadas**: Inspeccionar vistas SwiftUI para evitar `Text("literal")`, `Button("literal")` o títulos directos no semánticos.
2. **Paridad de traducción**: Verificar que los archivos `Localizable.xcstrings` contengan traducciones completas en los **6 idiomas obligatorios**:
   - `en` (Inglés)
   - `es` (Español)
   - `fr` (Francés)
   - `de` (Alemán)
   - `pt` (Portugués)
   - `zh-Hans` (Chino Simplificado)
3. **Selector dinámico de idioma**: Comprobar que el cambio manual en Ajustes y el valor por defecto del sistema se propaguen reactivamente.

---

### Paso 4: Auditoría de Casos Límite y Flujos Críticos
Verificar manualmente o mediante scripts los escenarios que suelen provocar rechazos por parte del equipo de revisión de Apple:

| Área Crítica | Qué comprobar | Riesgo si falla |
| :--- | :--- | :--- |
| **StoreKit 2 / Paywall** | Botón de "Restaurar Compras" visible, enlaces a Términos de Uso y Política de Privacidad funcionales. | Rechazo según Guía de Revisión 3.1.2. |
| **SwiftData / CloudKit** | Fallback local resiliente en caso de que iCloud esté desactivado o no haya conexión a Internet. | Cierre inesperado (*crash*) en primer arranque. |
| **Live Activities** | Iniciar, actualizar intervalo y finalizar sesión de cocina limpiamente sin dejar actividades zombies. | Mala experiencia de usuario en Dynamic Island. |
| **AppIcon** | Icono de 1024x1024 px **sin canal alfa** (`hasAlpha: no`). | Error inmediato de validación al subir el binario. |
| **Versionado** | Incrementar `CFBundleVersion` (Build number) respecto a cualquier versión subida previamente. | Conflicto de binario duplicado en App Store Connect. |

---

### Paso 5: Distribución y Pruebas en Dispositivos Reales

#### Opción A: Distribución Beta con TestFlight (Recomendada)
Para probar en condiciones idénticas a la App Store y compartir con evaluadores externos:

1. **Generar Archive en Xcode**:
   - Menú: `Product > Archive`.
   - Una vez completado en el *Organizer*, pulsar **Distribute App > Custom > App Store Connect > Upload**.
2. **Configuración en App Store Connect**:
   - Ir a [appstoreconnect.apple.com](https://appstoreconnect.apple.com) > Tu App > pestaña **TestFlight**.
   - **Pruebas Internas**: Asignar al equipo interno (disponibilidad inmediata, hasta 100 personas).
   - **Pruebas Externas**: Crear grupo (ej. *"Betatesters"*), invitar por email o habilitar un **Enlace Público** (*Public Link*).
3. **Experiencia del Tester**:
   - Descarga la app gratuita **TestFlight** desde la App Store.
   - Acepta la invitación o pulsa el enlace público e instala la versión.
   - Compras dentro de la app (StoreKit) son automáticas y gratuitas en entorno *Sandbox*.
4. **Al publicar en App Store**:
   - La versión pública reemplaza a la de TestFlight sin perder datos locales (mismo *Bundle Identifier*).
   - Marcar la compilación beta como expirada (*Expire Build*) para guiar a los evaluadores a la tienda pública.

#### Opción B: Instalación Directa desde Xcode (Cable o Wi-Fi)
Para pruebas rápidas de desarrollador en el dispositivo físico:
1. En el iPhone/iPad: ir a *Ajustes > Privacidad y seguridad > Modo de desarrollador* y reiniciar el dispositivo.
2. Conectar el dispositivo por cable o activar "Connect via network" en el *Devices and Simulators* de Xcode.
3. Seleccionar el dispositivo como destino de ejecución y pulsar `Cmd + R` (*Run*).
4. **Vigencia del perfil**:
   - Cuenta Apple ID gratuita: perfil válido durante **7 días**.
   - Apple Developer Program de pago: perfil válido durante **1 año**.

---

## ✅ Checklist de Salida (Definition of Done Pre-Release)
Antes de enviar a revisión final en App Store Connect, verificar:
- [ ] Compilación limpia sin warnings en Release mode.
- [ ] Todos los tests automatizados pasan al 100%.
- [ ] Cero textos hardcodeados; 6 idiomas verificados en `Localizable.xcstrings`.
- [ ] AppIcon de 1024x1024 sin transparencias.
- [ ] Enlaces legales de Privacidad y Términos funcionando en `/web`.
- [ ] Metadatos y capturas ASO en 6 idiomas generados según la skill `app-store-prep`.
- [ ] Pruebas satisfactorias en al menos un dispositivo físico (TestFlight o Xcode).
