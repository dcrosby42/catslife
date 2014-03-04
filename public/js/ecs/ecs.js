(function() {
  var Ecs, EventHandler, Simulation, System,
    __slice = [].slice;

  Ecs = {};

  System = (function() {
    function System(config) {
      this.config = config;
      this.updateFn = this.config.update;
      this.searchTypes = this.config.search;
    }

    System.prototype.run = function(context) {
      return Ecs["for"].components(context.state, this.searchTypes, (function(_this) {
        return function() {
          var args, comps;
          comps = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          args = comps.slice(0);
          args.unshift(context);
          return _this.updateFn.apply(_this, args);
        };
      })(this));
    };

    return System;

  })();

  EventHandler = (function() {
    function EventHandler(fn) {
      this.fn = fn;
    }

    EventHandler.prototype.handle = function(state, event) {
      return this.fn(state, event);
    };

    return EventHandler;

  })();

  Simulation = (function() {
    function Simulation(world, state) {
      this.world = world;
      this.state = state;
      this.systems = [];
      this.eventHandlers = {};
      this.context = {
        world: this.world,
        state: this.state
      };
    }

    Simulation.prototype.subscribeEvent = function(type, handler) {
      return this.eventHandlers[type] = handler;
    };

    Simulation.prototype.processEvent = function(event) {
      var handler;
      if (handler = this.eventHandlers[event.type]) {
        return handler.handle(this.state, event);
      } else {

      }
    };

    Simulation.prototype.addSystem = function(system) {
      return this.systems.push(system);
    };

    Simulation.prototype.update = function() {
      var system, _i, _len, _ref, _results;
      _ref = this.systems;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        system = _ref[_i];
        _results.push(system.run(this.context));
      }
      return _results;
    };

    Simulation.prototype.systems = function() {
      var s;
      return (function() {
        var _i, _len, _ref, _results;
        _ref = this.systems;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          s = _ref[_i];
          _results.push(s);
        }
        return _results;
      }).call(this);
    };

    return Simulation;

  })();

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

  Ecs.log = {};

  Ecs.log.debug = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return console.log.apply(console, args);
  };

  Ecs.log.warn = Ecs.log.debug;

  Ecs.log.error = Ecs.log.debug;

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

  Ecs.create.components = function(table) {
    var data, type, _results;
    _results = [];
    for (type in table) {
      data = table[type];
      _results.push(Ecs.create.component(type, data));
    }
    return _results;
  };

  Ecs.create.eventHandler = function(fn) {
    return new EventHandler(fn);
  };

  Ecs.create.system = function(opts) {
    return new System(opts);
  };

  Ecs.create.simulation = function(world, state) {
    return new Simulation(world, state);
  };

  Ecs.add = {};

  Ecs.add.component = function(state, eid, comp) {
    var storedComp, _base, _name;
    storedComp = Ecs.util.merge(comp, {
      eid: eid
    });
    (_base = state.comps)[_name = comp.type] || (_base[_name] = {});
    state.comps[comp.type][eid] = storedComp;
    return state;
  };

  Ecs.add.components = function(state, eid, comps) {
    var c, _;
    if (comps) {
      for (_ in comps) {
        c = comps[_];
        Ecs.add.component(state, eid, c);
      }
    }
    return state;
  };

  Ecs.remove = {};

  Ecs.remove.component = function(state, eid, comp) {
    var compType, comps;
    if (Ecs.util.isString(comp)) {
      compType = comp;
      if (comps = state.comps[compType]) {
        if (delete comps[eid]) {
          return true;
        } else {
          Ecs.log.warn("Ecs.remove.component: failed to delete '" + compType + "' component from " + eid);
          return false;
        }
      } else {
        return true;
      }
    } else if (Ecs.util.isComponent(comp)) {
      return Ecs.remove.component(state, eid, comp.type);
    } else {
      Ecs.log.warn("Ecs.remove.component: can't delete component from entity " + eid + ":", comp);
      return false;
    }
  };

  Ecs.remove.entity = function(state, eid) {
    var all, fails, h, res, _, _ref;
    _ref = state.comps;
    for (_ in _ref) {
      h = _ref[_];
      all = (delete h[eid] ? true : (Ecs.log.warn("Ecs.remove.entity: failed to delete component for " + eid + ":", h[eid]), false));
    }
    fails = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = all.length; _i < _len; _i++) {
        res = all[_i];
        if (res !== true) {
          _results.push(res);
        }
      }
      return _results;
    })();
    return fails.length === 0;
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
                _results.push(Ecs.log.error("Ecs.for.components: CAN'T DO MORE THAN 3 TYPES PER QUERY YET! SRY!"));
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
  } else if ((typeof module !== 'undefined') && (typeof module.exports !== 'undefined')) {
    module.exports = Ecs;
  }

}).call(this);
