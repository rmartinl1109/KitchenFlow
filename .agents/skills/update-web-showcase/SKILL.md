---
name: update-web-showcase
description: >-
  Procedimiento para actualizar la Landing Page de publicación oficial en /web (en inglés) cada vez que se añade una nueva funcionalidad o mejora a la aplicación en cualquier plataforma Apple (iOS, macOS, iPadOS, watchOS, tvOS, visionOS o Multiplataforma).
---

# Skill: Actualización de la Landing Page de Publicación (`/web`)

Este procedimiento asegura que la web oficial de comercialización y publicación de la aplicación en `/web` refleje continuamente el crecimiento del proyecto con un diseño comercial en inglés de alto impacto, listo para usuarios y clientes globales de cualquier plataforma de Apple.

---

## 📋 Archivos Involucrados
- Archivos modificados en el proyecto principal (nuevas pantallas, vistas, servicios o capacidades).
- Archivos del sitio web de publicación:
  - [`/web/index.html`](../../../web/index.html): Estructura de la Landing Page en inglés (Hero, Features, Interactive Demo, FAQ, Footer).
  - [`/web/app.js`](../../../web/app.js): Lógica del simulador o mockup interactivo del dispositivo/ventana (iPhone, iPad, macOS, etc.), acordeón FAQ y modo oscuro.

---

## 🚀 Procedimiento Paso a Paso

### Paso 1: Identificar el Valor Comercial en Inglés
- Analizar la funcionalidad recién implementada en el proyecto.
- Convertir los aspectos técnicos en **beneficios tangibles para el usuario en inglés**:
  - *Ejemplo iOS/iPadOS:* "Offline-first sync engine: Keep working without interruption anywhere; data automatically syncs when reconnected."
  - *Ejemplo macOS:* "Native menu bar integration and keyboard shortcuts: Instant productivity directly from your Mac desktop."
  - *Ejemplo Universal:* "Seamless continuity across Mac, iPad, and iPhone via iCloud Keychain and CloudKit."

### Paso 2: Incorporar la Característica en el Escaparate Web (`index.html`)
- Añadir la tarjeta o bloque visual en la sección de **Features** de [`/web/index.html`](../../../web/index.html) con su icono y textos en inglés.
- Si la característica es específica de una plataforma (ej. macOS Menubar, iPad Apple Pencil, iPhone Dynamic Island), destacar el badge correspondiente.

### Paso 3: Actualizar el Simulador o Mockup Interactivo (`app.js`)
- Si la funcionalidad tiene una pantalla o vista visual clave, agregar o actualizar la vista correspondiente en el mockup o simulador interactivo de [`/web/app.js`](../../../web/app.js) para que los visitantes puedan interactuar con ella.

### Paso 4: Validar Llamadas a la Acción (CTA) y Despliegue
1. Comprobar que los botones de acción (*"Download on the App Store"*, *"Get for Mac"*, *"Try Live Demo"*) funcionen correctamente según la plataforma.
2. Verificar el modo oscuro/claro y el diseño responsivo en móvil y escritorio.

