# 📄 Projektdokumentation – Restaurant Data Analysis

## 🎯 Ziel
Ein Restaurantbetreiber möchte das Angebot und die Tischstruktur datenbasiert optimieren. Ziel war es, aus Kassen- und Reservierungsdaten zu erkennen:
- Welche Gerichte sind besonders beliebt (nach Anzahl und Umsatz)?
- Welche Tischgrößen werden wann und wie lange belegt?
- Gibt es einen Zusammenhang zwischen Online-Reservierungen und Bestellwert?
- Wie kann das Angebot gezielter auf Kundenverhalten abgestimmt werden?

---

## 🧠 Vorgehensweise

### 1. Analyse der Ausgangsdaten
Vom Kunden bereitgestellt:
- **Reservations** (Datum, Uhrzeit, Online/Offline, No-Show, Personenanzahl)
- **Orders** (Bestellzeit, Checkout, Umsatz, Tisch)
- **Customer** (Kunden-ID und Kontaktdaten)
- **Tables** (Sitzplätze, Indoor/Outdoor)

### 2. Ergänzung fehlender Strukturelemente
Zur vollständigen Analyse wurden neue Entitäten ergänzt:
- `Order_Dishes` – Verknüpfung Bestellungen ↔ Gerichte
- `Dishes` – Gerichte mit Preis, warm/kalt, Typ
- `Dish_Category` – z. B. Vorspeise, Hauptgericht, Dessert, Getränke
- **Inventar- und Verbrauchsmodelle** *(für Ausblick)*:
  - `Ingredients`, `Inventory`, `Dish_Ingredients`, `Consumption_Log`

### 3. ER-Diagramm
Erstellung eines **Entity-Relationship-Diagramms** zur Visualisierung aller Tabellen und Beziehungen:
- **1:n**: Customer ↔ Reservations, Reservation ↔ Orders
- **m:n**: Orders ↔ Dishes (über Order_Dishes)
- **n:1**: Dish ↔ Dish_Category
- **n:1**: Order ↔ Tables

### 4. Mockdaten-Erzeugung
Da echte Daten nicht genutzt werden konnten:
- **Tools**: Python, SQLite, GPT-4, Mockdata-Webseiten
- Erzeugung realistisch strukturierter Daten (Zeiträume, Uhrzeiten, Preislogik)
- Simulation von Restaurantlogik:
  - Tisch nicht doppelt zur gleichen Zeit belegen
  - Personenanzahl ↔ Tischgröße matchen
  - Bestellmengen abhängig von Anzahl Personen

### 5. Datenaufbereitung & Bereinigung
- Umwandlung aller CSVs auf **UTF-8, Komma als Separator**
- Standardisierung von Datums- (`YYYY-MM-DD`) und Zeitformaten (`HH:MM:SS`)
- Umrechnung von Währungswerten (Komma → Punkt für SQL)
- Power Query zur Formatbereinigung vor SQL-Import
- Troubleshooting: Separator-Probleme (`;` vs `,`), falsche Datums-/Währungsformate

### 6. Technische Optimierungen
- **Auto-Increment Primary Keys** für interne IDs
- **Integer-Indexierung** für schnelle Joins
- Präfix-IDs (`S001` für Sushi, `D001` für Dessert) für Lesbarkeit
- Indexe auf häufig genutzte Filterspalten (Datum, Tisch-ID, Kategorie)

### 7. Analyse in SQL & Visualisierung in Power BI
Beispielfragen:
- ⏱ **Durchschnittliche Tischbelegung**: Differenz zwischen `Time_order` und `Time_checkout` pro `Table_ID`
- 🍣 **Top-Gerichte**: nach Anzahl und Umsatz (`Order_Dishes` → `Dishes`)
- 🪑 **Tischnutzung**: Indoor/Outdoor, Tischgröße, Belegungsrate
- 💻 **Online-Reservierung vs. Umsatz**: Vergleich `Reservations.Online` → `Orders.Amount_price`
- 📈 **Stoßzeiten**: Aggregation nach Wochentag/Uhrzeit

### 8. Erkenntnisse & Empfehlungen
- **Tischstruktur**: Mehr modulare kleine Tische für Flexibilität
- **Menüoptimierung**: Fokus auf hochmargige Bestseller
- **Personalplanung**: Stoßzeiten gezielt abdecken
- *(Ausblick)* Integration von Wetterdaten zur Prognose von Gästezahlen

---

## 🗂 Projektstruktur (GitHub)
SushiRestaurantAnalysis/
├── README.md
├── data/
│ ├── raw/ # Originaldaten
│ ├── processed/ # Bereinigte CSVs
├── scripts/
│ └── data_generation/ # Python-Skripte für Mockdaten
├── sql/
│ └── schema/ # CREATE TABLE + Constraints
├── reports/ # Analyseberichte
├── dashboards/ # Power BI
└── docs/ # ERD, technische Doku