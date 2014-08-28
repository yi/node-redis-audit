require 'mocha'
should = require('chai').should()
async = require 'async'

RedisAudit = require "../redis-audit"

KEY = "test"

#audit = new RedisAudit({maxLogLength:10})
audit = new RedisAudit()

describe "RedisAudit", ()->

  describe "clear", () ->
    it "clear all", (done) ->
      audit.clear KEY, done

  describe "add", ()->
    it "add multiple and pull backi", (done) ->
      ids = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
      #ids = [0...19999]
      #console.dir ids
      async.eachSeries ids, (id, next)=>
        audit.add KEY, id, '- test', (err)=>
          return next err if err?
          next()
      , (err) =>
        should.not.exist err
        audit.latest KEY, 1, (err, items) ->
          return consle.error err if err?
          console.dir items
          done()

  describe "pull", ()->
    it "pull back multiple", (done)->
      audit.list KEY, 0, 10, (err, items)->
        should.not.exist err
        console.dir items
        done()

    it "pull back reversely", (done)->
      audit.rlist KEY, 0, 10, (err, items)->
        should.not.exist err
        console.dir items
        done()


    it "pull back reversely", (done)->
      audit.rlist KEY, 10, 30, (err, items)->
        should.not.exist err
        console.dir items
        done()

    it "pull back reversely", (done)->
      audit.rlist KEY, -1, -10, (err, items)->
        should.not.exist err
        console.dir items
        done()



    it "pull sum count", (done)->
      audit.count KEY, (err, count)->
        should.not.exist err
        console.log "count: #{count}"
        done()


    it "pull latest", (done) ->
      audit.latest KEY, 100, (err, items)->
        should.not.exist err
        console.dir items
        done()








