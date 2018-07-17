{CompositeDisposable} = require 'atom'
_      = require('./utils')

# Utility class for dealing with configuration settings for an atom package
exports.PkgConfig = class PkgConfig extends CompositeDisposable
  _defaults  : { prefix: '', schema: {}, hash: {}, observers: [], master: atom.config }
  constructor : (opts = {} ) ->
    super()
    # Typically, you only need to pass the 'prefix' and 'schema', corresponding to Atom config keyPath prefix, and schema
    @watching = false; @arrangedWatch = false; @fetched = 0
    {@prefix, @schema, @hash, @observers, @master } = _.defaults(opts, @_defaults)
    @observers.push opts.observer if opts.observer?
    @observers.push opts.watch    if opts.watch?

  fetch       :  () ->  # Get our config settings
    for k,v of @schema
      @hash[k] = @master.get(@prefix + k)
    @fetched++
    return this

  addWatch  :  ( callback ) ->  # Register observers for changes to our settings
    @observers.push callback if callback? and not _.contains(@observers, callback)
    unless @arrangedWatch
      for k,v of @schema # register observer callbacks (closure!)
        # '@add' is inherited from 'CompositeDisposable'
        @add @master.observe @prefix + k, (val) =>  oVal = @hash[k];  @hash[k] = val; @doOnChanged(k, val, oVal, @hash)
      @arrangedWatch = true
    return this

  watch: (args...)        -> @addWatch(args...); @watching = true; return this
  startWatch: (args...)   -> @watch(args...)
  pauseWatch: (args...)   -> @watching = false;  @addWatch(args...) if args.length > 0; return this

  doOnChanged  : (key, val, oVal, hash) =>
    return this unless @watching
    for callback in @observers
      callback(key, val, oVal, hash)
    return this
