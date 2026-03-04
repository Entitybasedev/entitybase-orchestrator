#!/bin/sh
apk add --no-cache mysql-client python3 py3-pymysql > /dev/null 2>&1

python3 -c "
import http.server
import socketserver
import pymysql

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        try:
            conn = pymysql.connect(host='mysql', user='root', connect_timeout=2)
            conn.close()
            status = 200
            msg = b'healthy'
        except:
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
