(function() {
  var JoystickController, ex, initTouchJoystick;

  JoystickController = (function() {
    function JoystickController(input, joystickName) {
      this.input = input;
      this.joystickName = joystickName;
      this.current = {};
      this.previous = {};
      this.thresh = 0.1;
      initTouchJoystick(this.input, this.joystickName);
    }

    JoystickController.prototype.update = function() {
      var info, nx, ny;
      info = this.input[this.joystickName];
      if (info) {
        nx = this.input[this.joystickName].normalizedX;
        ny = this.input[this.joystickName].normalizedY;
      } else {
        nx = 0;
        ny = 0;
      }
      if (nx === this.old_nx && ny === this.old_ny) {
        return;
      }
      this.current = {};
      this.diff = {};
      this._change('right', nx > this.thresh);
      this._change('left', nx < -this.thresh);
      this._change('up', ny > this.thresh);
      this._change('down', ny < -this.thresh);
      this.previous = this.current;
      this.old_nx = nx;
      this.old_ny = ny;
      return this.diff;
    };

    JoystickController.prototype._change = function(key, val) {
      this.current[key] = val;
      if (val !== this.previous[key]) {
        return this.diff[key] = val;
      }
    };

    return JoystickController;

  })();

  initTouchJoystick = function(input, inputProperty) {
    GameController.init({
      left: {
        type: 'joystick',
        joystick: {
          touchStart: (function() {}),
          touchMove: function(joystick_details) {
            return input[inputProperty] = joystick_details;
          },
          touchEnd: function() {
            return input[inputProperty] = null;
          }
        }
      },
      right: {
        type: 'none'
      }
    });
    $('canvas').last().css('z-index', 20);
    return $('canvas').last().offset($('canvas').first().offset());
  };

  ex = {};

  ex.create = function(input, jname) {
    return new JoystickController(input, jname);
  };

  Exporter["export"]("JoystickController", ex);

}).call(this);
