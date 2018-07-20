{CompositeDisposable} = require 'atom'
_      = require('./utils')

# Utility class for dealing with configuration settings for an atom package
exports.PkgConfig = class PkgConfig extends CompositeDisposable
  _defaults   : { prefix: '', schema: {}, stash: {}, master: atom.config }
  _initial    : { fetched: 0, watching: false, tunedIn: false}
  tips        : () -> {
    onDidChange: { provokes: ['onRefreshed'] }
    onFetched:   { provokes: ['onRefreshed'] }
    onRefreshed: { }
    observe:     { }
  }

  constructor : (opts = {} ) ->
    super()
    # Typically, you only need to pass the 'prefix' and 'schema', corresponding to Atom config keyPath prefix, and schema
    { @prefix, @schema, @stash, @master }       = o = _.defaults( {}, opts, @_defaults)
    { @fetched, @watching, @tunedIn}            = @_initial   # Props that reflect internal state. They will be ignored if passed to the constructor.

    @addWatch(o.watch) if o?.watch?


  fetch:              () ->  # Get our config settings
    # for k,v of @schema
    #   @stash[k] = @master.get(@prefix + k)
    @refetch()
    @fetched++
    # _.dump data:{ _msg: 'Just fetched config', prefix: @prefix, schema: @schema, stash: @stash }
    @notice('onFetched')
    return this

  refetch: ( args...) -> # lower level routine; capable of selective fetches; does NOT fire any event.
    keyz = if args? and args.length > 0 then args else _.keys(@schema)
    for k in keyz
      @stash[k] = @master.get(@prefix + k)
    return this

  watch:              (args...)   -> @addWatch(args...); @watching = true; return this
  startWatch:         (args...)   -> @watch(args...)
  pauseWatch:         (args...)   -> @watching = false;  @addWatch(args...) if args.length > 0; return this

  addWatch:           ( o = {} ) ->  # use this to get notified of various events
    for k,f of o      # k: event category (i.e. observe, onDidChange, onFetched), f: function to be calledback
      @watches ?= {}
      a = @watches[k] ?= []
      a.push f if f? and not _.contains(a, f)

    @_tuneIn()

  removeWatch:        ( o = {} ) ->
    return this unless _.isObject(@watches)

    for category,f of o    # f is a reference to a callback function that was previously registered via 'addWatch'.
      categories = if category == '*' then _.keys(@watches) else [category]
      for k in categories
        continue unless @watches?[k]? and _.isArray(@watches[k])
        @watches[k] = _.without(@watches[k], f)

    return this

  notice:             (args...)               -> @takeNotice(args...)
  takeNotice:         (event, key, val, oVal)  =>
    @refetch(key) if event == 'onDidChange'

    if @watching
      for callback in ( @watches?[event] ? [] )
        callback(key, val, oVal, @stash, event)

    tips = @tips() ? {}
    for domino in ( tips?[event]?.provokes ? [] )
      @notice(domino)

    return this


  _tuneIn:            () ->  # Register event handlers for changes to our settings
    unless @tunedIn
      for k,v of @schema # register observer callbacks (closure!)
          # '@add' is inherited from 'CompositeDisposable'
          @add @master.onDidChange @prefix + k, (val) =>  oVal = @stash[k];  @stash[k] = val; @takeNotice('onDidChange', k, val, oVal)
          @add @master.observe     @prefix + k, (val) =>  oVal = @stash[k];  @stash[k] = val; @takeNotice('observe',     k, val, oVal)
      @tunedIn = true
    return this
