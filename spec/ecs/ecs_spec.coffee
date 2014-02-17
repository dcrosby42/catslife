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

