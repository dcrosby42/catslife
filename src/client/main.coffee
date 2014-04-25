 # appendDebugPanel = -> $('body').append("<div id='debug-panel'><pre id='debug-pre'></pre></div>")
# appendDebugPanel()
# debug = (str) -> $('#debug-pre').append("#{str}\n")
# debug = (str) -> $('#debug-pre').append("#{str}\n")
debug = (s...) -> console.log(s...)


#
# DEFINE SYSTEMS:
# 

UpdateMoveControl = Ecs.create.system
  name: "update-move-control"
  search: ['controller','moveControl']
  update: (controller, moveControl) ->
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

ReadSpritePosition = Ecs.create.system
  name: "read-sprite-position"
  search: ['sprite', 'position']
  update: (sprite, position) ->
    phaserSprite = @context.world.spriteTable[sprite.key]
    position.x = phaserSprite.x
    position.y = phaserSprite.y

UpdateVelocity = Ecs.create.system
  name: "update-velocity"
  search: [ 'moveControl', 'velocity' ]
  update: (moveControl, velocity) ->
    velocity.y = moveControl.y * 200
    velocity.x = moveControl.x * 200

UpdateAnimationAction = Ecs.create.system
  name: "update-animation-action"
  search: [ 'action', 'animation','velocity'],
  update: (action, animation, velocity) ->
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

WriteSpritePosition = Ecs.create.system
  name: "write-sprite-position"
  search: ['sprite','position']
  update: (sprite, position) ->
    phaserSprite = @context.world.spriteTable[sprite.key]
    phaserSprite.x = position.x
    phaserSprite.y = position.y

WriteSpriteVelocity = Ecs.create.system
  name: "write-sprite-velocity"
  search: ['sprite','velocity']
  update: (sprite, velocity) ->
    phaserSprite = @context.world.spriteTable[sprite.key]
    phaserSprite.body.velocity.x = velocity.x
    phaserSprite.body.velocity.y = velocity.y

WriteSpriteAnimation = Ecs.create.system
  name: "write-sprite-animation"
  search: ['sprite','animation']
  update: (sprite, animation) ->
    phaserSprite = @context.world.spriteTable[sprite.key]
    phaserSprite.animations.play animation.name

SortSprites = Ecs.create.system
  name: "sort-sprites"
  search: ['sprite', 'groupLayered']
  update: (sprite, groupLayered) ->
    phaserSprite = @context.world.spriteTable[sprite.key]
    oldY = @context.world.spriteOrderingCache[sprite.key]
    if phaserSprite.y != @context.world.oldY
      #  Group.sort() is an expensive operation
      #  You really want to minimise how often it is called as much as possible.
      #  So this little check helps at least, but if you can do it even less than this.
      @context.world.group.sort()
      @context.world.spriteOrderingCache[sprite.key] = phaserSprite.y

UpdateDebugHud = Ecs.create.system
  name: "update-debug-hud"
  search: ['debugHud','sprite','position']
  update: (debugHud, sprite, position) ->
    phaserSprite = @context.world.spriteTable[sprite.key]
    @context.world.myText.content = "sprite.x: #{phaserSprite.x.toFixed()}, sprite.y: #{phaserSprite.y.toFixed()}\npos.x: #{position.x.toFixed()}, pos.y: #{position.y.toFixed()}"




$WORLD = {}
$WORLD.spriteTable = {}
$WORLD.spriteOrderingCache = {}
$WORLD.group = null
$WORLD.oldY = 0
$WORLD.controllerHookups = []
$WORLD.touchEnabled = -> Modernizr.touch
$WORLD.myText = null

createThomasSprite = (game) ->
  fr = 7
  playerSprite = game.add.sprite(0, 0, 'cat')
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
  playerSprite

createGroundLayer = (game) ->
  map = game.add.tilemap('desert')
  tileset = game.add.tileset('tiles')
  layer = game.add.tilemapLayer(0, 0, 800, 600, tileset, map, 0)


createTreeSprites = (game, group) ->
  # Make some random trees
  for i in [0...50]
    x = game.math.snapTo(game.world.randomX, 32)
    y = game.math.snapTo(game.world.randomY, 32)
    group.create(x, y, 'trees', game.rnd.integerInRange(0, 8))

createHud = (game) ->
  text = game.add.text(16,16, '', {font: '16px arial', fill: "#000" })
  text

$WORLD.state = Ecs.create.state()
$WORLD.simulation = Ecs.create.simulation($WORLD, $WORLD.state)

for s in [
  ReadSpritePosition

  UpdateMoveControl
  UpdateVelocity
  UpdateAnimationAction

  WriteSpritePosition
  WriteSpriteVelocity
  WriteSpriteAnimation
  SortSprites
  UpdateDebugHud
  ]
  $WORLD.simulation.addSystem s

controllerEventHandler = Ecs.create.eventHandler (state,event) ->
  if controller = Ecs.get.component(state,event.eid,"controller")
    controller[event.action] = event.value

$WORLD.simulation.subscribeEvent "controllerInput", controllerEventHandler

window["$state"] = $WORLD.state # TODO: remove. for debugging only
window["$WORLD"] = $WORLD # TODO: remove. for debugging only
window["$simulation"] = $WORLD.simulation # TODO: remove. for debugging only


preload = ->
  game = $WORLD.game
  game.load.tilemap('desert', 'assets/maps/burd.json', null, Phaser.Tilemap.TILED_JSON)
  game.load.tileset('tiles', 'assets/maps/ground_1x1.png', 32, 32)
  game.load.spritesheet('trees', 'assets/maps/walls_1x2.png', 32, 64)
  game.load.spritesheet('cat', 'assets/cat_frames.png', 150,150)

create = ->
  game = $WORLD.game
  spriteKey = "player1"
  keyboardId = "keybd1"
  joystickId = "joy1"

  $WORLD.player_eid = "e1"
  Ecs.add.components $WORLD.simulation.state, $WORLD.player_eid, Ecs.create.components(
    controller: { up: false, down: false, left: false, right: false }
    groupLayered:  {}
    debugHud:  {}
    moveControl:  x: 0, y: 0
    velocity:  x: 0, y: 0
    position:  x: 0, y: 0
    sprite:    spec: 'thomas', key: '#'
    action:  action: "stand", direction: "down"
    animation:  name: "stand_down"
  )


  if $WORLD.touchEnabled()
    joystickController = JoystickController.create(game.input, "joystickLeft")
    $WORLD.controllerHookups.push [$WORLD.player_eid, joystickController]

  else
    arrowKeysController = KeyboardController.create(game.input.keyboard, {
      up:    { hold: "UP" }
      down:  { hold: "DOWN" }
      left:  { hold: "LEFT" }
      right: { hold: "RIGHT" }
    })
    $WORLD.controllerHookups.push [$WORLD.player_eid, arrowKeysController]

    wasdController = KeyboardController.create(game.input.keyboard, {
      up:    { hold: "W" }
      down:  { hold: "S" }
      left:  { hold: "A" }
      right: { hold: "D" }
    })
    $WORLD.controllerHookups.push [$WORLD.player_eid, wasdController]

  createGroundLayer(game)

  #  This group will hold the main player + all the tree sprites to depth sort against
  $WORLD.group = game.add.group()

  playerSprite = createThomasSprite(game)
  $WORLD.group.add(playerSprite)

  $WORLD.spriteTable[spriteKey] = playerSprite
  $WORLD.spriteOrderingCache[spriteKey] = playerSprite.y

  createTreeSprites(game, $WORLD.group)

  $WORLD.myText = createHud(game)


generateInputEvents = (controllerHookups) ->
  events = []

  for [eid,controller] in controllerHookups
    controlChanges = controller.update()

    controlInputEvents = (
      {
        type: "controllerInput"
        eid: $WORLD.player_eid
        action: k
        value: v
      } for k,v of controlChanges)
      
    events = events.concat controlInputEvents

  return events


update = ->
  inputEvents = generateInputEvents($WORLD.controllerHookups)

  $WORLD.simulation.processEvent(e) for e in inputEvents

  $WORLD.simulation.update()

#
# Instantiate the Phaser game object: GO!
#
$WORLD.game = new Phaser.Game(800, 600, Phaser.CANVAS, 'game-div', { preload: preload, create: create, update: update })
