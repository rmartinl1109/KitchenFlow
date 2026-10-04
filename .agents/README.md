# Estructura de Customizaciones (.agents)

Esta carpeta contiene la configuración personalizada para el asistente Antigravity en este espacio de trabajo.

## 📁 Estructura del Directorio

```text
.agents/
├── README.md               # Esta guía explicativa
├── rules/                  # Reglas y estándares de comportamiento / código
│   ├── 00-general.md       # Reglas base de estilo y ejecución
│   └── template-rule.md    # Plantilla para crear nuevas reglas
└── skills/                 # Procedimientos y runbooks paso a paso (on-demand)
    └── template-skill/     # Skill modelo / plantilla
        ├── SKILL.md        # Definición principal del skill con frontmatter YAML
        ├── scripts/        # Scripts de automatización y soporte
        ├── references/     # Documentación extensa o manuales de referencia
        └── examples/       # Ejemplos de uso, entrada/salida
```

---

## 🧭 ¿Cuándo usar una Rule vs un Skill?

| Tipo | Dónde se ubica | Cuándo se usa | Propósito |
| :--- | :--- | :--- | :--- |
| **Rules** | `.agents/rules/*.md` o `AGENTS.md` | Siempre activas o por contexto | Estándares de codificación, restricciones de seguridad, convenciones de nombres, formato de respuestas. |
| **Skills** | `.agents/skills/<nombre>/SKILL.md` | Bajo demanda (On-Demand) | Tareas procedimentales complejas, flujos de trabajo multi-paso, troubleshooting estructurado, migraciones, scripts repetitivos. |

---

## 🛠️ Cómo crear una nueva Rule
1. Crea un archivo `.md` dentro de `.agents/rules/` (ej. `sql-standards.md`, `git-flow.md`).
2. Redacta las directrices en Markdown limpio (puedes duplicar [`template-rule.md`](./rules/template-rule.md)).
3. El agente cargará automáticamente estas reglas en su contexto.

---

## ⚡ Cómo crear un nuevo Skill
1. Crea una carpeta dentro de `.agents/skills/<nombre-del-skill>/` (ej. `deploy-dba-scripts/`). Usa minúsculas y guiones.
2. Crea el archivo `SKILL.md` dentro de dicha carpeta.
3. Incluye obligatoriamente el encabezado YAML (**frontmatter**):
   ```yaml
   ---
   name: nombre-del-skill
   description: >-
     Describe en tercera persona qué hace el skill y exactamente cuándo debe activarlo el agente.
   ---
   ```
4. Define las secciones:
   - **Objetivo / Resumen**
   - **Requisitos previos**
   - **Instrucciones paso a paso**
   - **Verificación / Validación de resultados**
5. Opcionalmente añade carpetas:
   - `scripts/`: Scripts ejecutables (PowerShell, SQL, Python, bash, etc.).
   - `references/`: Documentación densa que solo se consultará si es necesario (Progressive Disclosure).
   - `examples/`: Casos prácticos y ejemplos.
