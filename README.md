Hubot Linda
===========
[Linda](https://www.npmjs.com/package/linda) connector for Hubot

- https://github.com/shokai/hubot-linda
- https://npmjs.org/package/hubot-linda


Install
-------

    % npm i hubot-linda -save

### edit `external-script.json`

```json
["hubot-linda"]
```


Config
------

set ENV Variables

### Required

    % export HUBOT_LINDA_SERVER=http://linda-server.herokuapp.com
    % export HUBOT_LINDA_TUPLESPACE=test

### Optional (default value is below)

    % export HUBOT_LINDA_ROOM=general
    % export HUBOT_LINDA_HEADER=:feelsgood:  # slack emoticon


## How it work?

following URL
- http://linda-server.herokuapp.com/test?type=hubot&cmd=post&value=hello

1. Write a Tuple into Linda `{type: "hubot", cmd: "post", value: "hello!!"}`
2. Hubot detects the Tuple
3. send "Hello!!" to chat

```javascript
{
  type: "hubot",   // required
  cmd: "post",     // required
  value: "hello",   // required
  room: "#general" // optional, you can specify chat room.
}
```


## for Hubot Script

hubot-linda emits `linda:ready` event when ready.

```coffee
# Description:
#   read light sensor value with Linda
# Commands:
#   hubot sensor light

module.exports = (robot) ->

  robot.on 'linda:ready', ->

    robot.respond /sensor light/, (msg) ->

      robot.linda.tuplespace('test').read {type: "sensor", name: "light"}, (err, tuple) ->
        if err
          msg.send "linda error"
          return
        msg.send "light : #{tuple.data.value}"
```
