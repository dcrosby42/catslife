
Ecs = {}

class System
  constructor: (@config) ->
    @updateFn = @config.update
    @searchTypes = @config.search

  run: (context) ->
    Ecs.for.components context.state, @searchTypes, (comps...) =>
      args = comps.slice(0)
      args.unshift(context)
      @updateFn.apply @, args

class EventHandler
  constructor: (@fn) ->
  handle: (state,event) ->
    @fn state, event

class Simulation
  constructor: (@world, @state) ->
    @systems = []
    @eventHandlers = {}
    @context = {
      world: @world
      state: @state
    }

  subscribeEvent: (type, handler) ->
    @eventHandlers[type] = handler

  processEvent: (event) ->
    if handler = @eventHandlers[event.type]
      handler.handle @state, event
    else

  addSystem: (system) ->
    @systems.push system

  update: ->
    for system in @systems
      system.run @context

  systems: ->
    return (s for s in @systems)

#
# Ecs.util
#

Ecs.util = {}
Ecs.util.merge = (defaults,overrides) ->
  res = {}
  res[k] = v for k,v of defaults
  res[k] = v for k,v of overrides
  res
Ecs.util.isString = (obj) -> "string" == typeof(obj)
Ecs.util.isComponent = (obj) -> Ecs.util.isString(obj.type)

Ecs.log = {}
Ecs.log.debug = (args...) -> console.log args...
Ecs.log.warn = Ecs.log.debug
Ecs.log.error = Ecs.log.debug
#
# Ecs.create
#

Ecs.create = {}
Ecs.create.state = (-> {comps:{}})
Ecs.create.component = (type, obj) -> Ecs.util.merge(obj, {type: type})
Ecs.create.components = (table) -> Ecs.create.component type,data for type,data of table
Ecs.create.eventHandler = (fn) -> new EventHandler(fn)
Ecs.create.system = (opts) -> new System(opts)
Ecs.create.simulation = (world,state) -> new Simulation(world,state)

#
# Ecs.add
#

Ecs.add = {}

Ecs.add.component = (state, eid, comp) ->
  storedComp = Ecs.util.merge(comp, {eid: eid})
  state.comps[comp.type] ||= {}
  state.comps[comp.type][eid] = storedComp
  state

Ecs.add.components = (state, eid, comps) ->
  if comps
    Ecs.add.component state,eid,c for _,c of comps
  state


#
# Ecs.remove
#

Ecs.remove = {}

Ecs.remove.component = (state, eid, comp) ->
  if Ecs.util.isString(comp)
    compType = comp
    if comps = state.comps[compType]
      if delete comps[eid]
        return true
      else
        Ecs.log.warn "Ecs.remove.component: failed to delete '#{compType}' component from #{eid}"
        return false
    else
      return true
      
  else if Ecs.util.isComponent(comp)
    return Ecs.remove.component(state, eid, comp.type)
  else
    # Don't know what to do with 'comp'
    Ecs.log.warn "Ecs.remove.component: can't delete component from entity #{eid}:", comp
    return false

Ecs.remove.entity = (state, eid) ->
  all = (if delete h[eid]
           true
         else
           Ecs.log.warn "Ecs.remove.entity: failed to delete component for #{eid}:", h[eid]
           false
         ) for _,h of state.comps
  fails = (res for res in all when res != true)
  fails.length == 0

#
# Ecs.get
#

Ecs.get = {}
Ecs.get.component = (state,eid,type) ->
  if h = state.comps[type]
    h[eid]
  
Ecs.get.components = (state,type) ->
  if h = state.comps[type]
    comp for eid,comp of h
  else
    []

#
# Ecs.for
#

Ecs.for = {}
Ecs.for.components = (state,types,f) ->
  numTypes = types.length
  t0 = types[0]
  for c0 in Ecs.get.components(state,t0)
    eid = c0.eid
    if numTypes > 1
      t1 = types[1]
      c1 = Ecs.get.component(state,eid,t1)
      if c1
        if numTypes > 2
          t2 = types[2]
          c2 = Ecs.get.component(state,eid,t2)
          if c2
            if numTypes > 3
              Ecs.log.error("Ecs.for.components: CAN'T DO MORE THAN 3 TYPES PER QUERY YET! SRY!")
              #f(c0,c1,c2,...)
            else # numTypes is 3, call back with 3 comps
              f(c0,c1,c2)

        else # numTypes is 2, call back with 2 comps
          f(c0,c1)

    else #numTypes is 1, call back with 1 comp
      f(c0)
      

#
# EXPORTS:
#

if typeof window != 'undefined'
  # Browser
  window.Ecs = Ecs
else if (typeof module != 'undefined') and (typeof module.exports != 'undefined')
  # Node
  module.exports = Ecs
