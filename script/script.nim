import nicoscript
import std/[math, strutils, tables]

 
type 
  Cursor = object
    line: int
    column: int
  Editor = object
    lines: seq[string]
    screenPos: int

const
  declColour = 2
  methodColour = 5
  keywordColour = 12
  otherColour = 12
  callColour = 14
  numberColour = 3
  lineColour = 3
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
  cursor*: Cursor
  editor*: Editor

proc selectorHeight: int = fontHeight() + 2

proc rows(): int =
  screenHeight() div (selectorHeight()) - 1 # screenSize getter

proc fileStr(): string =
  for i, line in editor.lines.pairs:
    result.add line
    if i != editor.lines.high:
      result.add "\n"

proc update(dt: float32) = 
  let glyph = getGlyph()

  if glyph.len == 0: 
  
    if btnpr(pcLeft, 5):
      dec cursor.column
                       
    if btnpr(pcRight, 5):
      inc cursor.column
    
    if btnpr(pcDown, 5):
      inc cursor.line

    if btnpr(pcUp, 5):
      dec cursor.line

    if btnpr(pcBack, 5):
      if editor.lines[cursor.line].len == 0:
        editor.lines.delete(cursor.line)
        cursor.line = clamp(cursor.line - 1, 0, editor.lines.high)
        cursor.column = clamp(cursor.column, 0, editor.lines[cursor.line].high)
      else:
        if cursor.column > 0:
          editor.lines[cursor.line].delete(cursor.column - 1, cursor.column - 1)
          dec cursor.column
        else:
          editor.lines[cursor.line - 1].add editor.lines[cursor.line]
          editor.lines.delete(cursor.line)                                                                                    
          cursor.column = editor.lines[cursor.line].len                                                       

    if btnpr(pcL1):
      writeFile("script/script.nim", fileStr())

    if btnpr(pcStart):
      let slice = editor.lines[cursor.line][cursor.column .. editor.lines[cursor.line].high]
      editor.lines[cursor.line].setLen(cursor.column)
      editor.lines.insert(" ".repeat(cursor.column) & slice, cursor.line + 1)
      inc cursor.line

    cursor.line = clamp(cursor.line, 0, editor.lines.high)
    cursor.column = clamp(cursor.column, 0, editor.lines[cursor.line].len)

    if cursor.line - editor.screenPos > rows():
      editor.screenPos = cursor.line - rows()
    if cursor.line <= editor.screenPos:
      editor.screenPos = cursor.line

    editor.screenPos = clamp(editor.screenPos, 0, editor.lines.len)

  else:
    editor.lines[cursor.line].insert(glyph, cursor.column)
    cursor.column += glyph.len


proc draw() =
  cls(backGroundColour)

  let
    digits = 4 
    startX = digits * textWidth(" ") + 5

  for ind in editor.screenPos .. min(editor.screenPos + rows(), editor.lines.high):

    let line = editor.lines[ind]
    var x = startX 
    let y = (ind - editor.screenPos) * selectorHeight()
    setColor(lineColour)
    print($ind, 1, y)

    for (tok, isSep) in line.tokenize:
      if not isSep:
        if tok in colours:
          setColor(colours[tok])
        elif tok.allCharsInSet(Digits):
          setColor(numberColour)
        else:
          setColor(otherColour)
        var ind = tok.find"("
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

  setColor(7)
  print("_", startX + cursor.column * textWidth(" "), (cursor.line - editor.screenPos) * selectorHeight() + 2)

proc init =
  startTextInput()
  editor.lines = readScript().splitLines
  setTargetSize(400, 240)

init("appname", "orgname")
createWindow("hmm", 256, 256, 4, false)
run(init, update, draw)
