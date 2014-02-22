Ecs = require '../../src/ecs/ecs'

describe "Ecs", ->
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

  describe "get", ->
    state = null
    pos = Ecs.create.component("pos", x:10, y:50)
    pos2 = Ecs.create.component("pos", x:30, y:40)
    color = Ecs.create.component("color", r:100)
    withEid = (comp, eid) -> Ecs.util.merge(comp,eid:eid)

    beforeEach ->
      state = Ecs.create.state()

    afterEach ->
      state = Ecs.create.state()

    describe "component", ->
      it "gets the component for the given entity and component type", ->
        Ecs.addComponent state, "e1", pos
        got = Ecs.get.component(state,"e1","pos")
        expect(got).toEqual(withEid(pos,"e1"))

    describe "components", ->
      beforeEach ->
        Ecs.addComponent state, "e42", pos
        Ecs.addComponent state, "e42", color
        Ecs.addComponent state, "e37", pos2
        Ecs.addComponent state, "e0", color

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

    withEid = (comp, eid) -> Ecs.util.merge(comp,eid:eid)

    beforeEach ->
      state = Ecs.create.state()
      Ecs.addComponent state, "e1", pos
      Ecs.addComponent state, "e1", color
      Ecs.addComponent state, "e2", pos2
      Ecs.addComponent state, "e2", sprite
      Ecs.addComponent state, "e2", phys2
      Ecs.addComponent state, "e3", pos3
      Ecs.addComponent state, "e3", sprite3
      Ecs.addComponent state, "e3", phys3
      # Ecs.addComponent state, "e42", color

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




