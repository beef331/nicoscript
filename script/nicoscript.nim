when defined(nimscript):
  type NicoButton* = enum
    pcLeft = "Left"
    pcRight = "Right"
    pcUp = "Up"
    pcDown = "Down"
    pcA = "A"
    pcB = "B"
    pcX = "X"
    pcY = "Y"
    pcL1 = "L1"
    pcL2 = "L2"
    pcL3 = "L3"
    pcR1 = "R1"
    pcR2 = "R2"
    pcR3 = "R3"
    pcStart = "Start"
    pcBack = "Back"


  proc cls*(i: int = 0) = discard
  proc circ*(x, y, z: int) = discard
  proc circFill*(x, y, z: int) = discard
  proc rect*(x1, y1, x2, y2: int) = discard 
  proc rectFill*(x1, y1, x2, y2: int) = discard
  proc setColor*(i: int) = discard

  proc btn*(_: NicoButton): bool = discard
  proc btnpr*(_: NicoButton, _: int = 48): bool = discard
  proc btnUp*(_: NicoButton): bool = discard

  proc init*(_, _: string) = discard
  proc createWindow*(windowName: string, width, height, scale: int, fullScreen: bool) = discard
  proc run*(init: proc(){.nimcall.}, update: proc(_: float32){.nimcall.}, draw: proc(){.nimcall.}) = discard

  proc screenWidth*(): int = discard
  proc screenHeight*(): int = discard

  proc setTargetSize*(x, y: int) = discard

  proc print*(str: string, x, y: int, scale: int = 1) = discard
  proc textWidth*(str: string, scale: int = 1): int = discard
  proc fontHeight*(): int = discard


  proc readScript*(): string = discard

  proc startTextInput*() = discard
  proc stopTextInput*() = discard
  proc getGlyph*(): string = discard
  proc getErrorMessage*(): (int, string) = discard

  proc mouse*(): (int,int) = discard
  proc mouserel*(): (float32,float32) = discard
  proc mousebtn*(b: range[0..2]): bool = discard
  proc mousebtnup*(b: range[0..2]): bool = discard
  proc mousebtnp*(b: range[0..2]): bool = discard
  proc mousebtnpr*(b: range[0..2], r: int = 48): bool = discard
  proc mousewheel*(): int = discard

else:
  import nico
  export nico
