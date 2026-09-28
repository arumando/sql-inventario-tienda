-- =============================================================
-- Base de datos de inventario y ventas para una tienda pequeña
-- Motor: SQLite 3
-- =============================================================

PRAGMA foreign_keys = ON;

DROP VIEW IF EXISTS v_ventas_por_producto;
DROP VIEW IF EXISTS v_productos_bajo_stock;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS proveedores;
DROP TABLE IF EXISTS categorias;

CREATE TABLE categorias (
    id      INTEGER PRIMARY KEY,
    nombre  TEXT NOT NULL UNIQUE
);

CREATE TABLE proveedores (
    id        INTEGER PRIMARY KEY,
    nombre    TEXT NOT NULL,
    telefono  TEXT,
    correo    TEXT
);

CREATE TABLE productos (
    id            INTEGER PRIMARY KEY,
    nombre        TEXT    NOT NULL UNIQUE,
    categoria_id  INTEGER NOT NULL REFERENCES categorias(id),
    proveedor_id  INTEGER REFERENCES proveedores(id),
    costo         REAL    NOT NULL CHECK (costo >= 0),
    precio_venta  REAL    NOT NULL CHECK (precio_venta > 0),
    stock         INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    stock_minimo  INTEGER NOT NULL DEFAULT 5 CHECK (stock_minimo >= 0)
);

CREATE TABLE ventas (
    id     INTEGER PRIMARY KEY,
    fecha  TEXT NOT NULL DEFAULT (date('now'))   -- formato AAAA-MM-DD
);

CREATE TABLE detalle_venta (
    venta_id         INTEGER NOT NULL REFERENCES ventas(id) ON DELETE CASCADE,
    producto_id      INTEGER NOT NULL REFERENCES productos(id),
    cantidad         INTEGER NOT NULL CHECK (cantidad > 0),
    precio_unitario  REAL    NOT NULL CHECK (precio_unitario > 0),
    PRIMARY KEY (venta_id, producto_id)
);

CREATE INDEX idx_detalle_producto ON detalle_venta(producto_id);
CREATE INDEX idx_ventas_fecha ON ventas(fecha);

-- -------------------------------------------------------------
-- Triggers: el inventario se actualiza solo al registrar ventas
-- -------------------------------------------------------------

-- Impide vender más piezas de las que hay en existencia
CREATE TRIGGER trg_validar_stock
BEFORE INSERT ON detalle_venta
WHEN (SELECT stock FROM productos WHERE id = NEW.producto_id) < NEW.cantidad
BEGIN
    SELECT RAISE(ABORT, 'Stock insuficiente para realizar la venta');
END;

-- Descuenta del inventario las piezas vendidas
CREATE TRIGGER trg_descontar_stock
AFTER INSERT ON detalle_venta
BEGIN
    UPDATE productos
       SET stock = stock - NEW.cantidad
     WHERE id = NEW.producto_id;
END;

-- -------------------------------------------------------------
-- Vistas reutilizables
-- -------------------------------------------------------------

CREATE VIEW v_productos_bajo_stock AS
SELECT p.nombre,
       p.stock,
       p.stock_minimo,
       p.stock_minimo - p.stock AS faltante,
       pr.nombre AS proveedor,
       pr.telefono
  FROM productos p
  LEFT JOIN proveedores pr ON pr.id = p.proveedor_id
 WHERE p.stock <= p.stock_minimo;

CREATE VIEW v_ventas_por_producto AS
SELECT p.id,
       p.nombre,
       SUM(d.cantidad)                                  AS unidades,
       ROUND(SUM(d.cantidad * d.precio_unitario), 2)    AS ingreso,
       ROUND(SUM(d.cantidad * (d.precio_unitario - p.costo)), 2) AS ganancia
  FROM detalle_venta d
  JOIN productos p ON p.id = d.producto_id
 GROUP BY p.id, p.nombre;
