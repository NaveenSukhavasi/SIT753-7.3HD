import os
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello, SIT753-7.3HD!"

if __name__ == "__main__":  # pragma: no cover
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)
