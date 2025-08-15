/******************************************************************************************
BUSINESS-ANALYSEN — RESTAURANT-DATENBANK
******************************************************************************************/

/******************************************************************************************
1) TISCHNUTZUNG & AUSLASTUNG
******************************************************************************************/

-- 1.1 Tischdauer (Belegung) je Tisch in Minuten + Durchschnitt pro Bestellung(avg_minutes_per_order)
 -- Bestellunen insgesamt (orders count), Gesamtminuten(minutes_occupied)
 -- Zeitraum Januar - Mai 2025 
SET @from_ts := TIMESTAMP('2024-01-01','00:00:00');
SET @to_ts   := TIMESTAMP('2025-05-01','00:00:00');
-- Jetzt Query starten
WITH spans AS (
  SELECT
    o.Table_ID,
    TIMESTAMP(o.Date_day, o.Time_order) AS ts_start,
    CASE
      WHEN TIMESTAMP(o.Date_day, o.Time_checkout) < TIMESTAMP(o.Date_day, o.Time_order)
      THEN TIMESTAMP(DATE_ADD(o.Date_day, INTERVAL 1 DAY), o.Time_checkout)
      ELSE TIMESTAMP(o.Date_day, o.Time_checkout)
    END AS ts_end
  FROM Orders o
),
filtered AS (
  SELECT
    Table_ID,
    GREATEST(ts_start, @from_ts) AS s,
    LEAST(ts_end,   @to_ts)     AS e
  FROM spans
  WHERE ts_end > @from_ts   -- überlappt Anfang
    AND ts_start < @to_ts   -- überlappt Ende
)
SELECT
  Table_ID,
  COUNT(*)                                                    AS orders_count,
  SUM(GREATEST(TIMESTAMPDIFF(MINUTE, s, e),0))                AS minutes_occupied,
  ROUND(AVG(GREATEST(TIMESTAMPDIFF(MINUTE, s, e),0)), 1)      AS avg_minutes_per_order
FROM filtered
GROUP BY Table_ID
ORDER BY minutes_occupied DESC;


-- 1.2 An welchen Tischen saßen die Kunden am längsten?
-- je Tisch in Minuten + Durchschnittsbesetzung pro Bestellung
-- Indoor vs Outdoor
SELECT
    o.Table_ID,
        CASE
			WHEN Indoor = 'True' THEN 'Indoor'
			WHEN Indoor = 'False' THEN 'Outdoor'
			ELSE 'Unbekannt'
    END AS area_type,  -- zeigt ob es ein Indoor- oder Outdoortisch ist
    COUNT(*) AS orders_count,
    SUM(
        CASE
            WHEN TIMESTAMP(o.Date_day, o.Time_checkout) < TIMESTAMP(o.Date_day, o.Time_order)
            THEN TIMESTAMPDIFF(
                   MINUTE,
                   TIMESTAMP(o.Date_day, o.Time_order),
                   TIMESTAMP(DATE_ADD(o.Date_day, INTERVAL 1 DAY), o.Time_checkout)
                 )
            ELSE TIMESTAMPDIFF(
                   MINUTE,
                   TIMESTAMP(o.Date_day, o.Time_order),
                   TIMESTAMP(o.Date_day, o.Time_checkout)
                 )
        END
    ) AS minutes_occupied,
    ROUND(AVG(
        CASE
            WHEN TIMESTAMP(o.Date_day, o.Time_checkout) < TIMESTAMP(o.Date_day, o.Time_order)
            THEN TIMESTAMPDIFF(
                   MINUTE,
                   TIMESTAMP(o.Date_day, o.Time_order),
                   TIMESTAMP(DATE_ADD(o.Date_day, INTERVAL 1 DAY), o.Time_checkout)
                 )
            ELSE TIMESTAMPDIFF(
                   MINUTE,
                   TIMESTAMP(o.Date_day, o.Time_order),
                   TIMESTAMP(o.Date_day, o.Time_checkout)
                 )
        END
    ), 1) AS avg_minutes_per_order,
    t.Amount_of_seats
FROM Orders o
JOIN restaurant_tables t ON t.Table_ID = o.Table_ID
GROUP BY o.Table_ID, t.Indoor, t.Amount_of_seats
ORDER BY minutes_occupied DESC
LIMIT 5;


-- 1.3 Monatliche Tischbelegung nach Bereich (Indoor vs. Outdoor)
 -- Dez 2024–Mai 2025 – Bestellanzahl, Ø Belegminuten/Bestellung & Gesamtminuten
WITH spans AS (
  SELECT
    o.Table_ID,
    CASE
      WHEN t.Indoor = 'True'  THEN 'Indoor'
      WHEN t.Indoor = 'False' THEN 'Outdoor'
      ELSE 'Unbekannt'
    END AS area_type,
    TIMESTAMP(o.Date_day, o.Time_order) AS ts_start,
    TIMESTAMP(
      o.Date_day + INTERVAL (o.Time_checkout < o.Time_order) DAY,
      o.Time_checkout
    ) AS ts_end
  FROM Orders o
  JOIN restaurant_tables t ON t.Table_ID = o.Table_ID
  WHERE o.Time_order IS NOT NULL
    AND o.Time_checkout IS NOT NULL
),
filtered AS (
  -- auf Zeitraum zuschneiden und nur überlappende Bestellungen behalten
  SELECT
    Table_ID,
    area_type,
    GREATEST(ts_start, @from_ts) AS s,
    LEAST(ts_end,   @to_ts)      AS e
  FROM spans
  WHERE ts_end   > @from_ts
    AND ts_start < @to_ts
),
per_order AS (
  -- Belegminuten pro Bestellung (nach Zuschnitt)
  SELECT
    Table_ID,
    area_type,
    s,
    e,
    YEAR(s)  AS yr,
    MONTH(s) AS mn,
    DATE_FORMAT(s, '%b %Y') AS month_label,
    GREATEST(TIMESTAMPDIFF(MINUTE, s, e), 0) AS occupied_minutes
  FROM filtered
)
SELECT
  month_label AS month,
  -- Indoor
  SUM(CASE WHEN area_type = 'Indoor' THEN 1 ELSE 0 END)                      AS indoor_orders,
  ROUND(AVG(CASE WHEN area_type = 'Indoor' THEN occupied_minutes END), 1)     AS indoor_avg_min_per_order,
  SUM(CASE WHEN area_type = 'Indoor' THEN occupied_minutes ELSE 0 END)        AS indoor_total_minutes,
  -- Outdoor
  SUM(CASE WHEN area_type = 'Outdoor' THEN 1 ELSE 0 END)                      AS outdoor_orders,
  ROUND(AVG(CASE WHEN area_type = 'Outdoor' THEN occupied_minutes END), 1)    AS outdoor_avg_min_per_order,
  SUM(CASE WHEN area_type = 'Outdoor' THEN occupied_minutes ELSE 0 END)       AS outdoor_total_minutes
FROM per_order
GROUP BY yr, mn, month_label
ORDER BY yr, mn;



-- 1.4. Generelle Auslastung( Anzahl gleichzeitig belegte Tische & prozentual) an Wochentagen pro stunde (11-23 Uhr)
-- Ø Auslastung je Wochentag und Stunde (11–23 Uhr)
WITH RECURSIVE
-- Zeitraumgrenzen aus den Daten
bounds AS (
  SELECT MIN(Date_day) AS min_d, MAX(Date_day) AS max_d
  FROM Orders
),

-- Alle Kalendertage im Zeitraum erzeugen
dates AS (
  SELECT min_d AS d
  FROM bounds
  UNION ALL
  SELECT DATE_ADD(d, INTERVAL 1 DAY)
  FROM dates
  JOIN bounds ON d < bounds.max_d
),

-- Stunden-Slots 11:00–23:00
hours AS (
  SELECT 11 AS h
  UNION ALL
  SELECT h+1
  FROM hours
  WHERE h < 22
),

-- Bestell-Zeitspannen mit Mitternachts-Fix
spans AS (
  SELECT
    o.Table_ID,
    TIMESTAMP(o.Date_day, o.Time_order) AS ts_start,
    TIMESTAMP(
      o.Date_day + INTERVAL (o.Time_checkout < o.Time_order) DAY,
      o.Time_checkout
    ) AS ts_end
  FROM Orders o
  WHERE o.Time_order IS NOT NULL AND o.Time_checkout IS NOT NULL
),

-- Stündliche Slots pro Kalendertag
slots AS (
  SELECT
    d.d AS slot_date,
    DAYNAME(d.d) AS weekday,
    h.h AS hour,
    TIMESTAMP(d.d, MAKETIME(h.h,   0, 0)) AS slot_start,
    TIMESTAMP(d.d, MAKETIME(h.h+1, 0, 0)) AS slot_end
  FROM dates d
  CROSS JOIN hours h
),

-- Beleg-Minuten je (Wochentag, Stunde)
slot_sums AS (
  SELECT
    s.weekday,
    s.hour,
    SUM(
      COALESCE(
        GREATEST(
          TIMESTAMPDIFF(
            MINUTE,
            GREATEST(sp.ts_start, s.slot_start),
            LEAST(sp.ts_end,   s.slot_end)
          ),
          0
        ),
        0
      )
    ) AS minutes_sum
  FROM slots s
  LEFT JOIN spans sp
    ON sp.ts_end   > s.slot_start
   AND sp.ts_start < s.slot_end
  GROUP BY s.weekday, s.hour
),

-- Anzahl Kalendertage je Wochentag
weekday_days AS (
  SELECT DAYNAME(d.d) AS weekday, COUNT(*) AS days_count
  FROM dates d
  GROUP BY 1
),

-- Anzahl Tische
tablecount AS (
  SELECT COUNT(*) AS n_tables FROM restaurant_tables
)

SELECT
  ss.weekday,
  ss.hour,
  CONCAT(LPAD(ss.hour,2,'0'), ':00-', LPAD(ss.hour+1,2,'0'), ':00') AS Stundenfenster,
  ROUND(ss.minutes_sum / (60 * wd.days_count), 3) AS durchschn_Anzahl_Tische,
  ROUND(100 * ss.minutes_sum / (60 * wd.days_count * t.n_tables), 1) AS Prozentuale_Auslastung
FROM slot_sums ss
JOIN weekday_days wd ON wd.weekday = ss.weekday
CROSS JOIN tablecount t
ORDER BY FIELD(ss.weekday,'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'),
         ss.hour;




/******************************************************************************************
2) BESTELLUNGSVERHALTEN & KATEGORIEN
******************************************************************************************/

-- 2.1 Durchschnitt warme Speisen pro Wochentag
WITH warm_orders_per_day AS (
    SELECT
        DATE(o.Date_day) AS day,
        COUNT(DISTINCT o.Order_ID) AS warm_orders
    FROM Orders o
    JOIN Order_Dishes od ON od.Order_ID = o.Order_ID
    JOIN Dishes d        ON d.Dish_ID   = od.Dish_ID
    WHERE d.Warm IN ('WAHR', 1, TRUE)
    GROUP BY day
)
SELECT
    DAYNAME(day)              AS weekday,
    ROUND(AVG(warm_orders), 2) AS avg_warm_orders_per_day
FROM warm_orders_per_day
GROUP BY weekday, WEEKDAY(day)
ORDER BY WEEKDAY(day);  -- Montag=0 ... Sonntag=6

-- 2.2 Bestellungsanzahl Speisekategorien pro Stunde des Tages
SELECT
    dc.Category,
    HOUR(o.Time_order) AS hour_of_day,
    SUM(od.Quantity)   AS order_qty
FROM Orders o
JOIN Order_Dishes od ON od.Order_ID = o.Order_ID
JOIN Dishes d        ON d.Dish_ID   = od.Dish_ID
JOIN Dish_Category dc ON dc.Category_ID = d.Category_ID
GROUP BY dc.Category, hour_of_day
ORDER BY dc.Category, hour_of_day;

-- 2.3 Top-Kategorien pro Tageszeitfenster (Lunch / Afternoon / Dinner)
WITH bins AS (
    SELECT
        o.Order_ID,
        CASE
            WHEN HOUR(o.Time_order) BETWEEN 11 AND 15 THEN 'lunch'
            WHEN HOUR(o.Time_order) BETWEEN 16 AND 18 THEN 'afternoon'
            ELSE 'dinner'
        END AS daypart
    FROM Orders o
),
by_cat AS (
    SELECT
        b.daypart, dc.Category,
        SUM(od.Quantity) AS qty
    FROM bins b
    JOIN Order_Dishes od ON od.Order_ID = b.Order_ID
    JOIN Dishes d        ON d.Dish_ID   = od.Dish_ID
    JOIN Dish_Category dc ON dc.Category_ID = d.Category_ID
    GROUP BY b.daypart, dc.Category
)
SELECT *
FROM by_cat
ORDER BY daypart, qty DESC;


/******************************************************************************************
3) TOP-SELLER & UMSATZ
******************************************************************************************/

-- 3.1 Top 10 Gerichte nach Anzahl
SELECT
    d.Dish_ID,
    d.Dish_name,
    SUM(od.Quantity)                     AS units_sold,
    ROUND(SUM(od.Quantity * d.Price), 2) AS revenue
FROM Order_Dishes od
JOIN Dishes d ON d.Dish_ID = od.Dish_ID
GROUP BY d.Dish_ID, d.Dish_name
ORDER BY units_sold DESC
LIMIT 10;

-- 3.2 Top 10 Gerichte nach Umsatz
SELECT
    d.Dish_ID,
    d.Dish_name,
    SUM(od.Quantity)                     AS units_sold,
    ROUND(SUM(od.Quantity * d.Price), 2) AS revenue
FROM Order_Dishes od
JOIN Dishes d ON d.Dish_ID = od.Dish_ID
GROUP BY d.Dish_ID, d.Dish_name
ORDER BY revenue DESC
LIMIT 10;

-- 3.3 Menu-Engineering-Matrix (Popularität vs. Umsatzanteil)
WITH agg AS (
    SELECT
        d.Dish_ID, d.Dish_name,
        SUM(od.Quantity) AS units,
        SUM(od.Quantity * d.Price) AS revenue
    FROM Order_Dishes od
    JOIN Dishes d ON d.Dish_ID = od.Dish_ID
    GROUP BY d.Dish_ID, d.Dish_name
),
ranked AS (
    SELECT
        a.*,
        NTILE(4) OVER (ORDER BY units DESC)   AS pop_quartile,
        NTILE(4) OVER (ORDER BY revenue DESC) AS rev_quartile
    FROM agg a
)
SELECT
    Dish_ID, Dish_name, units, revenue,
    pop_quartile, rev_quartile,
    CASE
        WHEN pop_quartile=1 AND rev_quartile=1 THEN 'Stars'
        WHEN pop_quartile=1 AND rev_quartile>=2 THEN 'Plowhorses'
        WHEN pop_quartile>=3 AND rev_quartile=1 THEN 'Puzzles'
        ELSE 'Dogs'
    END AS menu_segment
FROM ranked
ORDER BY revenue DESC;


/******************************************************************************************
4) KUNDEN- & RESERVIERUNGSANALYSEN
******************************************************************************************/

-- 4.1 Online-Reservierung vs. Bestellwert
SELECT
    CASE #weil nicht alle Booleans gleich sind, habe ich hier das zusammengeführt
        WHEN r.Online_reservation IN (1, '1', TRUE, 'TRUE', 'WAHR') THEN 'Online'
        WHEN r.Online_reservation IN (0, '0', FALSE, 'FALSE', 'FALSCH') THEN 'Offline'
        ELSE 'Laufkundschaft'
    END AS reservation_type,
    COUNT(o.Order_ID)               AS orders_count,
    ROUND(AVG(o.Amount_price), 2)   AS avg_order_value,
    ROUND(SUM(o.Amount_price), 2)   AS total_revenue
FROM Orders o
LEFT JOIN Reservations r 
       ON r.Reservation_ID = o.Reservation_ID
GROUP BY reservation_type
ORDER BY reservation_type;


-- 4.2 Durchschnittliche Personen pro Reservierung
SELECT
    AVG(r.count_persons) AS avg_persons_per_reservation,
    MIN(r.count_persons) AS min_persons,
    MAX(r.count_persons) AS max_persons
FROM Reservations r;

-- 4.3 „Pünktlichkeit“: Differenz Reservierungszeit ↔ tatsächlicher Order-Start
SELECT
    DAYNAME(r.Day_date) AS weekday,
    ROUND(AVG(
        TIMESTAMPDIFF(
            MINUTE,
            TIMESTAMP(r.Day_date, r.Time_reservation),
            TIMESTAMP(o.Date_day, o.Time_order)
        )
    ), 1) AS avg_minutes_late
FROM Reservations r
JOIN Orders o ON o.Reservation_ID = r.Reservation_ID
GROUP BY weekday
ORDER BY FIELD(
    weekday,
    'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'
);



/******************************************************************************************
5) TISCH- & SITZPLATZ-OPTIMIERUNG
******************************************************************************************/

-- 5.1 Beliebteste Tischgrößen
SELECT
    t.Amount_of_seats,
    COUNT(o.Order_ID) AS orders_count
FROM Orders o
JOIN restaurant_tables t ON t.Table_ID = o.Table_ID
GROUP BY t.Amount_of_seats
ORDER BY orders_count DESC;

-- 5.2 Überdimensionierte Tische (zu viele leere Plätze)
SELECT
    t.Amount_of_seats,
    COUNT(*) AS orders_count,
    SUM(CASE
            WHEN r.count_persons IS NOT NULL 
             AND t.Amount_of_seats >= r.count_persons + 2
            THEN 1 ELSE 0
        END) AS over_allocated,
    ROUND(100 * SUM(CASE
            WHEN r.count_persons IS NOT NULL 
             AND t.Amount_of_seats >= r.count_persons + 2
            THEN 1 ELSE 0
        END) / NULLIF(COUNT(*),0), 1) AS over_alloc_pct
FROM Orders o
JOIN restaurant_tables t ON t.Table_ID = o.Table_ID
LEFT JOIN Reservations r ON r.Reservation_ID = o.Reservation_ID
GROUP BY t.Amount_of_seats
ORDER BY over_alloc_pct DESC;


/******************************************************************************************
6) WARENKORB- & GERICHTSKOMBINATIONEN
******************************************************************************************/

-- 6.1 Häufig gemeinsam bestellte Gerichte (Top Dish-Paare)
WITH pairs AS (
  SELECT
      LEAST(od1.Dish_ID, od2.Dish_ID)    AS dish_a,
      GREATEST(od1.Dish_ID, od2.Dish_ID) AS dish_b,
      COUNT(*) AS together_orders
  FROM Order_Dishes od1
  JOIN Order_Dishes od2
    ON od1.Order_ID = od2.Order_ID       -- gleiches Ticket/Bestellung
   AND od1.Dish_ID  < od2.Dish_ID         -- jedes Paar nur 1× (keine A–A, keine Doppelzählung A–B/B–A)
  GROUP BY dish_a, dish_b
)
SELECT
  p.dish_a,
  d1.Dish_name AS dish_a_name,
  p.dish_b,
  d2.Dish_name AS dish_b_name,
  p.together_orders
FROM pairs p
JOIN Dishes d1 ON d1.Dish_ID = p.dish_a    -- Mappe ID -> Name (erstes Element)
JOIN Dishes d2 ON d2.Dish_ID = p.dish_b    -- Mappe ID -> Name (zweites Element)
WHERE p.together_orders >= 20
ORDER BY p.together_orders DESC
LIMIT 20;
