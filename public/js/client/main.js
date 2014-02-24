(function() {
  var create, createGroundLayer, createHud, createPlayerSprite, createTouchJoystick, createTreeSprites, debug, game, getCursors, getJoystick, local, preload, setCursors, setJoystick, state, touchEnabled, update,
    __slice = [].slice;

  local = {};

  local.spriteTable = {};

  local.spriteOrderingCache = {};

  local.group = null;

  local.oldY = 0;

  local.cursorStore = {};

  local.joystickStore = {};

  local.myText = null;

  debug = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return console.log.apply(console, args);
  };

  touchEnabled = function() {
    return Modernizr.touch;
  };

  setJoystick = function(joystickId, joystick) {
    return local.joystickStore[joystickId] = joystick;
  };

  getJoystick = function(joystickId) {
    return local.joystickStore[joystickId];
  };

  setCursors = function(keyboardId, cursors) {
    return local.cursorStore[keyboardId] = cursors;
  };

  getCursors = function(keyboardId) {
    return local.cursorStore[keyboardId];
  };

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
    text = game.add.text(16, 16, 'uhhh', {
      font: '16px arial',
      fill: "#000"
    });
    return text;
  };

  state = Ecs.create.state();

  window["$S"] = state;

  preload = function() {
    game.load.tilemap('desert', 'assets/maps/burd.json', null, Phaser.Tilemap.TILED_JSON);
    game.load.tileset('tiles', 'assets/maps/ground_1x1.png', 32, 32);
    game.load.spritesheet('trees', 'assets/maps/walls_1x2.png', 32, 64);
    return game.load.spritesheet('cat', 'assets/cat_frames.png', 150, 150);
  };

  create = function() {
    var controllerComponent, eid, joystickId, keyboardId, playerSprite, spriteKey;
    eid = "e1";
    spriteKey = "player1";
    keyboardId = "keybd1";
    joystickId = "joy1";
    Ecs.add.components(state, eid, Ecs.create.components({
      locallyControlled: {},
      physicsPosition: {},
      groupLayered: {},
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
    if (touchEnabled()) {
      setJoystick(joystickId, createTouchJoystick());
      controllerComponent = Ecs.create.component('joystickController', {
        id: joystickId
      });
    } else {
      setCursors(keyboardId, game.input.keyboard.createCursorKeys());
      controllerComponent = Ecs.create.component('keyboardController', {
        id: keyboardId
      });
    }
    Ecs.add.component(state, eid, controllerComponent);
    createGroundLayer(game);
    local.group = game.add.group();
    playerSprite = createPlayerSprite(game, local.group);
    local.spriteTable[spriteKey] = playerSprite;
    local.spriteOrderingCache[spriteKey] = playerSprite.y;
    createTreeSprites(game, local.group);
    return local.myText = createHud(game);
  };

  update = function() {
    Ecs["for"].components(state, ['keyboardController', 'moveControl'], function(keyboardController, moveControl) {
      var c;
      c = getCursors(keyboardController.id);
      if (c.up.isDown) {
        moveControl.y = -1;
      } else if (c.down.isDown) {
        moveControl.y = 1;
      } else {
        moveControl.y = 0;
      }
      if (c.left.isDown) {
        return moveControl.x = -1;
      } else if (c.right.isDown) {
        return moveControl.x = 1;
      } else {
        return moveControl.x = 0;
      }
    });
    Ecs["for"].components(state, ['joystickController', 'moveControl'], function(joystickController, moveControl) {
      var js;
      if (js = getJoystick(joystickController.id)) {
        moveControl.x = js.normalizedX;
        return moveControl.y = js.normalizedY;
      }
    });
    Ecs["for"].components(state, ['moveControl', 'velocity'], function(moveControl, velocity) {
      velocity.y = moveControl.y * 200;
      return velocity.x = moveControl.x * 200;
    });
    Ecs["for"].components(state, ['action', 'animation', 'velocity'], function(action, animation, velocity) {
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
    Ecs["for"].components(state, ['sprite', 'velocity'], function(sprite, velocity) {
      var phaserSprite;
      phaserSprite = local.spriteTable[sprite.key];
      phaserSprite.body.velocity.x = velocity.x;
      return phaserSprite.body.velocity.y = velocity.y;
    });
    Ecs["for"].components(state, ['sprite', 'animation'], function(sprite, animation) {
      var phaserSprite;
      phaserSprite = local.spriteTable[sprite.key];
      return phaserSprite.animations.play(animation.name);
    });
    return Ecs["for"].components(state, ['sprite', 'groupLayered'], function(sprite, groupLayered) {
      var oldY, phaserSprite;
      phaserSprite = local.spriteTable[sprite.key];
      oldY = local.spriteOrderingCache[sprite.key];
      if (phaserSprite.y !== local.oldY) {
        local.group.sort();
        return local.spriteOrderingCache[sprite.key] = phaserSprite.y;
      }
    });
  };

  game = new Phaser.Game(800, 600, Phaser.CANVAS, 'game-div', {
    preload: preload,
    create: create,
    update: update
  });

}).call(this);
