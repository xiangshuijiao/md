import tkinter as tk
import os
import time
from playsound import playsound
from tkinter import filedialog
 
root = tk.Tk()
root.withdraw()

# 17秒内选择的文件大小没有发生变化就播放指定音乐
file_path = filedialog.askopenfilename()
count = 0
file_size_past = 0
while (True):
    file_size_current = os.path.getsize(file_path)
    print("file_size_current = " + str(file_size_current))
    if file_size_current != file_size_past :
        file_size_past = file_size_current
        count = 0
    else :
        count = count + 1
    
    if count == 17 :
        playsound('file://debugpc.jkn/share_data_folder/4-script/1.mp3')
        break

    time.sleep(1)
