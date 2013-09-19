#= require ./lib/queue

# Utility class for updating models in memory.
Batman.Reactor =
  # Private queue for batching
  _q: queue(1)

  # Valid batch operations
  _verbs: ["updated", "created", "destroyed", "flushed", "batched"]

  # Public interface for updating objects in Batman in a bulk/one off fashion
  process: (verb, model, data) ->
    if @_verbs.indexOf(verb) > -1
      if verb is 'batched'
        @_batched(model, data)
      else
        @_enqueue(verb, model, data)
    else
      Batman.developer.warn("unrecognized operation: " + verb)

  _execute: (verb, model, data) ->
    @['_'+verb](model, data)

  _enqueue: (verb, model, data) ->
    @_q.defer (next) =>
      @_execute(verb, model, data)
      next()

  _updateRecord: (record, data) ->
    record._withoutDirtyTracking -> record.fromJSON(data)

  _initRecord: (model, data) ->
    record = new model()
    @_updateRecord(record, data)
    return record

  _findRecord: (model, data) ->
    model.get('loaded.indexedByUnique.id').get(data["id"])

  # Flush every object of a certain model that matches the criterion (all comments for a post)
  # used when you want Batman to request updates
  _flushed: (model, data) ->
    match_key   = data.match_key
    match_value = data.match_value
    Batman.developer.log("FLUSH #{model.name} - #{match_key} => #{match_value}")

    recordsToRemove = model.get('loaded').indexedBy(match_key).get(match_value).toArray()
    for record in recordsToRemove
      model.get('loaded').remove(record)
    if match_key == 'id'
      model.find match_value, ->
    else
      options = {}
      options["#{match_key}"] = match_value
      model.load options

  _batched: (model, batch) ->
    return unless batch?
    Batman.developer.log("BATCH: " + batch.length)

    for item in batch
      @_enqueue(item[0], model, item[1])

  _created: (model, data) ->
    Batman.developer.log("created: #{JSON.stringify(data)}")

    record = @_findRecord(model, data)
    if record? # already in memory, update it
      @_updateRecord(model, data)
    else # create object in memory
      model._mapIdentity @_initRecord(model, data)

  _updated: (model, data) ->
    Batman.developer.log("updated #{JSON.stringify(data)}")

    record = @_findRecord(model, data)
    @_updateRecord(record, data) if record?

  _destroyed: (model, data) ->
    Batman.developer.log("destroyed #{JSON.stringify(data)}")

    record = @_findRecord(model, data)
    model.get('loaded').remove(record) if record?

