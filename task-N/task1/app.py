import os

from flask import Flask
from redis import Redis

app = Flask(__name__)
r = Redis(host=os.environ.get("REDIS_HOST", "redis"), port=6379)


@app.route("/")
def index():
    visits = r.incr("visits")
    return f"Визитов: {visits}\n"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)