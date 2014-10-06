#!/usr/bin/python
import subprocess
import sys
import os
import htcondor
import classad
import socket

OK = 0
WARNING = 1
CRITICAL = 2
UNKNOWN = 3
rtnMsg = []
exitState = OK
DEVNULL = open(os.devnull, 'w')
def master(rtnMsg, exitState):
 try:
   
   command = '/usr/lib64/nagios/plugins/check_procs -u condor -c 1:1 -C condor_master'
   lm =  subprocess.check_call(command, shell=True, stdout=DEVNULL)
   rtnMsg.append("master")
   exitState = OK
 except subprocess.CalledProcessError, e:
   rtnMsg.append("Condor main not running")
   exitState = CRITICAL
 return exitState
 
def collect(rtnMsg, exitState):
 try:
   coll = htcondor.Collector(socket.gethostname())
   collectors = coll.query(htcondor.AdTypes.Collector, "true", ["Name"])
   numCollectors = len(collectors)
   if numCollectors == 1:
    rtnMsg.append("collector") 
    exitState = OK
   else:
    rtnMsg.append("no collector running")
    exitState = CRITICAL
 except Exception,e:
    rtnMsg.append("no collector running")
    exitState = CRITICAL
 return exitState

def negotiate(rtnMsg, exitState):
 try:
   coll = htcondor.Collector(socket.gethostname())
   negotiators = coll.query(htcondor.AdTypes.Negotiator, "true", ["Name"])
   numNegotiators = len(negotiators)
   if numNegotiators == 1:
    rtnMsg.append("negotiator")
   else:
    rtnMsg.append("no negotiator running")
    exitState = CRITICAL
 except Exception,e:
   rtnMsg.append("no negotiator running")
   exitState = CRITICAL
 return exitState


command = '/usr/bin/condor_config_val daemon_list'
newproc = subprocess.Popen(command, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
daemons = newproc.stdout.readline().rstrip('\n')
daemon = daemons.split(', ')
finalState = []
if 'MASTER' in daemon:
 finalState.append(master(rtnMsg, exitState))
else:
 pass
if 'COLLECTOR' in daemon:
 finalState.append(collect(rtnMsg, exitState))
else:
 pass 
if  'NEGOTIATOR' in daemon:
 finalState.append(negotiate(rtnMsg, exitState))
else:
 pass
print rtnMsg
print finalState
if any(finalState):
 finalExit = 2
else:
 finalExit = 0
raise SystemExit, finalExit
