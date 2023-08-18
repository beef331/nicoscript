import nico
from nico/backends/common import keymap
import nimscripter/nimscr
from "$nim"/compiler/nimeval import findNimStdLibCompileTime
import std/[strformat, os, times]


type Environment* = object
  intr: WrappedInterpreter
  init, update, draw: WrappedPnode
  lastModification: Time
  path*: string

when isMainModule:
  const orgName = "script"
  const appName = "scripter"

  type State = enum
    Editing, Playing

  var
    errorLine: int
    errorMessage: string
    presentState = Editing
    envs = [
      Editing: Environment(path: getAppDir() / "script" / "editor.nim"),
      Playing: Environment(path: getAppDir() / "script" / "script.nim")
    ]

errorHook = proc(name: cstring, line, col: int, msg: cstring, sev: Severity)  {.cdecl.} =
  errorLine = line
  errorMessage = fmt"{col}: {msg}"

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
    envs[presentState].init = args.getNode(0)
    envs[presentState].update = args.getNode(1)
    envs[presentState].draw = args.getNode(2)

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
    args.setResult(syncio.readFile envs[Playing].path)

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


proc invokeVmInit*() =
  if envs[presentState].intr.isValid and envs[presentState].init != nil:
    discard envs[presentState].intr.invoke(envs[presentState].init, [])

proc invokeVmUpdate*(dt: float32) =
  if envs[presentState].intr.isValid and envs[presentState].update != nil:
    discard envs[presentState].intr.invoke(envs[presentState].update, [newNode dt])
  inputedGlyphs = ""

proc invokeVmDraw*() =
  if envs[presentState].intr.isValid and envs[presentState].draw != nil:
    discard envs[presentState].intr.invoke(envs[presentState].draw, [])

proc loadTheScript*(envs: var array[State, Environment]) =
  let state = presentState
  for ind, env in envs.mpairs:
    if not env.intr.isValid:
      let 
        oldDir = getCurrentDir()
        dir = env.path.parentDir
      setCurrentDir dir
     
      let name = env.path.splitFile.name

      var vmProcs =  vmProcs
      for prc in vmProcs.mitems:
        if prc.package == "script":
          prc.package = cstring name

      let addins = VmAddins(procs: cast[ptr UncheckedArray[VmProcSignature]](vmProcs.addr), procLen: vmProcs.len)
      presentState = ind
      env.intr = loadScript(env.path, addins, [cstring dir], cstring findNimStdLibCompileTime(), defaultDefines)
      invokeVmInit()
    

      setCurrentDir oldDir

when isMainModule:
  var 
    defaultKeyMap: array[NicoButton, seq[ScanCode]]
  const
    editorKeymap = [
      @[SCANCODE_LEFT], # left
      @[SCANCODE_RIGHT], # right
      @[SCANCODE_UP], # up
      @[SCANCODE_DOWN], # down
      @[SCANCODE_Z, SCANCODE_Y, SCANCODE_SPACE], # A
      @[SCANCODE_X], # B
      @[SCANCODE_LSHIFT, SCANCODE_RSHIFT], # X
      @[SCANCODE_C], # Y

      @[SCANCODE_F1], # L1
      @[SCANCODE_F2], # L2
      @[SCANCODE_H], # L3

      @[SCANCODE_V], # R1
      @[SCANCODE_B], # R2
      @[SCANCODE_N], # R3

      @[SCANCODE_RETURN], # Start
      @[SCANCODE_BACKSPACE], # Back
    ]



  proc gameInit() =
    loadFont(0, "font.png")
    envs.loadTheScript()
    invokeVmInit()
    defaultKeyMap = keymap
    keymap = editorKeymap
    keymap[pcL2] = @[ScanCodeF2]

  proc gameUpdate(dt: float32) =
    if (let lastMod = getLastModificationTime(envs[presentState].path); lastMod) != envs[presentState].lastModification:
      errorMessage = ""
      errorLine = -1
      if not envs[presentState].intr.isValid:
        envs.loadTheScript()
      else:
        let saveState = envs[presentState].intr.saveState()
        envs[presentState].intr.reload(true)
        envs[presentState].intr.loadState(saveState)
      if envs[presentState].intr.isValid:
        invokeVmInit()
        envs[presentState].lastModification = lastMod

    if btnpr(pcL2, 60):
      case presentState
      of Editing:
        presentState = Playing
      of Playing:
        presentState = Editing

    invokeVmUpdate(dt)

  proc gameDraw() =
    invokeVmDraw()

nico.init(orgName, appName)
nico.createWindow(appName, 128, 128, 4, false)
nico.run(gameInit, gameUpdate, gameDraw)
