
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
        diff[sym] = val

  _addKeyCaptures: ->
    for sym,conf of @mappings
      if conf.hold
        code = Phaser.Keyboard[conf.hold]
        if typeof code != 'undefined'
          @keyboard.addKeyCapture(code)

ex = {}
ex.create = (keyboard,mappings) -> new KeyboardController(keyboard,mappings)

Exporter.export('KeyboardController', ex)
