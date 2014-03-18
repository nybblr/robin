#= require ../lib/queue
#= require_self
#
window.Robin ||= {}

# Utility class for updating models in memory.
Robin.Reactor =
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
    record.get('lifecycle').destroyed()

  _initOrUpdateRecord: (model, data) ->
    model._makeOrFindRecordFromData(data)

  _findRecord: (model, data) ->
    model._loadIdentity(data['id'])

  # Flush every record of a model matching the criterion.
  # Makes Batman request updates.
  _flushed: (model, data) ->
    key   = data.key
    value = data.value

    recordsToRemove = model.get('loaded').indexedBy(key).get(value).toArray()
    for record in recordsToRemove
      @_removeRecord(model, record)
    if key is model.get('primaryKey')
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
    @_initOrUpdateRecord(model, data)

  _updated: (model, data) ->
    record = @_findRecord(model, data)
    @_initOrUpdateRecord(model, data) if record?

  _destroyed: (model, data) ->
    record = @_findRecord(model, data)
    @_removeRecord(model, record) if record?

