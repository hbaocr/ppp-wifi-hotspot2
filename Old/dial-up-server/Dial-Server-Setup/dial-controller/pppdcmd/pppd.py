# import subprocess
# result = subprocess.run("ls -al", shell=True, stdout = subprocess.PIPE, stderr = subprocess.PIPE)
# print(result.stdout.decode("cp932"))

import fcntl
import os
import signal
import re
import time

from subprocess import Popen, PIPE, STDOUT
PPPD_RETURNCODES = {
    1:  'Fatal error occured',
    2:  'Error processing options',
    3:  'Not executed as root or setuid-root',
    4:  'No kernel support, PPP kernel driver not loaded',
    5:  'Received SIGINT, SIGTERM or SIGHUP',
    6:  'Modem could not be locked',
    7:  'Modem could not be opened',
    8:  'Connect script failed',
    9:  'pty argument command could not be run',
    10: 'PPP negotiation failed',
    11: 'Peer failed (or refused) to authenticate',
    12: 'The link was terminated because it was idle',
    13: 'The link was terminated because the connection time limit was reached',
    14: 'Callback negotiated',
    15: 'The link was terminated because the peer was not responding to echo reque               sts',
    16: 'The link was terminated by the modem hanging up',
    17: 'PPP negotiation failed because serial loopback was detected',
    18: 'Init script failed',
    19: 'Failed to authenticate to the peer',
}

class PPPConnectionError(Exception):
    def __init__(self, code, output=None):
        self.code = code
        self.message = PPPD_RETURNCODES.get(code, 'Undocumented error occured')
        self.output = output

        super(Exception, self).__init__(code, output)

    def __str__(self):
        return self.message

class PPPConnection:
    def __init__(self,pppd_cmd):
        self.proc = Popen(pppd_cmd, 
        stdout=PIPE, 
        stderr=STDOUT, 
        preexec_fn=os.setsid)
        # set stdout to non-blocking
        fd = self.proc.stdout.fileno()
        fl = fcntl.fcntl(fd, fcntl.F_GETFL)
        fcntl.fcntl(fd, fcntl.F_SETFL, fl | os.O_NONBLOCK)
    
    def poll(self):
        while(True):
            try:
                time.sleep(1)
                data = self.proc.stdout.read()
                if data:
                    self.output += data
            except IOError as e:
                if e.errno != 11: #Resource temporarily unavailable
                    #raise Exception("Err: "+ str(e))
                    print(str(e)) 
                    return {"code":1, "msg":str(e)}

                time.sleep(1)

            if b'ip-up finished' in self.output:
                print("New ppp connection :" )
                print(self.output.decode("utf-8") )
                return {"code":0, "msg":self.output.decode("utf-8")}
            elif self.proc.poll(): #if exit : it return exit code otherwise return NONE
                print(PPPD_RETURNCODES.get(self.proc.returncode, 'Undocumented error occured'))
                return {"code":1, "msg":PPPD_RETURNCODES.get(self.proc.returncode, 'Undocumented error occured')}
                #raise PPPConnectionError(self.proc.returncode, self.output)
    
    def terminate(self):
        self.proc.kill()
    def getoutput(self):
        return self.output