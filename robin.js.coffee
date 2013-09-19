#= require ./reactor

# Push-persistence backed by Faye.
class Batman.Robin extends Batman.Object
  @_nest: []

  @connect: (@socket) ->
    Batman.Robin.fire('socket:ready')

  @on 'socket:ready', ->
    bird() for bird in @_nest

  constructor: (@model) ->
    if @socket
      # Go ahead and subscribe.
      @subscribe()
    else
      # Add it to the nest.
      Batman.Robin._nest.push =>
        @socket = Batman.Robin.socket
        @subscribe()

  subscribe: ->
    channel = @model.storageKey
    Batman.developer.log "Subscribing to /#{channel}..."
    for verb in Batman.Reactor._verbs
      do (verb) =>
        @socket.subscribe "/#{channel}/#{verb}", (data) => @_process(verb, data)

  _process: (verb, data) ->
    Batman.Reactor.process(verb, @model, data)

@Robin = Batman.Robin
