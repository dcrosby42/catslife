(function() {
  var create, createGroundLayer, createHud, createPlayerSprite, createTouchJoystick, createTreeSprites, cursors, game, group, myText, oldY, preload, spriteTable, state, touchEnabled, update;

  touchEnabled = function() {
    return Modernizr.touch;
  };

  preload = function() {
    game.load.tilemap('desert', 'assets/maps/burd.json', null, Phaser.Tilemap.TILED_JSON);
    game.load.tileset('tiles', 'assets/maps/ground_1x1.png', 32, 32);
    game.load.spritesheet('trees', 'assets/maps/walls_1x2.png', 32, 64);
    return game.load.spritesheet('cat', 'assets/cat_frames.png', 150, 150);
  };

  spriteTable = {};

  group = null;

  oldY = 0;

  cursors = null;

  myText = null;

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

  create = function() {
    var comp, eid, spriteKey, _i, _len, _ref;
    eid = "e1";
    spriteKey = "player1";
    _ref = [
      Ecs.create.component('locallyControlled', {}), Ecs.create.component('physicsPosition', {}), Ecs.create.component('moveControl', {
        up: false,
        down: false,
        left: false,
        right: false
      }), Ecs.create.component('velocity', {
        x: 0,
        y: 0
      }), Ecs.create.component('position', {
        x: 0,
        y: 0
      }), Ecs.create.component('sprite', {
        key: spriteKey
      }), Ecs.create.component('action', {
        action: "stand",
        direction: "down"
      }), Ecs.create.component('animation', {
        name: "stand_down"
      })
    ];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      comp = _ref[_i];
      Ecs.addComponent(state, eid, comp);
    }
    createGroundLayer(game);
    group = game.add.group();
    spriteTable[spriteKey] = createPlayerSprite(game, group);
    createTreeSprites(game, group);
    myText = createHud(game);
    cursors = game.input.keyboard.createCursorKeys();
    if (touchEnabled()) {
      return createTouchJoystick();
    }
  };

  update = function() {
    var playerSprite;
    Ecs["for"].components(state, ['locallyControlled', 'moveControl'], function(x, moveControl) {
      var c;
      c = cursors;
      moveControl.up = c.up.isDown;
      moveControl.down = c.down.isDown;
      moveControl.left = c.left.isDown;
      return moveControl.right = c.right.isDown;
    });
    Ecs["for"].components(state, ['moveControl', 'velocity'], function(moveControl, velocity) {
      if (moveControl.up) {
        velocity.y = -200;
      } else if (moveControl.down) {
        velocity.y = 200;
      } else {
        velocity.y = 0;
      }
      if (moveControl.left) {
        return velocity.x = -200;
      } else if (moveControl.right) {
        return velocity.x = 200;
      } else {
        return velocity.x = 0;
      }
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
      if (Math.abs(velocity.x) > Math.abs(velocity.y)) {
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
      phaserSprite = spriteTable[sprite.key];
      phaserSprite.body.velocity.x = velocity.x;
      return phaserSprite.body.velocity.y = velocity.y;
    });
    Ecs["for"].components(state, ['animation', 'sprite'], function(animation, sprite) {
      var phaserSprite;
      phaserSprite = spriteTable[sprite.key];
      return phaserSprite.animations.play(animation.name);
    });
    playerSprite = spriteTable["player1"];
    if (playerSprite.y !== oldY) {
      group.sort();
      return oldY = playerSprite.y;
    }
  };

  game = new Phaser.Game(800, 600, Phaser.CANVAS, 'game-div', {
    preload: preload,
    create: create,
    update: update
  });

}).call(this);
