import os
import threading
import signal
import sys
import time
import subprocess
import logging



class FilebeatManager(object):
    def __init__(self):
        self.thread = threading.Thread(target=self.start_filebeat, args=())

    def start_filebeat(self):
      command = 'filebeat  -c filebeat.yml --path.config /app '
      with open('filebeat.log', "w") as f:
        process = subprocess.Popen(command.split(), stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        for c in iter(lambda: process.stdout.readline(), b''): 
          sys.stdout.buffer.write(c)
          f.buffer.write(c)

    def handle_sig(self, signal, frame):
        logging.warning("received signal!")
        for i in range(45):
            logging.warning("Filebeat manager will exit in {} second...".format(45-i))
            time.sleep(1)
        os._exit(1)

    def template_config(self):
      # It is pretty silly use to sigil to template something
      # from within a python script, however we are currently just attempting to
      # replace the bash entrypoint with this script, we can improve later
      try:
        meta_vars = []
        for var in os.environ.keys():
            if 'NOMAD' in var:
                meta_vars.append('{}={}'.format(var,os.environ[var]))
        command = 'sigil -f ./filebeat.yml.tmpl meta_vars={}'.format(','.join(meta_vars)) 
        process = subprocess.Popen(command.split(), stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        stdout = process.communicate()
        config = stdout[0].decode()
        rc = process.returncode
        if rc != 0:
            logging.error("Templating config returned Non-zero!")
            config = None
      except Exception as e:
        print("Exception: {}".format(e))
        config = None
      return config

        
if __name__ == "__main__":
     log_level = os.environ.get("LOG_LEVEL")
     if not log_level or log_level not in logging.__dict__:
         log_level = "INFO"
         logging.basicConfig(
         format="%(asctime)s - %(levelname)s %(message)s", level=logging.__dict__[log_level]
     )
     logging.info("Starting FilebeatManager...")
     mngr = FilebeatManager()
     signal.signal(signal.SIGTERM, mngr.handle_sig)
     signal.signal(signal.SIGINT, mngr.handle_sig)
     logging.info("Generating Filebeat Config...")
     config = mngr.template_config()
     if not config:
        logging.error("Could not generate config!")
        sys.exit(1)
     try:
       with open("filebeat.yml", 'w') as fh:
           fh.write(config)
     except Exception as e:
       logging.error("Failed to write config file!")
       logging.error("Exception: {}".format(e))
       sys.exit()
     logging.info("Config generated, launching filebeat thread...")
     mngr.thread.start()
     logging.info("Filebeat thread is running!")
     # Just block until signalled to do other wise
     while True:
       time.sleep(1)
