import nico
from nico/backends/common import keymap
import nimscripter/nimscr
from "$nim"/compiler/nimeval import findNimStdLibCompileTime
import std/[strformat, os, times]

when isMainModule:
  const orgName = "script"
  const appName = "scripter"

  var 
    intr: WrappedInterpreter
    init, update, draw: WrappedPnode
    lastModification = fromUnix(0)
    addins: VmAddins

errorHook = proc(name: cstring, line, col: int, msg: cstring, sev: Severity)  {.cdecl.} =
  echo fmt"{line}:{col}; {msg}"

let
  scriptDir = getAppDir() / "script"
  scriptPath = scriptDir / "script.nim"
var inputedGlyphs: string

discard addEventListener do(evt: Event) -> bool:
  if evt.kind == ekTextInput:
    inputedGlyphs = evt.text
    return true

{.push cdecl.}
proc clsImpl(args: VmArgs)  =
  {.cast(gcSafe).}:
    cls()

proc circImpl(args: VmArgs)  =
  {.cast(gcSafe).}:
    circ(args.getInt(0), args.getInt(1), args.getInt(2))

proc circFillImpl(args: VmArgs)  =
  {.cast(gcSafe).}:
    circFill(args.getInt(0), args.getInt(1), args.getInt(2))

proc rectImpl(args: VmArgs)  =
  {.cast(gcSafe).}:
    rect(args.getInt(0), args.getInt(1), args.getInt(2), args.getInt(3))

proc rectFillImpl(args: VmArgs)  =
  {.cast(gcSafe).}:
    rectFill(args.getInt(0), args.getInt(1), args.getInt(2), args.getInt(3))

proc setColorImpl(args: VmArgs)  =
  {.cast(gcSafe).}:
    setColor(args.getInt(0))

proc btnImpl(args: VmArgs)  =
  {.cast(gcSafe).}:
    args.setResult(btn(NicoButton args.getInt(0)))

proc btnprImpl(args: VmArgs)  =
  {.cast(gcSafe).}:
    args.setResult(btnpr(NicoButton args.getInt(0), int args.getInt(1)))

proc btnupImpl(args: VmArgs)  =
  {.cast(gcSafe).}:
    args.setResult(btnup(NicoButton args.getInt(0)))

proc startTextInputImpl(vmArgs: VmArgs) =
  {.cast(gcSafe).}:
    startTextInput()

proc stopTextInputImpl(vmArgs: VmArgs) =
  {.cast(gcSafe).}:
    stopTextInput()

proc getGlyphImpl(vmArgs: VmArgs) =
  {.cast(gcSafe).}:
    vmArgs.setResult(inputedGlyphs)
    
proc runImpl(args: VmArgs)  =
  {.cast(gcSafe).}:
    init = args.getNode(0)
    update = args.getNode(1)
    draw = args.getNode(2)

proc createWindowImpl(args: VmArgs)  =
  {.cast(gcSafe).}:
    setWindowTitle($args.getString(0))
    setTargetSize args.getInt(1), args.getInt(2)
    setFullscreen(args.getBool(4))

proc printImpl(args: VmArgs)  =
  {.cast(gcSafe).}:
    print($args.getString(0), args.getInt(1), args.getInt(2), args.getInt(3))

proc readScriptImpl(args: VmArgs)  =
  {.cast(gcSafe).}:
    args.setResult(syncio.readFile scriptPath)

proc textWidthImpl(args: VmArgs) =
  {.cast(gcSafe).}:
    args.setResult(textWidth($args.getString(0), args.getInt(1)))

proc fontHeightImpl*(args: VmArgs) =
  {.cast(gcSafe).}:
    args.setResult(fontHeight())

proc screenWidthImpl*(args: VmArgs) =
  {.cast(gcSafe).}:
    args.setResult(screenWidth)

proc screenHeightImpl*(args: VmArgs) =
  {.cast(gcSafe).}:
    args.setResult(screenHeight)

proc setTargetSizeImpl*(args: VmArgs) =
  {.cast(gcSafe).}:
    setTargetSize(args.getInt(0), args.getInt(0))

proc writeFileImpl*(args: VmArgs) =
  {.cast(gcSafe).}:
    writeFile($args.getString(0), $args.getString(1))

{.pop.}

const 
  vmProcs* = [
    VmProcSignature(package: "script", name: "cls", module: "nicoscript", vmProc: clsImpl),
    VmProcSignature(package: "script", name: "circ", module: "nicoscript", vmProc: circImpl),
    VmProcSignature(package: "script", name: "circFill", module: "nicoscript", vmProc: circFillImpl),
    VmProcSignature(package: "script", name: "rect", module: "nicoscript",  vmProc: rectImpl),
    VmProcSignature(package: "script", name: "rectFill", module: "nicoscript", vmProc: rectFillImpl),
    VmProcSignature(package: "script", name: "setColor", module: "nicoscript", vmProc: setColorImpl),
    VmProcSignature(package: "script", name: "btn", module: "nicoscript", vmProc: btnImpl),
    VmProcSignature(package: "script", name: "btnpr", module: "nicoscript", vmProc: btnprImpl),
    VmProcSignature(package: "script", name: "btnup", module: "nicoscript", vmProc: btnupImpl),

    VmProcSignature(package: "script", name: "run", module: "nicoscript", vmProc: runImpl),
    VmProcSignature(package: "script", name: "createWindow", module: "nicoscript", vmProc: createWindowImpl),

    VmProcSignature(package: "script", name: "screenWidth", module: "nicoscript", vmProc: screenWidthImpl),
    VmProcSignature(package: "script", name: "screenHeight", module: "nicoscript", vmProc: screenHeightImpl),
    VmProcSignature(package: "script", name: "setTargetSize", module: "nicoscript", vmProc: setTargetSizeImpl),

    VmProcSignature(package: "script", name: "print", module: "nicoscript", vmProc: printImpl),
    VmProcSignature(package: "script", name: "textWidth", module: "nicoscript", vmProc: textWidthImpl),
    VmProcSignature(package: "script", name: "fontHeight", module: "nicoscript", vmProc: fontHeightImpl),


    VmProcSignature(package: "script", name: "readScript", module: "nicoscript", vmProc: readScriptImpl),

    VmProcSignature(package: "script", name: "startTextInput", module: "nicoscript", vmProc: startTextInputImpl),
    VmProcSignature(package: "script", name: "stopTextInput", module: "nicoscript", vmProc: stopTextInputImpl),
    VmProcSignature(package: "script", name: "getGlyph", module: "nicoscript", vmProc: getGlyphImpl),

    VmProcSignature(package: "stdlib", name: "writeFile", module: "syncio", vmProc: writeFileImpl)
  ]

when isMainModule:
  let theProcs = vmProcs
  addins = VmAddins(procs: cast[ptr UncheckedArray[typeof theProcs[0]]](theProcs.addr), procLen: vmProcs.len)


proc loadTheScript*(addins: VmAddins): WrappedInterpreter =
  let oldDir = getCurrentDir()
  setCurrentDir scriptDir
  result = loadScript(cstring scriptPath, addins, [cstring scriptDir], cstring findNimStdLibCompileTime(), defaultDefines)
  setCurrentDir oldDir

proc invokeVmInit*() =
  if intr != nil and init != nil:
    discard intr.invoke(init, [])

proc invokeVmUpdate*(dt: float32) =
  if intr != nil and update != nil:
    discard intr.invoke(update, [newNode dt])
  inputedGlyphs = ""

proc invokeVmDraw*() =
  if intr != nil and draw != nil:
    discard intr.invoke(draw, [])

when isMainModule:
  proc gameInit() =
    loadFont(0, "font.png")
    intr = loadTheScript(addins)
    invokeVmInit()
    keymap =[
      @[SCANCODE_LEFT], # left
      @[SCANCODE_RIGHT], # right
      @[SCANCODE_UP], # up
      @[SCANCODE_DOWN], # down
      @[SCANCODE_Z, SCANCODE_Y, SCANCODE_SPACE], # A
      @[SCANCODE_X], # B
      @[SCANCODE_LSHIFT, SCANCODE_RSHIFT], # X
      @[SCANCODE_C], # Y

      @[SCANCODE_F1], # L1
      @[SCANCODE_G], # L2
      @[SCANCODE_H], # L3

      @[SCANCODE_V], # R1
      @[SCANCODE_B], # R2
      @[SCANCODE_N], # R3

      @[SCANCODE_RETURN], # Start
      @[SCANCODE_BACKSPACE], # Back
    ]

  proc gameUpdate(dt: float32) =
    if (let lastMod = getLastModificationTime(scriptPath); lastMod) > lastModification:
      echo "reload"
      if intr.isNil:
        intr = loadTheScript(addins)
      else:
        let saveState = intr.saveState()
        intr.reload()
        intr.loadState(saveState)
      if intr != nil:
        invokeVmInit()
        lastModification = lastMod
    invokeVmUpdate(dt)

  proc gameDraw() =
    invokeVmDraw()

  nico.init(orgName, appName)
  nico.createWindow(appName, 128, 128, 4, false)
  nico.run(gameInit, gameUpdate, gameDraw)
