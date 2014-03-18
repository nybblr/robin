muffin = require 'muffin'
path   = require 'path'
q      = require 'q'
glob   = require 'glob'
{exec, fork, spawn} = require 'child_process'

require 'coffee-script'

option '-w', '--watch',   'continue to watch the files and rebuild them when they change'
option '-c', '--commit',  'operate on the git index instead of the working tree'
option '-d', '--dist',    'compile minified versions of the platform dependent code into build/dist (build task only)'
option '-m', '--compare', 'compare to git refs (stat task only)'

pipedExec = do ->
  running = false
  pipedExec = (args..., callback) ->
    if !running
      running = true
      child = spawn('node', args, stdio: 'inherit')
      process.on 'exit', exitListener = -> child.kill()
      child.on 'close', (code) ->
        process.removeListener('exit', exitListener)
        running = false
        callback(code)

task 'build', 'compile robin.js', (options) ->
  callback = (dest) ->
    ->
      muffin.minifyScript(dest, options).then ->
        muffin.notify(dest, "File #{dest} minified.")
  callback = (->) unless options.dist

  compile = (prefix) ->
    (matches) ->
      path = matches[0]
      name = matches[1]
      dest = "#{prefix}#{name}.js"
      muffin.compileTree(path, dest, options).then(callback(dest))

  muffin.run
    files: './src/**/*'
    options: options
    map:
      'src/dist/([^/]+)\.coffee':     compile('build/')
      'src/platform/([^/]+)\.coffee': compile('build/robin.')
