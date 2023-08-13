import nicoscript
import std/[math, strutils, tables]

 
type 
  Cursor = object
    line: int
    column: int
  Editor = object
    cursor: Cursor
    lines: seq[string]
    screenPos: int

const
  declColour = 2
  methodColour = 5
  keywordColour = 12
  otherColour = 12
  callColour = 14
  numberColour = 3
  lineColour = 2
  backGroundColour = 0

  colours = {
    "var": declColour,
    "let": declColour,
    "const": declColour,
    "type": declColour,
    "proc": methodColour,
    "func": methodColour,
    "template": methodColour,
    "macro": methodColour,
    "if": keywordColour,
    "of": keywordColour,
    "else": keywordColour,
    "when": keywordColour,
    "elif": keywordColour,
    "case": keywordColour,
    "for": keywordColour,
    "import": keywordColour,
    "except": keywordColour,
    "from": keywordColour
  }.toTable


var 
  posX* = 64
  posY* = 32
  editor*: Editor

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
    
    if btnpr(pcDown, 2):
      inc editor.cursor.line
    if btnpr(pcUp, 2):
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
  cls(backGroundColour)

  let
    digits = 4 
    startX = digits * textWidth(" ") + 5

  for ind in editor.screenPos .. min(editor.screenPos + rows(), editor.lines.high):
    let line = editor.lines[ind]
    var x = startX 
    let y = (ind - editor.screenPos) * (fontHeight() + 1)
    setColor(lineColour)
    print($ind, 1, y)
    for (tok, isSep)in line.tokenize:
      if not isSep:
        if tok in colours:
          setColor(colours[tok])
        elif tok.allCharsInSet(Digits):
          setColor(numberColour)
        else:
          setColor(otherColour)
        let ind = tok.find'('
        if ind >= 0:
          setColor(callColour)
          let left = tok[0..ind - 1]
          print(left, x, y)
          x += textWidth(left)
          if ind < tok.len:
            setColor(otherColour)
            let right  = tok[ind..^1]
            print(right, x, y)
            x += textWidth(right)
        else:
          print(tok, x, y)
          x += textWidth(tok)
      else:
        x += textWidth(tok)

  setColor(1)
  print("_", startX + editor.cursor.column * textWidth(" "), (editor.cursor.line - editor.screenPos) * (fontHeight() + 1) + 1)

proc init =
  startTextInput()
  editor.lines = readScript().splitLines
  setTargetSize(340, 240)

init("appname", "orgname")
createWindow("hmm", 256, 256, 4, false)
run(init, update, draw)





