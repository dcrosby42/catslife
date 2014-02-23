touchEnabled = -> Modernizr.touch

debug = (str) ->
  console.log(str)

preload = ->
  game.load.tilemap('desert', 'assets/maps/burd.json', null, Phaser.Tilemap.TILED_JSON)
  game.load.tileset('tiles', 'assets/maps/ground_1x1.png', 32, 32)
  game.load.spritesheet('trees', 'assets/maps/walls_1x2.png', 32, 64)
  game.load.spritesheet('cat', 'assets/cat_frames.png', 150,150)

spriteTable = {}

group = null
oldY = 0

cursorStore = {}
getCursors = (keyboardId) -> cursorStore[keyboardId]

joystickStore = {}
getJoystick = (joystickId) -> joystickStore[joystickId]

myText = null

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

createTouchJoystick = (game) ->
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
          game.input.joystickLeft = joystick_details
        
        touchEnd: ->
          game.input.joystickLeft = null
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
  text = game.add.text(16,16, 'uhhh', {font: '16px arial', fill: "#000" })
  text

state = Ecs.create.state()
window["$S"] = state # TODO: remove. for debugging only

create = ->
  eid = "e1"
  spriteKey = "player1"
  keyboardId = "keybd1"
  joystickId = "joy1"

  for type,data of {
    locallyControlled:  {}
    physicsPosition:  {}
    moveControl:  x: 0, y: 0
    velocity:  x: 0, y: 0
    position:  x: 0, y: 0
    sprite:    key: spriteKey
    action:  action: "stand", direction: "down"
    animation:  name: "stand_down"
  }
    Ecs.addComponent state, eid, Ecs.create.component(type,data)

  if touchEnabled()
    joystickStore[joystickId] = createTouchJoystick()
    controllerComponent = Ecs.create.component 'joystickController', {id: joystickId}
  else
    controllerComponent = Ecs.create.component 'keyboardController', {id: keyboardId}
  Ecs.addComponent state, eid, controllerComponent

  createGroundLayer(game)

  #  This group will hold the main player + all the tree sprites to depth sort against
  group = game.add.group()

  spriteTable[spriteKey] = createPlayerSprite(game, group)

  createTreeSprites(game, group)

  cursorStore[keyboardId] = game.input.keyboard.createCursorKeys()

  myText = createHud(game)

update = ->
  Ecs.for.components state, ['keyboardController','moveControl'], (keyboardController, moveControl) ->
    # TODO... is this an "input" system?
    c = getCursors(keyboardController.id)
    if c.up.isDown
      moveControl.y = -1
    else if c.down.isDown
      moveControl.y = 1
    else
      moveControl.y = 0

    if c.left.isDown
      moveControl.x = -1
    else if c.right.isDown
      moveControl.x = 1
    else
      moveControl.x = 0

  Ecs.for.components state, ['joystickController','moveControl'], (joystickController, moveControl) ->
    if js = getJoystick(joystickController.id)
      moveControl.x = js.normalizedX
      moveControl.y = js.normalizedY

  Ecs.for.components state, ['moveControl','velocity'], (moveControl,velocity) ->
    velocity.y = moveControl.y * 200
    velocity.x = moveControl.x * 200

  Ecs.for.components state, ['action', 'animation','velocity'], (action, animation, velocity) ->
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


  Ecs.for.components state, ['sprite','velocity'], (sprite, velocity) ->
    phaserSprite = spriteTable[sprite.key]  # TODO: This is an "output" system!
    phaserSprite.body.velocity.x = velocity.x
    phaserSprite.body.velocity.y = velocity.y

  Ecs.for.components state, ['animation','sprite'], (animation, sprite) ->
    phaserSprite = spriteTable[sprite.key]  # TODO: This is an "output" system!
    phaserSprite.animations.play animation.name

  
# TODO: some kind of output System?
  playerSprite = spriteTable["player1"]
  if playerSprite.y != oldY
    #  Group.sort() is an expensive operation
    #  You really want to minimise how often it is called as much as possible.
    #  So this little check helps at least, but if you can do it even less than this.
    group.sort()
    oldY = playerSprite.y


game = new Phaser.Game(800, 600, Phaser.CANVAS, 'game-div', { preload: preload, create: create, update: update })
