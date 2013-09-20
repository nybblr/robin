#= require_self
#= require ./robin/reactor
#= require ./robin/adapter

# Push-persistence backed by Faye.
class @Robin extends Batman.Object
  @_nest: []

  @connect: (@socket) ->
    @fire('socket:ready')

  @on 'socket:ready', ->
    bird() for bird in @_nest

  constructor: (@model) ->
    if @socket
      # Go ahead and subscribe.
      @subscribe()
    else
      # Add it to the nest.
      @constructor._nest.push =>
        @socket = @constructor.socket
        @subscribe()

  subscribe: ->
    channel = @model.storageKey
    Batman.developer.log "Subscribing to /#{channel}..."
    for verb in Robin.Reactor._verbs
      do (verb) =>
        @socket.subscribe "/#{channel}/#{verb}", (data) => @_process(verb, data)

  _process: (verb, data) ->
    Robin.Reactor.process(verb, @model, data)

window.Robin = Robin
