window.Robin ||= {}

Robin.AdapterMethods =
  subscribe: ->
    Robin.observeAndFire 'socket', (newVal, oldVal) =>
      if newVal?
        @socket = newVal
        @_subscribeNow()

  _subscribeNow: ->
    channel = @model.storageKey
    Batman.developer.log "Subscribing to /#{channel}..."
    for verb in Robin.Reactor._verbs
      do (verb) =>
        @socket.subscribe "/#{channel}/#{verb}", (data) => @_react(verb, data)

  _react: (verb, data) ->
    Robin.Reactor.process(verb, @model, data)

class Robin.Adapter extends Batman.RailsStorage
  @mixin Robin.AdapterMethods

  constructor: (model) ->
    super(model)
    @subscribe()
