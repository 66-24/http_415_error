import os
# save as server.py
from http.server import BaseHTTPRequestHandler, HTTPServer

class SimpleHandler(BaseHTTPRequestHandler):
    # declare which types we accept
    accepted = ['application/text']

    def do_POST(self):
        ctype = self.headers.get('Content-Type', '')
        if ctype not in self.accepted:
            # 415 + advertise what we accept
            self.send_response(415, "Unsupported Media Type")
            self.send_header('Content-Type', 'text/plain')
            self.send_header('Accept-Post', ', '.join(self.accepted))
            self.end_headers()
            self.wfile.write(b'415: Unsupported Media Type\n')
            return

        # If acceptable, echo back
        length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(length)
        self.send_response(200)
        self.send_header('Content-Type', 'text/plain')
        self.end_headers()
        self.wfile.write(b"Received Text:\n" + body)

    def do_OPTIONS(self):
        # allow POST and report accepted types
        self.send_response(200)
        self.send_header('Allow', 'OPTIONS, POST')
        self.send_header('Accept-Post', ', '.join(self.accepted))
        self.end_headers()

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8888))
    addr = ('', port)
    print(f"Listening on http://localhost:{port}")
    HTTPServer(addr, SimpleHandler).serve_forever()
