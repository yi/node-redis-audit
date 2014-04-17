# redis-audit
[![Build Status](https://travis-ci.org/yi/node-redis-audit.png?branch=master)](https://travis-ci.org/yi/node-redis-audit)
[![Dependencies Status](https://david-dm.org/yi/node-redis-audit.png)](https://david-dm.org/yi/node-redis-audit)



a redis-backed audit log module for NodeJS

## Install
Install the module with:

```bash
npm install redis-audit
```

## Usage
```javascript
var RedisAudit = require('redis-audit');
audit = new RedisAudit;
audit.add(KEY, 1, "abc");
audit.add(KEY, 2, "efg");
audit.add(KEY, 3, "hij");
audit.add(KEY, 4, "klm");
audit.add(KEY, 5, "nop");
audit.list(KEY, 0, 3, function(err, items) {
    // items:
    // [
    //   ["1", "abc"]
    //   ["2", "efg"]
    //   ["3", "hij"]
    // ]
});

audit.latest(KEY, 2, function(err, items) {
    // items:
    // [
    //   ["5", "nop"]
    //   ["4", "klm"]
    // ]
});

```

## Options
 * maxLogLength : 9999
 * redisHost : "localhost"
 * redisPort : "6379"
 * prefix : "raudit"
 * delimiter : "\t"


## License
Copyright (c) 2014 Yi
Licensed under the MIT license.
