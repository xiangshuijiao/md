import time
import datetime
from subprocess import run

# 每隔n秒执行一次
def timer(n):
    while True:
        run("git add --all && git commit -m  \"" + time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()) +  "\" && git push origin master", shell=True)
        print("start sleep...\n")
        time.sleep(n)
timer(180)
    
