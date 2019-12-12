#!/usr/bin/env python3

import sys
import json
from websocket import create_connection

event_type = sys.argv[1]
ws = create_connection("ws://0.0.0.0:8181/core")
msg = {}
msg["type"] = event_type
msg["data"] = {}
msg_request = json.dumps(msg)
ws.send(msg_request)
sys.exit()
