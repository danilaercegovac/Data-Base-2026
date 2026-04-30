import mysql.connector
import psycopg2

manticore = mysql.connector.connect(host="192.168.0.78", port=9306, user="root")
pg = psycopg2.connect(
    host="192.168.0.78", port=5432, user="user", password="password", dbname="products"
)

cur = manticore.cursor()
pcur = pg.cursor()

cur.execute("SELECT COUNT(*) FROM products")
total_rows = cur.fetchone()[0]

batch_size = 10000
offset = 0
total_inserted = 0
max_matches_limit = 110000

while offset < total_rows:
    query = f"""
        SELECT title, description, category, brand, price, rating, reviews_count, in_stock, tags
        FROM products
        LIMIT {batch_size} OFFSET {offset}
        OPTION max_matches = {max_matches_limit}
    """
    cur.execute(query)
    rows = cur.fetchall()

    if not rows:
        break

    for row in rows:
        pcur.execute(
            """
            INSERT INTO pg_products
            (title, description, category, brand, price, rating, reviews_count, in_stock, tags)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """,
            (
                row[0],
                row[1],
                row[2],
                row[3],
                row[4],
                row[5],
                row[6],
                row[7],
                row[8],
            ),
        )
        total_inserted += 1
    pg.commit()

    offset += batch_size

cur.close()
pcur.close()
manticore.close()
pg.close()
