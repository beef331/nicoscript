import nicoscript

proc update(dt: float32) =
  discard

proc draw() =
  cls(0)
  circFill(0, 0, 100)

proc init() =
  discard

init("appname", "orgname")
createWindow("hmm", 256, 256, 5, false)

run(init, update, draw)