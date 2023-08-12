import nicoscript
import std/[math, strutils]

type 
  Cursor = object
    line: int
    column: int
  Editor = object
    cursor: Cursor
    lines: seq[string]
    screenPos: int


var 
  time*: float32
  posX* = 64
  posY* = 32
  editor = Editor()

proc update(dt: float32) = 
  time += dt
  
  if btnpr(pcLeft, 5):
    dec editor.cursor.column
  if btnpr(pcRight, 5):
    inc editor.cursor.column
  
  if btnpr(pcDown, 5):
    inc editor.cursor.line
  if btnpr(pcUp, 5):
    dec editor.cursor.line


  editor.cursor.line = clamp(editor.cursor.line, 0, editor.lines.high)
  editor.cursor.column = clamp(editor.cursor.column, 0, editor.lines[editor.cursor.line].high)

  if editor.cursor.line - editor.screenPos > 12:
    editor.screenPos = editor.cursor.line - 12
  if editor.cursor.line <= editor.screenPos:
    editor.screenPos = editor.cursor.line
  editor.screenPos = clamp(editor.screenPos, 0, editor.lines.high)


proc draw() =
  cls()
  for ind in editor.screenPos .. max(editor.screenPos + 12, editor.lines.high):
    let y = ind - editor.screenPos
    setColor(3)
    print($ind, 1, y * 10)
    setColor(5)
    print(editor.lines[ind], 10, y * 10)
  setColor(7)
  print("_", 10 + editor.cursor.column * 4, (editor.cursor.line - editor.screenPos) * 10 + 1)

proc init =
  editor.lines = readScript().splitLines
discard {'a', 'b', 'c'}
init("appname", "orgname")
createWindow("hmm", 256, 256, 4, false)
run(init, update, draw)
