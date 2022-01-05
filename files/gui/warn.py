#!/usr/bin/python3

import os
from guizero import App, Text, Picture

def testSpeed():
  with open("/tmp/speed", 'a+') as f:
    f.seek(0); speed.value = f.read()

run = os.system("speedtest --simple | tee /tmp/speed | logger &")

app = App(title="Atentie")
line = Text(app, "")
info = Text(app, text=">>> calculatorul unPi isi face acum update <<<")
stop = Text(app, text="te rog nu-l opri inca!")
line2 = Text(app, "")
image = Picture(app, image="/usr/share/cups/doc-root/images/wait.gif")
line30 = Text(app, "")
try:
  image2 = Picture(app, image="/var/tmp/emojis/1f0cf.gif")
except: image2 = image
line3 = Text(app, "")
speed = Text(app, "")

line.text_size = 30
info.text_size = 20
stop.text_size = 35
line2.text_size = 20
line30.text_size = 30
line3.text_size = 20
image.resize(100,100)
image2.resize(200,200)

app.repeat(30*1000, testSpeed)
app.bg = "yellow"
app.display()
