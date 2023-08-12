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


  proc cls*() = discard
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

  proc print*(str: string, x, y: int, scale: int = 1) = discard
  proc readScript*(): string = discard
  

else:
  import nico
  export nico
