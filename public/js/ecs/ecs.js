(function() {
  window.Ecs = {};

  Ecs.util = {};

  Ecs.util.merge = function(defaults, overrides) {
    return $.extend({}, defaults, overrides);
  };

  Ecs.create = {};

  Ecs.create.state = (function() {
    return {
      comps: {}
    };
  });

  Ecs.create.component = function(type, obj) {
    return Ecs.util.merge(obj, {
      type: type
    });
  };

  Ecs.addComponent = function(state, eid, comp) {
    var storedComp, _base, _name;
    storedComp = Ecs.util.merge(comp, {
      eid: eid
    });
    (_base = state.comps)[_name = comp.type] || (_base[_name] = {});
    state.comps[comp.type][eid] = storedComp;
    return state;
  };

  Ecs.get = {};

  Ecs.get.component = function(state, eid, type) {
    var h;
    if (h = state.comps[type]) {
      return h[eid];
    }
  };

  Ecs.get.components = function(state, type) {
    var comp, eid, h, _results;
    if (h = state.comps[type]) {
      _results = [];
      for (eid in h) {
        comp = h[eid];
        _results.push(comp);
      }
      return _results;
    } else {
      return [];
    }
  };

  Ecs["for"] = {};

  Ecs["for"].components = function(state, types, f) {
    var c0, c1, c2, eid, numTypes, t0, t1, t2, _i, _len, _ref, _results;
    numTypes = types.length;
    t0 = types[0];
    _ref = Ecs.get.components(state, t0);
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      c0 = _ref[_i];
      eid = c0.eid;
      if (numTypes > 1) {
        t1 = types[1];
        c1 = Ecs.get.component(state, eid, t1);
        if (c1) {
          if (numTypes > 2) {
            t2 = types[2];
            c2 = Ecs.get.component(state, eid, t2);
            if (c2) {
              if (numTypes > 3) {
                _results.push(console.log("Ecs.for.components: CAN'T DO MORE THAN 3 TYPES PER QUERY YET! SRY!"));
              } else {
                _results.push(f(c0, c1, c2));
              }
            } else {
              _results.push(void 0);
            }
          } else {
            _results.push(f(c0, c1));
          }
        } else {
          _results.push(void 0);
        }
      } else {
        _results.push(f(c0));
      }
    }
    return _results;
  };

}).call(this);
