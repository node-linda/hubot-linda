# Description:
#   hubot-linda
#
# Author:
#   @shokai

'use strict'

debug = require('debug')('hubot:linda')

process.env.HUBOT_LINDA_ROOM ||= '#general'
process.env.HUBOT_LINDA_HEADER ||= ':feelsgood:'

required_env_vars = [
  'HUBOT_LINDA_SERVER'
  'HUBOT_LINDA_TUPLESPACE'
]

module.exports = (robot) ->

  for name in required_env_vars
    unless process.env.hasOwnProperty name
      robot.logger.error "ENV Variable \"#{name}\" is required for hubot-linda."
      return

  LindaClient = require('linda').Client
  socket = require('socket.io-client').connect(process.env.HUBOT_LINDA_SERVER)
  robot.linda = linda = new LindaClient().connect(socket)

  linda.io.on 'connect', ->
    robot.emit 'linda:ready'
    cid = setInterval ->
      return if typeof robot?.send isnt 'function'
      debug "connected #{process.env.HUBOT_LINDA_SERVER}"
      robot.send {room: process.env.HUBOT_LINDA_ROOM}, "#{process.env.HUBOT_LINDA_HEADER} <hubot-linda> connected #{process.env.HUBOT_LINDA_SERVER}/#{process.env.HUBOT_LINDA_TUPLESPACE}"
      clearInterval cid
    , 1000

  ts = linda.tuplespace process.env.HUBOT_LINDA_TUPLESPACE
  ts.watch {type: 'hubot', cmd: 'post'}, (err, tuple) ->
    return if tuple.data.response?
    return unless tuple.data.value?
    debug tuple
    room = tuple.data.room or process.env.HUBOT_LINDA_ROOM

    unless room
      tuple.data.response = "fail"
      ts.write tuple.data
      return

    robot.send {room: room}, "#{process.env.HUBOT_LINDA_HEADER} <hubot-linda/#{ts.name}> #{tuple.data.value}"
    tuple.data.response = 'success'
    ts.write tuple.data

  robot.respond /linda config$/i, (msg) ->
    conf = {}
    for k,v of process.env
      if /^HUBOT_LINDA_.+$/.test k
        conf[k] = v
    msg.send "#{process.env.HUBOT_LINDA_HEADER} <linda config>\n#{JSON.stringify conf, null, 2}"
