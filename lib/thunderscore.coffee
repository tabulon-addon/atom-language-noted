_ = require('underscore')

# General
_.isDefined         = isDefined         = ( val )                     -> not _.isUndefined(val)
_.castArray         = castArray         = ( val )                     -> if _.isArray(val) then val else [val]
_.resolve           = resolve           = ( it, args... )             ->
  #console.warn '\n.....resolving..... ';
  self = this
  switch
    when not it?                          then return it
    when _.isFunction(it?.bake)           then return resolve.call(self, it.bake(args...), args...)
    when _.isFunction(it)                 then return resolve.call(self, it.call(self, args... ), args...)
    when _.isRegExp(it)                   then return ( it.source )
    when _.isArray(it)                    then return ( it.map (item) => resolve.call(self, item, args...) )
    when _.isObject(it)
      #console.warn 'Object';
      res = {}
      for k,v of it
        continue if  k == 'resolve' or k == 'constructor' or k == it.constructor.name
        continue if  v == it
        res[k] = resolve.call(self, v, args...)
      return res
  return it
_.simpleValue       = simpleValue       = ( val )                     ->
  return (if _.isRegExp(val) || not _.isObject(val) then val else JSON.stringify(val) )
_.simplify          = simplify          = ( obj = {} )                -> _.mapObject(obj, simpleValue)

# Arrays
_.arrayify          = terse             = (args...)                   ->
  res = []
  for arg in args
    a   = if _.isArray(arg) then arg else [arg]
    res = res.concat a
  return res
_.terse             = terse             = (a = [])                    -> a = _.compact(a); if a.length > 0 then a else undefined

# Objects
_.def               = def               = ( sources... )              -> _.defaults {},  sources... # shorthand alias for defaulted()
_.defaulted         = defaulted         = ( sources... )              -> _.defaults {},  sources...
_.extended          = extended          = ( sources... )              -> _.extend {}, sources...
_.combine           = combine           = ( sources... )              -> _.extend {}, sources...   # synonym for extended()
_.combined          = combined          = ( sources... )              -> _.extend {}, sources...   # synonym for extended()
_.terso             = terso             = ( o )                       ->  if _.allKeys(o).length > 0 then o else undefined
_.extract           = extract           = ( sources=[], keys=[] )     ->
  # extract each value for given keys in a list of given source objects. ORDERED by: SOURCES and then KEYS.
  sources = castArray(sources)
  keys    = castArray(keys)
  result  = []
  for src in sources
    o = src ? {}
    result = result.concat _.map keys, (key) -> o?[key]
  return result
_.extract_compact   = extract_compact   = ()                          -> _.compact extract(arguments...)
_.plucks            = plucks            = ( sources=[], keys=[] )     ->
  # extract each value for given keys in a list of given source objects. ORDERED by: KEYS and then SOURCES.
  sources = castArray(sources)
  keys    = castArray(keys)
  result  = []
  for key in keys
    result = result.concat _.pluck(sources, key)
  return result
_.plucks_compact    = plucks_compact    = ()                          -> _.compact plucks(arguments...)
_.maxNumKey         = maxNumKey         = ( obj )                     -> 1 + Math.max (key for key of obj)...
_.LookupOptions     = LookupOptions     = class
  constructor: ( { @specs, @flow, @mappings, @prefs } ) ->
_.findProps         = findProps         = ( )                         -> lookups(arguments...)
_.findProp          = findProp          = ( )                         -> lookup(arguments...)
_.lookup            = lookup            = ( options, args... )        ->
  unless options instanceof LookupOptions
    opts = new LookupOptions specs: options, prefs: { findMax: 1 }
  else
    opts.prefs.findMax ?= 1

  result      = lookups(opts, args...)
  kFound      = _.keys(result)
  switch kFound.length
    when 0 then return undefined            # nothing was found.
    when 1 then return result[kFound[0]]    # directly return the single value found, disregarding the name (key) of the property.
    else                                    # troubled waters...
      throw "The 'lookup()' routine is NOT suitable for seeking multiple keys/properties. Use 'lookups()' with deconstructive assignment instead."
_.lookups           = lookups           = ( options, args... )        ->
  {specs, flow, mappings, prefs} = if options instanceof LookupOptions then options else { specs: options, prefs: {} }
  specs ?= mappings
  switch
    when _.isArray(specs)     then flow ?= specs;
    when _.isObject(specs)    then flow ?=_.keys(specs); mappings ?= specs
    when not specs?           then flow ?= []
    else
      flow ?= [specs]

  flow ?= []; result = {}; found = 0; findMax = prefs?.findMax

  for k in flow    # k: destination key;   v: source key(s) -- maybe an array or a scalar
    continue unless k?
    v = mappings?[k] ? k
    #console.warn "looking up : #{k} <- #{v}"
    src_keys = if _.isArray(v) then v else [v]
    for ks in src_keys
      for o in args
        continue unless o?
        if o?[ks] and o[ks]?
          val = result[k] = o[ks]
          ++found
          #console.warn "Bingo : #{k} <- #{ks} : #{val}.  where { found: #{found}, findMax: #{findMax} }"
          return result if findMax? and found >= findMax
          #console.warn "Breaking..."
          break
  return result
_.dittoMapping      = dittoMapping      = ()                          -> dittoMappings(arguments...)
_.dittoMappings     = dittoMappings     = ( keys, src = {} )          ->
  keys ?= _.allKeys( src )
  mappings = {}
  for k in keys
    mappings[k] = k
  return mappings
_.mapProps          = mapProps          = ( opts = {} )               ->
  o = _.defaulted  opts, {
          obj: {},
          src: undefined, dest: undefined,
          mappings: undefined, props: undefined,
          disregard: { 'empty': true, 'undefined': true }
          reject: (val) -> _.isUndefined(val)
          transform: (val) -> val   # By default, no transformation is done (so it's an 'identity transformation')
        }

  { src, dest, transform, reject_src, reject_dest } = _.defaults o, {
    src: o.obj, dest: o.obj, reject_src: o.reject, reject_dest: o.reject
  }

  unless o?.mappings?
    throw "Can't guess key mappings when source and destination refer to the same object" if src == dest
    o.mappings = dittoMappings(o?.props, src)

  mappings = o?.mappings ? {}
  keyz = _.allKeys(mappings)
  _.dump data: { o: o, keyz: keyz } if (o?.dump ? false)

  for kd in keyz        # kd  : destination key
    ks = mappings[kd]   # ks  : source key
    delete dest[kd]
    vs  = src?[ks]          # vs: source value
    continue if reject_src(vs, ks, src, 'src')
    v   = transform(vs)     # v: destination value (transformed)
    continue if reject_dest(v, kd, dest, 'dest')
    dest[kd] = v

  _.dump data: { dest: dest } if (o?.dump ? false)
  return dest

# Strings
_.easyArray         = easyArray         =  (str) -> str.split(/(?:[\,]|\s)+/)
_.surround          = surround          = ( opts = {} )    ->    # o = options
  o                = _.defaulted  opts, { ignoreBlank: true, content: '', n: 0, with: '', prefix: '', suffix: '' }
  # by default, surround with nothing.
  return ''         if o.ignoreBlank and ( _.isUndefined(o.content) || _.isNull(o.content) || _.isEmpty(o.content) )
  return o.content  unless (n ? 0) > 0
  o.opener        ?= o.with
  o.closer        ?= o.with

  o.open          ?= o.opener.repeat(o.n)
  o.close         ?= o.closer.repeat(o.n)

  return "#{o.prefix}#{o.open}" + o.content + "#{o.close}#{o.suffix}"     #  explicit concatination for o.content, just in case it's a RegExp or something.

# RegExp
_.rex_escape_cc_char = rex_escape_cc_char = ( c )                       ->
  return (if contains [']', '-', '^', ',', '\\'], c then "\\" + c else c)
_.rex_surround       = rex_surround       = ( args... )                 -> RegExp surround(args...)
_.rex_group          = rex_group          = ( opts = {} )               -> rex_surround _.defaults( {}, opts, { opener: '()', closer: ')' } )
_.rex_cook_quote     = rex_cook_quote     = ( opts = {} )               -> #  -#<NOT yet tested!>
  o                = _.defaulted  opts, { marker: {}, start:{}, end: {}, content: {} }
  o.marker         = _.defaults o.marker, { char: "'", capture: 0 }  # By default, it's a single quote
  o.start          = _.defaults o.start,  o.marker

  for k in ['start', 'end']
    o[k]            = _.defaults o[k],    o.marker
    c = o[k].c     ?= rex_escape_cc_char o[k].char
    o[k].regex     ?= rex_group n: o[k].capture, content: ///[#{c}]///

  o.content        = _.defaults o.content, { capture: 1 }
  c                = rex_escape_cc_char( o.end.char )
  o.content.regex ?= rex_group n: o.content.capture, content: ///(?:[^#{c}\\]|[\\].)*///
  regex            = ///#{o.start.regex}#{o.content.regex}#{o.end.regex}///
  return regex
_.rex_escapeString   = rex_escapeString   = (str)                       ->
  # escape string for use in javascript regex
  # See <http://stackoverflow.com/questions/3446170/escape-string-for-use-in-javascript-regex>
  # Note that :   $& (in the replacer) means 'Insert the matched substring'
  str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")
_.rex_build          = rex_build          = ( o, opts = {} )            ->
  o = resolve(o, opts)
  switch
    when not o?           then return
    when  _.isRegExp(o)   then return o
    when  _.isString(o)   then return new RegExp rex_escapeString(o)
    when  _.isArray(o)    then return new RegExp o.map( item => rex_escapeString(item) ).join('|')
    when  _.isObject(o)
      base = _.lookup ['rex_base', 'base', 'rex_inner', 'inner', 'rex_cc', 'cc'], o
      if base?    # for the moment, we only buikd from a base regex
        base = base.source if _.isRegExp(base)
        quantifier = o?.quantifier ?  ''
        quantifier = '{' + quantifier + ',' + quantifier + '}' if _.isFinite(quantifier)
        quantifier = quantifier.source if _.isRegExp(quantifier)
        return new RegExp(base + quantifier)

  throw "Don't know how to build a RegExp with the given thingy"

# Console
_.dump              = dump              = ( opts = {} )               ->
  opts._indent    ?= 2
  opts._transform ?= (k, v) -> return (if _.isRegExp(v) then '/' + v.source + '/' else v)

  o = opts
  data  = _.omit opts, ['_indent', '_transform', '_msg', '_skip']
  data  = data?.data if data?.data? and _.keys(data).length == 1
  msg   = o?._msg ? 'Here we go... '
  output_data = false
  switch
    when _.isString(data)                      then  msg  += ': ' + data;
    when _.isObject(data) and !_.isEmpty(data) then  msg  += ' DUMP: '; output_data = true

  console.warn msg if msg
  console.warn JSON.stringify(data, opts._transform, opts._indent)  if output_data

_.writeOut          = writeOut          = ( opts = {} )               ->
  { data, format, path } = opts
  format ?= if path.match /\.cson$/ then 'CSON' else 'JSON'
  text    = undefined

  switch format
    when 'CSON' then CSON = require "season"; text = CSON.stringify(data)
    else
      text = JSON.stringify(data, null, "    ")

  switch
    when path? then fs = require "fs"; fs.writeFileSync path, text
    else
      process.stdout.write text

  return data

_.Bakeable  = class Bakeable
  constructor:   ()   ->
  bakingIngredients:   ()       ->
    # By default, we exclude properties that are functions (to avoid accidental side-effects), but they too can be included.
    res = _.allKeys(this)
    _.compact res.map (item) -> if _.isFunction(item) then undefined else item       # Typically overridden
  bakingDependencies:  ()       -> {}            # Typically overridden
  bakingParams:    (args...)    -> args          # Optionally overridden
  bakers:     ( key )           -> [key]         # Optionally overridden
  baker:      ( key )           ->               # Rarely overridden
    return unless key?
    return unless bakers = @bakers(key)
    bakers = [bakers] unless _.isArray(bakers)
    bakers = _.compact bakers
    for r in bakers
      #_.dump _msg: "   checking baker : #{r}"
      return r if _.isFunction(r) or _.isObject(r)
      res = this?[r]
      return res if res?
    return
  bake:       ()   ->
    # DEBUG
    # name_lc = @name_lc?();  _.dump _msg: "Resolving BEGINS for '#{name_lc}' ..."
    params = @bakingParams(arguments...)
    ingredients =  @bakingIngredients() ? []
    deps = @bakingDependencies() ? {}
    self = this
    res = {}; done={}
    for pass in [0 .. 2]
      for i in ingredients
        continue unless i?
        continue if done?[i]                   # Don't bother recomputing a value we already have
        preqs = deps?[i]
        continue if pass >  0 and !preqs?      # non-dependants are processed ONLY during pass 0
        continue if pass == 0 and  preqs?     #     dependants are processed ONLY after  pass 0
        continue if preqs and not _.every _.arrayify(preqs), (preq) => res?[preq]?

        #_.dump _msg: "Baking ingredient : #{i} ..."

        item = if @?.baker? then @baker(i) else @?[i]
        continue unless item?
        v = _.resolve.call(self, item, params...)
        res[i]  = v unless _.isUndefined(v)

        done[i] = true

    # DEBUG
    # name_lc = @name_lc?();  _.dump _msg: "Just resolved '#{name_lc}' : ", data:res  if ( name_lc == 'noted' )

    return unless _.keys(res).length > 0
    return res
  bakeOut:    ()   ->
    data = @bake(arguments...)
    _.writeOut _.defaults( {}, {data}, arguments...)


module.exports = _
