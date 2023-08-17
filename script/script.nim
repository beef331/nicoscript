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
  declColour = 4
  methodColour = 3
  keywordColour = 6
  otherColour = 15
  callColour = 14
  numberColour = 3
  stringColour = 3
  lineColour = 3
  backGroundColour = 1

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

proc textStart(): int =
  const digits = 4
  digits * textWidth(" ") + 10

proc fileStr(): string =
  for i, line in editor.lines.pairs:
    result.add line.strip(leading = false)
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
      if cursor.column > 0:
        let slice = editor.lines[cursor.line][cursor.column .. editor.lines[cursor.line].high]
        editor.lines[cursor.line].setLen(cursor.column)
        editor.lines.insert(" ".repeat(cursor.column) & slice, cursor.line + 1)
      else:
        editor.lines.insert("", cursor.line)

    if mouseBtn(0):
      cursor.line = editor.screenPos + mouse()[1] div selectorHeight()
      cursor.column = (mouse()[0] - textStart()) div textWidth(" ")

    cursor.line -= mouseWheel()

    cursor.line = clamp(cursor.line, 0, editor.lines.high)
    cursor.column = clamp(cursor.column, 0, editor.lines[cursor.line].len)

    if cursor.line - editor.screenPos > rows():
      editor.screenPos = cursor.line - rows()
    if cursor.line <= editor.screenPos:
      editor.screenPos = cursor.line

    editor.screenPos = clamp(editor.screenPos, 0, editor.lines.len)

  else:
    if editor.lines[cursor.line].len == 0:
      editor.lines[cursor.line].add glyph
    else:
      editor.lines[cursor.line].insert(glyph, cursor.column)
    cursor.column += glyph.len


proc draw() =
  cls(backGroundColour)

  let
    startX = textStart()
    (errorLine, errMsg) = getErrorMessage()
  for ind in editor.screenPos .. min(editor.screenPos + rows(), editor.lines.high):

    let line = editor.lines[ind]
    var x = startX
    let y = (ind - editor.screenPos) * selectorHeight()
    setColor(lineColour)
    print($ind, 1, y)
    var pos = 0
    for (tok, _) in line.tokenize(WhiteSpace + {'.', ',', '(', ')', '[', ']', '{', '}', '"', '\'', ':' }):
      pos += tok.high
      let
        isSep = tok.len == 0 or tok[0] in WhiteSpace
        canLookAhead = pos < line.high
      if not isSep:
        if tok in colours:
          setColor(colours[tok])
        elif tok.allCharsInSet(Digits):
          setColor(numberColour)
        elif canLookAhead:
          case line[pos + 1]
          of '(', '[', '.', ')', ']', '{', '}':
            setColor(callColour)
          of '"', '\'':
            setColor(stringColour)
          else:
            setColor(otherColour)
        else:
          setColor(otherColour)

      let tok =
        if x == startX:
          tok.replace("  ", "..")
        else:
          tok
      print(tok, x, y)
      x += textWidth(tok)
      setColor(otherColour)

    if errorLine - 1  == ind:
      setColor(8)
      print(errMsg, x + 1 + textWidth("_"), y)

  setColor(12)
  print("_", startX + cursor.column * textWidth(" "), (cursor.line - editor.screenPos) * selectorHeight() + 2)

proc init =
  startTextInput()
  editor.lines = readScript().splitLines
  setTargetSize(500, 256)

  loadFont(0, "iosevka.png")

init("appname", "orgname")
createWindow("hmm", 256, 256, 4, false)
run(init, update, draw)
