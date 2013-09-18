#= require ./reactor

# Push-persistence backed by Faye.
class Batman.Robin extends Batman.Object
  @_nest: []
  @_verbs: ["updated", "created", "destroyed", "flushed", "batched"]

  @on 'socket:ready', ->
    @socket = Batman.currentApp.socket
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
    for verb in @constructor._verbs
      do (verb) =>
        @socket.subscribe "/#{channel}/#{verb}", (data) => @_process(verb, data)

  _process: (verb, data) ->
    Batman.Reactor.process(verb, @model, data)

@Robin = Batman.Robin
