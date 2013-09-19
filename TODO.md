- Tests!!!
- Get rid of boilerplate
- Events for realtime events
    - Run something besides change event, augment with lock to prevent double saves
- Implement as storage adapter
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

