_ = require('underscore')

# Start out by re-exporting our helper's stuff.   This helps encapsulate things.
module.exports = exports = Object.assign(_)

# General
exports.isDefined     = isDefined     = ( val )                     -> not _.isUndefined(val)
exports.resolve       = resolve       = ( it, args... )             ->
  #console.warn '\n.....resolving..... ';
  #_.dump data:it
  self = this
  switch
    when _.isUndefined(it) then return it
    when res=it?.resolve?(args...)
      #console.warn 'Resolvable class';
      return resolve.call(self, res, args...)
      #return resolve.call(self, it.resolve(args...), args...)
    when _.isFunction(it)
      #console.warn 'Function';
      #return it.call(self, args... )
      resolve.call(self, it.call(self, args... ), args...)
    when _.isRegExp(it)
      #console.warn 'RegExp';
      return ( it.source )
    when _.isArray(it)
      #console.warn 'Array';
      return ( it.map (item) -> resolve.call(self, item, args...) )
      # a = []
      # for item in it
      #   a = a.concat resolve.call(self, item, args...)
      # return a
    when _.isObject(it)
      #console.warn 'Object';
      res = {}
      #res = _.create(it.constructor.prototype)
      #res = _.create(it.prototype)
      for k,v of it
        continue if  k == 'resolve' or k == 'constructor' or k == it.constructor.name
        continue if  v == it
        #console.warn "\n..key: #{k}"
        res[k] = resolve.call(it, v, args...)
      return res
    else
      #console.warn 'Other';
      return it

exports.simpleValue   = simpleValue   = ( val )                     ->
  return (if _.isRegExp(val) || not _.isObject(val) then val else JSON.stringify(val) )
exports.simplify      = simplify      = ( obj = {} )                -> _.mapObject(obj, simpleValue)

# Arrays
exports.arrayify      = terse          = (args...)                   ->
  res = []
  for arg in args
    a   = if _.isArray(arg) then arg else [arg]
    res = res.concat a
  return res
exports.terse         = terse          = (a = [])                    -> a = _.compact(a); if a.length > 0 then a else undefined

# Objects
exports.def           = def            = ( sources... )              -> _.defaults {},  sources... # shorthand alias for defaulted()
exports.defaulted     = defaulted      = ( sources... )              -> _.defaults {},  sources...

exports.extended      = extended       = ( sources... )              -> _.extend {}, sources...
exports.combine       = combine        = ( sources... )              -> _.extend {}, sources...   # synonym for extended()
exports.combined      = combined       = ( sources... )              -> _.extend {}, sources...   # synonym for extended()

exports.maxNumKey     = maxNumKey     = ( obj )                     -> 1 + Math.max (key for key of obj)...
exports.LookupOptions = LookupOptions = class
  constructor: ( { @specs, @flow, @mappings, @prefs } ) ->

exports.findProps     = findProps     = ( )                         -> lookups(arguments...)
exports.findProp      = findProp      = ( )                         -> lookup(arguments...)
exports.lookup        = lookup        = ( options, args... )   ->
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

exports.lookups       = lookups       = ( options, args... )       ->
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
    console.warn "looking up : #{k} <- #{v}"
    src_keys = if _.isArray(v) then v else [v]
    for ks in src_keys
      for o in args
        continue unless o?
        if o?[ks] and o[ks]?
          val = result[k] = o[ks]
          ++found
          console.warn "Bingo : #{k} <- #{ks} : #{val}.  where { found: #{found}, findMax: #{findMax} }"
          return result if findMax? and found >= findMax
          console.warn "Breaking..."
          break
  return result

exports.dittoMapping  = dittoMapping  = ()                          -> dittoMappings(arguments...)
exports.dittoMappings = dittoMappings = ( keys, src = {} )          ->
  keys ?= _.allKeys( src )
  mappings = {}
  for k in keys
    mappings[k] = k
  return mappings
exports.mapProps      = mapProps      = ( opts = {} )               ->
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
exports.easyArray = easyArray  =  (str) -> str.split(/(?:[\,]|\s)+/)
exports.surround   = surround       = ( opts = {} )    ->    # o = options
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
exports.re_escape_cc_char = re_escape_cc_char = ( c )            ->
  return (if contains [']', '-', '^', ',', '\\'], c then "\\" + c else c)
exports.re_surround         = re_surround     = ( args... )         -> RegExp surround(args...)
exports.re_group            = re_group        = ( opts = {} )       ->
  re_surround _.defaults( {}, opts, { opener: '()', closer: ')' } )
exports.re_cook_quote       = re_cook_quote   = ( opts = {} )       ->    # o = options. -#<NOT yet tested!>
  o                = _.defaulted  opts, { marker: {}, start:{}, end: {}, content: {} }
  o.marker         = _.defaults o.marker, { char: "'", capture: 0 }  # By default, it's a single quote
  o.start          = _.defaults o.start,  o.marker

  for k in ['start', 'end']
    o[k]            = _.defaults o[k],    o.marker
    c = o[k].c     ?= re_escape_cc_char o[k].char
    o[k].regex     ?= re_group n: o[k].capture, content: ///[#{c}]///

  o.content        = _.defaults o.content, { capture: 1 }
  c                = re_escape_cc_char( o.end.char )
  o.content.regex ?= re_group n: o.content.capture, content: ///(?:[^#{c}\\]|[\\].)*///
  regex            = ///#{o.start.regex}#{o.content.regex}#{o.end.regex}///
  return regex
exports.re_escapeString     = re_escapeString = (str) ->
  # escape string for use in javascript regex
  # See <http://stackoverflow.com/questions/3446170/escape-string-for-use-in-javascript-regex>
  # Note that :   $& (in the replacer) means 'Insert the matched substring'
  str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")

exports.re_build = buildRegExp = ( o, opts = {} ) ->
  o = resolve(o, opts)
  switch
    when not o?           then return
    when  _.isRegExp(o)   then return o
    when  _.isString(o)   then return new RegExp re_escapeString(o)
    when  _.isArray(o)    then return new RegExp o.map( item => re_escapeString(item) ).join('|')
    when  _.isObject(o)
      base = _.lookup ['re_base', 'base', 're_inner', 'inner', 're_cc', 'cc'], o
      if base?    # for the moment, we only buikd from a base regex
        base = base.source if _.isRegExp(base)
        quantifier = o?.quantifier ?  ''
        quantifier = '{' + quantifier + ',' + quantifier + '}' if _.isFinite(quantifier)
        quantifier = quantifier.source if _.isRegExp(quantifier)
        return new RegExp(base + quantifier)

  throw "Don't know how to build a RegExp with the given thingy"


# Console
exports.dump                = dump            = ( opts = {} ) ->
  opts._indent    ?= 2
  opts._transform ?= (k, v) -> return (if _.isRegExp(v) then '/' + v.source + '/' else v)

  o = _.extend(opts, opts?.data)
  data = _.omit o, ['_indent', '_transform', '_msg', '_skip', 'data']
  msg  = o?._msg ? 'Here we go... '
  msg += ' DUMP: ' if _.keys(data).length > 0
  console.warn msg if msg
  console.warn JSON.stringify(data, opts._transform, opts._indent) if _.keys(data).length > 0

exports.writeOut      = writeOut     = ( opts = {} )    ->
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
