Title: A server launcher with log console in Python Tkinter
Date: 2015-03-13 15:12
Author: admin
Category: coding, hack, scripts
Tags: GUI, Multithreading, python, Tkinter, UDP
Slug: a-server-launcher-with-log-console-in-python-tkinter
Status: published

I'm working on an Tk application that should start and stop an UDP
server, I need to show server logs in the Tk GUI with a "Pause & Resume"
button.

I already have the UDP server implemented using the
blocking [SocketServer.BaseRequestHandler ](https://docs.python.org/2/library/socketserver.html),
so in order to wrap a GUI to the server I need to run the server in a
separate Thread.

My server already logs all messages using the Python
[logging](https://docs.python.org/2/library/logging.html) module, [this
StackExchange snipped](http://stackoverflow.com/a/20671023) shows a good
example of how to write on a Text widget from the logging Python module.

Soon I found that Python Tkinter and multithreading is a
[frequent](http://stackoverflow.com/q/3567238) cause
of [headache](http://bugs.python.org/issue11077).

The secret for avoiding a big waste of debugging hours is to keep away
from all the graphical things child threads. In brief a child thread
cannot interact with Tk, otherwise your application is at risk of
deadlock or race conditions.

So I found the solution to write from the logging handler in a Python
Queue, the Tk widget will read and display the Queue contents using a
recursive [after](http://effbot.org/tkinterbook/widget.htm#Tkinter.Widget.after-method)
callback.

Here the code:

```python
# Copyright 2015 Pietro Bertera \<pietro@bertera.it\>  
#  
# This program is free software: you can redistribute it and/or modify  
# it under the terms of the GNU General Public License as published by  
# the Free Software Foundation, either version 3 of the License, or  
# (at your option) any later version.  
#  
# This program is distributed in the hope that it will be useful,  
# but WITHOUT ANY WARRANTY; without even the implied warranty of  
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the  
# GNU General Public License for more details.  
#  
# You should have received a copy of the GNU General Public License  
# along with this program. If not, see http://www.gnu.org/licenses/

import Queue
import SocketServer
import socket
import sys
import logging
import threading
import Tkinter as tk
from ScrolledText import ScrolledText
 
class QueueLogger(logging.Handler):
    def __init__(self, queue):
        logging.Handler.__init__(self)
        self.queue = queue
 
    # write in the queue
    def emit(self, record):
        self.queue.put(self.format(record).rstrip('\n') + '\n')
 
class LoggedUDPServer(SocketServer.ThreadingMixIn, SocketServer.UDPServer):
    def __init__(self, server_address, RequestHandlerClass, logger):
        SocketServer.UDPServer.__init__(self, server_address, RequestHandlerClass)
        # Add the queue logger
        self.logger = logger
 
class UDPHandler(SocketServer.BaseRequestHandler):
    def handle(self):
        # Queue logger is un under the self.server object
        self.server.logger.debug(self.request[0])
 
class MainApplication:
    def __init__(self, root, log_level, ip, port ):
        self.root = root
        self.log_level = log_level
        self.ip = ip
        self.port = port
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
 
        # 2 rows: firts with settings, second with registrar data
        self.main_frame = tk.Frame(self.root)
        # Commands row doesn't expands
        self.main_frame.rowconfigure(0, weight=0)
        # Logs row will grow
        self.main_frame.rowconfigure(1, weight=1)
        # Main fram can enlarge
        self.main_frame.columnconfigure(0, weight=1)
        self.main_frame.columnconfigure(1, weight=1)
        self.main_frame.grid(row=0, column=0, sticky=tk.NSEW)
 
        # Run/Stop button
        self.control_button = tk.Button(self.main_frame, text="Run Server", command=self.run_server)
        self.control_button.grid(row=0, column=0, sticky=tk.N)
 
        # Clear button
        self.clear_button = tk.Button(self.main_frame, text="Clear Log", command=self.clear_log)
        self.clear_button.grid(row=0, column=1, sticky=tk.N)
 
        # Stop log button
        self.control_log_button = tk.Button(self.main_frame, text="Pause Log", command=self.stop_log)
        self.control_log_button.grid(row=0, column=2, sticky=tk.N)
 
        # Logs Widget
        self.log_widget = ScrolledText(self.main_frame)
        self.log_widget.grid(row=1, column=0, columnspan=3, sticky=tk.NSEW)
 
        # Not editable
        self.log_widget.config(state='disabled')
 
        # Queue where the logging handler will write
        self.log_queue = Queue.Queue()
 
        # Stup the logger
        l = logging.getLogger('logger')
        l.setLevel(self.log_level)
        formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')
        # Use the QueueLogger as Handler
        hl = QueueLogger(queue=self.log_queue)
        hl.setFormatter(formatter)
        l.addHandler(hl)
        self.logger = logging.getLogger('logger')
 
        # Setup the update_widget callback reading logs from the queue
        self.start_log()
 
    def stop_log(self):
        self.logger.debug("Pausing the logger")
        if self.logger_alarm is not None:
            self.log_widget.after_cancel(self.logger_alarm)
            self.control_log_button.configure(text="Start Log", command=self.start_log)
            self.logger_alarm = None
 
    def start_log(self):
        self.logger.debug("Starting the logger")
        self.update_widget(self.log_widget, self.log_queue)
        self.control_log_button.configure(text="Pause Log", command=self.stop_log)
 
    def update_widget(self, widget, queue):
        widget.config(state='normal')
        # Read from the Queue and add to the log widger
        while not queue.empty():
            line = queue.get()
            widget.insert(tk.END, line)
            widget.see(tk.END)  # Scroll to the bottom
            widget.update_idletasks()
        widget.config(state='disabled')
        self.logger_alarm = widget.after(10, self.update_widget, widget, queue)
 
    def clear_log(self):
        self.log_widget.config(state='normal')
        self.log_widget.delete(0.0, tk.END)
        self.log_widget.config(state='disabled')
 
    def run_server(self):
        self.logger.debug("Starting thread")
        try:
            self.server = LoggedUDPServer((self.ip, self.port), UDPHandler, self.logger)
            self.server_thread = threading.Thread(name='server', target=self.server.serve_forever)
            self.server_thread.daemon = True
            self.server_thread.start()
            self.control_button.configure(text="Stop Server", command=self.stop_server)
        except Exception, e:
            self.logger.error("Cannot start the server: %s" % e)
            raise e
 
    def stop_server(self):
        self.logger.debug("Stopping server")
        self.server.shutdown()
        self.server.socket.close()
        self.logger.debug("Server stopped")
        self.control_button.configure(text="Run Server", command=self.run_server)
 
if __name__ == "__main__":
    root = tk.Tk()
    if len(sys.argv) == 3:
        port = int(sys.argv[2])
        address = sys.argv[1]
 
        app = MainApplication(root, logging.DEBUG, address, port)
        root.title(sys.argv[0])
        root.mainloop()
    else:
        print "Error: you must specify address and port.."
        sys.exit(-1)

```

Here a screenshot of the UDP server in action:

![A screenshot of the logging server in action]({attach}/static/tsafe.png)
