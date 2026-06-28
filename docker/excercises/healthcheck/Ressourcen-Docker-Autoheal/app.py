import os
from flask import Flask, Response
import time

app = Flask(__name__)

start_time = time.time()

@app.route("/healthcheck")
def healthcheck():
    if time.time() - start_time > 30:
        return Response(status=500)
    else:
        return Response(status=200)

@app.route("/")
def index():
    return "Hello, world!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)))
