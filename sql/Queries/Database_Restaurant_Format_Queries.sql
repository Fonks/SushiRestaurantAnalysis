/******************************************************************************************
SCHRITT 0 — SPALTENTYPEN PRÜFEN (nach CSV-Import)
******************************************************************************************/

-- Spaltenformate prüfen
-- Viele Spalten liegen als "text"-Format vor, da absichtlich so importiert, um Formatierung zu üben

DESCRIBE customers;
DESCRIBE dishes;              -- Ändern: price -> FLOAT/INT, warm -> BOOLEAN
DESCRIBE dish_category;
DESCRIBE restaurant_tables;   -- Ändern: indoor -> BOOLEAN
DESCRIBE reservations;        -- Ändern: day_date -> DATE, time_reservation -> DATETIME, online -> BOOLEAN, customer_id -> VARCHAR, no-show -> BOOLEAN
DESCRIBE orders;              -- Ändern: day_date -> DATE, time_order -> DATETIME, time_checkout -> DATETIME, amount_price -> FLOAT, reservation_id -> VARCHAR, customer_id -> VARCHAR, no-show -> BOOLEAN
DESCRIBE order_dishes;


/******************************************************************************************
SCHRITT 1 — SIMULATIONSDUBLETTEN ENTFERNEN
******************************************************************************************/

-- Dubletten prüfen
SELECT Customer_ID, COUNT(*) AS c 
FROM customers 
GROUP BY Customer_ID 
HAVING c > 1;

SELECT reservation_id, COUNT(*) AS c 
FROM reservations 
GROUP BY reservation_id 
HAVING c > 1;

SELECT order_id, COUNT(*) AS c 
FROM orders 
GROUP BY order_id 
HAVING c > 1;

-- Temporären AUTO_INCREMENT-Schlüssel hinzufügen
ALTER TABLE customers     ADD COLUMN _rid BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY;
ALTER TABLE reservations  ADD COLUMN _rid BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY;
ALTER TABLE orders        ADD COLUMN _rid BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY;

-- Exakte Dubletten löschen (customers)
DELETE c1 
FROM customers c1
JOIN customers c2
  ON c1.Customer_ID = c2.Customer_ID
 AND c1._rid > c2._rid
 AND (c1.last_name    <=> c2.last_name)
 AND (c1.email        <=> c2.email)
 AND (c1.phone_number <=> c2.phone_number);

-- Dubletten löschen (reservations) — behalte ältere
DELETE r1 
FROM reservations r1
JOIN reservations r2
  ON r1.reservation_id = r2.reservation_id
 AND r1._rid > r2._rid
 AND (r1.Day_date          <=> r2.Day_date)
 AND (r1.time_reservation  <=> r2.time_reservation)
 AND (r1.online_reservation<=> r2.online_reservation)
 AND (r1.customer_id       <=> r2.customer_id)
 AND (r1.no_show           <=> r2.no_show)
 AND (r1.count_persons     <=> r2.count_persons);

DELETE r1 
FROM reservations r1
JOIN reservations r2
  ON r1.reservation_id = r2.reservation_id
 AND (r1.Day_date, r1.time_reservation, r1._rid) < (r2.Day_date, r2.time_reservation, r2._rid);

-- PK wiederherstellen & Hilfsspalte entfernen (reservations)
ALTER TABLE reservations
  MODIFY reservation_id INT NOT NULL,
  DROP PRIMARY KEY,
  ADD PRIMARY KEY (reservation_id),
  DROP COLUMN _rid;

-- Dubletten löschen (orders)
DELETE o1 
FROM orders o1
JOIN orders o2
  ON o1.order_id = o2.order_id
 AND o1._rid > o2._rid
 AND (o1.Date_day      <=> o2.Date_day)
 AND (o1.Time_order    <=> o2.Time_order)
 AND (o1.Time_checkout <=> o2.Time_checkout)
 AND (o1.Amount_price  <=> o2.Amount_price)
 AND (o1.Reservation_ID<=> o2.Reservation_ID)
 AND (o1.Customer_ID   <=> o2.Customer_ID)
 AND (o1.Table_ID      <=> o2.Table_ID);

-- Prüfen, ob noch Dubletten vorhanden sind
SELECT * 
FROM customers
WHERE Customer_ID IN (
  SELECT Customer_ID 
  FROM customers 
  GROUP BY Customer_ID 
  HAVING COUNT(*) > 1
)
ORDER BY Customer_ID, _rid;

-- PK wiederherstellen & Hilfsspalte entfernen (orders)
ALTER TABLE orders
  MODIFY order_id INT NOT NULL,
  DROP PRIMARY KEY,
  ADD PRIMARY KEY (order_id),
  DROP COLUMN _rid;


/******************************************************************************************
SCHRITT 2 — SPALTENTYPEN ANPASSEN
******************************************************************************************/

-- ==============================
-- TABELLE orders
-- ==============================
-- Datum/Zeit umwandeln
UPDATE orders
SET Date_day = STR_TO_DATE(Date_day, '%d.%m.%Y'),
    Time_order = STR_TO_DATE(Time_order, '%H:%i:%s'),
    Time_checkout = STR_TO_DATE(Time_checkout, '%H:%i:%s')
WHERE order_id IS NOT NULL;

-- Währungsformat (Komma → Punkt)
UPDATE orders
SET Amount_price = REPLACE(Amount_price, ',', '.')
WHERE Amount_price LIKE '%,%';

-- Leere Strings in NULL umwandeln
UPDATE orders
SET Reservation_ID = NULL
WHERE Reservation_ID = '';

UPDATE orders
SET Customer_ID = NULL
WHERE Customer_ID = '';

-- Datentypen ändern
ALTER TABLE orders
  MODIFY Date_day DATE,
  MODIFY Time_order TIME,
  MODIFY Time_checkout TIME,
  MODIFY Amount_price FLOAT,
  MODIFY Reservation_ID INT(20),
  MODIFY Customer_ID VARCHAR(20),
  MODIFY Table_ID VARCHAR(10);

SELECT * FROM orders;


-- ==============================
-- TABELLE reservations
-- ==============================
-- Zeit umwandeln
UPDATE reservations
SET Time_reservation = STR_TO_DATE(Time_reservation, '%H:%i:%s')
WHERE Reservation_ID IS NOT NULL;

-- Spaltennamen anpassen
ALTER TABLE reservations
CHANGE COLUMN Online Online_reservation TEXT;

-- Boolean-Felder (WAHR/FALSCH → 1/0)
UPDATE reservations
SET No_show = CASE
  WHEN No_show = 'WAHR'   THEN 1
  WHEN No_show = 'FALSCH' THEN 0
  ELSE NULL
END;

UPDATE reservations
SET Online_reservation = CASE
  WHEN Online_reservation = 'WAHR'   THEN 1
  WHEN Online_reservation = 'FALSCH' THEN 0
  ELSE NULL
END;

-- Datentypen ändern
ALTER TABLE reservations
  MODIFY Day_date DATE,
  MODIFY time_reservation TIME,
  MODIFY Online_reservation BOOLEAN,
  MODIFY Reservation_ID INT(20),
  MODIFY Customer_ID VARCHAR(20),
  MODIFY No_show BOOLEAN,
  MODIFY count_persons INT(4);

SELECT * FROM reservations;


-- ==============================
-- TABELLE dishes
-- ==============================
-- Komma zu Punkt
UPDATE dishes
SET Price = REPLACE(Price, ',', '.')
WHERE Price LIKE '%,%';

-- Preis in FLOAT umwandeln
ALTER TABLE dishes
  MODIFY Price FLOAT;

SELECT * FROM dishes;


/******************************************************************************************
SCHRITT 3 — PRIMARY KEYS SETZEN
******************************************************************************************/

ALTER TABLE customers          ADD PRIMARY KEY (Customer_ID);       -- vorher Dubletten
ALTER TABLE dishes             ADD PRIMARY KEY (dish_id);
ALTER TABLE dish_category      ADD PRIMARY KEY (Category_ID);
ALTER TABLE restaurant_tables  ADD PRIMARY KEY (Table_ID);
ALTER TABLE reservations       ADD PRIMARY KEY (reservation_id);    -- vorher Dubletten
ALTER TABLE orders             ADD PRIMARY KEY (order_id);          -- vorher Dubletten

-- Übersicht Primary Keys
SELECT 
    TABLE_NAME,
    COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = DATABASE()
  AND CONSTRAINT_NAME = 'PRIMARY'
  AND TABLE_NAME IN ('customers', 'orders', 'reservations', 'dishes', 'dish_category', 'restaurant_tables')
ORDER BY TABLE_NAME;
