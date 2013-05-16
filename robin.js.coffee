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
        @socket.subscribe "/#{channel}/#{verb}", (data) => @delayIfXhrRequests(verb, data)

  delayIfXhrRequestsWithoutDecompress: (method, data) ->
    if Batman.Robin.activeXhrCount == 0
      setTimeout =>
        Batman.developer.log("Processing #{method} with data #{JSON.stringify(data)}")
        Batman.Reactor.process(method, @model, data)
      , 0
    else
      Batman.developer.log("Delaying #{method}")
      setTimeout =>
        @delayIfXhrRequestsWithoutDecompress(method, data)
      , 500

  delayIfXhrRequests: (method, data) ->
    @delayIfXhrRequestsWithoutDecompress(method, data)

@Robin = Batman.Robin
@Robin.activeXhrCount = 0
$(document).ajaxSend(=> @Robin.activeXhrCount++).ajaxComplete(=> @Robin.activeXhrCount--)
