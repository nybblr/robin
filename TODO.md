- Tests!!!
- Events for realtime events
    - Run something besides change event, augment with lock to prevent double saves
- Streaming protocol for large data sources: diffing, appending, or deletion.
- Intermediate streaming without "committing" to database (buffered writes?). e.g. strings/titles
- Peer-to-peer storage adapter for instant client-to-client sync
    - Allows objects that won't be saved in DB (e.g. one time file transfer) to be synced in realtime between a few clients quickly, privately, and easily.
- Sidekiq job processing with batch/flushing
- Generic socket interface: Batman.Socket or Batman.Robin.Socket
- Entirely websocket backing, with JSON fallback
- Controller rerender options
- Hook into Pundit or CanCan to reverse notify
- Private subscription DSL on client/server
- More powerful flush DSL: accept something like:

    {
      id: 4
      status: 'old'
    }

- Offline cache mode, with events (async delay)

Websocket query API:
- RESTful actions
- Automatic subscriptions (fallback to REST, register for WS events)
- Action syntax:
  - create
  - update
  - destroy
  - get
  - filter
- Powerful filter API like meta_where:

{
  matching: {
    id: 1
  },
  count: 50
}

