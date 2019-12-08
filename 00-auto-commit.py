import time
import datetime
import os

if (int(time.time()) % 300 == 0):
    os.system("git add --all && git commit -m  \"" + time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()) +  "\" && git push origin master")
