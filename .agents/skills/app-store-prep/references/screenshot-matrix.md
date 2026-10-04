# Matriz Oficial de Resoluciones de Screenshots (App Store Connect)

Esta guía recopila las dimensiones exactas en píxeles admitidas por Apple para capturas de pantalla de la App Store y Mac App Store.

---

## 📱 iOS (iPhone)

| Dispositivo / Tamaño | Dimensiones (Retrato) | Dimensiones (Paisaje) | Obligatorio / Requerido |
| :--- | :--- | :--- | :--- |
| **iPhone 6.9" Display** (iPhone 16 Pro Max) | **1320 x 2868 px** | **2868 x 1320 px** | Recomendado (última gen) |
| **iPhone 6.7" Display** (iPhone 15 Pro Max, 14 Pro Max) | **1290 x 2796 px** | **2796 x 1290 px** | **Obligatorio** (o 6.9") |
| **iPhone 6.5" Display** (iPhone 11 Pro Max, XS Max) | **1242 x 2688 px** | **2688 x 1242 px** | **Obligatorio** (dispositivos notch) |
| **iPhone 5.5" Display** (iPhone 8 Plus, 7 Plus) | **1242 x 2208 px** | **2208 x 1242 px** | Recomendado (pantallas 16:9 con botón Home) |
| **iPhone 4.7" Display** (iPhone SE 2ª/3ª gen) | **750 x 1334 px** | **1334 x 750 px** | Opcional |

> 💡 *Nota*: Si subes capturas de 6.7" o 6.9", Apple escalará automáticamente para pantallas similares si no se suministran explícitamente.

---

## 📱 iPadOS (iPad)

| Dispositivo / Tamaño | Dimensiones (Retrato) | Dimensiones (Paisaje) | Obligatorio / Requerido |
| :--- | :--- | :--- | :--- |
| **iPad Pro 13" (M4)** | **2064 x 2752 px** | **2752 x 2064 px** | **Obligatorio** si la app soporta iPad |
| **iPad Pro 12.9" (Generaciones 2 a 6)** | **2048 x 2732 px** | **2732 x 2048 px** | Aceptado como alternativa a 13" |
| **iPad 11" / iPad Air** | **1668 x 2388 px** | **2388 x 1668 px** | Opcional (se escala de 12.9"/13") |

---

## 💻 macOS (Mac App Store)

| Proporción / Resolución | Dimensiones | Requisitos |
| :--- | :--- | :--- |
| **Proporción 16:10 (Estándar Retina)** | **2880 x 1800 px** *(Recomendado)* | Sin esquinas redondeadas en el marco exterior |
| **Proporción 16:10 (Resolución alternativa)** | **2560 x 1600 px** | |
| **Proporción 16:10 (Escritorio)** | **1440 x 900 px** | Mínimo admitido |
| **Proporción 16:9 (Opcional)** | **1920 x 1080 px** | |

---

## ⌚ watchOS (Apple Watch)

| Modelo | Dimensiones |
| :--- | :--- |
| **Apple Watch Ultra (49mm)** | **410 x 502 px** |
| **Apple Watch Series 10 (46mm)** | **416 x 496 px** |
| **Apple Watch Series 7/8/9 (45mm)** | **396 x 484 px** |

---

## 🥽 visionOS (Apple Vision Pro)

| Modelo | Dimensiones |
| :--- | :--- |
| **Apple Vision Pro** | **3840 x 2160 px** (4K UHD) |

---

## ⚙️ Reglas Técnicas y Formatos
- **Formatos admitidos**: PNG de 72 dpi o JPEG plano (RGB de 24 bits sin capas ni canal alfa).
- **Límite de capturas**: Mínimo 1, máximo 10 capturas por dispositivo y por idioma.
- **Sin barras de estado desalineadas**: En capturas reales, asegurar hora `9:41 AM`, batería al 100% y señal Wi-Fi/celular llena (estándar Apple *Clean Status Bar*).
