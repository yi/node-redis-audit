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


class RedisAudit

  constructor: (options={}) ->
    @options = _.extend {}, DEFAULT_OPTIONS, options
    @redisClient = options.redisClient
    unless @redisClient?
      for key, val of DEFAULT_OPTIONS
        delete options[key]
      @redisClient = redis.createClient @options.redisPort, @options.redisHost, options


  add : (key, info...)->
    assert key, "missing key"

    callback = info.pop() if _.isFunction(_.last(info))
    unless info.length > 0
      callback() if callback?
      return

    key = "#{@options.prefix}:#{key}"
    @redisClient.RPUSH key , info.join(@options.delimiter), (err, length)=>
      if err?
        debuglog "[add] ERROR: when RPUSH. error: #{err}"
        callback err if err?
        return

      if length > @options.maxLogLength
        @redisClient.LTRIM key 0, @options.maxLogLength - 1, (err)->
          debuglog "[add] ERROR: when LTRIM. error: #{err}" if err?
          callback err if callback?
          return
      else
        callback() if callback?
      return
    return

  clear : (key, callback)->
    assert key, "missing key"
    key = "#{@options.prefix}:#{key}"
    @redisClient.DEL key, callback


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
      callback null, items.map((val)=> val.split(@options.delimiter))
      return
    return

  rlist : (key, from, to, callback)->
    @list key, to, from, (err, items)->
      items.reverse() if Array.isArray(items)
      callback err, items
      return
    return

  count : (key, callback)->
    assert key, "missing key"
    assert _.isFunction(callback), "missing callback"
    key = "#{@options.prefix}:#{key}"
    @redisClient.LLEN key, callback
    return

  latest : (key, count, callback)->
    assert key, "missing key"
    assert _.isFunction(callback), "missing callback"
    count = parseInt(count, 10) || 0
    return callback(null, []) if count < 1

    key = "#{@options.prefix}:#{key}"
    @redisClient.LRANGE key, -count, -1, (err, items)=>
      if err?
        debuglog "[latest] ERROR: when LRANGE. error: #{err}"
        callback err
        return

      callback null, items.reverse().map((val)=> val.split(@options.delimiter))
    return

module.exports=RedisAudit








