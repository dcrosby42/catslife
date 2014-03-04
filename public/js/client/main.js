(function() {
  var $world, ReadSpritePosition, SortSprites, UpdateAnimationAction, UpdateDebugHud, UpdateMoveControl, UpdateVelocity, WriteSpriteAnimation, WriteSpritePosition, WriteSpriteVelocity, controllerEventHandler, create, createGroundLayer, createHud, createPlayerSprite, createTreeSprites, debug, generateInputEvents, preload, s, update, _i, _len, _ref,
    __slice = [].slice;

  debug = function() {
    var s;
    s = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return console.log.apply(console, s);
  };

  UpdateMoveControl = Ecs.create.system({
    name: "update-move-control",
    search: ['controller', 'moveControl'],
    update: function(ctx, controller, moveControl) {
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
    }
  });

  ReadSpritePosition = Ecs.create.system({
    name: "read-sprite-position",
    search: ['sprite', 'position'],
    update: function(ctx, sprite, position) {
      var phaserSprite;
      phaserSprite = ctx.world.spriteTable[sprite.key];
      position.x = phaserSprite.x;
      return position.y = phaserSprite.y;
    }
  });

  UpdateVelocity = Ecs.create.system({
    name: "update-velocity",
    search: ['moveControl', 'velocity'],
    update: function(ctx, moveControl, velocity) {
      velocity.y = moveControl.y * 200;
      return velocity.x = moveControl.x * 200;
    }
  });

  UpdateAnimationAction = Ecs.create.system({
    name: "update-animation-action",
    search: ['action', 'animation', 'velocity'],
    update: function(ctx, action, animation, velocity) {
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
    }
  });

  WriteSpritePosition = Ecs.create.system({
    name: "write-sprite-position",
    search: ['sprite', 'position'],
    update: function(ctx, sprite, position) {
      var phaserSprite;
      phaserSprite = ctx.world.spriteTable[sprite.key];
      phaserSprite.x = position.x;
      return phaserSprite.y = position.y;
    }
  });

  WriteSpriteVelocity = Ecs.create.system({
    name: "write-sprite-velocity",
    search: ['sprite', 'velocity'],
    update: function(ctx, sprite, velocity) {
      var phaserSprite;
      phaserSprite = ctx.world.spriteTable[sprite.key];
      phaserSprite.body.velocity.x = velocity.x;
      return phaserSprite.body.velocity.y = velocity.y;
    }
  });

  WriteSpriteAnimation = Ecs.create.system({
    name: "write-sprite-animation",
    search: ['sprite', 'animation'],
    update: function(ctx, sprite, animation) {
      var phaserSprite;
      phaserSprite = ctx.world.spriteTable[sprite.key];
      return phaserSprite.animations.play(animation.name);
    }
  });

  SortSprites = Ecs.create.system({
    name: "sort-sprites",
    search: ['sprite', 'groupLayered'],
    update: function(ctx, sprite, groupLayered) {
      var oldY, phaserSprite;
      phaserSprite = ctx.world.spriteTable[sprite.key];
      oldY = ctx.world.spriteOrderingCache[sprite.key];
      if (phaserSprite.y !== ctx.world.oldY) {
        ctx.world.group.sort();
        return ctx.world.spriteOrderingCache[sprite.key] = phaserSprite.y;
      }
    }
  });

  UpdateDebugHud = Ecs.create.system({
    name: "update-debug-hud",
    search: ['debugHud', 'sprite', 'position'],
    update: function(ctx, debugHud, sprite, position) {
      var phaserSprite;
      phaserSprite = ctx.world.spriteTable[sprite.key];
      return ctx.world.myText.content = "sprite.x: " + (phaserSprite.x.toFixed()) + ", sprite.y: " + (phaserSprite.y.toFixed()) + "\npos.x: " + (position.x.toFixed()) + ", pos.y: " + (position.y.toFixed());
    }
  });

  $world = {};

  $world.spriteTable = {};

  $world.spriteOrderingCache = {};

  $world.group = null;

  $world.oldY = 0;

  $world.controllerHookups = [];

  $world.touchEnabled = function() {
    return Modernizr.touch;
  };

  $world.myText = null;

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

  $world.state = Ecs.create.state();

  $world.simulation = Ecs.create.simulation($world, $world.state);

  _ref = [ReadSpritePosition, UpdateMoveControl, UpdateVelocity, UpdateAnimationAction, WriteSpritePosition, WriteSpriteVelocity, WriteSpriteAnimation, SortSprites, UpdateDebugHud];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    s = _ref[_i];
    $world.simulation.addSystem(s);
  }

  controllerEventHandler = Ecs.create.eventHandler(function(state, event) {
    var controller;
    if (controller = Ecs.get.component(state, event.eid, "controller")) {
      return controller[event.action] = event.value;
    }
  });

  $world.simulation.subscribeEvent("controllerInput", controllerEventHandler);

  window["$state"] = $world.state;

  window["$world"] = $world;

  window["$simulation"] = $world.simulation;

  preload = function() {
    var game;
    game = $world.game;
    game.load.tilemap('desert', 'assets/maps/burd.json', null, Phaser.Tilemap.TILED_JSON);
    game.load.tileset('tiles', 'assets/maps/ground_1x1.png', 32, 32);
    game.load.spritesheet('trees', 'assets/maps/walls_1x2.png', 32, 64);
    return game.load.spritesheet('cat', 'assets/cat_frames.png', 150, 150);
  };

  create = function() {
    var arrowKeysController, game, joystickController, joystickId, keyboardId, playerSprite, spriteKey, wasdController;
    game = $world.game;
    spriteKey = "player1";
    keyboardId = "keybd1";
    joystickId = "joy1";
    $world.entity = "e1";
    Ecs.add.components($world.state, $world.entity, Ecs.create.components({
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
    if ($world.touchEnabled()) {
      joystickController = JoystickController.create(game.input, "joystickLeft");
      $world.controllerHookups.push([$world.entity, joystickController]);
    } else {
      arrowKeysController = KeyboardController.create(game.input.keyboard, {
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
      $world.controllerHookups.push([$world.entity, arrowKeysController]);
      wasdController = KeyboardController.create(game.input.keyboard, {
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
      $world.controllerHookups.push([$world.entity, wasdController]);
    }
    createGroundLayer(game);
    $world.group = game.add.group();
    playerSprite = createPlayerSprite(game, $world.group);
    $world.spriteTable[spriteKey] = playerSprite;
    $world.spriteOrderingCache[spriteKey] = playerSprite.y;
    createTreeSprites(game, $world.group);
    return $world.myText = createHud(game);
  };

  generateInputEvents = function(controllerHookups) {
    var controlChanges, controlInputEvents, controller, eid, events, k, v, _j, _len1, _ref1;
    events = [];
    for (_j = 0, _len1 = controllerHookups.length; _j < _len1; _j++) {
      _ref1 = controllerHookups[_j], eid = _ref1[0], controller = _ref1[1];
      controlChanges = controller.update();
      controlInputEvents = (function() {
        var _results;
        _results = [];
        for (k in controlChanges) {
          v = controlChanges[k];
          _results.push({
            type: "controllerInput",
            eid: $world.entity,
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
    var e, events, _j, _len1;
    events = generateInputEvents($world.controllerHookups);
    for (_j = 0, _len1 = events.length; _j < _len1; _j++) {
      e = events[_j];
      $world.simulation.processEvent(e);
    }
    return $world.simulation.update();
  };

  $world.game = new Phaser.Game(800, 600, Phaser.CANVAS, 'game-div', {
    preload: preload,
    create: create,
    update: update
  });

}).call(this);
