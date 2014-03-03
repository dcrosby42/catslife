appendDebugPanel = -> $('body').append("<div id='debug-panel'><pre id='debug-pre'></pre></div>")
appendDebugPanel()
debug = (str) -> $('#debug-pre').append("#{str}\n")


class KeyboardController
  constructor: (@keyboard,@mappings) ->
    @current = { up: false, down: false, left: false, right: false }
    @previous = {}
    @_addKeyCaptures()
    @update()

  update: ->
    @current = {}
    diff = {}
    @_updateSym(@keyboard,@current,@previous,diff,sym,conf) for sym,conf of @mappings
    @previous = @current
    return diff
    
  _updateSym: (keyboard,current,previous,diff,sym,conf) ->
    if conf.hold
      code = Phaser.Keyboard[conf.hold]
      val = keyboard.isDown(code)
      current[sym] = val
      if val != previous[sym]
        debug "keybd controller: adding diff #{sym}: #{val}"
        diff[sym] = val

  _addKeyCaptures: ->
    for sym,conf of @mappings
      if conf.hold
        code = Phaser.Keyboard[conf.hold]
        if typeof code != 'undefined'
          @keyboard.addKeyCapture(code)

class JoystickController
  constructor: (@input,@joystickName) ->
    @current = {}
    @previous = {}
    @thresh = 0.1

  update: ->
    info = @input[@joystickName]
    if info
      nx = @input[@joystickName].normalizedX
      ny = @input[@joystickName].normalizedY
    else
      nx = 0
      ny = 0
    return if nx == @old_nx and ny == @old_ny
    @current = {}
    @diff = {}
    @_change 'right', nx > @thresh
    @_change 'left', nx < -@thresh
    @_change 'up', ny > @thresh
    @_change 'down', ny < -@thresh
    @previous = @current
    @old_nx = nx
    @old_ny = ny
    @diff


  _change: (key,val) ->
    @current[key] = val
    if val != @previous[key]
      @diff[key] = val



class Simulation
  constructor: (@state) ->

  processEvent: (event) ->
    # window['$events'] ||= []
    # window['$events'].push(event)
    if event.type == "controllerInput"
      if controller = Ecs.get.component(state,event.eid,"controller")
        controller[event.action] = event.value

  update: (world) ->
    Ecs.for.components @state, ['controller','moveControl'], (controller, moveControl) ->
      if controller.up
        moveControl.y = -1
      else if controller.down
        moveControl.y = 1
      else
        moveControl.y = 0

      if controller.left
        moveControl.x = -1
      else if controller.right
        moveControl.x = 1
      else
        moveControl.x = 0

    # TODO... is this an "input" system?
    #   -> joystickController component
    #   -> Phaser joystick input(*)
    #   <- moveControl component
    # Ecs.for.components state, ['joystickController','moveControl'], (joystickController, moveControl) ->
    #   if js = local.getJoystick(joystickController.id)
    #     moveControl.x = js.normalizedX
    #     moveControl.y = js.normalizedY

    # TODO... is this an "input" system?
    #   -> sprite component
    #   -> Phaser sprite position (*)
    #   <- position component
    Ecs.for.components @state, ['sprite','position'], (sprite, position) ->
      phaserSprite = world.spriteTable[sprite.key]
      position.x = phaserSprite.x
      position.y = phaserSprite.y


    Ecs.for.components @state, ['moveControl','velocity'], (moveControl,velocity) ->
      velocity.y = moveControl.y * 200
      velocity.x = moveControl.x * 200

    Ecs.for.components @state, ['action', 'animation','velocity'], (action, animation, velocity) ->
      move = 'idle'
      if velocity.y < 0 then move = 'up'
      if velocity.y > 0 then move = 'down'
      if Math.abs(velocity.x) >= Math.abs(velocity.y)
        if velocity.x > 0 then move = 'right'
        if velocity.x < 0 then move = 'left'
      
      if move == 'idle'
        action.action = "stand"
      else
        action.action = "walk"
        action.direction = move

      animation.name = "#{action.action}_#{action.direction}"

    # TODO: This is an "output" system!
    #   -> sprite component
    #   -> position component
    #   <- Phaser sprite position(*)
    Ecs.for.components @state, ['sprite','position'], (sprite, position) ->
      phaserSprite = world.spriteTable[sprite.key]
      phaserSprite.x = position.x
      phaserSprite.y = position.y

    # TODO: This is an "output" system!
    #   -> sprite component
    #   -> velocity component
    #   <- Phaser sprite body velocity(*)
    Ecs.for.components @state, ['sprite','velocity'], (sprite, velocity) ->
      phaserSprite = world.spriteTable[sprite.key]
      phaserSprite.body.velocity.x = velocity.x
      phaserSprite.body.velocity.y = velocity.y

    # TODO: This is an "output" system!
    #   -> sprite component
    #   -> animation component
    #   <- Phaser sprite animation(*)
    Ecs.for.components @state, ['sprite','animation'], (sprite, animation) ->
      phaserSprite = world.spriteTable[sprite.key]
      phaserSprite.animations.play animation.name


    # TODO: This is an "output" system!
    #   -> sprite component
    #   -> groupLayered component
    #   -> Phaser sprite(*)
    #   -> cached sprite position(*)
    #   -> Phaser group(*)
    #   <- cached sprite position(*)
    #   <- re-sorted Phaser group(*)
    Ecs.for.components @state, ['sprite','groupLayered'], (sprite, groupLayered) ->
      phaserSprite = world.spriteTable[sprite.key]
      oldY = world.spriteOrderingCache[sprite.key]
      if phaserSprite.y != local.oldY
        #  Group.sort() is an expensive operation
        #  You really want to minimise how often it is called as much as possible.
        #  So this little check helps at least, but if you can do it even less than this.
        world.group.sort()
        world.spriteOrderingCache[sprite.key] = phaserSprite.y

    # TODO: This is an "output" system!
    #   -> debugHud component
    #   -> sprite component
    #   -> position component
    #   -> Phaser sprite(*)
    #   <- updated HUD content
    Ecs.for.components @state, ['debugHud','sprite','position'], (debugHud, sprite, position) ->
      phaserSprite = world.spriteTable[sprite.key]
      local.myText.content = "sprite.x: #{phaserSprite.x.toFixed()}, sprite.y: #{phaserSprite.y.toFixed()}\npos.x: #{position.x.toFixed()}, pos.y: #{position.y.toFixed()}"


local = {}
local.spriteTable = {}
local.spriteOrderingCache = {}
local.group = null
local.oldY = 0
local.controllerHookups = []
local.touchEnabled = -> Modernizr.touch
# local.cursorStore = {}
# local.joystickStore = {}
local.myText = null
# local.setJoystick = (joystickId,joystick) -> local.joystickStore[joystickId] = joystick
# local.getJoystick = (joystickId) -> local.joystickStore[joystickId]
# local.setCursors = (keyboardId,cursors) -> local.cursorStore[keyboardId] = cursors
# local.getCursors = (keyboardId) -> local.cursorStore[keyboardId]


createPlayerSprite = (game,group) ->
  #  The player:
  fr = 7
  playerSprite = group.create(0, 0, 'cat')
  # playerSprite = game.add.sprite(0, 0, 'cat')
  playerSprite.animations.add('stand_down', [0], fr, true)
  playerSprite.animations.add('walk_down', [1,2], fr, true)
  playerSprite.animations.add('stand_up', [3], fr, true)
  playerSprite.animations.add('walk_up', [4,5], fr, true)
  playerSprite.animations.add('stand_right', [6], fr, true)
  playerSprite.animations.add('walk_right', [7,8], fr, true)
  playerSprite.animations.add('stand_left', [9], fr, true)
  playerSprite.animations.add('walk_left', [10,11], fr, true)
  playerSprite.animations.play('stand_up')
  playerSprite.scale.x = 0.5
  playerSprite.scale.y = 0.5

  # group.add(playerSprite)

  playerSprite

createGroundLayer = (game) ->
  map = game.add.tilemap('desert')
  tileset = game.add.tileset('tiles')
  layer = game.add.tilemapLayer(0, 0, 800, 600, tileset, map, 0)

initTouchJoystick = (input, inputProperty) ->
  # Use Austin Hallock's HTML5 Virtual Game Controller
  # https://github.com/austinhallock/html5-virtual-game-controller/
  # Note: you must also require gamecontroller.js on your host page.

  # Init game controller with left thumb stick
  GameController.init
    left:
      type: 'joystick'
      joystick:
        touchStart: (->)
          # Don't need this, but the event is here if you want it.
        touchMove: (joystick_details) ->
          input[inputProperty] = joystick_details
        
        touchEnd: ->
          input[inputProperty] = null
    right:
      # We're not using anything on the right for this demo, but you can add buttons, etc.
      # See https://github.com/austinhallock/html5-virtual-game-controller/ for examples.
      type: 'none'

  # This is an ugly hack to get this to show up over the Phaser Canvas
  # (which has a manually set z-index in the example code) and position it in the right place,
  # because it's positioned relatively...
  # You probably don't need to do this in your game unless your game's canvas is positioned in a manner
  # similar to this example page, where the canvas isn't the whole screen.
  $('canvas').last().css('z-index', 20)
  $('canvas').last().offset( $('canvas').first().offset() )

createTreeSprites = (game, group) ->
  # Make some random trees
  for i in [0...50]
    x = game.math.snapTo(game.world.randomX, 32)
    y = game.math.snapTo(game.world.randomY, 32)
    group.create(x, y, 'trees', game.rnd.integerInRange(0, 8))

createHud = (game) ->
  text = game.add.text(16,16, '', {font: '16px arial', fill: "#000" })
  text

state = Ecs.create.state()
simulation = new Simulation(state)
window["$state"] = state # TODO: remove. for debugging only
window["$world"] = local # TODO: remove. for debugging only
window["$simulation"] = simulation # TODO: remove. for debugging only


preload = ->
  game.load.tilemap('desert', 'assets/maps/burd.json', null, Phaser.Tilemap.TILED_JSON)
  game.load.tileset('tiles', 'assets/maps/ground_1x1.png', 32, 32)
  game.load.spritesheet('trees', 'assets/maps/walls_1x2.png', 32, 64)
  game.load.spritesheet('cat', 'assets/cat_frames.png', 150,150)

create = ->
  spriteKey = "player1"
  keyboardId = "keybd1"
  joystickId = "joy1"

  local.entity = "e1"
  Ecs.add.components state, local.entity, Ecs.create.components(
    controller: { up: false, down: false, left: false, right: false }
    groupLayered:  {}
    debugHud:  {}
    moveControl:  x: 0, y: 0
    velocity:  x: 0, y: 0
    position:  x: 0, y: 0
    sprite:    key: spriteKey
    action:  action: "stand", direction: "down"
    animation:  name: "stand_down"
  )


  if local.touchEnabled()
    initTouchJoystick(game.input, 'joystickLeft')
    # local.setJoystick joystickId, createTouchJoystick()
    # controllerComponent = Ecs.create.component 'joystickController', {id: joystickId}
    joystickController = new JoystickController(game.input, "joystickLeft")
    local.controllerHookups.push [local.entity, joystickController]
  else
    arrowKeysController = new KeyboardController(game.input.keyboard, {
      up:    { hold: "UP" }
      down:  { hold: "DOWN" }
      left:  { hold: "LEFT" }
      right: { hold: "RIGHT" }
    })
    local.controllerHookups.push [local.entity, arrowKeysController]

    wasdController = new KeyboardController(game.input.keyboard, {
      up:    { hold: "W" }
      down:  { hold: "S" }
      left:  { hold: "A" }
      right: { hold: "D" }
    })
    local.controllerHookups.push [local.entity, wasdController]

  createGroundLayer(game)

  #  This group will hold the main player + all the tree sprites to depth sort against
  local.group = game.add.group()

  playerSprite = createPlayerSprite(game, local.group)
  local.spriteTable[spriteKey] = playerSprite
  local.spriteOrderingCache[spriteKey] = playerSprite.y

  createTreeSprites(game, local.group)

  local.myText = createHud(game)

#
# Events
#
# character movement 
#   keyboard or joystick -> move.x = -1 etc
#
# character instantiation
#   ? -> player entity & components & phaser objects


# {
#   up:    { hold: "W" }
#   down:  { hold: "S" }
#   left:  { hold: "A" }
#   right: { hold: "D" }
# }

generateInputEvents = (controllerHookups) ->
  events = []

  for [eid,controller] in controllerHookups
    controlChanges = controller.update()

    controlInputEvents = (
      {
        type: "controllerInput"
        eid: local.entity
        action: k
        value: v
      } for k,v of controlChanges)
      
    events = events.concat controlInputEvents

  return events


update = ->
  events = generateInputEvents(local.controllerHookups)

  simulation.processEvent(e) for e in events

  simulation.update(local)

#
# Instantiate the Phaser game object: GO!
#
game = new Phaser.Game(800, 600, Phaser.CANVAS, 'game-div', { preload: preload, create: create, update: update })
