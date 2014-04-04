(function() {
  window.Robin = {
    _verbs: ["updated", "created", "destroyed", "flushed", "batched"]
  };

}).call(this);

(function(){function n(n){function t(){for(;f=a<c.length&&n>p;){var u=a++,t=c[u],r=l.call(t,1);r.push(e(u)),++p,t[0].apply(null,r)}}function e(n){return function(u,l){--p,null==d&&(null!=u?(d=u,a=s=0/0,r()):(c[n]=l,--s?f||t():r()))}}function r(){null!=d?v(d):i?v(d,c):v.apply(null,[d].concat(c))}var o,f,i,c=[],a=0,p=0,s=0,d=null,v=u;return n||(n=1/0),o={defer:function(){return d||(c.push(arguments),++s,t()),o},await:function(n){return v=n,i=!1,s||r(),o},awaitAll:function(n){return v=n,i=!0,s||r(),o}}}function u(){}"undefined"==typeof module?self.queue=n:module.exports=n,n.version="1.0.4";var l=[].slice})();
(function() {
  Robin.EmberReactor = {
    _q: queue(1),
    process: function(verb, model, data) {
      if (Robin._verbs.indexOf(verb) > -1) {
        if (verb === 'batched') {
          return this._batched(model, data);
        } else {
          return this._enqueue(verb, model, data);
        }
      } else {
        return Ember.Logger.warn("unrecognized verb: " + verb);
      }
    },
    _execute: function(verb, model, data) {
      Ember.Logger.log("" + verb + " " + model + " => " + (JSON.stringify(data)));
      return this['_' + verb](model, data);
    },
    _enqueue: function(verb, model, data) {
      var _this = this;
      return this._q.defer(function(next) {
        _this._execute(verb, model, data);
        return next();
      });
    },
    _flushed: function(model, data) {
      var key, value;
      key = data.key;
      value = data.value;
      return Ember.Logger.warn("flushed not yet implemented");
    },
    _batched: function(model, batch) {
      var item, _i, _len, _results;
      if (batch == null) {
        return;
      }
      Ember.Logger.log("batched (" + batch.length + ")");
      _results = [];
      for (_i = 0, _len = batch.length; _i < _len; _i++) {
        item = batch[_i];
        _results.push(this._enqueue(item[0], model, item[1]));
      }
      return _results;
    },
    _created: function(model, data) {
      return this._storeFor(model).pushPayload(model, data);
    },
    _updated: function(model, data) {
      return this._storeFor(model).pushPayload(model, data);
    },
    _destroyed: function(model, data) {
      var record;
      record = this._storeFor(model).getById(model, data.id);
      return record != null ? record.deleteRecord() : void 0;
    },
    _storeFor: function(model) {
      var klass, name;
      name = Ember.String.classify(model);
      klass = App[name];
      return klass.store;
    }
  };

}).call(this);

(function() {
  var __slice = [].slice;

  Robin.EmberAdapter = Ember.Object.extend({
    init: function() {
      this.model = this.get('model');
      return this.subscribe();
    },
    subscribe: function() {
      var callback,
        _this = this;
      callback = function() {
        _this.socket = Robin.Ember.get('socket');
        return _this._subscribeNow();
      };
      Robin.Ember.addObserver('socket', callback);
      if (Robin.Ember.isConnected()) {
        return callback();
      }
    },
    _subscribeNow: function() {
      var channel, verb, _i, _len, _ref, _results,
        _this = this;
      channel = Ember.Inflector.inflector.pluralize(this.model);
      Ember.Logger.log("Subscribing to /" + channel + "...");
      _ref = Robin._verbs;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        verb = _ref[_i];
        _results.push((function(verb) {
          return _this.socket.subscribe("/" + channel + "/" + verb, function(data) {
            return _this._react(verb, data);
          });
        })(verb));
      }
      return _results;
    },
    _react: function(verb, data) {
      return Robin.EmberReactor.process(verb, this.model, data);
    }
  });

  Robin.EmberAdapter.reopenClass({
    subscribe: function() {
      var model, models, _i, _len, _results;
      models = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      _results = [];
      for (_i = 0, _len = models.length; _i < _len; _i++) {
        model = models[_i];
        _results.push(this.create({
          model: model
        }));
      }
      return _results;
    }
  });

}).call(this);

(function() {
  var ember;

  if (window.Ember != null) {
    ember = Ember.Object.extend({
      connect: function(socket) {
        return this.set('socket', socket);
      },
      isConnected: function() {
        return this.get('socket') != null;
      }
    });
    Robin.Ember = ember.create();
  }

}).call(this);
