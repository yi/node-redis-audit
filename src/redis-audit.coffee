##
# redis-audit
# https://github.com/yi/node-redis-audit
#
# Copyright (c) 2014 Yi
# Licensed under the MIT license.
##

debuglog = require("debug")("redis-audit")
assert = require "assert"
_ = require "underscore"
redis = require "redis"

DEFAULT_OPTIONS =
  maxLogLength : 9999
  redisHost : "localhost"
  redisPort : "6379"
  prefix : "raudit"
  delimiter : "\t"


Class RedisAudit

  constructor: (options={}) ->
    @options = _.extend {}, DEFAULT_OPTIONS, options
    @redisClient = options.redisClient
    unless @redisClient?
      for key, val of DEFAULT_OPTIONS
        delete options[key]
      @redisClient = redis.createClient @options.redisPort, @options.redisHost, options


  add : (key, info...)->
    assert key, "missing key"
    return unless info.length > 0
    key = "#{@options.prefix}:#{key}"
    @redisClient.RPUSH key , info.join(@options.delimiter), (err, length)->
      return debuglog "[add] ERROR: when RPUSH. error: #{err}" if err?
      if length > @options.maxLogLength
        @redisClient.LTRIM key 0, @options.maxLogLength - 1, (err)->
          debuglog "[add] ERROR: when LTRIM. error: #{err}" if err?
          return
      return
    return


  list : (key, from, to, callback)->
    assert key, "missing key"
    from = parseInt(from, 10) || 0
    to = parseInt(to, 10) || 0
    return [] if from is to

    [from, to] = [to, from] if from > to
    key = "#{@options.prefix}:#{key}"

    @redisClient.LRANGE key, from, to, (err, items)=>
      if err?
        debuglog "[list] ERROR: when LRANGE. error: #{err}"
        callback err
        return
      callback null, items.map(@deserialize)
      return
    return

  rlist : (key, from, to, callback)->
    @list key, to, from, (err, items)->
      items.reverse() if Array.isArray(items)
      callback err, items
      return
    return

  latest : (key, count, callback)->
    assert key, "missing key"
    count = parseInt(count, 10) || 0
    return [] if count < 1

    key = "#{@options.prefix}:#{key}"
    @redisClient.LRANGE key, -count, -1, (err, items)=>
      if err?
        debuglog "[latest] ERROR: when LRANGE. error: #{err}"
        callback err
        return

      callback null, items.reverse().map(@deserialize)
    return

  deserialize : (val)-> val.split(@options.delimiter)



module.exports=RedisAudit








