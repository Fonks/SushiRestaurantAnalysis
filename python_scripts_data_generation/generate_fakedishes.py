import pandas as pd
import random

# Kategorien laut Screenshot
categories = {
    1: 'appetizer',
    2: 'main',
    3: 'dessert',
    4: 'drink_alcoholic',
    5: 'drink_nonalcoholic'
}

# Grunddaten
dish_types = ['vegan', 'vegetarian', 'meat', 'fish']
main_dish_types = ['rice', 'noodle', 'soup', 'sushi', None]

# Ergebnisliste
dishes = []
dish_id = 1

# 1. Sushi (20)
sushi_names = [f"Sushi Roll {i}" for i in range(1, 21)]
for name in sushi_names:
    dishes.append({
        "Dish_ID": dish_id,
        "Dish_name": name,
        "Price": round(random.uniform(7.5, 14.0), 2),
        "Warm": False,
        "Category_ID": 2,
        "dish_description": f"Fusion-style sushi roll with unique ingredients {name[-1]}",
        "dish_type": random.choice(['fish', 'vegetarian']),
        "main_dish_type": 'sushi'
    })
    dish_id += 1

# 2. Weitere mains (10)
main_dishes = [
    ("Red Thai Curry", "meat", "rice", True),
    ("Green Thai Curry", "vegan", "rice", True),
    ("Pho Bo", "meat", "soup", True),
    ("Pho Chay", "vegan", "soup", True),
    ("Pad Thai", "vegetarian", "noodle", True),
    ("Yaki Udon", "meat", "noodle", True),
    ("Bibimbap", "vegetarian", "rice", True),
    ("Khao Pad", "meat", "rice", True),
    ("Kimchi Stew", "fish", "soup", True),
    ("Tofu Teriyaki Bowl", "vegan", "rice", True)
]

for name, dtype, mtype, warm in main_dishes:
    dishes.append({
        "Dish_ID": dish_id,
        "Dish_name": name,
        "Price": round(random.uniform(11.0, 16.0), 2),
        "Warm": warm,
        "Category_ID": 2,
        "dish_description": f"{name} – Asian fusion main dish",
        "dish_type": dtype,
        "main_dish_type": mtype
    })
    dish_id += 1

# 3. Appetizers (10)
appetizers = [
    ("Edamame", "vegan", False),
    ("Spring Rolls", "vegetarian", True),
    ("Gyoza (Veggie)", "vegetarian", True),
    ("Gyoza (Chicken)", "meat", True),
    ("Seaweed Salad", "vegan", False),
    ("Miso Soup", "vegan", True),
    ("Kimchi", "vegan", False),
    ("Chicken Satay", "meat", True),
    ("Tempura Veggies", "vegetarian", True),
    ("Shrimp Chips", "fish", False)
]

for name, dtype, warm in appetizers:
    dishes.append({
        "Dish_ID": dish_id,
        "Dish_name": name,
        "Price": round(random.uniform(4.0, 7.5), 2),
        "Warm": warm,
        "Category_ID": 1,
        "dish_description": f"{name} – popular starter",
        "dish_type": dtype,
        "main_dish_type": None
    })
    dish_id += 1

# 4. Desserts (5)
desserts = [
    ("Mango Sticky Rice", "vegan"),
    ("Matcha Ice Cream", "vegetarian"),
    ("Coconut Jelly", "vegan"),
    ("Fried Banana", "vegetarian"),
    ("Black Sesame Mochi", "vegan")
]

for name, dtype in desserts:
    dishes.append({
        "Dish_ID": dish_id,
        "Dish_name": name,
        "Price": round(random.uniform(4.0, 6.5), 2),
        "Warm": False,
        "Category_ID": 3,
        "dish_description": f"{name} – Asian dessert",
        "dish_type": dtype,
        "main_dish_type": None
    })
    dish_id += 1

# 5. Drinks (15 alcoholic, 15 non-alcoholic)
alcoholic_drinks = [
    "Sake", "Plum Wine", "Asahi Beer", "Tiger Beer", "Soju", "Choya", "Yuzu Spritz",
    "Lychee Martini", "Sake Mojito", "Asian Mule", "Umeshu Soda", "Tsingtao", "Sakura Fizz",
    "Shiso Sour", "Red Rice Beer"
]

non_alcoholic_drinks = [
    "Jasmine Tea", "Matcha Latte", "Thai Iced Tea", "Lemongrass Iced Tea", "Coconut Water",
    "Lychee Juice", "Yuzu Lemonade", "Iced Genmaicha", "Mango Lassi", "Plum Juice",
    "Ramune", "Sparkling Yuzu Water", "Water", "Green Tea", "Soy Milk Shake"
]

for name in alcoholic_drinks:
    dishes.append({
        "Dish_ID": dish_id,
        "Dish_name": name,
        "Price": round(random.uniform(4.0, 7.0), 2),
        "Warm": False,
        "Category_ID": 4,
        "dish_description": f"{name} – Asian alcoholic beverage",
        "dish_type": None,
        "main_dish_type": None
    })
    dish_id += 1

for name in non_alcoholic_drinks:
    dishes.append({
        "Dish_ID": dish_id,
        "Dish_name": name,
        "Price": round(random.uniform(2.5, 5.0), 2),
        "Warm": random.choice([True, False]),
        "Category_ID": 5,
        "dish_description": f"{name} – Asian non-alcoholic drink",
        "dish_type": None,
        "main_dish_type": None
    })
    dish_id += 1

# In DataFrame umwandeln
dish_df = pd.DataFrame(dishes)

# CSV exportieren
dish_df.to_csv("fake_dishes.csv", index=False)
