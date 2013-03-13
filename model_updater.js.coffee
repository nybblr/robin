Batman.ModelUpdater =
  # Private queue for jQuery
  _q: $({})

  # Valid batch operations
  _verbs: ["updated", "created", "destroyed", "flushed", "batched"]

  # Public interface for updating objects in Batman in a bulk/one off fashion
  process: (verb, model, data) ->
    if _.contains @_verbs, verb
      @['_'+verb](model, data)
    else
      Batman.currentApp.logger.warn("unrecognized batch operation: " + verb)

  _enqueue: (model, batch_item) ->
    @_q.queue (next) =>
      @process(batch_item[0], model, batch_item[1])
      next()

  _getObject: (model, data) ->
    # model = Batman.currentApp[pushed_data.model_name]
    # data = pushed_data.model_data
    obj = new model()
    obj._withoutDirtyTracking -> obj.fromJSON(data)
    return obj

  # Flush every object of a certain model that matches the criterion (all comments for a post)
  # used when you have too much data to pass through Pusher but want Batman to request updates
  _flushed: (model, data) ->
    # model = Batman.currentApp[reload_data.model_name]
    match_key = data.match_key
    match_value = data.match_value
    Batman.currentApp.logger.debug("FLUSH #{model.name} - #{match_key} => #{match_value}")
    recordsToRemove = model.get('loaded').indexedBy(match_key).get(match_value).toArray()
    recordsToRemove.forEach (existing) =>
      model.get('loaded').remove(existing)
    if match_key == 'id'
      model.find match_value, ->
    else
      options = {}
      options["#{match_key}"] = match_value
      model.load options

  _batched: (model, batch) ->
    return if batch == undefined
    Batman.currentApp.logger.debug("BATCH: " + batch.length)
    for batched_item in batch
      @_enqueue(model, batched_item)

  _created: (model, data) ->
    Batman.currentApp.logger.debug("created: #{JSON.stringify(data)}")
    obj = model.get('loaded.indexedByUnique.id').get(data["id"])
    if obj # If object already in memory, update it
      obj._withoutDirtyTracking -> obj.fromJSON(data)
    else # create object in memory
      obj = @_getObject(model, data)
      model._mapIdentity(obj)

  _updated: (model, data) ->
    Batman.currentApp.logger.debug("updated #{JSON.stringify(data)}")
    obj = model.get('loaded.indexedByUnique.id').get(data["id"])
    if obj
      obj._withoutDirtyTracking -> obj.fromJSON(data)

  _destroyed: (model, data) ->
    Batman.currentApp.logger.debug("destroyed #{JSON.stringify(data)}")
    existing = model.get('loaded.indexedByUnique.id').get(data["id"])
    if existing
      model.get('loaded').remove(existing)
