import argparse
import RPi.GPIO as GPIO
import requests
import time
import json
import traceback
import logging
from flask import Flask, request, Response

# Configure logging
logging.basicConfig(
    level=logging.DEBUG, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


def parse_arguments():
    """
    Parse command-line arguments for configuration
    """
    parser = argparse.ArgumentParser(
        description="Ollama Reverse Proxy with GPIO Monitoring"
    )
    parser.add_argument(
        "--port", type=int, default=8000, help="Port to listen on (default: 8000)"
    )
    parser.add_argument(
        "--ollama-url",
        type=str,
        default="http://localhost:11434",
        help="Ollama server URL (default: http://localhost:11434)",
    )
    parser.add_argument(
        "--gpio-pin",
        type=int,
        default=14,
        help="GPIO pin for power cycling (default: 14)",
    )

    return parser.parse_args()


def create_app(ollama_url, gpio_pin):
    app = Flask(__name__)

    # Ollama server configuration
    OLLAMA_URL = ollama_url
    POWER_GPIO_PIN = gpio_pin
    MAX_RETRY_ATTEMPTS = 20
    RETRY_DELAY = 3  # seconds between connection attempts

    # GPIO Setup
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(POWER_GPIO_PIN, GPIO.OUT)
    GPIO.output(POWER_GPIO_PIN, GPIO.LOW)  # Explicitly set pin to LOW on initialization

    def check_ollama_server():
        """
        Check if Ollama server is online by attempting a connection
        """
        try:
            logger.debug(f"Checking Ollama server at {OLLAMA_URL}/api/tags")

            # Use stream=True to handle potential chunked responses
            response = requests.get(f"{OLLAMA_URL}/api/tags", timeout=5)

            # Log full response details for debugging
            logger.debug(f"Response Status Code: {response.status_code}")
            logger.debug(f"Response Headers: {response.headers}")

            return response.status_code == 200

        except requests.ConnectionError as ce:
            logger.error(f"Connection Error: {ce}")
        except requests.Timeout as te:
            logger.error(f"Timeout Error: {te}")
        except Exception as e:
            logger.error(f"Unexpected error checking Ollama server: {e}")
            logger.error(traceback.format_exc())
        return False

    def power_cycle_server():
        """
        Simulate a button press to power on/restart the server
        """
        logger.info(f"Powering on Ollama server using GPIO pin {POWER_GPIO_PIN}...")
        GPIO.output(POWER_GPIO_PIN, GPIO.HIGH)
        time.sleep(1)
        GPIO.output(POWER_GPIO_PIN, GPIO.LOW)

    def wait_for_server_online():
        """
        Wait for Ollama server to come back online
        """
        attempts = 0
        while attempts < MAX_RETRY_ATTEMPTS:
            if check_ollama_server():
                logger.info("Ollama server is back online!")
                return True

            logger.info(
                f"Waiting for server... (Attempt {attempts + 1}/{MAX_RETRY_ATTEMPTS})"
            )
            time.sleep(RETRY_DELAY)
            attempts += 1

        logger.error("Failed to bring Ollama server online")
        return False

    power_cycle_in_progress = False  # Flag to track power cycle status

    @app.before_request
    def ollama_health_check():
        """
        Pre-request handler to check Ollama server health and power cycle if needed
        """
        nonlocal power_cycle_in_progress

        client_ip = request.remote_addr
        logger.info(f"Incoming request from IP: {client_ip}")


        try:
            if not check_ollama_server():
                if power_cycle_in_progress:
                    logger.warning("Power cycle already in progress. Waiting...")
                else:
                    logger.warning("Ollama server is offline. Attempting to power cycle...")
                    power_cycle_in_progress = True
                    power_cycle_server()

                # Wait for server to come back online
                if not wait_for_server_online():
                    raise Exception("Could not bring Ollama server online")

                power_cycle_in_progress = False
        except Exception as e:
            power_cycle_in_progress = False
            logger.error(f"Server health check failed: {e}")
            return "Ollama Server Unavailable", 503

    @app.route("/", defaults={"path": ""})
    @app.route("/<path:path>", methods=["GET", "POST", "PUT", "DELETE"])
    def proxy(path):
        try:
            url = f"{OLLAMA_URL}/{path}"
            data = request.get_data()

            # Prepare headers, removing Host to prevent routing issues
            headers = {
                key: value
                for (key, value) in request.headers
                if key not in ["Host", "Content-Length"]
            }

            # Make the request with streaming
            proxied_request = requests.request(
                method=request.method, url=url, headers=headers, data=data, stream=True
            )  # Proxy the request

            def generate():
                for chunk in proxied_request.iter_content(chunk_size=None):
                    if chunk:
                        yield chunk

            # Forward original response headers and content type
            response_headers = {
                key: value
                for key, value in proxied_request.headers.items()
                if key not in ["Transfer-Encoding", "Connection"]
            }

            return Response(
                generate(),
                content_type=proxied_request.headers.get("Content-Type"),
                status=proxied_request.status_code,
                headers=response_headers,
            )
        except Exception as e:
            logger.error(f"Proxy Error: {e}")
            logger.error(traceback.format_exc())
            return "Proxy Error", 500

    return app


def main():
    # Parse CLI arguments
    args = parse_arguments()

    try:
        # Create Flask app with parsed configuration
        app = create_app(args.ollama_url, args.gpio_pin)

        logger.info("Starting Ollama Proxy:")
        logger.info(f"  - Listening on port {args.port}")
        logger.info(f"  - Ollama URL: {args.ollama_url}")
        logger.info(f"  - GPIO Pin: {args.gpio_pin}")

        # Start the Flask app
        app.run(host="0.0.0.0", port=args.port)
    except Exception as e:
        logger.error(f"Application startup error: {e}")
        logger.error(traceback.format_exc())
    finally:
        # Cleanup GPIO on script exit
        GPIO.cleanup()


if __name__ == "__main__":
    main()
