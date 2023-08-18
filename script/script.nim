import nicoscript

var
  posX* = 0f
  dir = 1
  time* = 0f

const radius = 30f

proc update(dt: float32) =
  posX += float32(dir) * dt * 50
  if posX notin radius .. float32(screenWidth()) - radius:
    dir *= -1
    posX = clamp(posX, radius + 0.01, float32(screenWidth()) - radius - 0.01)
  time += dt

proc draw() =
  cls(0)
  setColor(1 + int(time) mod 15)
  circFill(int posX, screenHeight() div 2, int radius)

proc init() =
  setTargetSize(128, 128)

init("appname", "orgname")
createWindow("hmm", 128, 128, 5, false)
run(init, update, draw)
