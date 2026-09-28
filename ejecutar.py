"""Crea la base de datos de inventario y muestra el resultado de las consultas.

Uso:
    python ejecutar.py            # crea inventario.db y ejecuta las consultas
    python ejecutar.py --solo-crear
"""

import argparse
import re
import sqlite3
import sys
from pathlib import Path

CARPETA_SQL = Path(__file__).parent / "sql"
BD = Path(__file__).parent / "inventario.db"


def crear_base(ruta_bd: Path) -> sqlite3.Connection:
    """Crea (o recrea) la base con el esquema y los datos de ejemplo."""
    conexion = sqlite3.connect(ruta_bd)
    conexion.execute("PRAGMA foreign_keys = ON")
    for archivo in ("01_esquema.sql", "02_datos_ejemplo.sql"):
        conexion.executescript((CARPETA_SQL / archivo).read_text(encoding="utf-8"))
    conexion.commit()
    return conexion


def leer_consultas(ruta: Path) -> list[tuple[str, str]]:
    """Separa el archivo en (título, sql) usando las marcas '-- @consulta:'."""
    texto = ruta.read_text(encoding="utf-8")
    partes = re.split(r"^-- @consulta:\s*(.+)$", texto, flags=re.MULTILINE)
    # partes = [encabezado, titulo1, sql1, titulo2, sql2, ...]
    return [(partes[i].strip(), partes[i + 1].strip()) for i in range(1, len(partes), 2)]


def imprimir_tabla(columnas: list[str], filas: list[tuple]) -> None:
    """Imprime los resultados como una tabla de texto alineada."""
    if not filas:
        print("  (sin resultados)")
        return
    datos = [[("" if v is None else str(v)) for v in fila] for fila in filas]
    anchos = [max(len(c), *(len(f[i]) for f in datos)) for i, c in enumerate(columnas)]
    print("  " + " | ".join(c.ljust(a) for c, a in zip(columnas, anchos)))
    print("  " + "-+-".join("-" * a for a in anchos))
    for fila in datos:
        print("  " + " | ".join(v.ljust(a) for v, a in zip(fila, anchos)))


def demostrar_trigger(conexion: sqlite3.Connection) -> None:
    """Intenta vender más piezas de las que hay para mostrar la validación."""
    print("\n=== Prueba del trigger: vender 999 piezas de 'Arroz 1 kg' ===")
    try:
        with conexion:
            cursor = conexion.execute("INSERT INTO ventas (fecha) VALUES ('2026-09-30')")
            conexion.execute(
                "INSERT INTO detalle_venta VALUES (?, 1, 999, 30.00)", (cursor.lastrowid,)
            )
    except sqlite3.DatabaseError as error:
        print(f"  Venta rechazada correctamente: {error}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Crea inventario.db y ejecuta las consultas de ejemplo.")
    parser.add_argument("--solo-crear", action="store_true", help="Solo crea la base, sin mostrar consultas")
    args = parser.parse_args()

    conexion = crear_base(BD)
    print(f"Base de datos creada: {BD.name}")

    if not args.solo_crear:
        for titulo, sql in leer_consultas(CARPETA_SQL / "03_consultas.sql"):
            cursor = conexion.execute(sql)
            print(f"\n=== {titulo} ===")
            imprimir_tabla([d[0] for d in cursor.description], cursor.fetchall())
        demostrar_trigger(conexion)

    conexion.close()
    return 0


if __name__ == "__main__":
    sys.exit(main())
