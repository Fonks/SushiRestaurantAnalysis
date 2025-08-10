# Nach Code-Reset: Alles neu laden und generieren
import pandas as pd
import random
from datetime import datetime, timedelta

# CSVs erneut laden
reservations_df = pd.read_csv("reservations.csv")
tables_df = pd.read_csv("Restaurant_Tables_Setup.csv")
dishes_df = pd.read_csv("Dishes.csv")
order_df = pd.read_csv("orders.csv") 

# IDs vorbereiten
reservation_ids = reservations_df['Reservation_ID'].tolist()
table_ids = tables_df['Table_ID'].tolist()
dish_ids = dishes_df['Dish_ID'].tolist()
dish_prices = dishes_df.set_index('Dish_ID')['Price'].to_dict()

# Optional: Customer_ID aus reservations extrahieren
customer_ids = list(reservations_df['Customer_ID'].unique())

# Tischbelegung überwachen: {table_id: [(start, end)]}
table_schedule = {table_id: [] for table_id in table_ids}

# Helferfunktion für Tischverfügbarkeit
def is_table_available(table_id, new_start, new_end):
    for start, end in table_schedule[table_id]:
        if (new_start < end and new_end > start):
            return False
    return True

# Order- und Order_Dishes-Tabellen generieren
orders = []
order_dishes = []

num_orders = 120
order_counter = 1

start_date = datetime(2024, 12, 1)
end_date = datetime(2025, 5, 31)
delta_days = (end_date - start_date).days

while order_counter <= num_orders:
    order_date = start_date + timedelta(days=random.randint(0, delta_days))
    hour = random.randint(11, 23)
    minute = random.choice([0, 30])
    time_order = datetime.combine(order_date.date(), datetime.min.time()) + timedelta(hours=hour, minutes=minute)
    duration = timedelta(minutes=random.randint(30, 120))
    time_checkout = time_order + duration

    table_id = random.choice(table_ids)
    if not is_table_available(table_id, time_order, time_checkout):
        continue  # skip this one if table is occupied

    table_schedule[table_id].append((time_order, time_checkout))

    # Chance auf Reservierung oder Laufkundschaft
    if random.random() < 0.7:
        reservation_row = reservations_df.sample(1).iloc[0]
        reservation_id = reservation_row['Reservation_ID']
        customer_id = reservation_row['Customer_ID']
    else:
        reservation_id = None
        customer_id = random.choice(customer_ids) if random.random() < 0.5 else None

    # Dummy-Wert für Amount_price (wird später durch Order_Dishes berechnet)
    orders.append({
        "Order_ID": order_counter,
        "Date": order_date.date(),
        "Time_order": time_order.time(),
        "Time_checkout": time_checkout.time(),
        "Amount_price": 0.0,  # wird unten gefüllt
        "Reservation_ID": reservation_id,
        "Customer_ID": customer_id,
        "Table_ID": table_id
    })

    # Dishes pro Order (1–4 verschiedene Gerichte)
    chosen_dishes = random.sample(dish_ids, random.randint(1, 4))
    order_total = 0.0
    for dish_id in chosen_dishes:
        qty = random.randint(1, 3)
        order_dishes.append({
            "Order_ID": order_counter,
            "Dish_ID": dish_id,
            "Quantity": qty
        })
        order_total += dish_prices[dish_id] * qty

    orders[-1]['Amount_price'] = round(order_total, 2)
    order_counter += 1

# DataFrames erstellen
orders_df = pd.DataFrame(orders)
order_dishes_df = pd.DataFrame(order_dishes)

# Anzeigen
import ace_tools as tools; tools.display_dataframe_to_user(name="Orders", dataframe=orders_df)
tools.display_dataframe_to_user(name="Order_Dishes", dataframe=order_dishes_df)
