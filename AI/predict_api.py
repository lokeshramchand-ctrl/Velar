from flask import Flask, request, jsonify
import joblib  
import sklearn  
import numpy as np

model = joblib.load("model/category_model.pkl")
vectorizer = joblib.load("model/vectorizer.pkl")  

app = Flask(__name__)

@app.route("/api/predict", methods=["POST"])
def predict():
    data = request.json
    description = data.get("description", "")

    if not description:
        return jsonify({"error": "Description is required"}), 400

    # Preprocess and predict
    X = vectorizer.transform([description])
    prediction = model.predict(X)[0]

    return jsonify({"category": prediction})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
