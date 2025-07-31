# 🍽️ Restaurant Insights – Datenbasiertes Menü- & Tischmanagement

Ein datenanalytisches Projekt zur Optimierung der Speisekarte und Tischorganisation in einem Restaurant.

## 🎯 Ziel des Projekts

Ein Restaurantbetreiber wollte das Angebot auf Basis von **Kassendaten und Kundenverhalten** optimieren. Ziel war es, mithilfe datenbasierter Analysen herauszufinden:

- Welche Gerichte sind besonders beliebt?
- Welche Tischgrößen sind wann und wie lange belegt?
- Gibt es Zusammenhänge zwischen Online-Reservierung und Bestellverhalten?

Auf Basis dieser Erkenntnisse sollten fundierte Handlungsempfehlungen abgeleitet werden – von der Speisekartenoptimierung bis zur Tischstruktur.

---

## 🧠 Vorgehensweise

### 1. Analyse der vorhandenen Daten
Der Kunde lieferte CSV-Dateien zu:
- `Reservations` (Datum, Uhrzeit, online/offline)
- `Orders` (Zeitpunkt, Umsatz, Tisch)
- `Customer_ID`
- `Tables` (Sitzanzahl, indoor/outdoor)

### 2. Ergänzung fehlender Strukturelemente
Zur vollständigen Analyse wurden folgende Tabellen erstellt:
- `Order_Dishes` – Welche Gerichte wurden pro Bestellung geordert?
- `Dishes` – Liste aller Gerichte mit Preis
- `Dish_Category` – Kategorisierung in z. B. Vorspeise, Hauptgericht, Dessert

### 3. Erstellung eines ER-Diagramms
Ein Entity-Relationship-Diagramm half dabei, Datenquellen zu strukturieren, Beziehungen zu identifizieren und Lücken aufzudecken.

### 4. Generierung realistischer Mockdaten
Da echte Kassendaten aus Datenschutzgründen nicht verwendet werden durften, wurden mit **Python, SQLite, GPT-4 und Mockdata-Websites** realistische Mockdaten erzeugt – in Struktur und Verhalten nah an der Realität.

### 5. Automatische Klassifizierung von Gerichten
Durch die Verwendung von **präfixbasierten IDs** (z. B. `S001` für Sushi) konnten Gerichte automatisiert Kategorien zugewiesen werden.

### 6. Technische Umsetzung & Optimierung
- Verwendung von **Auto-Increment Primary Keys** in SQL
- **Integer-Indexierung** zur Performancesteigerung
- Zusätzliche externe IDs für bessere Lesbarkeit in Berichten

### 7. Datenanalyse & Visualisierung
Mittels SQL und Power BI wurden zentrale Fragestellungen analysiert (siehe unten).

### 8. Handlungsempfehlungen
Die Analyse lieferte konkrete Empfehlungen für:
- Tischstruktur (z. B. kleine Tische modular stellen)
- Menüoptimierung nach Nachfrage
- bessere Planung für Stoßzeiten & Personal

---

## 📊 Analysefragen basierend auf dem ERD

- **🪑 Wie lange bleibt ein Tisch besetzt?**  
  → Zeitdifferenz zwischen `Time_order` und `Time_checkout` je `Table_ID`

- **🔥 Wie viele warme Speisen werden meist bestellt?**  
  → Filter auf `Dish.Warm = True` und Aggregation über `Order_Dishes`

- **🍷 Welche Kategorien (z. B. Getränke vs. Hauptgericht) werden wann bestellt?**  
  → `Order → Order_Dishes → Dish → Dish_Category`

- **🥇 Top 10 Gerichte (nach Anzahl & Umsatz)**  
  → `COUNT(*)` und `SUM(Price × Quantity)` pro `Dish_ID`

- **🌐 Sind Online-Reservierungen mit höherem Bestellwert verknüpft?**  
  → Vergleich `Reservations.Online` mit `Order.Amount_price`

- **🪟 Wie hoch ist die Auslastung je Tisch (Indoor/Outdoor, Uhrzeit)?**  
  → `Table_ID`, `Time_order–Time_checkout`, `Tables.Indoor`

- **👥 Welche Tischarten werden bevorzugt?**  
  → Analyse nach `Table_ID`, `Amount_of_seats`

- **📆 Wie viele Personen kommen pro Reservierung (geschätzt)?**  
  → Ableitung über `Order_Dishes` oder belegte Plätze je Tisch

---

## 🧰 Technologien & Tools

- **Python** (pandas, Faker, sqlite3)
- **SQL** (Joins, Aggregationen, Auto-Increment Keys)
- **Power BI** (Dashboard, DAX Measures)
- **ER-Diagramm** (dbdiagram.io / Lucidchart)
- **Mockdaten-Generatoren** (Faker, GPT-4, testdatagen.com)

---

## 📁 Projektstruktur

restaurant-insights/
│
├── data/ → CSV-Dateien aller Tabellen
├── sql/ → SQL-Skripte: Modell, Inserts, Queries
├── powerbi/ → Power BI Dashboard (.pbix)
├── visuals/ → Screenshots von Auswertungen
├── README.md → Projektbeschreibung (diese Datei)
└── restaurant_report.pdf → Vollständiger Projektbericht (optional)
