(function() {
  var KeyboardController, ex;

  KeyboardController = (function() {
    function KeyboardController(keyboard, mappings) {
      this.keyboard = keyboard;
      this.mappings = mappings;
      this.current = {
        up: false,
        down: false,
        left: false,
        right: false
      };
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

  ex = {};

  ex.create = function(keyboard, mappings) {
    return new KeyboardController(keyboard, mappings);
  };

  Exporter["export"]('KeyboardController', ex);

}).call(this);
