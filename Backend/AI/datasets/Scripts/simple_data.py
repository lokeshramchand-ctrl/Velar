import random
import json
import string

# ---------- CONFIG ----------

NUM_SAMPLES = 3000

categories = {
    "Food": ["Swiggy", "Zomato", "Burger King", "Dominos", "KFC"],
    "Shopping": ["Amazon", "Flipkart", "Nike", "Zudio", "Myntra"],
    "Bills": ["Airtel", "Jio", "Electricity", "Water Bill"],
    "Travel": ["Uber", "Ola", "RedBus"],
    "Entertainment": ["Netflix", "Spotify", "BookMyShow"]
}

templates = [
    "Paid {amount} to {merchant}",
    "Spent {amount} at {merchant}",
    "{merchant} charged {amount}",
    "Payment of {amount} made to {merchant}",
    "{amount} debited for {merchant}",
    "Used UPI to pay {amount} to {merchant}",
    "Txn of {amount} at {merchant}",
    "{merchant} payment of {amount} successful",
]

amount_formats = [
    "₹{amount}",
    "{amount} INR",
    "{amount} rs",
    "Rs {amount}",
    "{amount}"
]

noise_phrases = [
    "",
    " via UPI",
    " using debit card",
    " using credit card",
    " txn id " + str(random.randint(10000, 99999)),
    " successful",
    " at " + str(random.randint(1, 12)) + ":" + str(random.randint(10, 59)) + " PM",
]

typo_prob = 0.1


# ---------- UTIL FUNCTIONS ----------

def introduce_typo(word):
    if len(word) < 4:
        return word
    i = random.randint(0, len(word) - 2)
    return word[:i] + word[i+1] + word[i] + word[i+2:]


def random_case(text):
    return "".join(
        c.upper() if random.random() < 0.2 else c.lower()
        for c in text
    )


def generate_amount():
    return random.randint(50, 5000)


def format_amount(amount):
    fmt = random.choice(amount_formats)
    return fmt.format(amount=amount)


def generate_noise():
    return random.choice(noise_phrases)


def maybe_typo(text):
    words = text.split()
    for i in range(len(words)):
        if random.random() < typo_prob:
            words[i] = introduce_typo(words[i])
    return " ".join(words)


# ---------- SAMPLE GENERATOR ----------

def generate_sample():
    category = random.choice(list(categories.keys()))
    merchant = random.choice(categories[category])
    amount = generate_amount()

    template = random.choice(templates)
    amount_str = format_amount(amount)

    text = template.format(amount=amount_str, merchant=merchant)

    # Add noise
    text += generate_noise()

    # Random casing
    text = random_case(text)

    # Introduce typos
    text = maybe_typo(text)

    return {
        "text": text,
        "amount": amount,
        "merchant": merchant.lower(),
        "category": category
    }


# ---------- DATASET GENERATOR ----------

def generate_dataset(n):
    return [generate_sample() for _ in range(n)]


# ---------- MAIN ----------

if __name__ == "__main__":
    dataset = generate_dataset(NUM_SAMPLES)

    with open("synthetic_dataset.json", "w", encoding="utf-8") as f:
        json.dump(dataset, f, indent=2, ensure_ascii=False)

    print(f"Generated {NUM_SAMPLES} samples → synthetic_dataset.json")
