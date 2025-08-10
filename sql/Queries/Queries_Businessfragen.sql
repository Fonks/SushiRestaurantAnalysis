## Hier beantworte ich Businessfragen

--  1) Tischdauer (Belegung) je Tisch
-- Dauer in Minuten pro Order und Summe je Tisch
SELECT
  o.Table_ID,
  COUNT(*)                         AS orders_count,
  SUM(TIMESTAMPDIFF(MINUTE,
        TIMESTAMP(o.Date_day, o.Time_order),
        TIMESTAMP(o.Date_day, o.Time_checkout))) AS minutes_occupied,
  ROUND(AVG(TIMESTAMPDIFF(MINUTE,
        TIMESTAMP(o.Date_day, o.Time_order),
        TIMESTAMP(o.Date_day, o.Time_checkout))), 1) AS avg_minutes_per_order
FROM Orders o
GROUP BY o.Table_ID
ORDER BY minutes_occupied DESC;


-- 2) Wie viele warme Speisen an verschiedenen Tagen werden bestellt?
SELECT
  DATE(o.Date_day) AS day,
  SUM(od.Quantity) AS warm_qty
FROM Orders o
JOIN Order_Dishes od ON od.Order_ID = o.Order_ID
JOIN Dishes d        ON d.Dish_ID   = od.Dish_ID
WHERE d.Warm = 1
GROUP BY day
ORDER BY day;



-- 3) Welche Kategorien werden wann bestellt?
--  (Kategorie × Stunde des Bestellstarts)
SELECT
  dc.Category,
  HOUR(o.Time_order) AS hour_of_day,
  SUM(od.Quantity)   AS qty
FROM Orders o
JOIN Order_Dishes od ON od.Order_ID = o.Order_ID
JOIN Dishes d        ON d.Dish_ID   = od.Dish_ID
JOIN Dish_Category dc ON dc.Category_ID = d.Category_ID
GROUP BY dc.Category, hour_of_day
ORDER BY dc.Category, hour_of_day;


-- 4) Top 10 Gerichte (nach Anzahl & Umsatz)
	-- nach Anzahl
    SELECT
  d.Dish_ID,
  d.Dish_name,
  SUM(od.Quantity)                           AS units_sold,
  ROUND(SUM(od.Quantity * d.Price), 2)       AS revenue
FROM Order_Dishes od
JOIN Dishes d ON d.Dish_ID = od.Dish_ID
GROUP BY d.Dish_ID, d.Dish_name
ORDER BY units_sold DESC
LIMIT 10;
	
    -- nach Umsatz
    SELECT
  d.Dish_ID,
  d.Dish_name,
  SUM(od.Quantity)                           AS units_sold,
  ROUND(SUM(od.Quantity * d.Price), 2)       AS revenue
FROM Order_Dishes od
JOIN Dishes d ON d.Dish_ID = od.Dish_ID
GROUP BY d.Dish_ID, d.Dish_name
ORDER BY revenue DESC
LIMIT 10;
