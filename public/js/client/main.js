


var game = new Phaser.Game(800, 600, Phaser.CANVAS, 'game-div', { preload: preload, create: create, update: update });

function preload() {
    game.load.tilemap('desert', 'assets/maps/burd.json', null, Phaser.Tilemap.TILED_JSON);
    game.load.tileset('tiles', 'assets/maps/ground_1x1.png', 32, 32);
    game.load.spritesheet('trees', 'assets/maps/walls_1x2.png', 32, 64);
    game.load.spritesheet('cat', 'assets/cat_frames.png', 150,150);
}

var map;
var tileset;
var layer;

var sprite;
var group;
var oldY = 0;
var cursors;

var myText;

function create() {

    //  Create our tilemap to walk around
    map = game.add.tilemap('desert');
    tileset = game.add.tileset('tiles');
    layer = game.add.tilemapLayer(0, 0, 800, 600, tileset, map, 0);

    //  This group will hold the main player + all the tree sprites to depth sort against
    group = game.add.group();

    //  The player:
    var fr=7;
    sprite = group.create(300, 200, 'cat');
    sprite.animations.add('stand_down', [0], fr, true);
    sprite.animations.add('walk_down', [1,2], fr, true);
    sprite.animations.add('stand_up', [3], fr, true);
    sprite.animations.add('walk_up', [4,5], fr, true);
    sprite.animations.add('stand_right', [6], fr, true);
    sprite.animations.add('walk_right', [7,8], fr, true);
    sprite.animations.add('stand_left', [9], fr, true);
    sprite.animations.add('walk_left', [10,11], fr, true);
    sprite.animations.play('stand_up');
    sprite.scale.x = 0.5;
    sprite.scale.y = 0.5;

    myText = game.add.text(16,16, 'uhhh', {font: '16px arial', fill: "#000" });
    // myText.visible = false;

    //  Some trees
    for (var i = 0; i < 50; i++)
    {
        var x = game.math.snapTo(game.world.randomX, 32);
        var y = game.math.snapTo(game.world.randomY, 32);
        group.create(x, y, 'trees', game.rnd.integerInRange(0, 8));
    }

    //  Move it
    cursors = game.input.keyboard.createCursorKeys();

    if (Modernizr.touch) {
      // Use Austin Hallock's HTML5 Virtual Game Controller
      // https://github.com/austinhallock/html5-virtual-game-controller/
      // Note: you must also require gamecontroller.js on your host page.

      // Init game controller with left thumb stick
      GameController.init({
          left: {
              type: 'joystick',
              joystick: {
                  touchStart: function() {
                      // Don't need this, but the event is here if you want it.
                  },
                  touchMove: function(joystick_details) {
                      game.input.joystickLeft = joystick_details;
                  },
                  touchEnd: function() {
                      game.input.joystickLeft = null;
                  }
              }
          },
          right: {
              // We're not using anything on the right for this demo, but you can add buttons, etc.
              // See https://github.com/austinhallock/html5-virtual-game-controller/ for examples.
              type: 'none'
          }
      });

      // This is an ugly hack to get this to show up over the Phaser Canvas
      // (which has a manually set z-index in the example code) and position it in the right place,
      // because it's positioned relatively...
      // You probably don't need to do this in your game unless your game's canvas is positioned in a manner
      // similar to this example page, where the canvas isn't the whole screen.
      $('canvas').last().css('z-index', 20);
      $('canvas').last().offset( $('canvas').first().offset() );
    }
}

var dir = 'down';
function update() {

    sprite.body.velocity.x = 0;
    sprite.body.velocity.y = 0;

    var vx = 0;
    var vy = 0;
    if (cursors.up.isDown)
    {
      vy = -200;
    }
    else if (cursors.down.isDown)
    {
      vy = 200;
    }

    if (cursors.left.isDown)
    {
      vx = -200;
    }
    else if (cursors.right.isDown)
    {
      vx = 200;
    }


    if (game.input.joystickLeft) {
      // Move the ufo using the joystick's normalizedX and Y values,
      // which range from -1 to 1.
      // ufo.body.velocity.setTo(game.input.joystickLeft.normalizedX * 200, game.input.joystickLeft.normalizedY * ufoSpeed * -1);
      vx = game.input.joystickLeft.normalizedX * 200;
      vy = game.input.joystickLeft.normalizedY * -200;

      myText.content = "(" + vx + "," + vy + ")";
    }

    sprite.body.velocity.y = vy;
    sprite.body.velocity.x = vx;

    var move = 'idle';
    if (vy < 0) { move = 'up'; }
    if (vy > 0) { move = 'down'; }
    if (Math.abs(vx) > Math.abs(vy)) {
      if (vx > 0) { move = 'right'; }
      if (vx < 0) { move = 'left'; }
    }

    if (move === 'idle') {
      sprite.animations.play("stand_"+dir);

    } else {
      dir = move;
      sprite.animations.play('walk_'+dir);
    }

    
    if (sprite.y !== oldY)
    {
        //  Group.sort() is an expensive operation
        //  You really want to minimise how often it is called as much as possible.
        //  So this little check helps at least, but if you can do it even less than this.
        group.sort();
        oldY = sprite.y;
    }

}

