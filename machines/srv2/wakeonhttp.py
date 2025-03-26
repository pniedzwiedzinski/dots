import argparse
import time
from flask import Flask
import RPi.GPIO as GPIO

app = Flask(__name__)

# Global configuration variables
GPIO_PIN: int = 14

GPIO.setmode(GPIO.BCM)
GPIO.setup(GPIO_PIN, GPIO.OUT)
GPIO.output(GPIO_PIN, GPIO.LOW)


@app.route("/power", methods=["GET"])
def power_on() -> tuple[str, int]:
    """Endpoint to power on the server."""
    GPIO.output(GPIO_PIN, GPIO.HIGH)
    time.sleep(1)
    GPIO.output(GPIO_PIN, GPIO.LOW)
    return "Server Powering On", 200


def parse_arguments() -> argparse.Namespace:
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Flask app to control and proxy requests to a compute server."
    )
    _ = parser.add_argument("--port", type=int, default=5000, help="Port to listen on.")
    _ = parser.add_argument(
        "--gpio-pin",
        type=int,
        default=14,
        help="GPIO pin number to power on the server.",
    )
    return parser.parse_args()


if __name__ == "__main__":
    try:
        args = parse_arguments()
        # GPIO_PIN = args.gpio_pin

        app.run(host="0.0.0.0", port=args.port)
    finally:
        GPIO.cleanup()
