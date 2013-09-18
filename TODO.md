- Sidekiq job processing with batch/flushing
- JS examples
- Get rid of boilerplate
- Events for realtime events
- Remove jQuery dep
- Implement as storage adapter
- Generic socket interface: Batman.Socket or Batman.Robin.Socket
- Entirely websocket backing, with JSON fallback
- Controller rerender options
- Encapsulate Rails controllers with realtime options
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

