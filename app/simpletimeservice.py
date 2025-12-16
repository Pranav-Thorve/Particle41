from http.server import BaseHTTPRequestHandler, HTTPServer
from datetime import datetime
import json

# Simple HTTP request handler for the SimpleTimeService
class SimpleTimeService(BaseHTTPRequestHandler):

    # Handle HTTP GET requests
    def do_GET(self):
        # Only respond to the root path "/"
        # Any other path returns 404 Not Found
        if self.path != "/":
            self.send_response(404)
            self.end_headers()
            return

        # Retrieve the X-Forwarded-For header if present
        # This header contains the original client IP when behind a load balancer
        xff = self.headers.get("X-Forwarded-For")

        # Use the first IP from X-Forwarded-For if available,
        # otherwise fall back to the direct client socket IP
        client_ip = xff.split(",")[0].strip() if xff else self.client_address[0]

        # Build the JSON response
        response = {
            # Current UTC timestamp in ISO 8601 format
            "timestamp": datetime.utcnow().isoformat(),

            # IP address of the visitor
            "ip": client_ip
        }

        # Send HTTP 200 OK response
        self.send_response(200)

        # Specify JSON content type
        self.send_header("Content-Type", "application/json")
        self.end_headers()

        # Write JSON response body
        self.wfile.write(json.dumps(response).encode())


# Start the HTTP server and listen on port 8080
if __name__ == "__main__":
    HTTPServer(("0.0.0.0", 8080), SimpleTimeService).serve_forever()
