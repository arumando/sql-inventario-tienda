-- =============================================================
-- Datos de ejemplo (FICTICIOS) para probar la base de datos
-- =============================================================

PRAGMA foreign_keys = ON;

INSERT INTO categorias (id, nombre) VALUES
    (1, 'Abarrotes'),
    (2, 'Bebidas'),
    (3, 'Limpieza'),
    (4, 'Lácteos');

INSERT INTO proveedores (id, nombre, telefono, correo) VALUES
    (1, 'Proveedor A', '000-000-0001', 'ventas@proveedor-a.ejemplo'),
    (2, 'Proveedor B', '000-000-0002', 'contacto@proveedor-b.ejemplo'),
    (3, 'Proveedor C', '000-000-0003', NULL);

-- Stock inicial antes de las ventas
INSERT INTO productos (id, nombre, categoria_id, proveedor_id, costo, precio_venta, stock, stock_minimo) VALUES
    (1,  'Arroz 1 kg',             1, 1, 22.00, 30.00, 40, 10),
    (2,  'Frijol negro 1 kg',      1, 1, 28.00, 38.00, 35, 10),
    (3,  'Aceite vegetal 1 L',     1, 1, 35.00, 46.00, 20,  8),
    (4,  'Azúcar 1 kg',            1, 2, 25.00, 33.00, 30, 10),
    (5,  'Café soluble 200 g',     1, 2, 70.00, 95.00, 12,  5),
    (6,  'Refresco 600 ml',        2, 2, 12.00, 18.00, 60, 24),
    (7,  'Agua natural 1.5 L',     2, 2,  9.00, 15.00, 48, 12),
    (8,  'Jabón de barra',         3, 3, 11.00, 17.00, 25,  6),
    (9,  'Detergente 1 kg',        3, 3, 32.00, 45.00, 15,  5),
    (10, 'Leche entera 1 L',       4, 1, 20.00, 27.00, 30, 12),
    (11, 'Queso fresco 400 g',     4, 1, 45.00, 62.00, 10,  4);

INSERT INTO ventas (id, fecha) VALUES
    (1, '2026-07-03'), (2, '2026-07-10'), (3, '2026-07-18'), (4, '2026-07-27'),
    (5, '2026-08-02'), (6, '2026-08-09'), (7, '2026-08-15'), (8, '2026-08-24'),
    (9, '2026-09-01'), (10, '2026-09-08'), (11, '2026-09-16'), (12, '2026-09-22');

-- Cada inserción activa los triggers y descuenta el stock
INSERT INTO detalle_venta (venta_id, producto_id, cantidad, precio_unitario) VALUES
    (1, 1, 5, 30.00),  (1, 6, 6, 18.00),  (1, 10, 3, 27.00),
    (2, 2, 4, 38.00),  (2, 4, 3, 33.00),  (2, 7, 6, 15.00),
    (3, 6, 12, 18.00), (3, 8, 4, 17.00),
    (4, 1, 6, 30.00),  (4, 3, 5, 46.00),  (4, 10, 6, 27.00),
    (5, 5, 3, 95.00),  (5, 6, 10, 18.00), (5, 11, 2, 62.00),
    (6, 2, 8, 38.00),  (6, 4, 6, 33.00),
    (7, 1, 10, 30.00), (7, 3, 6, 46.00),  (7, 10, 8, 27.00),
    (8, 6, 12, 18.00), (8, 7, 10, 15.00), (8, 8, 6, 17.00),
    (9, 5, 4, 95.00),  (9, 2, 6, 38.00),
    (10, 1, 8, 30.00), (10, 10, 5, 27.00), (10, 11, 3, 62.00),
    (11, 6, 8, 18.00), (11, 3, 3, 46.00),
    (12, 4, 5, 33.00), (12, 8, 5, 17.00);
