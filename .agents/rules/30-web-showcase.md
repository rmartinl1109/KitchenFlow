# Regla: Sitio Web Oficial y Landing Page de Publicación (/web)

> **Propósito**: Mantener una Landing Page moderna, atractiva e interactiva en la carpeta `/web` de la raíz del proyecto, concebida para **publicar, comercializar y promocionar la aplicación ante usuarios finales y clientes a nivel global**. Esta web está desarrollada en **inglés**, lista para desplegarse directamente en cualquier hosting estático (GitHub Pages, Cloudflare Pages, Vercel, Netlify o servidor propio). Aplica a cualquier proyecto Xcode del ecosistema Apple (iOS, macOS, iPadOS, watchOS, tvOS, visionOS o Multiplataforma).

---

## 1. Directrices Principales

### 1.1 Naturaleza del Sitio Web e Idioma
- La carpeta `/web` contiene el **sitio web de producto / marketing / presentación oficial** de la aplicación, no una herramienta interna de desarrollo.
- **Idioma del Sitio Web**: **Inglés exclusivamente (`en`)** como estándar global de comercialización internacional. (Nota: La aplicación nativa mantiene su soporte en los 6 idiomas según la regla `10-localization.md`, y la web puede destacar este soporte multi-idioma como una de sus ventajas competitivas clave).
- **Despliegue Cero-Configuración (Zero-Build)**:
  - HTML5 semántico en inglés, optimizado para SEO y conversión.
  - **Tailwind CSS** vía CDN oficial (`https://cdn.tailwindcss.com`) con estética premium, moderna y pulida.
  - **JavaScript vainilla modular** para interactividad (acordeón FAQ, navegación de pantallas en el simulador/mockup, modo oscuro/claro).
  - Totalmente lista para ser publicada simplemente apuntando el hosting a la carpeta `/web`.

### 1.2 Secciones Esenciales de la Landing Page
1. **Barra de Navegación (Header)**:
   - Logotipo y nombre del producto.
   - Enlaces a secciones: *Features*, *Live Demo*, *FAQ*.
   - Conmutador de modo claro / modo oscuro.
   - Botón de llamada a la acción principal (CTA: *"Download on the App Store"*, *"Get for Mac"*, o *"Get Started"*).
2. **Hero Section (Impacto Visual Inmediato)**:
   - Titular de alto impacto y subtítulo orientado a beneficios del usuario en inglés.
   - Badges o menciones a las plataformas soportadas (ej. *Available on iPhone, iPad & Mac*).
   - Botones de acción principales (*Download*, *Try Live Demo*).
   - Mockup visual o interactivo del producto mostrando la aplicación en funcionamiento en el marco de dispositivo correspondiente (iPhone, iPad, ventana de macOS o visor universal).
3. **Escaparate de Funcionalidades (Features Showcase)**:
   - Cuadrícula con las capacidades del proyecto explicadas desde la perspectiva de valor para el usuario.
   - Cada vez que el proyecto incorpora una nueva funcionalidad, se añade su correspondiente tarjeta comercial en inglés.
4. **Preguntas Frecuentes (FAQ)** y Soporte.
5. **Llamada a la Acción Final (Banner CTA)** y **Footer** (términos legales, privacidad y copyright).

---

## 2. Instrucciones para el Agente

Cada vez que se añada, modifique o complete una funcionalidad en el proyecto principal:
1. **Traducir el valor técnico a valor comercial en inglés**: Redactar el beneficio directo para el usuario final con un lenguaje persuasivo, conciso y profesional en inglés (ej. *"Seamless iCloud sync across iPhone, iPad, and Mac for uninterrupted workflow"*).
2. **Actualizar el escaparate en `/web`**:
   - Añadir la nueva funcionalidad en la sección de características de `index.html`.
   - Si la funcionalidad tiene una vista visual destacable, actualizar la pantalla interactiva del mockup en `app.js` en el formato del dispositivo adecuado.
3. **Mantener la web lista para producción**: Asegurar que todos los enlaces, botones de descarga, imágenes y estilos funcionen sin dependencias locales rotas.

---

## 3. Checklist de Verificación (Definición de Hecho / DoD)
- [ ] ¿La landing page en `/web` presenta la app orientada al usuario/cliente final en inglés?
- [ ] ¿Se reflejan con claridad las plataformas de Apple para las que está disponible la app?
- [ ] ¿Las nuevas funcionalidades añadidas al proyecto están reflejadas en la web con textos persuasivos en inglés?
- [ ] ¿Incluye botones claros de llamada a la acción (descarga, App Store o acceso anticipado)?
- [ ] ¿El simulador/mockup interactivo permite probar las pantallas clave de la app?
- [ ] ¿Se puede publicar directamente en un hosting estático sin requerir comandos de compilación previa?
