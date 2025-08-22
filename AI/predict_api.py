# from flask import Flask, request, jsonify
# import joblib  
# import sklearn  
# import numpy as np
# from Rules.transaction_rules import get_category_from_rules

# model = joblib.load("model/category_model.pkl")
# vectorizer = joblib.load("model/vectorizer.pkl")  

# app = Flask(__name__)

# @app.route("/api/predict", methods=["POST"])
# def predict():
#     data = request.json
#     description = data.get("description", "")

#     if not description:
#         return jsonify({"error": "Description is required"}), 400
      
#     category = get_category_from_rules(description)
#     if not category:
#       X = vectorizer.transform([description])
#       prediction = model.predict(X)[0]

#     return jsonify({"category": prediction})

# if __name__ == "__main__":
#     app.run(host="0.0.0.0", port=5000)
from flask import Flask, request, jsonify
import joblib
import sklearn
import numpy as np
from Rules.transaction_rules import get_category_from_rules

model = joblib.load("model/category_model.pkl")
vectorizer = joblib.load("model/vectorizer.pkl")

app = Flask(__name__)

@app.route("/api/predict", methods=["POST"])
def predict():
    data = request.json
    description = data.get("description", "")

    if not description:
        return jsonify({"error": "Description is required"}), 400

    # First try rules
    category = get_category_from_rules(description)

    if category:
        prediction = category   # ✅ assign directly
    else:
        # fallback to ML
        X = vectorizer.transform([description])
        prediction = model.predict(X)[0]

    return jsonify({"category": prediction})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
