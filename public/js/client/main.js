(function() {
  var create, cursors, dir, game, group, layer, map, myText, oldY, preload, sprite, tileset, update;

  preload = function() {
    game.load.tilemap('desert', 'assets/maps/burd.json', null, Phaser.Tilemap.TILED_JSON);
    game.load.tileset('tiles', 'assets/maps/ground_1x1.png', 32, 32);
    game.load.spritesheet('trees', 'assets/maps/walls_1x2.png', 32, 64);
    return game.load.spritesheet('cat', 'assets/cat_frames.png', 150, 150);
  };

  map = null;

  tileset = null;

  layer = null;

  sprite = null;

  group = null;

  oldY = 0;

  cursors = null;

  myText = null;

  create = function() {
    var fr, i, x, y, _i;
    map = game.add.tilemap('desert');
    tileset = game.add.tileset('tiles');
    layer = game.add.tilemapLayer(0, 0, 800, 600, tileset, map, 0);
    group = game.add.group();
    fr = 7;
    sprite = group.create(300, 200, 'cat');
    sprite.animations.add('stand_down', [0], fr, true);
    sprite.animations.add('walk_down', [1, 2], fr, true);
    sprite.animations.add('stand_up', [3], fr, true);
    sprite.animations.add('walk_up', [4, 5], fr, true);
    sprite.animations.add('stand_right', [6], fr, true);
    sprite.animations.add('walk_right', [7, 8], fr, true);
    sprite.animations.add('stand_left', [9], fr, true);
    sprite.animations.add('walk_left', [10, 11], fr, true);
    sprite.animations.play('stand_up');
    sprite.scale.x = 0.5;
    sprite.scale.y = 0.5;
    myText = game.add.text(16, 16, 'uhhh', {
      font: '16px arial',
      fill: "#000"
    });
    for (i = _i = 0; _i < 50; i = ++_i) {
      x = game.math.snapTo(game.world.randomX, 32);
      y = game.math.snapTo(game.world.randomY, 32);
      group.create(x, y, 'trees', game.rnd.integerInRange(0, 8));
    }
    cursors = game.input.keyboard.createCursorKeys();
    if (Modernizr.touch) {
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
    }
  };

  dir = 'down';

  update = function() {
    var move, vx, vy;
    sprite.body.velocity.x = 0;
    sprite.body.velocity.y = 0;
    vx = 0;
    vy = 0;
    if (cursors.up.isDown) {
      vy = -200;
    } else if (cursors.down.isDown) {
      vy = 200;
    }
    if (cursors.left.isDown) {
      vx = -200;
    } else if (cursors.right.isDown) {
      vx = 200;
    }
    if (game.input.joystickLeft) {
      vx = game.input.joystickLeft.normalizedX * 200;
      vy = game.input.joystickLeft.normalizedY * -200;
      myText.content = "(" + vx + "," + vy + ")";
    }
    sprite.body.velocity.y = vy;
    sprite.body.velocity.x = vx;
    move = 'idle';
    if (vy < 0) {
      move = 'up';
    }
    if (vy > 0) {
      move = 'down';
    }
    if (Math.abs(vx) > Math.abs(vy)) {
      if (vx > 0) {
        move = 'right';
      }
      if (vx < 0) {
        move = 'left';
      }
    }
    if (move === 'idle') {
      sprite.animations.play("stand_" + dir);
    } else {
      dir = move;
      sprite.animations.play('walk_' + dir);
    }
    if (sprite.y !== oldY) {
      group.sort();
      return oldY = sprite.y;
    }
  };

  game = new Phaser.Game(800, 600, Phaser.CANVAS, 'game-div', {
    preload: preload,
    create: create,
    update: update
  });

}).call(this);
