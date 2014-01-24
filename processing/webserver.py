#!/usr/bin/env python

import re
import os
import urllib2
import SimpleHTTPServer
import BaseHTTPServer
import SocketServer 

PORT = 8080
SERVER = '0.0.0.0'

class CustomHandler(SimpleHTTPServer.SimpleHTTPRequestHandler):
	def do_GET(self):
		if not os.path.exists(self.path):
			match = re.match(r'/data/replays/viewreplay_(.*).json', self.path)
			if match:
				data = urllib2.urlopen('http://osn.codepenguin.com/api/getReplay/' + match.group(1)).read()
				output = open(self.path[1:],'w')
				output.write(data)
				output.close()
				pass
		return SimpleHTTPServer.SimpleHTTPRequestHandler.do_GET(self)

Handler = CustomHandler

class Server(SocketServer.ThreadingMixIn, BaseHTTPServer.HTTPServer):
	pass

httpd = Server((SERVER, PORT), Handler)
print "Web Server listening on http://%s:%s/ (stop with ctrl+c)..." % (SERVER, PORT)

try:
	httpd.serve_forever()
except KeyboardInterrupt:
	print "Closing server..."