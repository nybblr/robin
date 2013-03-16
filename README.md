Robin.js
========
Every superhero needs a sidekick. Batman.js is no exception.

Realtime
--------
Okay, let's face it: realtime updates are awesome and the future of web apps. But they're a pain to use from scatch for anything more complex than a couple models. We'd like things to just "autoupdate" and add functionality as desired to react to live updates. That's where Robin.js comes in.

Credit where due!
-----------------
Much thanks to [@zhubert](http://github.com/zhubert) for his `fancy_batman_app` with Pusher updates. I started from his code and rewrote it to work with Faye and a slightly cleaner architecture.

Usage
=====
Load up `robin.js`, `reactor.js`, and `logger.js` after you loading jQuery and Batman.js.

Scripts
-------
- Robin is the Faye persistence handler for per-model push updates.
- Reactor is a general-purpose utility class for updating models (*reacting*) in memory with five past-tense verbs:
  - `created`: add a model to memory. The payload is just a set of attributes (whatever Batman can use for input).
  - `updated`: change the model in memory. Again, the payload is the record's attributes.
  - `destroyed`: delete a model in memory. While the entire set of attributes can be passed in, Reactor only expects the `id` parameters.
  - `batched`: run a bunch of reactions. We expect an array of arrays, where each subarray has the verb as the first element and usual payload as the second.
  - `flushed`: force a reload via AJAX. Requires a match key and match value, e.g. to flush a model, pass `{match_key: 'id', match_value: 4}` to flush a model with id = 4.
- Logger is a simple utility class for logging levels (great for debugging). Taken almost verbatim (some whitespace/nitty gritty changes) from @zhubert's example app.

Client (Batman.js)
------------------
On the client side, you need a few things to get started.

First off, Robin needs a Faye connection. Set it up however you like; here's one way to do it in your main app file:

    ...
    @on 'run', ->
      # Open Faye socket for push
      console?.log "Opening socket..."
      @socket = new Faye.Client $('meta[name="faye-url"]').attr('content')

      # Logger object
      Quibble.logger = new Logger()

      # Notify Robin that it can subscribe
      Batman.Robin.fire('socket:ready')

      console?.log "Running..."
    ...

This assumes that the URL for your Faye server is in a `meta` tag (it's not nice to embed it directly in the code). Make sure you set `@socket` (Robin looks for it), then fire the `socket:ready` event on Robin so it knows it can start subscriptions.

In your models (that you want to receive push updates), initialize a Robin instance for the model:

    ...
    # Load Robin
    @set 'robin', new Batman.Robin(@)

You're all set on the client side!

Server (Rails)
--------------
**NOTE: This guide is for setting up observers in Rails, but any implementation which uses Faye and sends the appropriate payload will work.**

The easiest way to get started is to add the excellent `faye-rails` gem to your Gemfile. This adds some nice wrapper for running Faye in your Rails app.

Create a FayeRails::Controller for each model you want to observe and propagate to Robin:

    class PostsRealtime < FayeRails::Controller
      observe Post, :after_create do |post|
        PostsRealtime.publish "/posts/created", post.attributes
      end

      observe Post, :after_update do |post|
        PostsRealtime.publish "/posts/updated", post.attributes
      end

      observe Post, :after_destroy do |post|
        PostsRealtime.publish "/posts/destroyed", :id => post.id
      end
    end

That's it! If you've got faye-rails setup and running Faye correctly (e.g. make sure you use Thin), you should now be able to open several browser clients, edit models in the JS console, then watch the events propagate to other subscribed clients!

Contributing
============
No guidelines yet other than your basics: fork it, submit pull request, and try to follow the conventions already in the code. Any and all quality contributions welcome!
