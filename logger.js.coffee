# Simple logging interface
# Usage: App.current.logger.log("")
class Logger
  logLevel: 'debug'
  environment: 'development'

  debug: (msg) ->
    @log('debug',msg) if _(['debug']).include(@logLevel)

  warn: (msg) ->
    @log('warn',msg) if _(['debug','warn']).include(@logLevel)

  error: (msg) ->
    if _(['debug','warn','error']).include(@logLevel)
      @log('error',msg)

  log: (level, msg) ->
    console?.log(level + ': ' + msg)

@Logger = Logger
