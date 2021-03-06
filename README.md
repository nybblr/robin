Robin.js
========
Every superhero needs a sidekick. Batman.js is no exception.

Realtime
--------
Okay, let's face it: realtime updates are awesome and the future of web apps. But they're a pain to use from scatch for anything more complex than a couple models. We'd like things to just "autoupdate" and add functionality as desired to react to live updates. That's where Robin.js comes in.

Credit where due!
-----------------
Much thanks to [@zhubert](https://github.com/zhubert) for his [fancy_batman_app](https://github.com/zhubert/fancy_batman_app) with Pusher updates. I started from his code and rewrote it to work with Faye and a cleaner architecture.

Usage
=====
Load up `robin.js.coffee` with its dependencies after Batman.js.

Scripts
-------
- Robin is the Faye persistence handler for per-model push updates.
- Reactor is a general-purpose utility class for updating models *(reacting)* in memory with five past-tense verbs:
  - `created`: add a model to memory. The payload is just a set of attributes (whatever Batman can use for input).
  - `updated`: change the model in memory. Again, the payload is the record's attributes.
  - `destroyed`: delete a model in memory. While the entire set of attributes can be passed in, Reactor only expects the `id` parameter.
  - `batched`: run a bunch of reactions. We expect an array of arrays, where each subarray has the verb as the first element and usual payload as the second.
  - `flushed`: force a reload via AJAX. Requires a match key and match value, e.g. pass `{match_key: 'id', match_value: 4}` to flush a record with id = 4.

Client (Batman.js)
------------------
On the client side, you need a few things to get started.

First off, Robin needs a Faye connection. Set it up however you like; here's one way to do it in your main app file:

```coffeescript
class Awesome extends Batman.App
  # ...

  @on 'run', ->
    # Open Faye socket for push
    @socket = new Faye.Client $('meta[name="faye-url"]').attr('content')

    Robin.connect(@socket)

  # ...
```

This assumes that the URL for your Faye server is in a `meta` tag (it's not nice to embed it directly in the code). Once you've pulled out the path, just tell Robin to connect with that socket by default.

In your models (that you want to receive push updates), just switch to the Robin storage adapter (Rails based at the moment).

```coffeescript
class Awesome.Post extends Batman.Model
  @resourceName: 'post'
  @storageKey: 'posts'

  @persist Robin.Adapter

  # ...
```

You're all set on the client side!

Server (Rails)
--------------

If you want to get an instant realtime backend for your Rails powered JSON API, checkout the [Robin.js Rails gem.](https://github.com/nybblr/robin-rails)

Demo
====
You can checkout a full demo of Robin.js and some awesome Batman.js tidbits working out of a Rails app at [Awesome Starter,](https://github.com/nybblr/awesome-starter/tree/complete-demo-app) an app I made for my ATLRUG realtime talk.

Have a peruse through those [slides](https://speakerdeck.com/nybblr/into-the-batmobile-realtime-batman-dot-js-with-robin-dot-js-and-rails) and [the video](http://vimeo.com/68354627) for a walkthrough.

Contributing
============
This project is (obviously) in its infancy with just the basics. TODO lists a bunch of features I hope to get implemented, but this is GitHub: if you add a feature on your own, give me a hand and contribute!

No guidelines yet other than your basics: fork it, submit a pull request with relevant tests, and try to follow the conventions already in the code. Any and all quality contributions welcome!


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/nybblr/robin/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

