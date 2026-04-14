def get_category_from_rules(text: str):
    if not text:
        return None

    text = text.lower()

    mapping = {
        # FOOD
        "swiggy": "Food",
        "zomato": "Food",
        "ubereats": "Food",
        "burger king": "Food",

        # SHOPPING
        "zudio": "Shopping",
        "nike": "Shopping",
        "amazon": "Shopping",
        "flipkart": "Shopping",

        # BILLS
        "electricity": "Bills",
        "airtel": "Bills",
        "jio": "Bills",
        "wifi": "Bills",

        # ENTERTAINMENT
        "netflix": "Entertainment",
        "spotify": "Entertainment",
        "movie": "Entertainment",

        # TRAVEL
        "uber": "Travel",
        "ola": "Travel",

        # OTHER
        "pharmacy": "Other",
        "hospital": "Other",
        "bank": "Other"
    }

    for keyword, category in mapping.items():
        if keyword in text:
            return category

    return None
