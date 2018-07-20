_ = require('underscore')

# Start out by re-exporting our helper's stuff.   This helps encapsulate things.
module.exports = exports = Object.assign(_)

# General
exports.resolve       = resolve       = ( it, args... )         ->
  switch
    when _.isFunction(it) then return resolve( it( args... ), args...)
    when _.isRegExp(it)   then return ( it.source )
    when _.isArray(it)    then return ( it.map (item) -> resolve(item, args...) )
    when _.isObject(it)
      res = {}
      res[k] = resolve(v, args...) for k,v of it
      return res

    else return it
exports.simpleValue   = simpleValue   = ( val )                     -> return (if _.isRegExp(val) || not _.isObject(val) then val else JSON.stringify(val) )
exports.simplify      = simplify      = ( obj = {} )                -> _.mapObject(obj, simpleValue)

# Objects
exports.combine       = combine       = ( sources... )              -> _.extend({}, sources...)
exports.stash         = stash         = ( defaultz = {}, args... )  -> _.extend({}, defaultz, args...)
exports.maxNumKey     = maxNumKey     = ( obj )                     -> 1 + Math.max (key for key of obj)...
exports.dittoMappings = dittoMappings = ( keys, src = {} )          ->
  keys ?= _.allKeys( src )
  mappings = {}
  for k in keys
    mappings[k] = k
  return mappings

exports.mapProps      = mapProps      = ( opts = {} )               ->
  o = _.defaults {}, opts,  {
                              obj: {},
                              src: undefined, dest: undefined,
                              mappings: undefined, props: undefined,
                              disregard: { 'empty': true, 'undefined': true }
                              reject: (val) -> _.isUndefined(val)
                              transform: (val) -> val   # By default, no transformation is done (so it's an 'identity transformation')
                            }
  # src  = o.src    ?=   ( o.obj ? {} )
  # dest = o.dest   ?=   ( o.obj ? {} )

  { src, dest, transform, reject_src, reject_dest } = _.defaults o, {
    src: o.obj, dest: o.obj, reject_src: o.reject, reject_dest: o.reject
  }

  unless o?.mappings?
    throw "Can't guess key mappings when source and destination refer to the same object" if src == dest
    o.mappings = dittoMappings(o?.props, src)
    # props = o?.props ? _.allKeys( src ? {} )
    # o.mappings = {}
    # for k in props
    #   o.mappings[k] = k

  mappings = o?.mappings ? {}
  keyz = _.allKeys(mappings)
  _.dump data: { o: o, keyz: keyz } if (o?.dump ? false)

  for kd in keyz        # kd  : destination key
    ks = mappings[kd]   # ks  : source key
    delete dest[kd]
    vs  = src?[ks]          # vs: source value
    continue if reject_src(vs, ks, src, 'src')
#    continue if  _.isUndefined(vs) and (disregard?['undefined'] ? true)
    #continue if  _.isEmpty(vs)     and (disregard?['empty']     ? true)
    v   = transform(vs)     # v: destination value (transformed)
#    continue if  _.isUndefined(v) and (disregard?['undefined'] ? true)
    continue if reject_dest(v, kd, dest, 'dest')
    #continue if  _.isEmpty(v)     and (disregard?['empty']     ? true)
    dest[kd] = v

  _.dump data: { dest: dest } if (o?.dump ? false)
  return dest

# Strings
exports.surround      = surround       = ( opts = {} )    ->    # o = options
  o                = _.defaults {}, opts, { ignoreBlank: true, content: '', n: 0, with: '', prefix: '', suffix: '' }
  # by default, surround with nothing.
  return ''         if o.ignoreBlank and ( _.isUndefined(o.content) || _.isNull(o.content) || _.isEmpty(o.content) )
  return o.content  unless (n ? 0) > 0
  o.opener        ?= o.with
  o.closer        ?= o.with

  o.open          ?= o.opener.repeat(o.n)
  o.close         ?= o.closer.repeat(o.n)

  return "#{o.prefix}#{o.open}" + o.content + "#{o.close}#{o.suffix}"     #  explicit concatination for o.content, just in case it's a RegExp or something.





# RegExp
exports.re_escape_cc_char   = re_escape_cc_char  = ( c )            -> return (if contains [']', '-', '^', ',', '\\'], c then "\\" + c else c)
exports.re_surround         = re_surround     = ( args... )         -> RegExp surround(args...)
exports.re_group            = re_group        = ( opts = {} )       -> re_surround _.defaults( {}, opts, { opener: '()', closer: ')' } )
exports.re_cook_quote       = re_cook_quote   = ( opts = {} )          ->    # o = options. -#<NOT yet tested!>
  o                = _.defaults {}, opts, { marker: {}, start:{}, end: {}, content: {} }
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

# Console
exports.dump                = dump            = ( o = {} ) ->
  o.indent    ?= 2
  o.transform ?= (k, v) -> return (if _.isRegExp(v) then '/' + v.source + '/' else v)
  console.warn JSON.stringify(o.data, o.transform, o.indent)
