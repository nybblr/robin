#= require_self
#= require ./batman/reactor
#= require ./batman/adapter

# Push-persistence backed by Faye.
class @Robin extends Batman.Object
  @connect: (socket) ->
    @set 'socket', socket
    @fire('socket:ready')

window.Robin = Robin
