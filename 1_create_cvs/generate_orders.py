import pandas as pd
import random
from datetime import datetime, timedelta

# CSVs erneut laden
reservations_df = pd.read_csv("reservations.csv")
tables_df = pd.read_csv("Restaurant_Tables_Setup.csv")
dishes_df = pd.read_csv("Dishes.csv")

# IDs und Dictionaries vorbereiten
dish_ids = dishes_df['Dish_ID'].tolist()
dish_prices = dishes_df.set_index('Dish_ID')['Price'].to_dict()
customer_ids = list(reservations_df['Customer_ID'].unique())
table_schedule = {table_id: [] for table_id in tables_df['Table_ID']}

# Hilfsfunktion: Ist ein Tisch im gewünschten Zeitfenster frei?
def is_table_available(table_id, new_start, new_end):
    for start, end in table_schedule[table_id]:
        if (new_start < end and new_end > start):
            return False
    return True

# Order- und Order_Dishes-Tabellen generieren
orders = []
order_dishes = []

num_orders = 43897  # Anzahl der Bestellungen
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

    # Mit oder ohne Reservierung?
    has_reservation = random.random() < 0.7
    if has_reservation:
        reservation_row = reservations_df.sample(1).iloc[0]
        reservation_id = reservation_row['Reservation_ID']
        customer_id = reservation_row['Customer_ID']
        count_persons = reservation_row['count_persons']

        # Passende Tische finden (genau passend oder +1 bei ungerader Gruppengröße)
        matching_tables = tables_df[
            (tables_df["Amount_of_seats"] == count_persons) |
            ((count_persons % 2 == 1) & (tables_df["Amount_of_seats"] == count_persons + 1))
        ]["Table_ID"].tolist()
    else:
        reservation_id = None
        customer_id = random.choice(customer_ids) if random.random() < 0.5 else None
        count_persons = random.randint(1, 6)
        matching_tables = tables_df[
            (tables_df["Amount_of_seats"] >= count_persons)
        ]["Table_ID"].tolist()

    # Nach freien Tischen suchen
    assigned_table = None
    random.shuffle(matching_tables)
    for table_id in matching_tables:
        if is_table_available(table_id, time_order, time_checkout):
            assigned_table = table_id
            table_schedule[table_id].append((time_order, time_checkout))
            break

    if not assigned_table:
        continue  # keine freien Tische, nächster Versuch

    # Bestellung erzeugen
    orders.append({
        "Order_ID": order_counter,
        "Date": order_date.date(),
        "Time_order": time_order.time(),
        "Time_checkout": time_checkout.time(),
        "Amount_price": 0.0,  # wird unten berechnet
        "Reservation_ID": reservation_id,
        "Customer_ID": customer_id,
        "Table_ID": assigned_table
    })



 #####################################################
    ### ORDER DISHES generieren ###


    # Gesamtanzahl an Gerichten/Getränken anhand Personenanzahl
    min_dishes = count_persons
    max_dishes = count_persons * 4
    total_dish_count = random.randint(min_dishes, max_dishes)

    # Zufällig so viele unterschiedliche Gerichte auswählen
    # Wenn weniger verschiedene verfügbar, Wiederholung durch random.choices
    if total_dish_count <= len(dish_ids):
        chosen_dishes = random.sample(dish_ids, total_dish_count)
    else:
        chosen_dishes = random.choices(dish_ids, k=total_dish_count)

    ## Order Dishes hinzufügen, weil direkt mit "orders" verknüpft
    ## kein best practice, aber für diese Aufgabe ausreichend
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

## DataFrames erzeugen
orders_df = pd.DataFrame(orders)
order_dishes_df = pd.DataFrame(order_dishes)


## CSV exportieren
orders_df.to_csv("orders.csv", index=False)
order_dishes_df.to_csv("order_dishes.csv", index=False)