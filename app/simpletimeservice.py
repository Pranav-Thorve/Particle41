from http.server import BaseHTTPRequestHandler, HTTPServer
from datetime import datetime
import json

class SimpleTimeService(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path != "/":
            self.send_response(404)
            self.end_headers()
            return

        response = {
            "timestamp": datetime.utcnow().isoformat(),
            "ip": self.client_address[0]
        }

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(response).encode())

if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", 8080), SimpleTimeService)
    server.serve_forever()
