-- =============================================================
-- Consultas de negocio
-- Cada consulta inicia con "-- @consulta:" para que ejecutar.py
-- pueda separarlas y mostrarlas con su título.
-- =============================================================

-- @consulta: 1. Inventario actual con categoría y proveedor
SELECT p.nombre       AS producto,
       c.nombre       AS categoria,
       pr.nombre      AS proveedor,
       p.stock,
       p.precio_venta
  FROM productos p
  JOIN categorias c       ON c.id = p.categoria_id
  LEFT JOIN proveedores pr ON pr.id = p.proveedor_id
 ORDER BY c.nombre, p.nombre;

-- @consulta: 2. Productos que hay que resurtir (stock en o por debajo del mínimo)
SELECT nombre, stock, stock_minimo, faltante, proveedor, telefono
  FROM v_productos_bajo_stock
 ORDER BY faltante DESC;

-- @consulta: 3. Los 5 productos más vendidos
SELECT nombre, unidades, ingreso
  FROM v_ventas_por_producto
 ORDER BY unidades DESC
 LIMIT 5;

-- @consulta: 4. Ingresos por mes
SELECT strftime('%Y-%m', v.fecha)                  AS mes,
       COUNT(DISTINCT v.id)                        AS num_ventas,
       ROUND(SUM(d.cantidad * d.precio_unitario), 2) AS ingreso
  FROM ventas v
  JOIN detalle_venta d ON d.venta_id = v.id
 GROUP BY mes
 ORDER BY mes;

-- @consulta: 5. Ganancia por categoría
SELECT c.nombre                    AS categoria,
       SUM(vp.unidades)            AS unidades,
       ROUND(SUM(vp.ingreso), 2)   AS ingreso,
       ROUND(SUM(vp.ganancia), 2)  AS ganancia
  FROM v_ventas_por_producto vp
  JOIN productos p  ON p.id = vp.id
  JOIN categorias c ON c.id = p.categoria_id
 GROUP BY c.nombre
 ORDER BY ganancia DESC;

-- @consulta: 6. Valor del inventario (a costo y a precio de venta)
SELECT SUM(stock)                          AS piezas,
       ROUND(SUM(stock * costo), 2)        AS valor_a_costo,
       ROUND(SUM(stock * precio_venta), 2) AS valor_a_precio_venta
  FROM productos;

-- @consulta: 7. Ticket promedio por venta
SELECT ROUND(AVG(total), 2) AS ticket_promedio,
       ROUND(MAX(total), 2) AS venta_mayor,
       ROUND(MIN(total), 2) AS venta_menor
  FROM (SELECT venta_id, SUM(cantidad * precio_unitario) AS total
          FROM detalle_venta
         GROUP BY venta_id);

-- @consulta: 8. Productos que nunca se han vendido
SELECT p.nombre, p.stock
  FROM productos p
  LEFT JOIN detalle_venta d ON d.producto_id = p.id
 WHERE d.producto_id IS NULL;
