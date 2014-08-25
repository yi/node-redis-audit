require 'mocha'
should = require('chai').should()

RedisAudit = require "../redis-audit"

KEY = "test"

audit = new RedisAudit({maxLogLength:10})

describe "RedisAudit", ()->

  describe "constructor", ()->

    it "could be instancelised with custom options", ->
      r = new RedisAudit
        maxLogLength : 11111
        prefix : "testaudit"
        delimiter : "~~"

      r.options.maxLogLength.should.eql 11111
      r.options.prefix.should.eql "testaudit"
      r.options.delimiter.should.eql "~~"


  describe "add", ()->
    #afterEach (done)-> audit.clear KEY, done

    it "should work", (done)->
      audit.add KEY, 1, "abc", (err)->
        should.not.exist err
        done()

    it "add and pull back", (done)->
      audit.add KEY, 1, "abc", (err)->
        should.not.exist err
        audit.add KEY, 2, "efg", (err)->
          should.not.exist err
          audit.latest KEY, 1, (err, items)->
            should.not.exist err
            should.exist items
            Array.isArray(items).should.be.ok
            items.length.should.eql 1
            Array.isArray(items[0]).should.be.ok
            items[0].length.should.eql 2
            items[0][0].should.eql "2"
            items[0][1].should.eql "efg"
            done()

    it "add and pull back multiple", (done)->
      audit.add KEY, 1, "abc", (err)->
        audit.add KEY, 2, "efg", (err)->
          audit.add KEY, 3, "hij", (err)->
            audit.add KEY, 4, "klm", (err)->
              audit.add KEY, 5, "nop", (err)->
                audit.list KEY, 0, 3, (err, items)->
                  should.not.exist err
                  Array.isArray(items).should.be.ok
                  items.length.should.eql 4
                  items[0][0].should.eql "1"
                  items[1][0].should.eql "2"
                  items[2][0].should.eql "3"
                  items[3][0].should.eql "4"
                  done()

    it "add and pull back reversely", (done)->
      audit.add KEY, 1, "abc", (err)->
        audit.add KEY, 2, "efg", (err)->
          audit.add KEY, 3, "hij", (err)->
            audit.add KEY, 4, "klm", (err)->
              audit.add KEY, 5, "nop", (err)->
                audit.rlist KEY, 0, 3, (err, items)->
                  should.not.exist err
                  Array.isArray(items).should.be.ok
                  items.length.should.eql 4
                  items[0][0].should.eql "4"
                  items[1][0].should.eql "3"
                  items[2][0].should.eql "2"
                  items[3][0].should.eql "1"
                  audit.count KEY, (err, count)->
                    should.not.exist err
                    count.should.eql 5
                    done()











