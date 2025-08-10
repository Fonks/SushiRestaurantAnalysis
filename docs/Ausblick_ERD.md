## 🔮 Ausblick – Spätere mögliche Entitäten

---

### 1. **Waiter / Employees** *(optionale Erweiterung)*

**Employees**
- `Employee_ID` **(PK)**
- `first_name`
- `last_name`
- `role` *(z. B. waiter, kitchen, management)*
- `hire_date`
- `active` *(boolean)*

**Änderung in Orders**:
- `Waiter_ID` **(FK)** ➝ Employees

**Mögliche Analysen**:
- Durchschnittlicher Umsatz pro Kellner:in  
- Anzahl bedienter Tische pro Schicht  

---

### 2. **Lager, Ressourcen & Verbrauch**  
*(zweite Datenwelt – Inventory Management & Warenwirtschaft; Modul „Kitchen & Inventory Insights“)*

**Ingredients**
- `Ingredient_ID` **(PK)**
- `name`
- `unit` *(z. B. g, ml, Stück)*
- `perishable` *(boolean)*

**Inventory**
- `Inventory_ID` **(PK)**
- `Ingredient_ID` **(FK) ➝ Ingredients**
- `quantity_in_stock`
- `date_added`
- `expire_date`
- `supplier` *(optional)*

**Dish_Ingredients** *(m:n zwischen Dish und Ingredients)*
- `Dish_ID` **(FK) ➝ Dish**
- `Ingredient_ID` **(FK) ➝ Ingredients**
- `quantity_required_per_dish`

**Consumption_Log**
- `Consumption_ID` **(PK)**
- `Dish_ID` **(FK) ➝ Dish**
- `Order_ID` **(FK) ➝ Order**
- `Ingredient_ID` **(FK) ➝ Ingredients**
- `quantity_used`
- `date`

---

## 📊 Mögliche Analysen

| Frage | Mögliche Analyse |
|-------|------------------|
| Was wurde pro Woche verbraucht? | `SUM(quantity_used) GROUP BY ingredient, week` |
| Was läuft bald ab? | `WHERE expire_date < TODAY() + 3` |
| Welche Gerichte brauchen welche Zutaten? | `JOIN dish_ingredients + dishes` |
| Wie viel Lagerbestand haben wir noch? | `inventory.quantity_in_stock - SUM(consumption_log.quantity_used)` |
| Wie viel kosten Gerichte in der Produktion? | Berechne Zutatenpreis je Dish |
