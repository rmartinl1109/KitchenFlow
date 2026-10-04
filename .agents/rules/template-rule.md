# [Título de la Regla o Estándar]

> **Propósito**: Describe brevemente qué aspecto del proyecto regula este documento (por ejemplo: convenciones de SQL, nomenclatura de objetos, directrices de seguridad, control de versiones).

---

## 1. Directrices Principales
- **Punto 1**: Detalla la regla específica o estándar esperado.
- **Punto 2**: Restricciones de diseño o patrones prohibidos.
- **Punto 3**: Requisitos obligatorios al generar o editar código en este ámbito.

## 2. Ejemplos

### ✅ Código Recomendado / Estándar
```sql
-- Ejemplo de formato correcto
SELECT id, nombre, estado
FROM dbo.Clientes
WHERE activo = 1;
```

### ❌ Prácticas a Evitar
```sql
-- Ejemplo de lo que NO se debe hacer
SELECT * FROM Clientes;
```

## 3. Checklist de Verificación
- [ ] ¿Cumple con la nomenclatura definida?
- [ ] ¿Incluye validaciones y manejo de excepciones?
- [ ] ¿Ha sido probado en un entorno seguro antes de proponer cambios?
