
class JoystickController
  constructor: (@input,@joystickName) ->
    @current = {}
    @previous = {}
    @thresh = 0.1
    initTouchJoystick(@input,@joystickName)

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

###############################################

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

###################################################

ex = {}
ex.create = (input,jname) -> new JoystickController(input,jname)

Exporter.export("JoystickController", ex)
