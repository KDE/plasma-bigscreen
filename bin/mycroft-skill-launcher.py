#!/usr/bin/env python3

import sys
import json
#import notify2
from websocket import create_connection

#notify2.init("mycroftlauncher")
#n = notify2.Notification('foo', 'bar')
#n.show()
utterance = sys.argv[1]
ws = create_connection("ws://0.0.0.0:8181/core")
msg = {}
msg["type"] = "recognizer_loop:utterance"
msg["data"] = {}
msg["data"]["utterances"] = [utterance]
msg_request = json.dumps(msg)
ws.send(msg_request)
sys.exit()
