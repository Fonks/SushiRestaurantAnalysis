import pandas as pd
import random
from datetime import datetime, timedelta

# 1. Kundenliste laden (Pfad ggf. anpassen)
customers_df = pd.read_csv("1_create_cvs/customers.csv")  # z. B. lokal aus deinem Projektordner
customer_ids = customers_df['customer_ID'].tolist()

# 2. Anzahl der zu generierenden Reservierungen
num_reservations = 7000
reservations = []

# 3. Zeitbereich festlegen (Dezember 2024 – Mai 2025)
start_date = datetime(2024, 12, 1)
end_date = datetime(2025, 5, 31)
delta_days = (end_date - start_date).days

# 4. Generierung der Reservierungsdaten
for i in range(1, num_reservations + 1):
    customer_id = random.choice(customer_ids)
    res_date = start_date + timedelta(days=random.randint(0, delta_days))

    # Uhrzeit: zwischen 11:00 und 23:30 Uhr in 30-Minuten-Schritten
    hour = random.randint(11, 23)
    minute = random.choice([0, 30])
    res_time = f"{hour:02d}:{minute:02d}"

    reservations.append({
        "Reservation_ID": i,
        "Date": res_date.date(),
        "Time": res_time,
        "Online": random.choice([True, False]),
        "Customer_ID": customer_id,
        "No_show": random.choices([False, True], weights=[90, 10])[0],  # 90 % erscheinen
        "count_persons": random.randint(2, 8)  # Anzahl der Personen zwischen 2 und 8
    })

# 5. In DataFrame umwandeln
reservations_df = pd.DataFrame(reservations)

# 6. Optional: Als CSV exportieren
reservations_df.to_csv("reservations.csv", index=False)

# 7. Optional: Ausgabe anzeigen
print(reservations_df.head())

