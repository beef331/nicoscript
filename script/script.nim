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
  posX* = 64
  posY* = 32
  editor* = Editor()

proc rows(): int =
  screenHeight() div (fontHeight() + 1) - 1 # screenSize getter

proc fileStr(): string =
  for line in editor.lines:
    result.add line
    result.add "\n"

proc update(dt: float32) = 
  let glyph = getGlyph()
  if glyph.len == 0: 
  
    if btnpr(pcLeft, 3):
      dec editor.cursor.column

    if btnpr(pcRight, 3):
      inc editor.cursor.column
    
    if btnpr(pcDown, 3):
      inc editor.cursor.line

    if btnpr(pcUp, 3):
      dec editor.cursor.line

    if btnpr(pcBack, 5):
      if editor.lines[editor.cursor.line].len == 0:
        editor.lines.delete(editor.cursor.line)
      else:
        if editor.cursor.column > 0:
          editor.lines[editor.cursor.line].delete(editor.cursor.column - 1, editor.cursor.column - 1)
          dec editor.cursor.column

    if btnpr(pcL1):
      writeFile("script/script.nim", fileStr())

    if btnpr(pcStart):
      editor.lines.insert("", editor.cursor.line + 1)
      inc editor.cursor.line

    editor.cursor.line = clamp(editor.cursor.line, 0, editor.lines.high)
    editor.cursor.column = clamp(editor.cursor.column, 0, editor.lines[editor.cursor.line].len)

    if editor.cursor.line - editor.screenPos > rows():
      editor.screenPos = editor.cursor.line - rows()
    if editor.cursor.line <= editor.screenPos:
      editor.screenPos = editor.cursor.line

    editor.screenPos = clamp(editor.screenPos, 0, editor.lines.len)

  else:
    editor.lines[editor.cursor.line].insert(glyph, editor.cursor.column)
    editor.cursor.column += glyph.len


proc draw() =
  cls()
  for ind in editor.screenPos .. min(editor.screenPos + rows(), editor.lines.high):
    let y = ind - editor.screenPos
    setColor(3)
    print($ind, 1, y * (fontHeight() + 1))
    setColor(8)
    print(editor.lines[ind], 10, y * (fontHeight() + 1))
  setColor(7)
  print("_", 10 + editor.cursor.column * 4, (editor.cursor.line - editor.screenPos) * (fontHeight() + 1) + 1)

proc init =
  startTextInput()
  editor.lines = readScript().splitLines
  setTargetSize(512, 128)

init("appname", "orgname")
createWindow("hmm", 256, 256, 5, false)
run(init, update, draw)












