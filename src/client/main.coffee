touchEnabled = -> Modernizr.touch

preload = ->
  game.load.tilemap('desert', 'assets/maps/burd.json', null, Phaser.Tilemap.TILED_JSON)
  game.load.tileset('tiles', 'assets/maps/ground_1x1.png', 32, 32)
  game.load.spritesheet('trees', 'assets/maps/walls_1x2.png', 32, 64)
  game.load.spritesheet('cat', 'assets/cat_frames.png', 150,150)

spriteTable = {}

group = null
oldY = 0
cursors = null

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
  #  Some trees
  for i in [0...50]
    x = game.math.snapTo(game.world.randomX, 32)
    y = game.math.snapTo(game.world.randomY, 32)
    group.create(x, y, 'trees', game.rnd.integerInRange(0, 8))

createHud = (game) ->
  text = game.add.text(16,16, 'uhhh', {font: '16px arial', fill: "#000" })
  text


state = Ecs.create.state()

create = ->

  eid = "e1"
  spriteKey = "player1"
  for comp in [
    Ecs.create.component 'locallyControlled', {}
    Ecs.create.component 'physicsPosition', {}
    Ecs.create.component 'moveControl', up: false, down: false, left: false, right: false
    Ecs.create.component 'velocity', x: 0, y: 0
    Ecs.create.component 'position', x: 0, y: 0
    Ecs.create.component 'sprite',   key: spriteKey
    Ecs.create.component 'action', action: "stand", direction: "down"
    Ecs.create.component 'animation', name: "stand_down"

  ]
    Ecs.addComponent(state, eid, comp)

  

  createGroundLayer(game)

  #  This group will hold the main player + all the tree sprites to depth sort against
  group = game.add.group()

  spriteTable[spriteKey] = createPlayerSprite(game, group)


  createTreeSprites(game, group)

  myText = createHud(game)

  cursors = game.input.keyboard.createCursorKeys()

  if touchEnabled()
    createTouchJoystick()
   

update = ->

  Ecs.for.components state, ['locallyControlled','moveControl'], (x, moveControl) ->
    c = cursors # TODO... is this an "input" system?
    moveControl.up = c.up.isDown
    moveControl.down = c.down.isDown
    moveControl.left = c.left.isDown
    moveControl.right = c.right.isDown
# 
#     TODO!!!
#     if game.input.joystickLeft
#       # Move the ufo using the joystick's normalizedX and Y values,
#       # which range from -1 to 1.
#       vx = game.input.joystickLeft.normalizedX * 200
#       vy = game.input.joystickLeft.normalizedY * -200

  Ecs.for.components state, ['moveControl','velocity'], (moveControl,velocity) ->
    if moveControl.up
      velocity.y = -200
    else if moveControl.down
      velocity.y = 200
    else
      velocity.y = 0

    if moveControl.left
      velocity.x = -200
    else if moveControl.right
      velocity.x = 200
    else
      velocity.x = 0

  Ecs.for.components state, ['action', 'animation','velocity'], (action, animation, velocity) ->
    move = 'idle'
    if velocity.y < 0 then move = 'up'
    if velocity.y > 0 then move = 'down'
    if Math.abs(velocity.x) > Math.abs(velocity.y)
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

  
# TODO: System?
  playerSprite = spriteTable["player1"]
  if playerSprite.y != oldY
    #  Group.sort() is an expensive operation
    #  You really want to minimise how often it is called as much as possible.
    #  So this little check helps at least, but if you can do it even less than this.
    group.sort()
    oldY = playerSprite.y


game = new Phaser.Game(800, 600, Phaser.CANVAS, 'game-div', { preload: preload, create: create, update: update })
