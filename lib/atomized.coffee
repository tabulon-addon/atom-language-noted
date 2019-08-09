{CompositeDisposable} = require 'atom'
_      = require('./thunderscore')

# Utility class for dealing with configuration settings for an atom package
exports.PkgConfig = class PkgConfig extends CompositeDisposable
  _initial:           {fetched: 0, watching: false, tunedIn: false}
  defs:         () -> {stash: {}, backend: atom.config}

  tips:         () -> {
    onDidChange: {provokes: ['onRefreshed']}
    onFetched:   {provokes: ['onRefreshed']}
    onRefreshed: {}
    observe:     {}
  }

  constructor : (opts = {} ) ->
    super()
    {@fetched, @watching, @tunedIn}                = @_initial   # Props that reflect internal state. They will be ignored if passed to the constructor.
    {@pkgName, @prefix, @schema, @config, @stash, @backend} = o = _.defaulted opts, @defs() # The only opts really needed are: 'schema' and 'prefix' (or 'pkgName')

    @schema ?= @config  # synonym
    @prefix ?= if @pkgName? then @pkgName + '.' else ''

    @addWatch(o.watch) if o?.watch?

  fetch:              () ->  # Get our config settings
    # for k,v of @schema
    #   @stash[k] = @backend.get(@prefix + k)
    @refetch()
    @fetched++
    # _.dump _msg: 'Just fetched config', prefix: @prefix, schema: @schema, stash: @stash
    @notice('onFetched')
    return this

  refetch: ( args...) -> # lower level routine; capable of selective fetches; does NOT fire any event.
    keyz = if args? and args.length > 0 then args else _.keys(@schema)
    for k in keyz
      @stash[k] = @backend.get(@prefix + k)
    return this

  watch:              (args...)   -> @addWatch(args...); @watching = true; return this
  startWatch:         (args...)   -> @watch(args...)
  pauseWatch:         (args...)   -> @watching = false;  @addWatch(args...) if args.length > 0; return this

  addWatch:           (o = {})    ->  # use this to get notified of various events
    for k, f of o     # k: event category (i.e. observe, onDidChange, onFetched), f: function to be calledback
      @watches ?= {}
      a = @watches[k] ?= []
      a.push f if f? and not _.contains(a, f)

    @_tuneIn()

  removeWatch:        ( o = {} ) ->
    return this unless _.isObject(@watches)

    for category, f of o    # f is a reference to a callback function that was previously registered via 'addWatch'.
      categories = if category == '*' then _.keys(@watches) else [category]
      for k in categories
        continue unless @watches?[k]? and _.isArray(@watches[k])
        @watches[k] = _.without(@watches[k], f)

    return this

  notice:             (args...)               -> @takeNotice(args...)
  takeNotice:         (event, key, val, oVal)  =>
    @refetch(key) if event == 'onDidChange'
    @recompute()  if event == 'onRefreshed'

    if @watching
      for callback in ( @watches?[event] ? [] )
        callback(key, val, oVal, @stash, event)

    tips = @tips() ? {}
    for domino in ( tips?[event]?.provokes ? [] )
      @notice(domino)

    return this

  recompute:          ( h = @stash ) -> h  # Feel free to override this for recomputing calculated settings. Must return the -eventually updated- stash. It does nothing by default.
  _tuneIn:            () ->  # Register event handlers for changes to our settings
    unless @tunedIn
      for k, v of @schema   # register observer callbacks (closure!)
        # '@add' is inherited from 'CompositeDisposable'
        @add @backend.onDidChange @prefix + k, (val) =>  oVal = @stash[k];  @stash[k] = val; @takeNotice('onDidChange', k, val, oVal)
        @add @backend.observe     @prefix + k, (val) =>  oVal = @stash[k];  @stash[k] = val; @takeNotice('observe',     k, val, oVal)
      @tunedIn = true
    return this


exports.grammatics =
  tmgUpdate:     ( g = {}, args... )  ->
    @tmgRetire   g, args...
    @tmgRegister(g, args...) #unless g?.disabled ? false
  tmgRegister:   ( args... )          -> atom?.grammars?.addGrammar @tmgCreate( args...)
  tmgCreate:     ( g = {}, args... )  ->
    filename =  g?.filename ? arguments?.caller?.__filename ? __filename
    g  = _.resolve(g, args...)
    #g = g.bake(args...) if g?.bake?
    atom?.grammars?.createGrammar filename, g
  tmgRetire:     ( g = {}, args... )  -> atom?.grammars?.removeGrammarForScopeName g.scopeName  if g?.scopeName?
