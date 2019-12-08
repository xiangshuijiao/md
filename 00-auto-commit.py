import time
import datetime
from subprocess import run

# 每隔n秒执行一次
def timer(n):
    while True:
        os.system("git add --all && git commit -m  \"" + time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()) +  "\" && git push origin master")
        time.sleep(n)

timer(180)
    
