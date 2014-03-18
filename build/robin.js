(function(){function n(n){function t(){for(;f=a<c.length&&n>p;){var u=a++,t=c[u],r=l.call(t,1);r.push(e(u)),++p,t[0].apply(null,r)}}function e(n){return function(u,l){--p,null==d&&(null!=u?(d=u,a=s=0/0,r()):(c[n]=l,--s?f||t():r()))}}function r(){null!=d?v(d):i?v(d,c):v.apply(null,[d].concat(c))}var o,f,i,c=[],a=0,p=0,s=0,d=null,v=u;return n||(n=1/0),o={defer:function(){return d||(c.push(arguments),++s,t()),o},await:function(n){return v=n,i=!1,s||r(),o},awaitAll:function(n){return v=n,i=!0,s||r(),o}}}function u(){}"undefined"==typeof module?self.queue=n:module.exports=n,n.version="1.0.4";var l=[].slice})();
(function() {
  window.Robin || (window.Robin = {});

  Robin.Reactor = {
    _q: queue(1),
    _verbs: ["updated", "created", "destroyed", "flushed", "batched"],
    process: function(verb, model, data) {
      if (this._verbs.indexOf(verb) > -1) {
        if (verb === 'batched') {
          return this._batched(model, data);
        } else {
          return this._enqueue(verb, model, data);
        }
      } else {
        return Batman.developer.warn("unrecognized verb: " + verb);
      }
    },
    _execute: function(verb, model, data) {
      Batman.developer.log("" + verb + " " + model.name + " => " + (JSON.stringify(data)));
      return this['_' + verb](model, data);
    },
    _enqueue: function(verb, model, data) {
      var _this = this;
      return this._q.defer(function(next) {
        _this._execute(verb, model, data);
        return next();
      });
    },
    _removeRecord: function(model, record) {
      model.get('loaded').remove(record);
      return record.get('lifecycle').destroyed();
    },
    _initOrUpdateRecord: function(model, data) {
      return model._makeOrFindRecordFromData(data);
    },
    _findRecord: function(model, data) {
      return model._loadIdentity(data['id']);
    },
    _flushed: function(model, data) {
      var key, options, record, recordsToRemove, value, _i, _len;
      key = data.key;
      value = data.value;
      recordsToRemove = model.get('loaded').indexedBy(key).get(value).toArray();
      for (_i = 0, _len = recordsToRemove.length; _i < _len; _i++) {
        record = recordsToRemove[_i];
        this._removeRecord(model, record);
      }
      if (key === model.get('primaryKey')) {
        return model.find(value, function() {});
      } else {
        options = {};
        options["" + key] = value;
        return model.load(options);
      }
    },
    _batched: function(model, batch) {
      var item, _i, _len, _results;
      if (batch == null) {
        return;
      }
      Batman.developer.log("batched (" + batch.length + ")");
      _results = [];
      for (_i = 0, _len = batch.length; _i < _len; _i++) {
        item = batch[_i];
        _results.push(this._enqueue(item[0], model, item[1]));
      }
      return _results;
    },
    _created: function(model, data) {
      return this._initOrUpdateRecord(model, data);
    },
    _updated: function(model, data) {
      var record;
      record = this._findRecord(model, data);
      if (record != null) {
        return this._initOrUpdateRecord(model, data);
      }
    },
    _destroyed: function(model, data) {
      var record;
      record = this._findRecord(model, data);
      if (record != null) {
        return this._removeRecord(model, record);
      }
    }
  };

}).call(this);

(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Robin || (window.Robin = {});

  Robin.AdapterMethods = {
    subscribe: function() {
      var _this = this;
      return Robin.observeAndFire('socket', function(newVal, oldVal) {
        if (newVal != null) {
          _this.socket = newVal;
          return _this._subscribeNow();
        }
      });
    },
    _subscribeNow: function() {
      var channel, verb, _i, _len, _ref, _results,
        _this = this;
      channel = this.model.storageKey;
      Batman.developer.log("Subscribing to /" + channel + "...");
      _ref = Robin.Reactor._verbs;
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
      return Robin.Reactor.process(verb, this.model, data);
    }
  };

  Robin.Adapter = (function(_super) {
    __extends(Adapter, _super);

    Adapter.mixin(Robin.AdapterMethods);

    function Adapter(model) {
      Adapter.__super__.constructor.call(this, model);
      this.subscribe();
    }

    return Adapter;

  })(Batman.RailsStorage);

}).call(this);

(function() {
  var _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  this.Robin = (function(_super) {
    __extends(Robin, _super);

    function Robin() {
      _ref = Robin.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Robin.connect = function(socket) {
      this.set('socket', socket);
      return this.fire('socket:ready');
    };

    return Robin;

  })(Batman.Object);

  window.Robin = Robin;

}).call(this);
