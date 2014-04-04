#= require ../../lib/queue

# Utility class for updating models in memory.
Robin.EmberReactor =
  # Private queue for batching
  _q: queue(1)

  # Public interface for updating objects in Batman in a bulk/one off fashion
  process: (verb, model, data) ->
    if Robin._verbs.indexOf(verb) > -1
      if verb is 'batched'
        @_batched(model, data)
      else
        @_enqueue(verb, model, data)
    else
      Ember.Logger.warn("unrecognized verb: " + verb)

  _execute: (verb, model, data) ->
    Ember.Logger.log("#{verb} #{model} => #{JSON.stringify(data)}")
    @['_'+verb](model, data)

  _enqueue: (verb, model, data) ->
    @_q.defer (next) =>
      @_execute(verb, model, data)
      next()

  # Flush every record of a model matching the criterion.
  _flushed: (model, data) ->
    key   = data.key
    value = data.value

    Ember.Logger.warn("flushed not yet implemented")

  _batched: (model, batch) ->
    return unless batch?
    Ember.Logger.log("batched (#{batch.length})")

    for item in batch
      @_enqueue(item[0], model, item[1])

  _created: (model, data) ->
    @_storeFor(model).pushPayload(model, data)

  _updated: (model, data) ->
    @_storeFor(model).pushPayload(model, data)

  _destroyed: (model, data) ->
    record = @_storeFor(model).getById(model, data.id)
    record?.deleteRecord()

  _storeFor: (model) ->
    name = Ember.String.classify(model)
    klass = App[name]
    klass.store

