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
  update: (ctx, controller, moveControl) ->
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
  update: (ctx, sprite, position) ->
    phaserSprite = ctx.world.spriteTable[sprite.key]
    position.x = phaserSprite.x
    position.y = phaserSprite.y

UpdateVelocity = Ecs.create.system
  name: "update-velocity"
  search: [ 'moveControl', 'velocity' ]
  update: (ctx, moveControl, velocity) ->
    velocity.y = moveControl.y * 200
    velocity.x = moveControl.x * 200

UpdateAnimationAction = Ecs.create.system
  name: "update-animation-action"
  search: [ 'action', 'animation','velocity'],
  update: (ctx, action, animation, velocity) ->
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
  update: (ctx, sprite, position) ->
    phaserSprite = ctx.world.spriteTable[sprite.key]
    phaserSprite.x = position.x
    phaserSprite.y = position.y

WriteSpriteVelocity = Ecs.create.system
  name: "write-sprite-velocity"
  search: ['sprite','velocity']
  update: (ctx, sprite, velocity) ->
    phaserSprite = ctx.world.spriteTable[sprite.key]
    phaserSprite.body.velocity.x = velocity.x
    phaserSprite.body.velocity.y = velocity.y

WriteSpriteAnimation = Ecs.create.system
  name: "write-sprite-animation"
  search: ['sprite','animation']
  update: (ctx, sprite, animation) ->
    phaserSprite = ctx.world.spriteTable[sprite.key]
    phaserSprite.animations.play animation.name

SortSprites = Ecs.create.system
  name: "sort-sprites"
  search: ['sprite', 'groupLayered']
  update: (ctx, sprite, groupLayered) ->
    phaserSprite = ctx.world.spriteTable[sprite.key]
    oldY = ctx.world.spriteOrderingCache[sprite.key]
    if phaserSprite.y != ctx.world.oldY
      #  Group.sort() is an expensive operation
      #  You really want to minimise how often it is called as much as possible.
      #  So this little check helps at least, but if you can do it even less than this.
      ctx.world.group.sort()
      ctx.world.spriteOrderingCache[sprite.key] = phaserSprite.y

UpdateDebugHud = Ecs.create.system
  name: "update-debug-hud"
  search: ['debugHud','sprite','position']
  update: (ctx, debugHud, sprite, position) ->
    phaserSprite = ctx.world.spriteTable[sprite.key]
    ctx.world.myText.content = "sprite.x: #{phaserSprite.x.toFixed()}, sprite.y: #{phaserSprite.y.toFixed()}\npos.x: #{position.x.toFixed()}, pos.y: #{position.y.toFixed()}"




$world = {}
$world.spriteTable = {}
$world.spriteOrderingCache = {}
$world.group = null
$world.oldY = 0
$world.controllerHookups = []
$world.touchEnabled = -> Modernizr.touch
$world.myText = null

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

$world.state = Ecs.create.state()
$world.simulation = Ecs.create.simulation($world, $world.state)

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
  $world.simulation.addSystem s

controllerEventHandler = Ecs.create.eventHandler (state,event) ->
  if controller = Ecs.get.component(state,event.eid,"controller")
    controller[event.action] = event.value

$world.simulation.subscribeEvent "controllerInput", controllerEventHandler

window["$state"] = $world.state # TODO: remove. for debugging only
window["$world"] = $world # TODO: remove. for debugging only
window["$simulation"] = $world.simulation # TODO: remove. for debugging only


preload = ->
  game = $world.game
  game.load.tilemap('desert', 'assets/maps/burd.json', null, Phaser.Tilemap.TILED_JSON)
  game.load.tileset('tiles', 'assets/maps/ground_1x1.png', 32, 32)
  game.load.spritesheet('trees', 'assets/maps/walls_1x2.png', 32, 64)
  game.load.spritesheet('cat', 'assets/cat_frames.png', 150,150)

create = ->
  game = $world.game
  spriteKey = "player1"
  keyboardId = "keybd1"
  joystickId = "joy1"

  $world.entity = "e1"
  Ecs.add.components $world.state, $world.entity, Ecs.create.components(
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


  if $world.touchEnabled()
    joystickController = JoystickController.create(game.input, "joystickLeft")
    $world.controllerHookups.push [$world.entity, joystickController]

  else
    arrowKeysController = KeyboardController.create(game.input.keyboard, {
      up:    { hold: "UP" }
      down:  { hold: "DOWN" }
      left:  { hold: "LEFT" }
      right: { hold: "RIGHT" }
    })
    $world.controllerHookups.push [$world.entity, arrowKeysController]

    wasdController = KeyboardController.create(game.input.keyboard, {
      up:    { hold: "W" }
      down:  { hold: "S" }
      left:  { hold: "A" }
      right: { hold: "D" }
    })
    $world.controllerHookups.push [$world.entity, wasdController]

  createGroundLayer(game)

  #  This group will hold the main player + all the tree sprites to depth sort against
  $world.group = game.add.group()

  playerSprite = createPlayerSprite(game, $world.group)
  $world.spriteTable[spriteKey] = playerSprite
  $world.spriteOrderingCache[spriteKey] = playerSprite.y

  createTreeSprites(game, $world.group)

  $world.myText = createHud(game)


generateInputEvents = (controllerHookups) ->
  events = []

  for [eid,controller] in controllerHookups
    controlChanges = controller.update()

    controlInputEvents = (
      {
        type: "controllerInput"
        eid: $world.entity
        action: k
        value: v
      } for k,v of controlChanges)
      
    events = events.concat controlInputEvents

  return events


update = ->
  events = generateInputEvents($world.controllerHookups)

  $world.simulation.processEvent(e) for e in events
  $world.simulation.update()

#
# Instantiate the Phaser game object: GO!
#
$world.game = new Phaser.Game(800, 600, Phaser.CANVAS, 'game-div', { preload: preload, create: create, update: update })
