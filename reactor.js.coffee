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
      Batman.developer.warn("unrecognized verb: " + verb)

  _execute: (verb, model, data) ->
    Batman.developer.log("#{verb} #{model.name} => #{JSON.stringify(data)}")
    @['_'+verb](model, data)

  _enqueue: (verb, model, data) ->
    @_q.defer (next) =>
      @_execute(verb, model, data)
      next()

  _removeRecord: (model, record) ->
    model.get('loaded').remove(record)

  _updateRecord: (record, data) ->
    record._withoutDirtyTracking -> record.fromJSON(data)

  _initRecord: (model, data) ->
    record = new model()
    @_updateRecord(record, data)
    return record

  _findRecord: (model, data) ->
    model.get('loaded.indexedByUnique.id').get(data["id"])

  # Flush every record of a model matching the criterion.
  # Makes Batman request updates.
  _flushed: (model, data) ->
    key   = data.key
    value = data.value

    recordsToRemove = model.get('loaded').indexedBy(key).get(value).toArray()
    for record in recordsToRemove
      @_removeRecord(model, record)
    if key is 'id'
      model.find value, ->
    else
      options = {}
      options["#{key}"] = value
      model.load options

  _batched: (model, batch) ->
    return unless batch?
    Batman.developer.log("batched (#{batch.length})")

    for item in batch
      @_enqueue(item[0], model, item[1])

  _created: (model, data) ->
    record = @_findRecord(model, data)
    if record? # already in memory
      @_updateRecord(model, data)
    else # create object in memory
      model._mapIdentity @_initRecord(model, data)

  _updated: (model, data) ->
    record = @_findRecord(model, data)
    @_updateRecord(record, data) if record?

  _destroyed: (model, data) ->
    record = @_findRecord(model, data)
    @_removeRecord(model, record) if record?

