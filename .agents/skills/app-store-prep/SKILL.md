---
name: app-store-prep
description: >-
  Procedimiento integral para preparar, generar y validar todos los activos y metadatos de publicación en App Store Connect (iOS, macOS, iPadOS, watchOS, visionOS): textos ASO en 6 idiomas, especificaciones de AppIcon, matriz de screenshots y URLs de soporte/privacidad.
---

# Skill: Preparación para Publicación en App Store Connect (`app-store-prep`)

Este procedimiento guía al agente y al desarrollador en la recopilación, redacción ASO (App Store Optimization), validación técnica y empaquetado de todos los metadatos y activos visuales necesarios para publicar o actualizar una aplicación en **App Store Connect** para cualquier plataforma de Apple.

---

## 📋 Entorno y Archivos Involucrados
- Metadatos generados: Carpeta `AppStore/` o `metadata/` (compatible con el formato canónico de App Store Connect y herramientas como Fastlane `deliver`).
- Assets visuales del proyecto: `Assets.xcassets/AppIcon.appiconset/`.
- URLs públicas de soporte y privacidad: Proporcionadas directamente por la carpeta [`/web`](../../../web/index.html).

---

## 🚀 Procedimiento Paso a Paso

### Paso 1: Generación de Metadatos ASO en los 6 Idiomas Obligatorios
Para cada uno de los 6 idiomas del proyecto (`en-US`, `es-ES`, `fr-FR`, `de-DE`, `pt-BR`, `zh-Hans`), generar y validar los siguientes campos respetando estrictamente los límites de caracteres de Apple:

| Campo | Límite Máximo | ¿Modificable sin nueva versión? | Buenas Prácticas ASO |
| :--- | :--- | :--- | :--- |
| **App Name** | **30 caracteres** | ❌ Solo con nueva versión | Nombre de la marca + 1-2 palabras clave de mayor volumen de búsqueda (ej. `ProyectoBase – Task Planner`). |
| **Subtitle** | **30 caracteres** | ❌ Solo con nueva versión | Propuesta de valor clara, concisa y persuasiva que complemente al título sin repetir palabras. |
| **Promotional Text** | **170 caracteres** | ✅ En cualquier momento | Destaca ofertas, novedades destacadas o eventos temporales. Aparece sobre la descripción. |
| **Keywords** | **100 caracteres** | ❌ Solo con nueva versión | Palabras separadas por comas **sin espacios tras la coma** (ej. `tasks,planner,focus,todo`). Prohibido incluir nombres de marcas registradas o palabras ya presentes en el título/subtítulo. |
| **Description** | **4.000 caracteres** | ❌ Solo con nueva versión | Estructurada en: 1) Gancho emocional (primeras 3 líneas visibles antes de "más"), 2) Características clave en viñetas, 3) Credenciales/reconocimientos, 4) Llamada a la acción. |
| **What's New** | **4.000 caracteres** | ❌ Solo en actualizaciones | Registro de cambios claro y amigable para el usuario, evitando textos genéricos ("corrección de errores"). |

> 📌 *Consultar la plantilla completa en [`examples/metadata-template.json`](./examples/metadata-template.json).*

---

### Paso 2: Especificaciones del Icono de la Aplicación (`AppIcon`)
Verificar o generar el icono base respetando los requisitos de Apple según el target:

1. **iOS / iPadOS**:
   - **Tamaño**: `1024 x 1024 px` (PNG o JPEG, espacio de color sRGB o P3).
   - **Forma y Fondo**: Cuadrado perfecto con esquinas rectas (Apple aplica automáticamente la máscara de curvatura *squircle*).
   - **Canal Alfa**: **Estrictamente prohibido**. No debe tener transparencias (causa rechazo en validación de App Store Connect).
2. **macOS**:
   - **Tamaño**: `1024 x 1024 px`.
   - **Diseño**: Debe seguir la cuadrícula de diseño de macOS (icono con padding, perspectiva frontal y sombra sutil integrada en el lienzo, con fondo transparente exterior cuando la forma no ocupe todo el lienzo).
3. **watchOS**:
   - Icono circular visible, optimizado para fondos oscuros.
4. **visionOS**:
   - Composición por capas (fondo, elemento central, elemento frontal) con sensación de profundidad espacial.

---

### Paso 3: Guía y Matriz de Screenshots
App Store Connect requiere capturas de pantalla específicas para los tamaños de pantalla principales de cada plataforma objetivo.

1. **Resoluciones Críticas Obligatorias**:
   - **iPhone 6.9" / 6.7" (Display Super Retina)**: `1320 x 2868 px` o `1290 x 2796 px`.
   - **iPhone 6.5" (Generaciones anteriores)**: `1242 x 2688 px`.
   - **iPad Pro 13" / 12.9"**: `2064 x 2752 px` o `2048 x 2732 px`.
   - **Mac (Desktop)**: Proporción 16:10, típicamente `2880 x 1800 px` o `2560 x 1600 px`.
   *(Ver tabla exhaustiva con todas las resoluciones en [`references/screenshot-matrix.md`](./references/screenshot-matrix.md)).*

2. **Narrativa Visual Recomendada (Mínimo 4-5 Screenshots por idioma)**:
   - **Captura 1 (El Gancho)**: La pantalla más atractiva o el beneficio principal resuelto en una frase concisa arriba.
   - **Captura 2 (Flujo Principal)**: Demostración de cómo se realiza la tarea clave en segundos.
   - **Captura 3 (Diferenciador)**: Función avanzada (ej. sincronización iCloud, Face ID, widgets o soporte multilingüe).
   - **Captura 4 (Modo Oscuro o Personalización)**: Variedad visual atractiva.
   - **Captura 5 (Respaldo y Seguridad)**: Privacidad, cifrado local o integración nativa.

---

### Paso 4: Enlaces Obligatorios de Publicación (Hosting en `/web`)
Apple exige URLs públicas y funcionales antes de enviar a revisión. Estas URLs se obtienen del despliegue del escaparate en `/web`:
- **Support URL**: `https://[tudominio]/#faq` o enlace directo a contacto/soporte.
- **Marketing URL (Opcional pero recomendado)**: `https://[tudominio]/` (la Landing Page principal de `/web`).
- **Privacy Policy URL (Obligatoria)**: `https://[tudominio]/privacy.html` o anclaje a la sección de política de privacidad del footer de `/web`.

---

### Paso 5: Generación del Directorio de Salida (`AppStore/`)
Cuando se solicite preparar los metadatos de un proyecto, generar o actualizar los archivos en la carpeta `AppStore/metadata/`:
```text
AppStore/
├── metadata/
│   ├── default/
│   │   ├── copyright.txt
│   │   ├── primary_category.txt
│   │   └── secondary_category.txt
│   ├── en-US/
│   │   ├── name.txt
│   │   ├── subtitle.txt
│   │   ├── promotional_text.txt
│   │   ├── keywords.txt
│   │   ├── description.txt
│   │   └── release_notes.txt
│   ├── es-ES/ ...
│   ├── fr-FR/ ...
│   ├── de-DE/ ...
│   ├── pt-BR/ ...
│   └── zh-Hans/ ...
└── screenshots/
    ├── iPhone-6.9/
    ├── iPad-13/
    └── Mac/
```

---

## ✅ Checklist de Validación Final (Pre-Envío)
- [ ] ¿Los nombres (`name.txt`) tienen 30 caracteres o menos en todos los 6 idiomas?
- [ ] ¿Los subtítulos (`subtitle.txt`) tienen 30 caracteres o menos en todos los 6 idiomas?
- [ ] ¿Las palabras clave (`keywords.txt`) no superan los 100 caracteres y están separadas solo por comas sin espacios?
- [ ] ¿El icono de iOS no contiene canal alfa / transparencias?
- [ ] ¿Las screenshots están en formato PNG/JPEG y coinciden con las dimensiones oficiales exactas de píxeles?
- [ ] ¿Las URLs de soporte y política de privacidad cargan correctamente?
