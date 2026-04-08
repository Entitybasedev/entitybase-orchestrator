#!/bin/sh
apk add --no-cache docker-cli python3 > /dev/null 2>&1

python3 -c "
import http.server
import socketserver
import subprocess
import json

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        try:
            result = subprocess.run(
                ['docker', 'exec', 'redpanda', 'rpk', 'cluster', 'health', '--format', 'json'],
                capture_output=True, timeout=5
            )
            health = json.loads(result.stdout)
            if health.get('is_healthy'):
                status = 200
                msg = b'healthy'
            else:
                status = 503
                msg = b'unhealthy'
        except Exception as e:
            status = 503
            msg = b'unhealthy'
        self.send_response(status)
        self.send_header('Content-Type', 'text/plain')
        self.end_headers()
        self.wfile.write(msg)

socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(('', 8080), Handler) as httpd:
    httpd.serve_forever()
"