import random
import json
import re

NUM_SAMPLES = 3000

# ---------- CATEGORY CONFIG ----------
categories = {
    "Food": ["Swiggy", "Zomato", "KFC"],
    "Shopping": ["Amazon", "Flipkart", "Nike"],
    "Bills": ["Airtel", "Jio", "Electricity"],
    "Travel": ["Uber", "Ola"],
    "Entertainment": ["Netflix", "Spotify"]
}

all_merchants = [m for v in categories.values() for m in v]

# ---------- TEXT VARIATIONS ----------

def random_case(text):
    return "".join(
        c.upper() if random.random() < 0.3 else c.lower()
        for c in text
    )

def merchant_variation(merchant):
    variants = [
        merchant,
        merchant.lower(),
        merchant.upper(),
        merchant + " india",
        merchant + " ltd"
    ]
    return random.choice(variants)

def format_amount(amount):
    formats = [
        f"₹{amount}",
        f"{amount} INR",
        f"{amount} rs",
        f"Rs {amount}",
        str(amount)
    ]
    return random.choice(formats)

def add_noise(text):
    tokens = ["txn id", "upi ref", "success", "debited", "credited"]
    if random.random() < 0.5:
        text += f" {random.choice(tokens)} {random.randint(10000,99999)}"
    return text

# ---------- EASY SAMPLES (CLEAR SIGNAL) ----------

def generate_easy():
    category = random.choice(list(categories.keys()))
    merchant = random.choice(categories[category])
    amount = random.randint(50, 5000)

    templates = [
        "Paid {amount} to {merchant}",
        "Spent {amount} at {merchant}",
        "{merchant} charged {amount}",
    ]

    text = random.choice(templates).format(
        amount=format_amount(amount),
        merchant=merchant
    )

    return {
        "text": text,
        "amount": amount,
        "merchant": merchant.lower(),
        "category": category
    }

# ---------- MEDIUM SAMPLES (NOISE + VARIATION) ----------

def generate_medium():
    category = random.choice(list(categories.keys()))
    merchant = random.choice(categories[category])
    merchant_var = merchant_variation(merchant)
    amount = random.randint(50, 5000)

    templates = [
        "INR {amount} debited from A/C for {merchant}",
        "Rs {amount} spent on {merchant}",
        "{merchant} ko {amount} pay kiya",
        "{amount} rupay kharch kiye {merchant} pe"
    ]

    text = random.choice(templates).format(
        amount=format_amount(amount),
        merchant=merchant_var
    )

    text = add_noise(text)
    text = random_case(text)

    return {
        "text": text.strip(),
        "amount": amount,
        "merchant": merchant.lower(),
        "category": category
    }

# ---------- HARD SAMPLES (AMBIGUITY + ADVERSARIAL) ----------

def generate_hard():
    amount = random.randint(50, 5000)

    hard_type = random.choice([
        "no_merchant",
        "multi_merchant",
        "wrong_signal",
        "generic"
    ])

    if hard_type == "no_merchant":
        text = f"{format_amount(amount)} payment successful"
        return {
            "text": text,
            "amount": amount,
            "merchant": None,
            "category": "Other"
        }

    elif hard_type == "multi_merchant":
        m1 = random.choice(all_merchants)
        m2 = random.choice(all_merchants)
        text = f"Paid {format_amount(amount)} to {m1} and {m2}"
        return {
            "text": text,
            "amount": amount,
            "merchant": m1.lower(),
            "category": random.choice(list(categories.keys()))
        }

    elif hard_type == "wrong_signal":
        merchant = random.choice(all_merchants)
        text = f"{merchant} electricity bill {format_amount(amount)}"
        return {
            "text": text,
            "amount": amount,
            "merchant": merchant.lower(),
            "category": "Bills"
        }

    else:  # generic ambiguous
        text = random.choice([
            "transaction completed",
            "amount debited",
            "money spent"
        ]) + f" {format_amount(amount)}"

        return {
            "text": text,
            "amount": amount,
            "merchant": None,
            "category": "Other"
        }

# ---------- MAIN GENERATOR ----------

def generate_sample():
    r = random.random()

    if r < 0.4:
        return generate_easy()
    elif r < 0.7:
        return generate_medium()
    else:
        return generate_hard()

def generate_dataset(n):
    return [generate_sample() for _ in range(n)]

# ---------- MAIN ----------

if __name__ == "__main__":
    data = generate_dataset(NUM_SAMPLES)

    with open("final_dataset.json", "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print(f"Generated {NUM_SAMPLES} samples (40% easy, 30% medium, 30% hard)")
