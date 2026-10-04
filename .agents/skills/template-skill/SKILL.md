---
name: template-skill
description: >-
  Plantilla base para crear nuevos skills. Utiliza este formato para enseñar al
  agente procedimientos paso a paso, flujos de trabajo específicos o resolución de problemas.
---

# Plantilla de Skill: [Nombre del Flujo / Procedimiento]

Breve introducción de qué objetivo cumple este skill y qué resultados se esperan obtener tras su ejecución.

---

## 📋 Requisitos Previos y Entorno
- Herramientas o permisos necesarios (ej. PowerShell 7+, SQL Server Management Studio, Azure CLI, etc.).
- Variables de entorno o accesos requeridos.

---

## 🚀 Procedimiento Paso a Paso

### Paso 1: Preparación / Diagnóstico Inicial
Describe qué debe comprobar el agente antes de empezar o qué comandos debe ejecutar:
- Ejecutar verificación previa:
  ```powershell
  # Comando de verificación
  Get-Service -Name "MSSQLSERVER"
  ```

### Paso 2: Ejecución de la Tarea Principal
- Indicar los pasos ordenados.
- Si existe un script de apoyo, referenciarlo de forma relativa:
  - Ver script de automatización: [run.ps1](./scripts/run.ps1)

### Paso 3: Validación y Confirmación de Éxito
Instrucciones para validar que el proceso concluyó correctamente:
1. Comprobar que no hay errores en la salida.
2. Validar el estado final del servicio o dato.

---

## ⚠️ Casos Borde y Troubleshooting
- **Problema conocido A**: Causa y solución inmediata.
- **Problema conocido B**: Alternativa o procedimiento de rollback.

---

## 📚 Referencias Adicionales
Para detalles técnicos extensos o manuales completos, consultar:
- [Documentación detallada](./references/detalles.md)
- [Ejemplos de casos de uso](./examples/ejemplo-uso.md)
