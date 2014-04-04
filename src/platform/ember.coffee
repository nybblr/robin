#= require ../robin
#= require ./ember/reactor
#= require ./ember/adapter

if window.Ember?
  ember = Ember.Object.extend
    connect: (socket) ->
      @set 'socket', socket
    isConnected: ->
      @get('socket')?

  Robin.Ember = ember.create()
