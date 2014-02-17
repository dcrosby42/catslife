(function() {
  var Ecs;

  Ecs = {};

  Ecs.util = {};

  Ecs.util.merge = function(defaults, overrides) {
    var k, res, v;
    res = {};
    for (k in defaults) {
      v = defaults[k];
      res[k] = v;
    }
    for (k in overrides) {
      v = overrides[k];
      res[k] = v;
    }
    return res;
  };

  Ecs.util.isString = function(obj) {
    return "string" === typeof obj;
  };

  Ecs.util.isComponent = function(obj) {
    return Ecs.util.isString(obj.type);
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

  Ecs.removeComponent = function(state, eid, comp) {
    var compType, comps;
    if (Ecs.util.isString(comp)) {
      compType = comp;
      if (comps = state.comps[compType]) {
        return delete comps[compType];
      }
    } else if (Ecs.util.isComponent(comp)) {
      return Ecs.removeComponent(state, eid, comp.type);
    } else {

    }
  };

  Ecs.removeEntity = function(state, eid) {
    var h, _, _ref;
    _ref = state.comps;
    for (_ in _ref) {
      h = _ref[_];
      (function(h) {
        return delete h[eid];
      });
    }
    return null;
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

  if (typeof window !== 'undefined') {
    window.Ecs = Ecs;
  } else {
    module.exports = Ecs;
  }

}).call(this);
