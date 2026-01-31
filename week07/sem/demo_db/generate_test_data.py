import csv
import random
from datetime import datetime, timedelta

# Paths for the CSV files
paths = {
    "customers": "/mnt/data/customers.csv",
    "stores": "/mnt/data/stores.csv",
    "manufacturers": "/mnt/data/manufacturers.csv",
    "categories": "/mnt/data/categories.csv",
    "products": "/mnt/data/products.csv",
    "purchases": "/mnt/data/purchases.csv",
    "purchase_items": "/mnt/data/purchase_items.csv",
    "deliveries": "/mnt/data/deliveries.csv",
    "price_change": "/mnt/data/price_change.csv"
}

# Generate Customers data
with open(paths["customers"], "w", newline='') as file:
    writer = csv.writer(file)
    writer.writerow(["customer_id", "customer_fname", "customer_lname"])
    for i in range(1, 101):
        writer.writerow([i, f"FirstName{i}", f"LastName{i}"])

# Generate Stores data
with open(paths["stores"], "w", newline='') as file:
    writer = csv.writer(file)
    writer.writerow(["store_id", "store_name"])
    for i in range(1, 11):
        writer.writerow([i, f"Store {i}"])

# Generate Manufacturers data
with open(paths["manufacturers"], "w", newline='') as file:
    writer = csv.writer(file)
    writer.writerow(["manufacturer_id", "manufacturer_name"])
    for i, name in enumerate(["A", "B", "C", "D", "E"], 1):
        writer.writerow([i, f"Manufacturer {name}"])

# Generate Categories data
with open(paths["categories"], "w", newline='') as file:
    writer = csv.writer(file)
    writer.writerow(["category_id", "category_name"])
    for i in range(1, 6):
        writer.writerow([i, f"Category {i}"])

# Generate Products data
with open(paths["products"], "w", newline='') as file:
    writer = csv.writer(file)
    writer.writerow(["product_id", "category_id", "manufacturer_id", "product_name"])
    for i in range(1, 51):
        writer.writerow([i, random.randint(1, 5), random.randint(1, 5), f"Product {i}"])

# Generate Purchases data
with open(paths["purchases"], "w", newline='') as file:
    writer = csv.writer(file)
    writer.writerow(["purchase_id", "store_id", "customer_id", "product_name", "purchase_date"])
    for i in range(1, 501):
        purchase_date = datetime.now() - timedelta(days=random.randint(0, 365))
        writer.writerow([i, random.randint(1, 10), random.randint(1, 100), f"Product {random.randint(1, 50)}", purchase_date])

# Generate Purchase Items data
with open(paths["purchase_items"], "w", newline='') as file:
    writer = csv.writer(file)
    writer.writerow(["product_id", "purchase_id", "product_count", "product_price"])
    for i in range(1, 501):
        for _ in range(2):
            writer.writerow([random.randint(1, 50), i, random.randint(1, 10), round(random.uniform(5, 100), 2)])

# Generate Deliveries data
with open(paths["deliveries"], "w", newline='') as file:
    writer = csv.writer(file)
    writer.writerow(["store_id", "product_id", "delivery_date", "product_count"])
    for i in range(1, 101):
        delivery_date = datetime.now() - timedelta(days=random.randint(0, 365))
        writer.writerow([random.randint(1, 10), random.randint(1, 50), delivery_date, random.randint(1, 50)])

# Generate Price Change data
with open(paths["price_change"], "w", newline='') as file:
    writer = csv.writer(file)
    writer.writerow(["product_id", "price_change_ts", "new_price"])
    for i in range(1, 51):
        price_change_ts = datetime.now() - timedelta(days=random.randint(0, 365))
        writer.writerow([i, price_change_ts, round(random.uniform(5, 100), 2)])
