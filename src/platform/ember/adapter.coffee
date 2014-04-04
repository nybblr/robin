Robin.EmberAdapter = Ember.Object.extend
  init: ->
    @model = @get 'model'
    @subscribe()

  subscribe: ->
    callback = =>
      @socket = Robin.Ember.get('socket')
      @_subscribeNow()

    Robin.Ember.addObserver 'socket', callback
    callback() if Robin.Ember.isConnected()

  _subscribeNow: ->
    channel = Ember.Inflector.inflector.pluralize(@model)
    Ember.Logger.log "Subscribing to /#{channel}..."
    for verb in Robin._verbs
      do (verb) =>
        @socket.subscribe "/#{channel}/#{verb}", (data) => @_react(verb, data)

  _react: (verb, data) ->
    Robin.EmberReactor.process(verb, @model, data)

Robin.EmberAdapter.reopenClass
  subscribe: (models...) ->
    for model in models
      @create(model: model)

# DS?.RobinAdapter = Robin.EmberAdapter
