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
    errorLine: int
    errorMessage: string

errorHook = proc(name: cstring, line, col: int, msg: cstring, sev: Severity)  {.cdecl.} =
  errorLine = line
  errorMessage = fmt"{col}: {msg}"
  echo errorMessage

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
    cls(args.getInt(0))

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

proc mouseImpl(args: VmArgs) =
  {.cast(gcSafe).}:
    args.setResult newNode mouse()

proc mouseRelImpl(args: VmArgs) =
  {.cast(gcSafe).}:
    args.setResult newNode mouseRel()

proc mouseBtnImpl(args: VmArgs) =
  {.cast(gcSafe).}:
    args.setResult mousebtn(args.getInt(0))

proc mouseBtnupImpl(args: VmArgs) =
  {.cast(gcSafe).}:
    args.setResult mousebtnUp(args.getInt(0))

proc mouseBtnpImpl(args: VmArgs) =
  {.cast(gcSafe).}:
    args.setResult mousebtnp(args.getInt(0))

proc mouseBtnPrImpl(args: VmArgs) =
  {.cast(gcSafe).}:
    args.setResult mousebtnPr(args.getInt(0), args.getInt(1))

proc mouseWheelImpl(args: VmArgs) =
  {.cast(gcSafe).}:
    args.setResult mouseWheel()

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

proc loadFontImpl(args: VmArgs) =
  {.cast(gcSafe).}:
    let strPath = $args.getString(1)
    try:
      loadFont(args.getInt(0), strPath)
    except:
      echo "Could not load: ", strPath

proc screenWidthImpl(args: VmArgs) =
  {.cast(gcSafe).}:
    args.setResult(screenWidth)

proc screenHeightImpl(args: VmArgs) =
  {.cast(gcSafe).}:
    args.setResult(screenHeight)

proc setTargetSizeImpl(args: VmArgs) =
  {.cast(gcSafe).}:
    setTargetSize(args.getInt(0), args.getInt(0))

proc writeFileImpl(args: VmArgs) =
  {.cast(gcSafe).}:
    writeFile($args.getString(0), $args.getString(1))

proc setCameraImpl(args: VmArgs) =
  {.cast(gcSafe).}:
    setCamera(args.getInt(0), args.getInt(1))

proc getCameraImpl(args: VmArgs) =
  {.cast(gcSafe).}:
    args.setResult newNode getCamera()

proc getErrorMessageImpl(args: VmArgs) =
  {.cast(gcSafe).}:
    args.setResult(newNode (errorLine, errorMessage))

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


    VmProcSignature(package: "script", name: "mouse", module: "nicoscript", vmProc: mouseImpl),
    VmProcSignature(package: "script", name: "mouserel", module: "nicoscript", vmProc: mouseRelImpl),
    VmProcSignature(package: "script", name: "mousebtn", module: "nicoscript", vmProc: mouseBtnImpl),
    VmProcSignature(package: "script", name: "mousebtnup", module: "nicoscript", vmProc: mouseBtnupImpl),
    VmProcSignature(package: "script", name: "mousebtnp", module: "nicoscript", vmProc: mouseBtnpImpl),
    VmProcSignature(package: "script", name: "mousebtnpr", module: "nicoscript", vmProc: mouseBtnPrImpl),
    VmProcSignature(package: "script", name: "mousewheel", module: "nicoscript", vmProc: mouseWheelImpl),


    VmProcSignature(package: "script", name: "setCamera", module: "nicoscript", vmProc: setCameraImpl),
    VmProcSignature(package: "script", name: "getCamera", module: "nicoscript", vmProc: getCameraImpl),

    VmProcSignature(package: "script", name: "run", module: "nicoscript", vmProc: runImpl),
    VmProcSignature(package: "script", name: "createWindow", module: "nicoscript", vmProc: createWindowImpl),

    VmProcSignature(package: "script", name: "screenWidth", module: "nicoscript", vmProc: screenWidthImpl),
    VmProcSignature(package: "script", name: "screenHeight", module: "nicoscript", vmProc: screenHeightImpl),
    VmProcSignature(package: "script", name: "setTargetSize", module: "nicoscript", vmProc: setTargetSizeImpl),

    VmProcSignature(package: "script", name: "print", module: "nicoscript", vmProc: printImpl),
    VmProcSignature(package: "script", name: "textWidth", module: "nicoscript", vmProc: textWidthImpl),
    VmProcSignature(package: "script", name: "fontHeight", module: "nicoscript", vmProc: fontHeightImpl),
    VmProcSignature(package: "script", name: "loadFont", module: "nicoscript", vmProc: loadFontImpl),



    VmProcSignature(package: "script", name: "readScript", module: "nicoscript", vmProc: readScriptImpl),

    VmProcSignature(package: "script", name: "startTextInput", module: "nicoscript", vmProc: startTextInputImpl),
    VmProcSignature(package: "script", name: "stopTextInput", module: "nicoscript", vmProc: stopTextInputImpl),
    VmProcSignature(package: "script", name: "getGlyph", module: "nicoscript", vmProc: getGlyphImpl),

    VmProcSignature(package: "stdlib", name: "writeFile", module: "syncio", vmProc: writeFileImpl),
    VmProcSignature(package: "script", name: "getErrorMessage", module: "nicoscript", vmProc: getErrorMessageImpl)


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
  if intr.isValid and init != nil:
    discard intr.invoke(init, [])

proc invokeVmUpdate*(dt: float32) =
  if intr.isValid and update != nil:
    discard intr.invoke(update, [newNode dt])
  inputedGlyphs = ""

proc invokeVmDraw*() =
  if intr.isValid and draw != nil:
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
      errorMessage = ""
      errorLine = -1
      if not intr.isValid:
        intr = loadTheScript(addins)
      else:
        let saveState = intr.saveState()
        intr.reload(true)
        intr.loadState(saveState)
      if intr.isValid:
        invokeVmInit()
        lastModification = lastMod

    invokeVmUpdate(dt)

  proc gameDraw() =
    invokeVmDraw()

  nico.init(orgName, appName)
  nico.createWindow(appName, 128, 128, 4, false)
  nico.run(gameInit, gameUpdate, gameDraw)
