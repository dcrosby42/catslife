
Ecs = {}

Ecs.util = {}
Ecs.util.merge = (defaults,overrides) ->
  res = {}
  res[k] = v for k,v of defaults
  res[k] = v for k,v of overrides
  res

Ecs.util.isString = (obj) -> "string" == typeof(obj)
Ecs.util.isComponent = (obj) -> Ecs.util.isString(obj.type)

Ecs.create = {}
Ecs.create.state = (-> {comps:{}})
Ecs.create.component = (type, obj) -> Ecs.util.merge(obj, {type: type})

Ecs.addComponent = (state, eid, comp) ->
  storedComp = Ecs.util.merge(comp, {eid: eid})
  state.comps[comp.type] ||= {}
  state.comps[comp.type][eid] = storedComp
  state

Ecs.removeComponent = (state, eid, comp) ->
  if Ecs.util.isString(comp)
    compType = comp
    if comps = state.comps[compType]
      delete comps[compType]
  else if Ecs.util.isComponent(comp)
    Ecs.removeComponent state, eid, comp.type
  else
    # Don't know what to do with 'comp'

Ecs.removeEntity = (state, eid) ->
  ((h) -> delete h[eid]) for _,h of state.comps
  null
  

Ecs.get = {}
Ecs.get.component = (state,eid,type) ->
  if h = state.comps[type]
    h[eid]
  
Ecs.get.components = (state,type) ->
  if h = state.comps[type]
    comp for eid,comp of h
  else
    []

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
              console.log("Ecs.for.components: CAN'T DO MORE THAN 3 TYPES PER QUERY YET! SRY!")
              #f(c0,c1,c2,...)
            else # numTypes is 3, call back with 3 comps
              f(c0,c1,c2)

        else # numTypes is 2, call back with 2 comps
          f(c0,c1)

    else #numTypes is 1, call back with 1 comp
      f(c0)
      

if typeof window != 'undefined'
  window.Ecs = Ecs
else
  module.exports = Ecs
