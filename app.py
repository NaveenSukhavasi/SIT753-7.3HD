import os
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello, SIT753-7.3HD!"

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    # Listen on all interfaces
    app.run(host="0.0.0.0", port=port)