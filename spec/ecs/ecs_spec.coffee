Ecs = require '../../src/ecs/ecs'

describe "Ecs", ->
  withEid = (comp, eid) -> Ecs.util.merge(comp,eid:eid)

  it "exists", -> expect(Ecs).toBeDefined()

  describe "utils", ->
    it "exists", -> expect(Ecs.util).toBeDefined()
    
    describe "merge", ->
      a = {a:"hello"}
      b = {b:"world"}
      c = {a:"goodbye", b:"place"}

      it "adds fields", ->
        res = Ecs.util.merge(a,b)
        expect(res.a).toEqual "hello"
        expect(res.b).toEqual "world"

      it "overrides fields in defaults", ->
        res = Ecs.util.merge(a,c)
        expect(res.a).toEqual "goodbye"
        expect(res.b).toEqual "place"
        expect(a.a).toEqual "hello"
        expect(c.a).toEqual "goodbye"
        expect(c.b).toEqual "place"

        res2 = Ecs.util.merge(c,a)
        expect(res2.a).toEqual "hello"

    describe "isString", ->
      it "is true for strings", ->
        expect(Ecs.util.isString("hi")).toEqual(true)
        expect(Ecs.util.isString("")).toEqual(true)
        expect(Ecs.util.isString(1)).toEqual(false)
        expect(Ecs.util.isString(NaN)).toEqual(false)
        expect(Ecs.util.isString(null)).toEqual(false)
    
    describe "isComponent", ->
      it "is true for objects with a type string property", ->
        expect(Ecs.util.isComponent({type: "car"})).toEqual(true)
        expect(Ecs.util.isComponent({type: ""})).toEqual(true)
        expect(Ecs.util.isComponent({type: 1})).toEqual(false)
        expect(Ecs.util.isComponent({})).toEqual(false)
        expect(Ecs.util.isComponent("huh")).toEqual(false)
        expect(Ecs.util.isComponent("huh")).toEqual(false)

  describe "create", ->
    describe "state", ->
      it "makes a new state instance", ->
        s = Ecs.create.state()
        expect(s.comps).toEqual([])

    describe "component", ->
      it "makes a new component", ->
        c = Ecs.create.component("hat", size:5, color: "green")
        expect(c.type).toEqual("hat")
        expect(c.size).toEqual(5)
        expect(c.color).toEqual("green")

      it "makes a new component from an empty", ->
        c = Ecs.create.component("x",{})
        expect(c.type).toEqual("x")

      it "makes a new component with only 1 param", ->
        c = Ecs.create.component("x")
        expect(c.type).toEqual("x")

        c2 = Ecs.create.component("y",null)
        expect(c2.type).toEqual("y")

    describe "components", ->
      it "converts a 'table' (object w properties) into a set of components", ->
        comps = Ecs.create.components {
          color: {val:'red'}
          pos: {x:45}
        }
        expect(comps[0]).toEqual {type:'color', val:'red'}
        expect(comps[1]).toEqual {type:'pos', x: 45}

      it "returns empty array for empty object, null, and missing arg", ->
        expect(Ecs.create.components({})).toEqual []
        expect(Ecs.create.components(null)).toEqual []
        expect(Ecs.create.components()).toEqual []

  describe "add", ->
    state = null
    pos = Ecs.create.component "pos", x:50
    color = Ecs.create.component "color", val: "red"

    beforeEach ->
      state = Ecs.create.state()

    describe "component", ->
      it "adds a component to the specified entity", ->
        Ecs.add.component state, 'e42', pos
        comp = Ecs.get.component(state, 'e42', "pos")
        expect(comp).toEqual withEid(pos,'e42')

    describe "components", ->
      it "adds an array of components to the specified entity", ->
        Ecs.add.components state, 'e42', [pos,color]
        comp1 = Ecs.get.component(state, 'e42', "pos")
        expect(comp1).toEqual withEid(pos,'e42')

        comp2 = Ecs.get.component(state, 'e42', "color")
        expect(comp2).toEqual withEid(color,'e42')

  describe "get", ->
    state = null
    pos = Ecs.create.component("pos", x:10, y:50)
    pos2 = Ecs.create.component("pos", x:30, y:40)
    color = Ecs.create.component("color", r:100)

    beforeEach ->
      state = Ecs.create.state()

    afterEach ->
      state = Ecs.create.state()

    describe "component", ->
      it "gets the component for the given entity and component type", ->
        Ecs.add.component state, "e1", pos
        got = Ecs.get.component(state,"e1","pos")
        expect(got).toEqual(withEid(pos,"e1"))

    describe "components", ->
      beforeEach ->
        Ecs.add.component state, "e42", pos
        Ecs.add.component state, "e42", color
        Ecs.add.component state, "e37", pos2
        Ecs.add.component state, "e0", color

      it "gets all components of the given type", ->
        got = Ecs.get.components(state,"pos")
        expect(got).toContain(withEid(pos,"e42"))
        expect(got).toContain(withEid(pos2,"e37"))

        got2 = Ecs.get.components(state,"color")
        expect(got2).toContain(withEid(color,"e42"))
        expect(got2).toContain(withEid(color,"e0"))

  describe "for", ->
    state = null
    pos = Ecs.create.component("pos", x:10, y:50)
    pos2 = Ecs.create.component("pos", x:30, y:40)
    color = Ecs.create.component("color", r:100)
    phys = Ecs.create.component("phys", ang_v: 3.1)
    phys2 = Ecs.create.component("phys", ang_v: 0.4)
    sprite = Ecs.create.component("sprite", action: "stand")

    pos3 = Ecs.create.component("pos", x:333, y:444)
    phys3 = Ecs.create.component("phys", ang_v: 0.3)
    sprite3 = Ecs.create.component("sprite", action: "jump")


    beforeEach ->
      state = Ecs.create.state()
      Ecs.add.component state, "e1", pos
      Ecs.add.component state, "e1", color
      Ecs.add.component state, "e2", pos2
      Ecs.add.component state, "e2", sprite
      Ecs.add.component state, "e2", phys2
      Ecs.add.component state, "e3", pos3
      Ecs.add.component state, "e3", sprite3
      Ecs.add.component state, "e3", phys3
      # Ecs.add.component state, "e42", color

    describe "components", ->
      it "can search on 1 component type", ->
        hits = []
        Ecs.for.components state, ["pos"], (pos) ->
          hits.push pos
        expect(hits.length).toEqual 3
        expect(hits).toContain(withEid(pos, "e1"))
        expect(hits).toContain(withEid(pos2, "e2"))
        expect(hits).toContain(withEid(pos3, "e3"))

      it "can search on 2 component types", ->
        hits = []
        Ecs.for.components state, ["pos","color"], (pos,color) ->
          hits.push [pos,color]

        expect(hits.length).toEqual 1
        expect(hits).toContain([withEid(pos, "e1"), withEid(color, "e1")])

      it "can search on 3 component types", ->
        hits = []
        Ecs.for.components state, ["pos","sprite","phys"], (_pos,_sprite,_phys) ->
          hits.push [_pos,_sprite,_phys]

        expect(hits.length).toEqual 2
        expect(hits).toContain([withEid(pos2, "e2"), withEid(sprite, "e2"), withEid(phys2,"e2")])
        expect(hits).toContain([withEid(pos3, "e3"), withEid(sprite3, "e3"), withEid(phys3,"e3")])

  describe "remove", ->
    state = null
    beforeEach ->
      state = Ecs.create.state()
      Ecs.add.components state, 'e1', Ecs.create.components(
        pos: {x:50}
        color: {val:'red'}
      )
      Ecs.add.components state, 'e2', Ecs.create.components(
        pos: {x:100}
        color: {val:'green'}
      )

    seeComponent = (eid,ctype,data) ->
      comp = Ecs.get.component(state,eid,ctype)
      expect(comp).toEqual withEid(Ecs.util.merge(data,type:ctype),eid)
      comp

    removeComponent = (eid,comp) ->
      res = Ecs.remove.component(state, 'e1', comp)
      expect(res).toEqual true
      res

    seeUndefinedComponent = (eid,ctype) ->
      comp = Ecs.get.component(state,eid,ctype)
      expect(comp).toBeUndefined()
      comp

    removeEntity = (eid) ->
      res = Ecs.remove.entity(state,eid)
      expect(res).toEqual(true)
      res

    describe "component", ->
      it "removes the component of the given type from the indicated entity", ->
        # Sanity check components
        seeComponent 'e1', 'pos', {x:50}
        seeComponent 'e1', 'color', {val:'red'}
        seeComponent 'e2', 'pos', {x:100}
        seeComponent 'e2', 'color', {val:'green'}

        # Remove component by name:
        removeComponent 'e1', 'pos'

        # See pos component is gone:
        seeUndefinedComponent 'e1', 'pos'

        # See other components intact:
        seeComponent 'e1', 'color', {val:'red'}
        seeComponent 'e2', 'pos', {x:100}
        seeComponent 'e2', 'color', {val:'green'}

        # Another!
        removeComponent 'e1', 'color'

        seeUndefinedComponent 'e1', 'color'

        seeComponent 'e2', 'pos', {x:100}
        seeComponent 'e2', 'color', {val:'green'}

      it "removes the given component from the indicated entity", ->
        # Sanity check components
        pos = seeComponent 'e1', 'pos', {x:50}
        color = seeComponent 'e1', 'color', {val:'red'}
        seeComponent 'e2', 'pos', {x:100}
        seeComponent 'e2', 'color', {val:'green'}

        # Remove component by name:
        removeComponent 'e1', pos

        # See pos component is gone:
        seeUndefinedComponent 'e1', 'pos'

        # See other components intact:
        seeComponent 'e1', 'color', {val:'red'}
        seeComponent 'e2', 'pos', {x:100}
        seeComponent 'e2', 'color', {val:'green'}

        # Another!
        removeComponent 'e1', color

        seeUndefinedComponent 'e1', 'color'

        seeComponent 'e2', 'pos', {x:100}
        seeComponent 'e2', 'color', {val:'green'}

    describe "entity", ->
      it "removes ALL components stored for a given entity", ->
        # Sanity check components
        seeComponent 'e1', 'pos', {x:50}
        seeComponent 'e1', 'color', {val:'red'}
        seeComponent 'e2', 'pos', {x:100}
        seeComponent 'e2', 'color', {val:'green'}
        
        # Remove e1
        removeEntity 'e1'

        # See all e1 components are gone:
        seeUndefinedComponent 'e1', 'pos'
        seeUndefinedComponent 'e1', 'color'

        # See e2 components intact: 
        seeComponent 'e2', 'pos', {x:100}
        seeComponent 'e2', 'color', {val:'green'}
    
        # Remove e2:
        removeEntity 'e2'

        # See all e2 components are gone:
        seeUndefinedComponent 'e2', 'pos'
        seeUndefinedComponent 'e2', 'color'
