from flask import Flask, Response, request
import argparse
import threading
import subprocess
import requests


def proxy_pass(url: str) -> Response:
    headers: dict[str, str] = {
        key: value for key, value in request.headers if key.lower() != "host"
    }

    response: requests.Response = requests.request(
        method=request.method,
        url=url,
        headers=headers,
        data=request.get_data(),
        cookies=request.cookies,
        allow_redirects=False,
    )

    excluded_headers = {
        "content-encoding",
        "content-length",
        "transfer-encoding",
        "connection",
    }
    filtered_headers: dict[str, str] = {
        name: value
        for name, value in response.headers.items()
        if name.lower() not in excluded_headers
    }

    return Response(response.content, response.status_code, filtered_headers)


app = Flask(__name__)

SERVICE_URL: str = ""
SHUTDOWN_TIMEOUT: int = 600  # Time to shutdown in seconds
shutdown_timer: threading.Timer | None = None
shutdown_lock: threading.Lock = threading.Lock()


def is_ssh_active() -> bool:
    """Checks if there are active SSH sessions."""
    result = subprocess.run(["who"], capture_output=True, text=True)
    return "pts/" in result.stdout  # SSH sessions are in the form "user pts/0 ..."


def reset_shutdown_timer() -> None:
    """Resets the shutdown timer."""
    global shutdown_timer
    with shutdown_lock:
        if shutdown_timer:
            shutdown_timer.cancel()  # Cancel the previous countdown
        shutdown_timer = threading.Timer(SHUTDOWN_TIMEOUT, shutdown_if_no_activity)
        shutdown_timer.start()
        print("Shutdown timer reset.")


def shutdown_if_no_activity() -> None:
    """Shuts down the computer if there's no SSH activity and no application requests."""
    if not is_ssh_active():
        print("No activity detected, shutting down...")
        # _ = os.system("shutdown -h now")
    else:
        print("SSH session active, canceling shutdown.")
        reset_shutdown_timer()  # Restart the timer if SSH session is still active


@app.route("/<path:path>", methods=["GET", "POST", "PUT", "DELETE", "PATCH"])
def proxy(path: str) -> Response:
    """Proxy requests to the compute server."""
    url: str = f"{SERVICE_URL}/{path}"
    return proxy_pass(url)


def parse_arguments() -> argparse.Namespace:
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Flask app to control and proxy requests to a compute server."
    )
    _ = parser.add_argument("--port", type=int, default=5000, help="Port to listen on.")
    _ = parser.add_argument(
        "--service-url", type=str, required=True, help="Service URL"
    )
    _ = parser.add_argument(
        "--timeout",
        type=int,
        default=600,
        help="Shutdown timeout in seconds",
    )
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_arguments()
    SERVICE_URL = args.service_url
    SHUTDOWN_TIMEOUT = args.timeout
    port: int = args.port

    print(f"Forwarding to {SERVICE_URL}")

    reset_shutdown_timer()  # Start the initial timer
    app.run(host="0.0.0.0", port=port)
