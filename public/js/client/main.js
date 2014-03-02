(function() {
  var KeyboardController, Simulation, create, createGroundLayer, createHud, createPlayerSprite, createTouchJoystick, createTreeSprites, debug, game, generateInputEvents, local, preload, simulation, state, update,
    __slice = [].slice;

  debug = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return console.log.apply(console, args);
  };

  KeyboardController = (function() {
    function KeyboardController(keyboard, mappings) {
      this.keyboard = keyboard;
      this.mappings = mappings;
      this.current = {};
      this.previous = {};
      this._addKeyCaptures();
      this.update();
    }

    KeyboardController.prototype.update = function() {
      var conf, diff, sym, _ref;
      this.current = {};
      diff = {};
      _ref = this.mappings;
      for (sym in _ref) {
        conf = _ref[sym];
        this._updateSym(this.keyboard, this.current, this.previous, diff, sym, conf);
      }
      this.previous = this.current;
      return diff;
    };

    KeyboardController.prototype._updateSym = function(keyboard, current, previous, diff, sym, conf) {
      var code, val;
      if (conf.hold) {
        code = Phaser.Keyboard[conf.hold];
        val = keyboard.isDown(code);
        current[sym] = val;
        if (val !== previous[sym]) {
          return diff[sym] = val;
        }
      }
    };

    KeyboardController.prototype._addKeyCaptures = function() {
      var code, conf, sym, _ref, _results;
      _ref = this.mappings;
      _results = [];
      for (sym in _ref) {
        conf = _ref[sym];
        if (conf.hold) {
          code = Phaser.Keyboard[conf.hold];
          if (typeof code !== 'undefined') {
            _results.push(this.keyboard.addKeyCapture(code));
          } else {
            _results.push(void 0);
          }
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    return KeyboardController;

  })();

  Simulation = (function() {
    function Simulation(state) {
      this.state = state;
    }

    Simulation.prototype.processEvent = function(event) {
      var controller;
      window['$events'] || (window['$events'] = []);
      window['$events'].push(event);
      if (event.type === "controllerInput") {
        if (controller = Ecs.get.component(state, event.eid, "controller")) {
          return controller[event.action] = event.value;
        }
      }
    };

    Simulation.prototype.update = function(world) {
      Ecs["for"].components(this.state, ['controller', 'moveControl'], function(controller, moveControl) {
        if (controller.up) {
          moveControl.y = -1;
        } else if (controller.down) {
          moveControl.y = 1;
        } else {
          moveControl.y = 0;
        }
        if (controller.left) {
          return moveControl.x = -1;
        } else if (controller.right) {
          return moveControl.x = 1;
        } else {
          return moveControl.x = 0;
        }
      });
      Ecs["for"].components(this.state, ['sprite', 'position'], function(sprite, position) {
        var phaserSprite;
        phaserSprite = world.spriteTable[sprite.key];
        position.x = phaserSprite.x;
        return position.y = phaserSprite.y;
      });
      Ecs["for"].components(this.state, ['moveControl', 'velocity'], function(moveControl, velocity) {
        velocity.y = moveControl.y * 200;
        return velocity.x = moveControl.x * 200;
      });
      Ecs["for"].components(this.state, ['action', 'animation', 'velocity'], function(action, animation, velocity) {
        var move;
        move = 'idle';
        if (velocity.y < 0) {
          move = 'up';
        }
        if (velocity.y > 0) {
          move = 'down';
        }
        if (Math.abs(velocity.x) >= Math.abs(velocity.y)) {
          if (velocity.x > 0) {
            move = 'right';
          }
          if (velocity.x < 0) {
            move = 'left';
          }
        }
        if (move === 'idle') {
          action.action = "stand";
        } else {
          action.action = "walk";
          action.direction = move;
        }
        return animation.name = "" + action.action + "_" + action.direction;
      });
      Ecs["for"].components(this.state, ['sprite', 'position'], function(sprite, position) {
        var phaserSprite;
        phaserSprite = world.spriteTable[sprite.key];
        phaserSprite.x = position.x;
        return phaserSprite.y = position.y;
      });
      Ecs["for"].components(this.state, ['sprite', 'velocity'], function(sprite, velocity) {
        var phaserSprite;
        phaserSprite = world.spriteTable[sprite.key];
        phaserSprite.body.velocity.x = velocity.x;
        return phaserSprite.body.velocity.y = velocity.y;
      });
      Ecs["for"].components(this.state, ['sprite', 'animation'], function(sprite, animation) {
        var phaserSprite;
        phaserSprite = world.spriteTable[sprite.key];
        return phaserSprite.animations.play(animation.name);
      });
      Ecs["for"].components(this.state, ['sprite', 'groupLayered'], function(sprite, groupLayered) {
        var oldY, phaserSprite;
        phaserSprite = world.spriteTable[sprite.key];
        oldY = world.spriteOrderingCache[sprite.key];
        if (phaserSprite.y !== local.oldY) {
          world.group.sort();
          return world.spriteOrderingCache[sprite.key] = phaserSprite.y;
        }
      });
      return Ecs["for"].components(this.state, ['debugHud', 'sprite', 'position'], function(debugHud, sprite, position) {
        var phaserSprite;
        phaserSprite = world.spriteTable[sprite.key];
        return local.myText.content = "sprite.x: " + (phaserSprite.x.toFixed()) + ", sprite.y: " + (phaserSprite.y.toFixed()) + "\npos.x: " + (position.x.toFixed()) + ", pos.y: " + (position.y.toFixed());
      });
    };

    return Simulation;

  })();

  local = {};

  local.spriteTable = {};

  local.spriteOrderingCache = {};

  local.group = null;

  local.oldY = 0;

  local.controllerHookups = [];

  local.touchEnabled = function() {
    return Modernizr.touch;
  };

  local.myText = null;

  createPlayerSprite = function(game, group) {
    var fr, playerSprite;
    fr = 7;
    playerSprite = group.create(0, 0, 'cat');
    playerSprite.animations.add('stand_down', [0], fr, true);
    playerSprite.animations.add('walk_down', [1, 2], fr, true);
    playerSprite.animations.add('stand_up', [3], fr, true);
    playerSprite.animations.add('walk_up', [4, 5], fr, true);
    playerSprite.animations.add('stand_right', [6], fr, true);
    playerSprite.animations.add('walk_right', [7, 8], fr, true);
    playerSprite.animations.add('stand_left', [9], fr, true);
    playerSprite.animations.add('walk_left', [10, 11], fr, true);
    playerSprite.animations.play('stand_up');
    playerSprite.scale.x = 0.5;
    playerSprite.scale.y = 0.5;
    return playerSprite;
  };

  createGroundLayer = function(game) {
    var layer, map, tileset;
    map = game.add.tilemap('desert');
    tileset = game.add.tileset('tiles');
    return layer = game.add.tilemapLayer(0, 0, 800, 600, tileset, map, 0);
  };

  createTouchJoystick = function(game) {
    GameController.init({
      left: {
        type: 'joystick',
        joystick: {
          touchStart: (function() {}),
          touchMove: function(joystick_details) {
            return game.input.joystickLeft = joystick_details;
          },
          touchEnd: function() {
            return game.input.joystickLeft = null;
          }
        },
        right: {
          type: 'none'
        }
      }
    });
    $('canvas').last().css('z-index', 20);
    return $('canvas').last().offset($('canvas').first().offset());
  };

  createTreeSprites = function(game, group) {
    var i, x, y, _i, _results;
    _results = [];
    for (i = _i = 0; _i < 50; i = ++_i) {
      x = game.math.snapTo(game.world.randomX, 32);
      y = game.math.snapTo(game.world.randomY, 32);
      _results.push(group.create(x, y, 'trees', game.rnd.integerInRange(0, 8)));
    }
    return _results;
  };

  createHud = function(game) {
    var text;
    text = game.add.text(16, 16, '', {
      font: '16px arial',
      fill: "#000"
    });
    return text;
  };

  state = Ecs.create.state();

  simulation = new Simulation(state);

  window["$state"] = state;

  window["$world"] = local;

  window["$simulation"] = simulation;

  preload = function() {
    game.load.tilemap('desert', 'assets/maps/burd.json', null, Phaser.Tilemap.TILED_JSON);
    game.load.tileset('tiles', 'assets/maps/ground_1x1.png', 32, 32);
    game.load.spritesheet('trees', 'assets/maps/walls_1x2.png', 32, 64);
    return game.load.spritesheet('cat', 'assets/cat_frames.png', 150, 150);
  };

  create = function() {
    var arrowKeysController, joystickId, keyboardId, playerSprite, spriteKey, wasdController;
    spriteKey = "player1";
    keyboardId = "keybd1";
    joystickId = "joy1";
    local.entity = "e1";
    Ecs.add.components(state, local.entity, Ecs.create.components({
      controller: {
        up: false,
        down: false,
        left: false,
        right: false
      },
      groupLayered: {},
      debugHud: {},
      moveControl: {
        x: 0,
        y: 0
      },
      velocity: {
        x: 0,
        y: 0
      },
      position: {
        x: 0,
        y: 0
      },
      sprite: {
        key: spriteKey
      },
      action: {
        action: "stand",
        direction: "down"
      },
      animation: {
        name: "stand_down"
      }
    }));
    if (local.touchEnabled()) {

    } else {
      arrowKeysController = new KeyboardController(game.input.keyboard, {
        up: {
          hold: "UP"
        },
        down: {
          hold: "DOWN"
        },
        left: {
          hold: "LEFT"
        },
        right: {
          hold: "RIGHT"
        }
      });
      wasdController = new KeyboardController(game.input.keyboard, {
        up: {
          hold: "W"
        },
        down: {
          hold: "S"
        },
        left: {
          hold: "A"
        },
        right: {
          hold: "D"
        }
      });
      local.controllerHookups.push([local.entity, arrowKeysController]);
      local.controllerHookups.push([local.entity, wasdController]);
    }
    createGroundLayer(game);
    local.group = game.add.group();
    playerSprite = createPlayerSprite(game, local.group);
    local.spriteTable[spriteKey] = playerSprite;
    local.spriteOrderingCache[spriteKey] = playerSprite.y;
    createTreeSprites(game, local.group);
    return local.myText = createHud(game);
  };

  generateInputEvents = function(controllerHookups) {
    var controlChanges, controlInputEvents, controller, eid, events, k, v, _i, _len, _ref;
    events = [];
    for (_i = 0, _len = controllerHookups.length; _i < _len; _i++) {
      _ref = controllerHookups[_i], eid = _ref[0], controller = _ref[1];
      controlChanges = controller.update();
      controlInputEvents = (function() {
        var _results;
        _results = [];
        for (k in controlChanges) {
          v = controlChanges[k];
          _results.push({
            type: "controllerInput",
            eid: local.entity,
            action: k,
            value: v
          });
        }
        return _results;
      })();
      events = events.concat(controlInputEvents);
    }
    return events;
  };

  update = function() {
    var e, events, _i, _len;
    events = generateInputEvents(local.controllerHookups);
    for (_i = 0, _len = events.length; _i < _len; _i++) {
      e = events[_i];
      simulation.processEvent(e);
    }
    return simulation.update(local);
  };

  game = new Phaser.Game(800, 600, Phaser.CANVAS, 'game-div', {
    preload: preload,
    create: create,
    update: update
  });

}).call(this);
