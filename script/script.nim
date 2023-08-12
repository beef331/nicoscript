import nicoscript

import std/math

var 
  time*: float32
  posX* = 64
  posY* = 32

proc update(dt: float32) = 
  time += dt
  
  if btn(pcLeft):
    posX -= 1
  if btn(pcRight):
    posX += 1
  
  if btn(pcUp):
    posY -= 1
  if btn(pcDown):
    posY += 1


proc draw() =
  cls()
  if btn(pcA):
    setColor(13)
  else:
    setColor(10)
  circFill(posX,posY + int(sin(time * 5) * 10), 20)

  setColor(3)
  circFill(posX - 6,posY - 6 + int(sin(time * 5) * 10), 3)
  circFill(posX + 6,posY - 6 + int(sin(time * 5) * 10), 3)


  setColor(3)
  circFill(posX,posY + 10 + int(sin(time * 5) * 10), 2)


  setColor(3)
  circFill(posX + 20,posY + int(sin((time * 5) + Tau / 4) * 4), 10)
  circFill(posX - 20,posY + int(sin((time * 5) + Tau / 4) * 4), 10)

proc init = discard

init("appname", "orgname")
createWindow("hmm", 128, 128, 4, false)
run(init, update, draw)

