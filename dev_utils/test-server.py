#!/usr/bin/env python3

from http.server import BaseHTTPRequestHandler, HTTPServer
from json import dumps
import re

import psycopg2
import uuid

""" The HTTP request handler """
class RequestHandler(BaseHTTPRequestHandler):

    def _send_cors_headers(self):
        """ Sets headers required for CORS """
        self.send_header("Access-Control-Allow-Origin", "http://localhost:3000")
        self.send_header("Access-Control-Allow-Methods", "GET,POST,OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "x-api-key,Content-Type,access-control-allow-origin")
        self.send_header("Access-Control-Allow-Credentials", "true")

    def send_dict_response(self, d):
        """ Sends a dictionary (JSON) back to the client """
        self.wfile.write(bytes(dumps(d), "utf8"))

    def do_OPTIONS(self):
        self.send_response(200)
        self._send_cors_headers()
        self.end_headers()

    def do_GET(self):
        self.send_response(200)
        self._send_cors_headers()
        self.end_headers()

        ### This is your grand-dads url-parsing
        res = re.search(r"id=([^&]+)", self.path)
        if not res:
            print("No match")
            response = {"status": "Not Ok"}
            self.send_dict_response(response)

        id_to_retry = res[1]
        print(f"Will retry {id_to_retry}")

        response = {}
        response["status"] = "OK"
        self.send_dict_response(response)

    def do_POST(self):
        self.send_response(200)
        self._send_cors_headers()
        self.send_header("Content-Type", "application/json")
        self.end_headers()

        dataLength = int(self.headers["Content-Length"])
        data = self.rfile.read(dataLength)

        print(data)

        response = {}
        response["status"] = "OK"
        self.send_dict_response(response)


print("Starting server")
port = 8808
httpd = HTTPServer(("127.0.0.1", port), RequestHandler)
print(f"Hosting server on port {port}")
httpd.serve_forever()
