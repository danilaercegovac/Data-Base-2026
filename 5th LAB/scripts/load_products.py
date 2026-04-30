import json
import random
import time
from datetime import datetime, timedelta

import mysql.connector
from faker import Faker

HOST = "192.168.0.78"
PORT = 9306
USER = "root"
PASSWORD = ""
DATABASE = "Manticore"

TOTAL_RECORDS = 100_000
BATCH_SIZE = 1_000

random.seed(42)
fake = Faker("en_US")

CATEGORIES = [
    "Electronics",
    "Computers",
    "Audio",
    "Mobile Phones",
    "Gaming",
    "Cameras",
    "TV & Video",
    "Accessories",
    "Smart Home",
    "Wearables",
]
BRANDS = [
    "Sony",
    "Samsung",
    "Apple",
    "LG",
    "Philips",
    "Bose",
    "JBL",
    "Logitech",
    "Razer",
    "Anker",
    "Dell",
    "HP",
    "Lenovo",
    "Asus",
    "Acer",
]
COLORS = ["black", "white", "silver", "blue", "red", "green", "gold"]
MATERIALS = ["plastic", "aluminum", "steel", "leather", "fabric"]

TEMPLATES = [
    (
        "Wireless Bluetooth Headphones",
        "High-quality wireless bluetooth headphones with noise cancelling technology. "
        "Perfect for music lovers who want portable speaker quality on the go. "
        "Foldable design, 30h battery, USB-C charging.",
    ),
    (
        "Gaming Laptop",
        "Powerful gaming laptop with fast processor and dedicated GPU. "
        "Ideal for gaming, 3D rendering and professional workloads. "
        "Backlit keyboard, 144Hz display, Wi-Fi 6.",
    ),
    (
        "Smart TV 4K",
        "Ultra HD smart TV with HDR support and built-in streaming apps. "
        "Crystal clear display, Dolby Atmos sound, voice remote included.",
    ),
    (
        "Noise Cancelling Earbuds",
        "True wireless earbuds with active noise cancelling. "
        "Long battery life and comfortable fit for all-day use. "
        "IPX5 waterproof, touch controls, Bluetooth 5.3.",
    ),
    (
        "Portable Bluetooth Speaker",
        "Compact portable speaker with 360-degree sound. "
        "Waterproof design perfect for outdoor adventures. "
        "20h playback, built-in mic, USB-C fast charge.",
    ),
    (
        "Mechanical Keyboard",
        "RGB mechanical keyboard with tactile switches. "
        "Designed for gaming and professional typing. "
        "N-key rollover, aluminum frame, detachable USB-C cable.",
    ),
    (
        "Wireless Mouse",
        "Ergonomic wireless mouse with precision optical tracking. "
        "Silent clicks, 18-month battery, 3 DPI levels.",
    ),
    (
        "USB-C Hub",
        "Multi-port USB-C hub with HDMI 4K, USB 3.0 and SD card reader. "
        "Compatible with laptop, tablet and phone.",
    ),
    (
        "Action Camera",
        "Waterproof action camera with 4K video recording and image stabilisation. "
        "Wide-angle lens, touch screen, Wi-Fi and Bluetooth.",
    ),
    (
        "Smart Watch",
        "Fitness smart watch with heart rate monitor and built-in GPS. "
        "Track your health metrics and stay connected with phone notifications.",
    ),
    (
        "Phone Case",
        "Shockproof phone case with wireless charging pass-through. "
        "Slim profile, raised edges, available in black and other colors.",
    ),
    (
        "Gaming Monitor 27 inch",
        "QHD gaming monitor with 165Hz refresh rate and 1ms response. "
        "IPS panel, wide color gamut, AMD FreeSync Premium.",
    ),
    (
        "Webcam HD",
        "Full HD 1080p webcam for video conferencing and streaming. "
        "Built-in noise-cancelling microphone, auto-focus, plug and play.",
    ),
    (
        "Portable SSD",
        "External portable SSD with 1050 MB/s read speed. "
        "Compact aluminium design for fast data backup and transfer.",
    ),
    (
        "Power Bank",
        "20000 mAh power bank with 65W USB-C fast charging. "
        "Charge laptop, phone and tablet simultaneously.",
    ),
]


def random_date():
    start = datetime(2022, 1, 1)
    return int((start + timedelta(days=random.randint(0, 1000))).timestamp())


def generate_product(index):
    tmpl = TEMPLATES[index % len(TEMPLATES)]
    brand = random.choice(BRANDS)
    category = random.choice(CATEGORIES)
    title = f"{brand} {tmpl[0]} {random.randint(100, 9999)}"
    description = f"{tmpl[1]} Brand: {brand}. Model {fake.bothify('??-####')}."
    price = round(random.uniform(500.0, 150_000.0), 2)
    rating = round(random.uniform(1.0, 5.0), 1)
    reviews_count = random.randint(0, 5000)
    in_stock = random.randint(0, 1)
    tags = json.dumps(
        {
            "color": random.choice(COLORS),
            "material": random.choice(MATERIALS),
            "warranty_years": random.randint(1, 3),
        }
    )
    created_at = random_date()
    return (
        title,
        description,
        category,
        brand,
        price,
        rating,
        reviews_count,
        in_stock,
        tags,
        created_at,
    )


INSERT_SQL = """
    INSERT INTO products
        (title, description, category, brand, price, rating,
         reviews_count, in_stock, tags, created_at)
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
"""


def main():
    conn = mysql.connector.connect(
        host=HOST, port=PORT, user=USER, password=PASSWORD, database=DATABASE
    )
    cursor = conn.cursor()

    t0 = time.time()
    for batch_start in range(0, TOTAL_RECORDS, BATCH_SIZE):
        batch = [generate_product(batch_start + i) for i in range(BATCH_SIZE)]
        cursor.executemany(INSERT_SQL, batch)
        conn.commit()
        done = batch_start + BATCH_SIZE
        if done % 10_000 == 0:
            print(f"  {done:>7,} / {TOTAL_RECORDS:,}  ({time.time() - t0:.1f}s)")
    cursor.execute("SELECT COUNT(*) FROM products")
    total = cursor.fetchone()[0]
    print(f"\nDone in {time.time() - t0:.1f}s. Total: {total:,}")
    cursor.close()
    conn.close()


if __name__ == "__main__":
    main()
