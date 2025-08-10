## 📦 Entities und Attribute

### 1. **Customer**
- `Customer_ID` **(PK)**
- `last_name`
- `email`
- `phone_number`

---

### 2. **Reservations**
- `Reservation_ID` **(PK)**
- `date` *(Dezember 2024 – Mai 2024)*
- `time` *(11:00 – 23:30 Uhr)*
- `online` *(boolean)*
- `Customer_ID` **(FK) ➝ Customer**
- `no_show` *(boolean, Standard: FALSE, ~90% FALSE)*
- `count_persons` *(integer)*

---

### 3. **Order**
- `Order_ID` **(PK)**
- `date` *(Dezember 2024 – Mai 2024)*
- `time_order` *(11:00 – 23:30 Uhr)*
- `time_checkout` *(mindestens 30 Min. nach `time_order`)*
- `amount_price` *(über SQL berechnet mit `dish_id`, `price` von Dish und `order_ID` aus Order_Dishes)*
- `Reservation_ID` **(FK) ➝ Reservations** *(NULL, falls keine Reservierung)*
- `Customer_ID` **(FK) ➝ Customer** *(optional, NULL falls ohne Reservierung bestellt)*
- `Table_ID` **(FK) ➝ restaurant_tables** *(Tisch darf nicht doppelt belegt sein zur gleichen Zeit)*

---

### 4. **Order_Dishes** *(m:n zwischen Order und Dish)*
- `Order_ID` **(FK) ➝ Order**
- `Dish_ID` **(FK) ➝ Dish** *(mehrere IDs möglich)*
- `quantity` *(optional)*

---

### 5. **Dish**
- `Dish_ID` **(PK)**
- `dish_name`
- `price`
- `warm` *(boolean)*
- `Category_ID` **(FK) ➝ Dish_Category**
- `dish_description`
- `dish_type` *(vegetarian, vegan, meat, fish)*
- `main_dish_type` *(rice, noodle, soup, sushi, null)*

---

### 6. **Dish_Category**
- `Category_ID` **(PK)**
- `category`

---

### 7. **restaurant_tables**
- `Table_ID` **(PK)**
- `table_type` *(A–D)*
- `amount_of_seats` *(2, 4, 5, 8)*
- `indoor` *(boolean)*



