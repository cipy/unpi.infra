#!/usr/bin/python3

from guizero import App, Text, Picture

app = App(title="Atentie")
line = Text(app, "")
info = Text(app, text=">>> calculatorul unPi isi face acum update <<<")
stop = Text(app, text="te rog nu-l opri inca!")
line2 = Text(app, "")
image = Picture(app, image="/usr/share/cups/doc-root/images/wait.gif")

line.text_size = 30
info.text_size = 20
stop.text_size = 35
line2.text_size = 20
image.resize(100,100)

app.bg = "yellow"
app.display()
