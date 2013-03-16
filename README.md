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

Contributing
============
No guidelines yet other than your basics: fork it, submit pull request, and try to follow the conventions already in the code. Any and all quality contributions welcome!
