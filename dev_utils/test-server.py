#!/usr/bin/env python3

from http.server import BaseHTTPRequestHandler, HTTPServer
from json import dumps

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

      print("Will make a query")

      conn = psycopg2.connect(
          host="localhost",
          port=5432,
          database="lega",
          user="postgres",
          password="rootpass")

      c = conn.cursor()
      c.execute("""INSERT INTO sda.files (submission_user, submission_file_path) VALUES (%s, %s)""", ('userXX', '/userXX/sfeaads/' + str(uuid.uuid4())))
      conn.commit()

      print("Query done")

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
