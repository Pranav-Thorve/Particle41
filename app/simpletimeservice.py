from http.server import BaseHTTPRequestHandler, HTTPServer
from datetime import datetime
import json

class SimpleTimeService(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path != "/":
            self.send_response(404)
            self.end_headers()
            return

        xff = self.headers.get("X-Forwarded-For")
        client_ip = xff.split(",")[0].strip() if xff else self.client_address[0]

        response = {
            "timestamp": datetime.utcnow().isoformat(),
            "ip": client_ip
        }

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(response).encode())

if __name__ == "__main__":
    HTTPServer(("0.0.0.0", 8080), SimpleTimeService).serve_forever()
